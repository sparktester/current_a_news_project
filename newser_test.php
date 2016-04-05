<?php

ini_set('display_errors', 1);
include 'login_info.php';

//first, hit the hourly database and find out the most recent timestamp
$query = "SELECT Hourly.date FROM Hourly ORDER BY Hourly.date DESC LIMIT 1;";
$result = mysql_query($query); 
$time1= NULL; //this way, if the table is empty it will see them as different and fill it
while($row = mysql_fetch_row($result)) { $time1= $row[0];}
echo $time1 . "<BR><BR><BR>";
//echo "got in" . "<BR><BR><BR>";

//get the news and stick it in the database
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=e&output=rss", "entertainment", $time1);
         
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=s&output=rss", "sports", $time1);
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=w&output=rss", "international", $time1);
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=n&output=rss", "nation", $time1);
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=b&output=rss", "business", $time1);
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=m&output=rss", "health", $time1);
//sleep(1);//wait a second so we don't overload the google
getNews("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=t&output=rss", "scitech", $time1);
//sleep(1);//wait a second so we don't overload the google

//we're done!

mysql_close($conn);  //close the database connection
  
////////////////////////////////////////////
//Get the news itms
////////////////////////////////////////////  
function getNews($url, $myCategory, $myTime) {
  
  //$url = "http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=e&output=rss";
  //get the info
  $data = file_get_contents($url);
  //$data = fopen($url, 'r');
  //echo $data . "<BR><BR>";
  echo "THAT WAS THE DATA<BR><BR>";
  //Transfer it
  $xml = new SimpleXmlElement($data);
  var_dump($xml);
  
	foreach ($xml->channel->item as $item) 
                {     	 
					//initialize the final veriables so they're never NULL
					$myTitle = "unknown";
					$myCount = "0";
					
    				//get the title we want, and change it to the form we're looking for
    				$myTitle = trim($item->title); 
					$searchForDash = " - ";
					$dashPos = strrpos($myTitle, $searchForDash);
					$myCount = trim(str_replace("'", "\'", $myCount)); 
					//$myCount = trim(str_replace("\"", "\\"", $myCount)); 
					
					if ($dashPos) {$myTitle = substr($myTitle, 0, $dashPos);}
					//echo $myTitle . "<br>";
						
					$myDescription = $item->description; 
					//echo $myDescription . "<br><BR>";
					
					//now get what we want from the description, and change it to the form we want
					$searchForStart = "<nobr><b>all ";
					$searchForEnd = " news articles&nbsp;&raquo;";
					$startPos = strpos($myDescription, $searchForStart);
					$endPos = strpos($myDescription, $searchForEnd);
						//echo $startPos . "<BR>";
						//echo $endPos. "<BR>";
					$length = $endPos - $startPos;
					
					if ($startPos && $endPos) {
			 			$myCount = substr($myDescription, ($startPos+strlen($searchForStart)), $length-13);
						$myCount = trim(str_replace(",", "", $myCount));
							
					}//end if
					
					//now we're going to use that description and get other related headlines from it!!
					//cut off some of the extra at the beginning
					$descriptionHolder = substr($myDescription, strpos($myDescription, "..."), strlen($myDescription)-1);
					
					//make a variable to hold the search string
					$mySearchString = $myTitle;
					
					//now, I want to cut the string down, I want each time there is a "> that isn't followe by a <
	
					$searchForStart = "\">";
					
					while ($beginning = (strpos($descriptionHolder, $searchForStart))) { //this will run till we can't find ">
						//cut the string to that length+2
						$descriptionHolder = substr($descriptionHolder, $beginning+2, strlen($descriptionHolder)-1);
						//echo $descriptionHolder;
						//Check the position of the next < .  If it's not 0, print what's there
						$endPos = strpos($descriptionHolder, "<");
						if ($endPos != 0) {
							//echo substr($descriptionHolder, 0, $endPos) . "<BR>";
							//now let's add that sentence to all the sentences that came so far!
							$mySearchString = $mySearchString . " " . substr($descriptionHolder, 0, $endPos);
							
						}//end if
				
					}//end while
					
					//echo $mySearchString . "<BR>";
										
					//now, let's see if we can't get some terms outa that title!
					$termExtractor = "http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction?appid=wR5V7c3V34FMeNRbTWmwxQxFW0.ToaJY_YzppxdBppvvT4jOi1OfcvRoWSg-&context=" . rawurlencode(trim($mySearchString)) . "&output=xml"; 	
					//echo $termExtractor . "<BR>";
					$dataTerms = file_get_contents($termExtractor);
					$xmlTerms = new SimpleXmlElement($dataTerms);
					//var_dump($xmlTerms);
					
					//make a variable to hold the list of terms
					$myTerms = NULL;
					foreach ($xmlTerms  as $item) {
					 //echo $item . "<br>";
					 $myTerms = $item . " - " . $myTerms ;
					 //now, let's add this to the string for this item
					}
					
					//now get myTitle ready to go into the database
					$myTitle = addslashes($myTitle); //Note:  this should be done for terms too
					$myTerms = addslashes($myTerms);
					echo $myTerms . "<BR>";
					echo $myCount . "<br>";
					echo $myTitle . "<br>";
					echo $myCategory . "<BR>";
					echo $myTime . "<BR><BR>";
					
			//Now put it all in a database
			//echo "About to put in database<BR>";
			//databaseStickerNews($myTitle, $myCount, $myTerms, $myCategory, $myTime);  //mytime is originally calculate in grabber
			//echo "tried to put in database<BR><BR>";	
			
		}//end foreach
}//end getnews


///////////////////////////////////////
//Put it in a database
///////////////////////////////////////
function databaseStickerNews($myTitle, $myCount, $myTerms, $myCategory, $myTime) {

	//start by getting the most recent date from the terms hourly database
	//echo "About to database it<BR>";
	
	$query="INSERT INTO Hourly_News (date, headline, keywords, score, category) VALUES ('$myTime', '$myTitle', '$myTerms', '$myCount', '$myCategory');";
	//echo $query . "<br>";
	
	mysql_query($query); 	
	
	//echo "Inserted<BR><BR>";
	
}//end databaseStickerNews

//do any language processing intended

?>