class NewsItem {
  
  String Headline;
  String Keywords; 
  String Category; 
  int Score;
  boolean newsExists; //keeps track of if anything is in this one
  
  
  //constructor
  NewsItem(String tempHeadline, String tempKeywords, String tempCategory, int tempScore) {
    
     Headline = tempHeadline;
     Keywords = tempKeywords; 
     Category = tempCategory; 
     Score = tempScore;
     newsExists = false;
    
  }//end constructor
  
  
///Calculate out the current size, based on the score  
int getSize(){
  int presentSize = constrain((Score/20), 2, 80);
  return presentSize;
}//end getsize



void render(int xlocal, int ylocal) {
  
  //stroke(255);
  fill(255, 50);
  smooth();
  
  //this should be for show details!
 
  if (Category.equals("international")) {stroke(internationalColor); }
  else if (Category.equals("nation")) {stroke(nationColor);}
  else if (Category.equals("scitech")) {stroke(scitechColor);}
  else if (Category.equals( "sports")) {stroke(sportsColor);}
  else if (Category.equals("entertainment")) {stroke(entertainmentColor); }
  else if (Category.equals("business")) {stroke(businessColor);}
  else if (Category.equals("health")) {stroke(healthColor);}
  else {stroke(255);}
  

  int itemSize = int(getSize()/2.8);
  ellipse(xlocal, ylocal, itemSize, itemSize);
}//end render



void renderExtra(int xlocal, int ylocal) {
  //RENDER THE STUFF ON TOP  
  //println(Category);
 
  if (Category.equals("international")) {fill(internationalColor, 40); }
  else if (Category.equals("nation")) {fill(nationColor, 40);}
  else if (Category.equals("scitech")) {fill(scitechColor, 40);}
  else if (Category.equals( "sports")) {fill(sportsColor, 40);}
  else if (Category.equals("entertainment")) {fill(entertainmentColor,40); }
  else if (Category.equals("business")) {fill(businessColor,40);}
  else if (Category.equals("health")) {fill(healthColor,40);}
  else {fill(0, 255, 255);}
   
  noStroke();
  strokeWeight(1);//for testing
  stroke(255);//for testing
  smooth();
  //fill(255, 30);
  
  int itemSize = int(constrain((map(Score, 350, 5000, 2, 5000)/30), 2, 85)); //let's get a more realistic aspect of the size
  ellipse(xlocal, ylocal, itemSize, itemSize);
}//end render
  

    
  }
