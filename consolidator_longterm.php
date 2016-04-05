<?php
//This is a script to read in all the items from the Hourly database and cnosolidate them by item,  I'ts complicated!
include 'timezone.php';
include 'login_info.php';

//truncate the table so we start off with a new slate - this can be turned off for testing
$query = "TRUNCATE TABLE Consolidated;";
mysql_query($query);

//In this casewe only want the info for the last 25 hours
$startDate = date('Y-m-d H:i:s', strtotime("-48 hours"));
//echo $startDate . "<BR><BR>"; 

//Get terms for this timeframe from hourly.  
$query="SELECT DISTINCT Hourly.term 
FROM Hourly 
WHERE Hourly.date > '$startDate' 
ORDER BY length(Hourly.term) DESC;";  

$result = mysql_query($query); //storing the result of $query in $result

//Ready?  Let's go through each row and do stuff to it
while($row = mysql_fetch_row($result))   	 {
    $term = $row[0];
	echo "<BR>" . $term . "<BR>";
	
	//now call a function to check if this term matches anything
	$match = "test";  //just so its set to something
	$match = matchMe($term);
	 
	//There's a match? Add all rows with $term, in that timeframe, to the consolidated table
	if ($match == "no match") { addMe($term, $startDate); }
	//Or, combine terms and matching terms in consolidated table in that timeframe
	else {combineMe($match, $term, $startDate);}//end else
}//end while

//now insert all of the source information!
//echo "<BR><BR><BR>ABOUT TO ADD SOURCE INFO<BR><BR><BR>";
//addSource();

//closing the conection
mysql_close($conn);

echo "<BR><BR>DONE";

//this is where to drop in matcher!
include 'matcher.php';

//////////////////////////////////////////////////////
///////////////////FUNCTIONS//////////////////////////
//////////////////////////////////////////////////////


//A function to see if there is a match
function matchMe($myList) {

	$hourlyPieces = explode(" ", $myList);//put the search term into an array

	//pull all existing linked terms in consolidate as $consolidated
	$query="SELECT DISTINCT Consolidated.all_terms 
	FROM Consolidated;";  //what I really want is to order by the length of Hourly Term
	$consolidated = mysql_query($query); //storing the result of $query in $result
	
	//itterate through consolidated with each item as consolidatedTerm
	while($row = mysql_fetch_row($consolidated))   {	
		
    	$consolidatedTerm = $row[0]; 	//get the particular item at each cell of the row
		$consolidatedPieces = explode(" ", $consolidatedTerm); //explode as an array 
		
		//itterate through hourlyPieces and consolidatedPieices against each other
		foreach ($consolidatedPieces as $consolidatedValue) {
    		foreach ($hourlyPieces as $hourlyValue) {
				//compare them. 
				if ($consolidatedValue == $hourlyValue) {return $consolidatedTerm;}
			}//end foreach2
		}//end foreach1
	}//end while
	
 return "no match"; //we'll only get here if nothing matches
}//end matchMe



//a function that adds combined information to the new table
function combineMe($match, $term, $startDate){

	echo  "MATCHES: " . $match . "<BR>";
	
	//calculate the new all_terms by combining term and match
	$all_terms = stripMe($term);
	
	$newMatch = "temp";
	$newMatch = $match . " - " . $all_terms;
	
	//get the new term name for items with all_terms = match in consolidated
	$query="SELECT Consolidated.term 
	FROM Consolidated 
	WHERE Consolidated.all_terms = '$match';";  //what I really want is to order by the length of Hourly Term
	$result = mysql_query($query); //storing the result of $query in $result

	$newTerm = "temp";
	//go through each row 
	while($row = mysql_fetch_row($result))  { 	 //iterate through the rows of $result
		$newTerm = $row[0]; //get the term name for the new rows in Consolidated (the same as the old)
	}
	//echo "And theyll all go under name: " . $newTerm . "<BR>";
	
	//alright, let's do this. first, enter all terms that match something in consolidated, adding the totals
	$query="UPDATE Consolidated, Hourly 
	SET Consolidated.score = Hourly.score+Consolidated.score, 
		Consolidated.term_history = CONCAT(Consolidated.term_history, ' - ', Hourly.term, ' = ', Hourly.score)  
	WHERE ((Hourly.date = Consolidated.date) 
	AND (Hourly.term = '$term') 
	AND (Consolidated.term = '$newTerm'));";  
	mysql_query($query); 
	
	//Add all terms with name Term in Hourly that don't have a matching date with name Match in Consolidated
	$query = "INSERT INTO Consolidated
	(Consolidated.term, Consolidated.date, Consolidated.score, Consolidated.term_history)
	SELECT '$newTerm', Hourly.date, Hourly.score, CONCAT (Hourly.term, ' = ', Hourly.score)   
	FROM Hourly
	WHERE Hourly.term = '$term' 
	AND Hourly.date > '$startDate' 
	AND Hourly.date NOT IN (SELECT Consolidated.date from Consolidated   
	WHERE Consolidated.term = '$newTerm');";
	//echo $query . "<BR><BR>";
	mysql_query($query); 
	
	//update the all_terms area for all terms with this name, so they all match and can be searched as one meme
	$query="UPDATE Consolidated 
	SET Consolidated.all_terms = '$newMatch'
	WHERE Consolidated.term = '$newTerm';";  
	mysql_query($query); 
	 
	 //you rock!
}//end combineMe


//A function that adds terms that have no match
function addMe($term, $startDate) {
	echo  "NO MATCHES<BR>";
	
	
	//first we should strip it!
	$all_terms = stripMe($term);
	//echo "after: " . $all_terms . "<BR>";
	
	//go through and insert them into Consolidated
	$query="SELECT Hourly.date, Hourly.score 
	FROM Hourly 
	WHERE Hourly.term = '$term'
	AND Hourly.date > '$startDate';";  //what I really want is to order by the length of Hourly Term
	$result = mysql_query($query); //storing the result of $query in $result

	//go through each row 
	while($row = mysql_fetch_row($result))  { 	 //iterate through the rows of $result
		//echo "<BR><BR>no match<BR>";
		$date = $row[0];
		$score = $row[1];
		$history = $term . " = " . $score;
		echo $history . "<br>";
		//and we already know term and all_terms
		
		//echo "about to add " . $date . " AND " . $score . " AND " . $term . "<BR><BR>";
		$query="INSERT INTO Consolidated (date, term, score, all_terms, term_history) VALUES ('$date', '$term', '$score', '$all_terms', '$history');";
		mysql_query($query); 	
	}

}//end addMe

function stripMe($term) {
	$all_terms = " " . $term . " "; //this is for keeping track of our results.  the spaces are so we can find things
		//echo "before: " . $all_terms . "<BR>";
		$all_terms_array = explode(" ", $term); //this is for testing
		$leaveOut = array('do', 'we', 'day', 'online', 'and', 'or', 'is', 'its', 'in', 'at', 'will', 'season', 'with', 'i', 'you', 'live', 'are', 'the', 'of', 'not', 'a', 'to', 'no', 'an', 'yes', 'our', 'university', 'college', 'new', 'who', 'won', 'pictures', 'picture', 'rumors', 'results', 'for', 'tickets', 'show','tv', 'rumor', 'movie', 'torrent', 'video', 'videos', 'free', 'national', 'us', 'usa', 'score', 'how', 'or', '2008', '2009', '2010', 'when', 'why', 'episode', 'episodes', 'vs', 'vs.', 'live', 'streaming', 'watch', 'where', 'what', 'music', 'file', 'international', 'results', '1', 'login', 'game', 'obama', 'barack', 'score', 'scores','text','2','3', '4', '5','6', '7','8', '9', '10','11','12','13','14','15','16','17','18','19', 's');
		
			for ($j = 0; $j < count($all_terms_array); $j++) {
				//echo "Im in<BR>";
				if (in_array($all_terms_array[$j], $leaveOut)) {
						//echo "found something<BR>";
						//ger rid of terms $leaveOut[i] from $all_terms
						$all_terms=str_replace( " " . $all_terms_array[$j] . " ", " ", $all_terms );
					}//end if
			}//end for
			
			//echo "after: " . $all_terms . "<BR>";
			return $all_terms;

}//end stripMe
	
?>