<?php

include 'login_info.php';

//first, hit the Consolidated database and find out the most recent timestamp
$query = "SELECT Consolidated.date FROM Consolidated ORDER BY Consolidated.date ASC LIMIT 1;";
$result = mysql_query($query); 
$oldest= NULL; //this way, if the table is empty it will see them as different and fill it
while($row = mysql_fetch_row($result)) { $oldest= $row[0];}
echo $oldest . "<BR>";

//now, hit the Consolidated database and find out the oldest timestamp
$query = "SELECT Consolidated.date FROM Consolidated ORDER BY Consolidated.date DESC LIMIT 1;";
$result = mysql_query($query); 
$newest= NULL; //this way, if the table is empty it will see them as different and fill it
while($row = mysql_fetch_row($result)) { $newest= $row[0];}
echo $newest . "<BR><BR>";

///////////////
//Now let's start messing around with arrays!
////////////////////////

//Select all from Hourly_news that falls into this time frame
$query="SELECT Hourly_News.identity, Hourly_News.keywords, Hourly_News.date  FROM Hourly_News WHERE (Hourly_News.date >= '" . $oldest . "') AND (Hourly_News.date <= '" . $newest . "')";
$newsTerms = mysql_query($query); //storing the result of $query in $result

mysql_close($conn);  //close the database connection

////////////////
///////////Now we're ready to start cycling!
//////////////////////////////

//Ready?  Let's go through each row of news and do stuff for each item
while($row = mysql_fetch_row($newsTerms))   	 {  //first we cycle through news items
	
    $identity = $row[0];
	$newsWords = $row[1];
	$newsDate = $row[2];
	
	//Get the news string ready
	$newsPrep = " " . str_replace( "- " , "", trim($newsWords)) . " "; 
	$newsPrep = " " . str_replace( "-" , "", $newsPrep) . " ";
	echo "<BR>NEWS ITEM: " . $newsPrep . "<BR>";
	
	//Now! Let's call matcher on this information!
	//we also have to call it with identity, and date!  SO you know where and what to stick into COnsolidated
	matchThis($newsPrep, $newsDate, $identity, $newsWords);
	
}//end first while


	


//////////////////////////////////////////////////
///////////////////FUNCTIONS//////////////////////
//////////////////////////////////////////////////
function matchThis($newsString, $newsDate, $identity, $newsWords) {	

	//let's get newsString ready:
	$news_array = explode(" ", trim($newsString)); //this is for testing
	
	//let's get all the searchterms!
	include 'login_info.php';
	$query="SELECT DISTINCT Consolidated.all_terms FROM Consolidated;";  
	$searchTerms = mysql_query($query); 
	mysql_close($conn);
	
	//Now, for each let's go through all search terms for the above newsString
	while($row = mysql_fetch_row($searchTerms))   	 {
		$searchWords = $row[0];
		//echo "SEARCH WORDS: " . $searchWords . "<BR>";
		//get the search array for this row ready.
		$termsPrep = trim(str_replace( "  -  " , " ", $searchWords ));
		$termsPrep = trim(str_replace( "-" , "", $termsPrep ));
		
		$termsArray = explode(" ", $termsPrep );
		//echo $termsArray[0] . "+";
		
		$foundSomething = false; //this will keep track of if there's a match
		//Now, let's cycle through TermsArray and compare them!!!
		for ($j = 0; $j < count($termsArray); $j++) {
				//echo $termsArray[$j] . "++" ;
				//do the comparison here
				if (in_array($termsArray[$j], $news_array)) { 
					//echo "MATCH: " . $searchWords . "ON: " . $termsArray[$j] . "<BR>";
					$foundSomething = true;
					//return $searchWords so we know what to update with this particular news item
				}//end if
					
		}//end for 
		
		//if foundSomething is true, let's stick it in the database
		if ($foundSomething == true) {
					//echo "MATCH: " . $searchWords . "<BR>";
					//Now take that number, and add it to this $searchWords at date in COnsolidatedse
					include 'login_info.php';
					
					$query="UPDATE Consolidated 
					SET Consolidated.articles = '$identity' 
					WHERE Consolidated.all_terms = '$searchWords' 
					AND Consolidated.date = '$newsDate'";
					
					echo $query . "<BR>"; //Do it!
					mysql_query($query); 
					mysql_close($conn);
					
		}//end if
				
	}//end while
	echo "<BR>";
}//end matchthis	
  
?>