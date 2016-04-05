<?php

include 'login_info.php';

//select the last date in the table
	 $query = "SELECT Consolidated.date FROM Consolidated ORDER BY Consolidated.date DESC LIMIT 1;";
	 $result = mysql_query($query); 
		
	while($row = mysql_fetch_row($result)) {  	 //iterate through the rows of $result
    	$lastDate  = $row[0];	
		//echo $lastDate . "<BR><BR>";
	}//end while
	
//select the last date in the table
	$query = "SELECT Consolidated.date FROM Consolidated ORDER BY Consolidated.date ASC LIMIT 1;";
	$result = mysql_query($query); 
		
	while($row = mysql_fetch_row($result)) {  	 //iterate through the rows of $result
    	$firstDate  = $row[0];	
		//echo $firstDate . "<BR><BR><BR><BR>";
	}//end while
	
//how many dates we talking about here?
	$query = "SELECT COUNT(DISTINCT Consolidated.date) FROM Consolidated;";
	$result = mysql_query($query); 
		
	while($row = mysql_fetch_row($result)) {  	 //iterate through the rows of $result
    	$number_hours  = $row[0];	
		//echo $number_hours . "<BR><BR><BR>";
	}//end while
	

//Long-term:  pulling in the news from this span that does not have a match!  
//Might want to find a way to display half of that before and half after.

/////////////////////////////////////////////////////
//start displayin'!!!!!!!
/////////////////////////////////////////////////////////////////
echo "<?xml version=\"1.0\"?>\n";								//print out an html head tag
echo "<feedInfo>\n";										//open the feedinfo tag for the body of the xml feed
echo "<start_date>" . $lastDate . "</start_date>" . "\n";	
echo "<end_date>" . $firstDate . "</end_date>" . "\n";
echo "<hours>" . $number_hours . "</hours>" . "\n\n";

////////////////////////////////////////////////////////////////
//First, let's pull what's in News that's not in consolidated:  Entertainment, Sports, Health
$query3 = "SELECT Hourly_News.date, Hourly_News.headline, Hourly_News.keywords, Hourly_News.category, Hourly_News.score, ($number_hours-1)-(TIMESTAMPDIFF(HOUR, Hourly_News.date, DATE_ADD('$lastDate', INTERVAL 20 MINUTE)))AS myRank, Hourly_News.identity 
					FROM Hourly_News 
					WHERE Hourly_News.date >= '$firstDate'
					AND Hourly_News.date <= '$lastDate'
					AND (Hourly_News.category = 'entertainment' OR Hourly_News.category = 'sports' OR Hourly_News.category = 'health' OR Hourly_News.category = 'business')
					AND Hourly_News.identity NOT IN (SELECT Consolidated.articles FROM Consolidated)
					AND Hourly_News.score > 350 
					ORDER BY Hourly_News.score ASC;";
//echo $query3;
//echo "<BR><BR>";					
					
$result3 = mysql_query($query3); 					 		//storing the result of $query in $result

while($row3 = mysql_fetch_row($result3))   	 //iterate through the rows of $result
{
    $date   = $row3[0];											//get the particular item at each cell of the row

	//now get date in a form you want
	$date1= date('m-d H:00', strtotime($date));
	
	$hasNews = "true";

	$news_headline = $row3[1];
	$news_headline = str_replace( "&", "",  $news_headline);//temporary fix
	$news_headline = str_replace(";", "", $news_headline);
	$news_headline = str_replace(">", "", $news_headline);
	$news_headline = str_replace("<", "", $news_headline);
	
	$news_keywords = $row3[2];
	$news_keywords = $news_keywords . " ";
	$news_category = $row3[3];
	$news_score = $row3[4];
	$order = $row3[5];
	$identity = $row3[6];

	echo "<databaseItem> \n" .
	
		 "<is_news>true</is_news> \n" . 
		 "<has_news>true</has_news>  \n" .
		 "<date>" . $date1 . "</date>  \n" .	//write it all out as one big old line.  I'll actually use xml tags here.
		 "<order>" . $order . "</order>  \n" .  //precalculated order of where that item falls in the timeline
		 "<term>" . $identity . "</term> \n" .   //this is neccesary for processing!!!!!!
		 "<score>0</score> \n" .
		 "<all_terms>none</all_terms>  \n" .
		 "<term_history>none</term_history>  \n" .
		 "<news_headline>" . $news_headline . "</news_headline>  \n" .  //NEWS RELATED
		 "<news_keywords>" . $news_keywords . "</news_keywords>  \n" .
		 "<news_category>" . $news_category . "</news_category>  \n" .
		 "<news_score>" . $news_score . "</news_score>  \n" .			
		
		 "</databaseItem>\n \n";

}//end while first half news

////////////////////////////////////////////////////////////
///////Now, let's pull what's in consolidated!///////////////
/////////////////////////////////////////////////////////////	

//Get the information we want, sorted by date
$query="SELECT Consolidated.date, Consolidated.term, Consolidated.score,  ($number_hours-1)-(TIMESTAMPDIFF(HOUR, Consolidated.date, DATE_ADD('" . $lastDate . "', INTERVAL 20 MINUTE)))AS myRank, Consolidated.all_terms, Consolidated.term_history, Consolidated.articles 
		FROM Consolidated
	ORDER BY Consolidated.term, Consolidated.date;";
$result = mysql_query($query); 					 		//storing the result of $query in $result



while($row = mysql_fetch_row($result))   	 //iterate through the rows of $result
{
    $date   = $row[0];											//get the particular item at each cell of the row
    $term = $row[1];
	$term = str_replace("&", "",  $term);//temporary fix
    $score = $row[2];
	$order = $row[3];  //precalculated order of where that item falls in the timeline
	$all_terms = $row[4];
	$term_history = $row[5];
	$articles = $row[6];
	
	//now get date in a form you want
	$date1= date('m-d H:00', strtotime($date));
	
	$hasNews = "false";
	$news_headline = "none";
	$news_keywords = "none";
	$news_category = "none";
	$news_score = "none";
	
////////////////////////////////////////////////////////////////
///////Is there news?  let's do something about it!	/////////////
////////////////////////////////////////////////////////////////
	
	
	if ($articles != '0') { 
		$hasNews = 'true';  
		//call an sql statement that pulls in news neccesary into
		include 'login_info.php';
		$query2 = "SELECT Hourly_News.headline, Hourly_News.keywords, Hourly_News.category, Hourly_News.score 
					FROM Hourly_News 
					WHERE Hourly_News.identity = $articles;";
		$result2 = mysql_query($query2);
		mysql_close($conn);		
		
		while($row2 = mysql_fetch_row($result2)) {  	 //iterate through the rows of $result
				
			$news_headline = $row2[0];
			$news_headline = str_replace( "&", "",  $news_headline);//temporary fix
			$news_headline = str_replace(";", "", $news_headline);
			$news_headline = str_replace(">", "", $news_headline);
			$news_headline = str_replace("<", "", $news_headline);
			
			$news_keywords = $row2[1];
			$news_keywords = $news_keywords . " ";
			$news_category = $row2[2];
			$news_score = $row2[3];
		}//end while
	}//end if
	
//////////////////////////////////////////////////////////	
////////Alright, let's make that xml we love!/////////////
///////////////////////////////////////////////////////////	


	if ($order >= 0) { 	//just in case there was a server glitch that might give us dates more than 24 hours old
		/*
		echo "IS NEWS: 	false <BR>" . 
			 "HAS NEWS: " . $hasNews . "<BR>" .
			 "DATE: " . $date1 . "<BR>" .	//write it all out as one big old line.  I'll actually use xml tags here.
			 "ORDER: " .$order . "<BR>" .  //precalculated order of where that item falls in the timeline
			 "TERM: " .$term . "<BR>" . 
			 "SCORE: " .$score. "<BR>" .
			 "ALL RELATED TERMS: " .$all_terms. "<BR>" .
			 "DATE HISTORY: " .$term_history . "<BR>" .
			 
			 "NEWS HEADLINE: " . $news_headline . "<BR>" .  //NEWS RELATED
			 "NEWS KEYWORD: " . $news_keywords . "<BR>" .
			 "NEWS HISTORY: " . $news_category . "<BR>" .
			 "NEWS SCORE: " . $news_score . "<BR><br>";
			*/
	
	echo "<databaseItem> \n" .
	
		 "<is_news>false</is_news> \n" . 
		 "<has_news>" . $hasNews . "</has_news>  \n" .
		 "<date>" . $date1 . "</date>  \n" .	//write it all out as one big old line.  I'll actually use xml tags here.
		 "<order>" . $order . "</order>  \n" .  //precalculated order of where that item falls in the timeline
		 "<term>" . $term . "</term> \n" . 
		 "<score>" . $score. "</score> \n" .
		 "<all_terms>" . $all_terms. "</all_terms>  \n" .
		 "<term_history>" . $term_history . "</term_history>  \n" .
		 "<news_headline>" . $news_headline . "</news_headline>  \n" .  //NEWS RELATED
		 "<news_keywords>" . $news_keywords . "</news_keywords>  \n" .
		 "<news_category>" . $news_category . "</news_category>  \n" .
		 "<news_score>" . $news_score . "</news_score>  \n" .			
		
		 "</databaseItem>\n \n";
		
	}//end if
}//end while

////////////////////////////////////////////////////////////////
//Finally, let's pull what's in News that's not in consolidated:  international, nation, business, scitech
/////////////////////////////////////////////////////////////
$query3 = "SELECT Hourly_News.date, Hourly_News.headline, Hourly_News.keywords, Hourly_News.category, Hourly_News.score, ($number_hours-1)-(TIMESTAMPDIFF(HOUR, Hourly_News.date, DATE_ADD('$lastDate', INTERVAL 20 MINUTE)))AS myRank, Hourly_News.identity 
					FROM Hourly_News 
					WHERE Hourly_News.date >= '$firstDate'
					AND Hourly_News.date <= '$lastDate'
					AND (Hourly_News.category = 'international' OR Hourly_News.category = 'nation' OR Hourly_News.category = 'scitech')
					AND Hourly_News.identity NOT IN (SELECT Consolidated.articles FROM Consolidated)
					AND Hourly_News.score > 350 
					ORDER BY Hourly_News.score DESC;";
							
//echo $query3;
//echo "<BR><BR>";					
					
include 'login_info.php';					
$result3 = mysql_query($query3); 					 		//storing the result of $query in $result
mysql_close($conn);

while($row3 = mysql_fetch_row($result3))   	 //iterate through the rows of $result
{
    $date   = $row3[0];											//get the particular item at each cell of the row

	//now get date in a form you want
	$date1= date('m-d H:00', strtotime($date));
	
	$hasNews = "true";
	$news_headline = $row3[1];
	$news_headline = str_replace( "&", "",  $news_headline);//temporary fix
	$news_headline = str_replace(";", "", $news_headline);
	$news_headline = str_replace(">", "", $news_headline);
	$news_headline = str_replace("<", "", $news_headline);
	
	$news_keywords = $row3[2];
	$news_keywords = $news_keywords  . " ";
	$news_category = $row3[3];
	$news_score = $row3[4];
	$order = $row3[5];
	$identity = $row3[6];

	echo "<databaseItem> \n" .
	
		 "<is_news>true</is_news> \n" . 
		 "<has_news>true</has_news>  \n" .
		 "<date>" . $date1 . "</date>  \n" .	//write it all out as one big old line.  I'll actually use xml tags here.
		 "<order>" . $order . "</order>  \n" .  //precalculated order of where that item falls in the timeline
		 "<term>" . $identity . "</term> \n" .   //this is neccesary for processing!!!!!!
		 "<score>0</score> \n" .
		 "<all_terms>none</all_terms>  \n" .
		 "<term_history>none</term_history>  \n" .
		 "<news_headline>" . $news_headline . "</news_headline>  \n" .  //NEWS RELATED
		 "<news_keywords>" . $news_keywords . "</news_keywords>  \n" .
		 "<news_category>" . $news_category . "</news_category>  \n" .
		 "<news_score>" . $news_score . "</news_score>  \n" .			
		
		 "</databaseItem>\n \n";

}//end while first half news



echo "</feedInfo>\n";
	 
?>