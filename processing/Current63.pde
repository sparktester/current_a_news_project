

//addauto play option
//screenshots of longer time intervals
//pre-initialize date array!

import simpleML.*;

//Some variables for datahandling
DatabaseHandler DBInfo;
XMLRequest xmlRequest;
TermSystem termSystem;  //this is initialized in DatabaseHandler
Navigator navBar;
SecondaryNavigator secondaryNavBar;
Boolean termSystemExists = false;  //keep track of weather or not it exists yet

//global variables 
String[]  date; //the lables of the dates for the visualization
String [] hours = {"temp"}; 
String [] is_news = {"temp"}; 
String [] has_news = {"temp"}; 
String [] order = {"temp"}; 
String [] name = {"temp"}; 
String [] score = {"temp"}; 
String [] all_terms = {"temp"}; 
String [] term_history = {"temp"}; 

String [] news_headline = {"temp"}; 
String [] news_keywords = {"temp"}; 
String [] news_category = {"temp"}; 
String [] news_score = {"temp"}; 

//variables for the selection process 
boolean somethingSelected = false;
int currentSelected = 0;
boolean inspecting = false; ///this is important.  It tells us which view we're looking at.
boolean showAll = true;  //keeps track of if we want to see all the back
boolean showNews = true;

//other variables
int interval; //this is huge!  It's the number of numbers processing can expect.

PFont font_small;
PFont font;
PFont font_medium;
PFont font_big;
PFont font_italic;
PFont font_bold;
PFont font_navigation;

PImage question;
PImage eye;
PImage akey;

//for the top navigation
String maxMeme= "none";
int maxMemeNumber = 0;
String maxFertelized= "none";
int maxFertelizedNumber = 0;
String maxCarnivorous= "none";
int maxCarnivorousNumber = 0;
//String [] maxSuggestions = {"temp"}; 
//int [] news_score = {"temp"}; 
String suggestion = "";//you want maybe 5 of these?



//some variables for different colors of news
color internationalColor;
color nationColor;
color scitechColor;
color sportsColor;
color entertainmentColor;
color businessColor;
color healthColor;


void setup(){
  
   size(1000,700);
   background(150, 150, 150);
   smooth();

   interval = 0;
   font_small = loadFont("Corbel-10.vlw");
   font = loadFont("Corbel-14.vlw");
   font_navigation = loadFont("Corbel-Italic-12.vlw"); 
   font_medium = loadFont("ArialRoundedMTBold-30.vlw"); 
   font_italic = loadFont("BookmanOldStyle-Italic-16.vlw"); 
   font_big = loadFont("Corbel-Bold-50.vlw"); 
   font_bold = loadFont("Corbel-Bold-14.vlw"); 
   
   question = loadImage("question.png");
   eye = loadImage("eye.png");
   akey = loadImage("key.png");

   sportsColor= color(245, 0, 250);
   entertainmentColor= color(178, 0, 250);
   businessColor= color(240, 164, 0);
   healthColor= color(85, 70, 29);
   
   internationalColor = color(20, 240, 10);
   nationColor= color(10, 240, 199);
   scitechColor= color(252, 245, 0);
   
   DBInfo = new DatabaseHandler();   //make a new database handler to deal with the stuff coming in from the server
   navBar = new Navigator();  //Make a navigator to deal with the other elements of the page 
   
   //Before we get  data - initialize secondary Navigator and SecondaryTermSystem objects so they're ready for data
   secondaryNavBar = new SecondaryNavigator();
   
   //Let's do it!
  //xmlRequest = new XMLRequest(this, "http://www.upables.org/current/examples/backup4-4b.xml");
  //xmlRequest = new XMLRequest(this, "http://www.upables.org/current/examples/backup4-25.xml");
  //xmlRequest = new XMLRequest(this, "http://www.upables.org/current/examples/5-6.xml");
  //xmlRequest = new XMLRequest(this, "http://www.binaryspark.com/Academia/thesis_backup/5-6.xml");
   xmlRequest = new XMLRequest(this, "http://www.upables.org/current/harvestor.php");
   xmlRequest.makeRequest();
   
}//end setup



void draw() {
  noStroke();
  background(255);
  
  if (termSystemExists){ //if we're ready to do anything
      if (showAll) {navBar.renderBottom();}
      if (termSystem.terms.size() > 20) {termSystem.display(); }  
      if (inspecting) {secondaryNavBar.renderBottom();}  //if we're inspecting, display it on top
      if (showAll) {navBar.renderTop();}
  }//end if termsystem exists
}//end draw


void netEvent(XMLRequest xmlRequest) {
    //println (" got to netEvent");
    
    //get the all the information as arrays
    String [] localHours = xmlRequest.getElementArray( "hours" );  //this will tell us how many intervals we will have
    String [] localIs_News = xmlRequest.getElementArray( "is_news" );
    String [] localHas_News = xmlRequest.getElementArray( "has_news" );
    String [] localDate = xmlRequest.getElementArray( "date" );
    String [] localOrder = xmlRequest.getElementArray( "order" );
    String [] localTerm = xmlRequest.getElementArray( "term" );
    String [] localScore = xmlRequest.getElementArray( "score" );
    String [] localAll_Terms = xmlRequest.getElementArray( "all_terms" );
    String [] localTerm_History = xmlRequest.getElementArray( "term_history" );
    String [] localNews_Headline = xmlRequest.getElementArray( "news_headline" );
    String [] localNews_Keywords = xmlRequest.getElementArray( "news_keywords" );
    String [] localNews_Category = xmlRequest.getElementArray( "news_category" );
    String [] localNews_Score = xmlRequest.getElementArray( "news_score" );   
    
    //now get it into the object you need
    DBInfo.recordDB(localHours, localIs_News, localHas_News, localDate, localOrder, localTerm, localScore, localAll_Terms, localTerm_History, localNews_Headline, localNews_Keywords, localNews_Category, localNews_Score);
  
 
  
}//end netevent


void mousePressed() { 
  //someone's pressed somethin!  Only do something with it if we've got a termsystem!
  if(termSystemExists){
        if (inspecting) {secondaryNavBar.clickTracker();} //if we're inspecting
        
        else if (mouseY <= 30) {navBar.clickChecker();  }//if it was in the navigation bar
        
        else{                                             //otherwise, check other options
          if (somethingSelected) {termSystem.inspect();}
          else {termSystem.highlight();}
        }//end else
  }//end termsystemexists
}


void keyReleased() {
  if (keyCode == 32) { showAll = !showAll; } //32
  if (key == 'n') {showNews = !showNews; }
      println ("Turning off visuals");
      
   if (key == 's') {save("Current_Screenshot.png"); }
   //if (key == 's') {save("Current_Screenshot.tif"); }
   
}//end keyreleased


