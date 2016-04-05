<?php

ini_set('display_errors', 1);

include 'timezone.php';

//ini_set('max_execution_time', 120) //let's just see if this works
//set_time_limit(0); //let's just see if this works

$currentTerm = NULL;


//get the currently popular terms from google
$myTerms = getTerms("http://www.google.com/trends/hottrends/atom/hourly");

//Now stick both arrays in the database
databaseSticker($myTerms);

//get the news terms for this time period
include 'newser.php';


//////////////////////////////////////////////////////
///////////////////FUNCTIONS//////////////////////////
//////////////////////////////////////////////////////

function getTerms($myUrl) {

	$itterator = 0;
            
	 //echo ("About to get raw feed<BR><BR>");
     $rawPage = file_get_contents($myUrl); 
	 
	 $searchForStart = "sa=X\">";
	 $searchForEnd = "</a>";
	 
	 while ($startPos = (strpos($rawPage, $searchForStart))) { 
	
		 $endPos = strpos($rawPage, $searchForEnd);
		 $length = $endPos - $startPos;
		 
		 if ($startPos && $endPos) {
			 $currentTerm = substr($rawPage, ($startPos+strlen($searchForStart)), $length-6);
			 //echo $currentTerm  . "<BR>";
			 $terms[$itterator] = $currentTerm;
			 $itterator++;
		 } //end if
		 
		 $rawPage = substr($rawPage, ($endPos + 4));
	 
	 } //end while
	 //echo var_dump($terms);
	 //echo "done now";
	 return $terms;
	
}//end getTerms



function databaseSticker($someTerms) {
	 
	 //Now create the datetime stamp for this particular itteration as YYYY-MM-DD HH:MM:SS
	 $dropDate = date('Y-m-d H:i:s', strtotime("-24 hours 15 minutes")); 
	 $mydate = date('Y-m-d H:i:s', strtotime("now"));
	
	include 'login_info.php';
		
	//first check that this script hasn't been run in the last 5 minutes, to guard against server hickups
	 $query = "SELECT Hourly.date FROM Hourly ORDER BY Hourly.date DESC LIMIT 1;";
	 $result = mysql_query($query); 
	
	//time1 and 2 will hold the last time it was run, and the time now
	 $time1= 0; //this way, if the table is empty it will see them as different and fill it
	 $time2 = date('H', strtotime(now)); 
		
	while($row = mysql_fetch_row($result)) {  	 //iterate through the rows of $result
    	//$lastDate   = $row[0];	
		
		$time1= date('H', strtotime($row[0])); //the most recent reading
		//$time2 = date('H', strtotime(now));  //The current time...I could also just use H from $mydate here
		
	}//end while
	
	if ($time1 != $time2) {
	//if (true) { //for testing only
		echo "Been more than an hour or table empty<BR><BR>";
	
		 for($i=0; $i < count($someTerms); $i++) {
	   
			 //$inTimes = $someArticles[$i];
			 $term = $someTerms[$i];
			 $score = count($someTerms)-$i; // a score of 0 is really the highest possible to the length of the list
			 
			 echo $term . "<BR>Score: " . $score . "<BR>Get rid of older than " . $dropDate . " <BR>date: " . $mydate . "<BR><BR>"; 
			 
			 //Add the new stuff
			 $query="INSERT INTO Hourly (date, term, score) VALUES ('$mydate', '$term', '$score');";
			 mysql_query($query); 	
		} //end for
		
		//now drop the old stuff
		//for now, we're not going to drop old stuff.
		//$query = "DELETE FROM Hourly WHERE date <= '$dropDate';";
		//mysql_query($query); 
		
	}//end if
	
	else {
	echo "It's too soon<BR><BR>";
	}
	
	//we're done!
     mysql_close($conn);  //close the database connection
	
}//end databaseSticker
	 
?>