class DatabaseHandler  {
   
//this is a class to handle all external interactions and route them to the correct place

DatabaseHandler () { 
 //Not a whole lot happening here
}//end constructor  
   
void recordDB (String[] tempHours, String[] tempIs_News, String[] tempHas_News, String[] tempDate, String[] tempOrder, String[] tempTerm, String[] tempScore, String[] tempAll_Terms,  String[] tempTerm_History,  String[] tempNews_Headline,  String[] tempNews_Keywords,  String[] tempNews_Category,  String[] tempNews_Score) {
 
  //first, match up these to make them universal.  They're too big to pass every time.
  
//Let's start by just bringing in what we need for now.  No news information will be used.
  hours = tempHours;   //We'll use this for filling in the universal interval
  order = tempOrder;
  name = tempTerm; 
  score = tempScore;  
  all_terms = tempAll_Terms;
  
  is_news = tempIs_News; 
  has_news = tempHas_News;  
  term_history = tempTerm_History; 
  news_headline = tempNews_Headline; 
  news_keywords = tempNews_Keywords; 
  news_category = tempNews_Category; 
  news_score = tempNews_Score; 
  
  //Initialize the interval.  We'll need that for everything else.
  interval = int(hours[0]);
  println ("INTERVAL: " + interval);
  
  //use the date information to populate the Date aspect of the Navigator array
  
  navBar.initializeGrid(tempDate);
 
  termSystem = new TermSystem(); // I could pass the arrays here instead if I didn't want em to be global!
  termSystemExists = true;  //let the system know it's ready
    
  }   //end recordDB
}//end class


