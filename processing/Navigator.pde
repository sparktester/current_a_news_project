class Navigator  {
   //boolean mouseIsInTheHouse;
   String view;
   
   boolean mouseisinthehouseQuestion;
   boolean mouseisinthehouseEye;
   boolean mouseisinthehouseKey;


Navigator () { 
 
  //mouseIsInTheHouse = false;
  //view = "popularity";
   mouseisinthehouseQuestion = false;
   mouseisinthehouseEye= false;
   mouseisinthehouseKey = false;

}//end constructor  

//set up the names of the lables
void initializeGrid (String[] localDate) {
  
   localDate = sort(localDate);
   date = new String[interval];  //move this to part of Database handler
  
   //now sort each individual guy into its own array cell
   String recentDate = "initial";
   int counter = 0;
   for (int i = 0; i < localDate.length; i++) {  //for every item in the date list
    
        if ((localDate[i].equals(recentDate)) == false) {  //this is the first time we've seen this term
          //println (counter + " has date " + localDate[i]);
          date[counter] = localDate[i];  //this is breaking when there are more or less than 24 items
          
          counter = constrain(counter+1, 0, interval-1); //make sure that counter never goes over interval - it will break the script
          recentDate = localDate[i];
        }//end if
   }//end for
}//end initializeGrid


void renderBottom(){
  
  //first lets have some dates and lines
      for (int i = 0; i < date.length; i++) {   //change this to length!
        fill(0, 50);
        stroke(05, 50);
        strokeWeight(1);
        line(map(i, 0, interval-1, 0, width), 0, map(i, 0, interval-1, 0, width), height);
        
        //now render some lables for each hour!
        rectMode(CORNER);
        textFont(font); 
        text(date[i], map(i, 0, interval-1, 0, width)+5, 35, 50, 200);  
      }//end for
      
}  //end render bottom


void renderTop(){
  //let's do it!
  //first we want a very thin nav bar at top
  fill(150);
  noStroke();
  rect (0,0, width, 30);
  fill(200);
  textFont(font_medium);
  text("current", 5,25);
  
  image(question, width-140, 0);
  image(eye, width-90, 0);
  image(akey, width-40, 0);
  
  fill(150, 240);
  strokeWeight(1);
  stroke(255);
  textFont(font_bold); 
  
  //now let's reset all the mouseIntheHouse to make sure they're still relevant
  if(mouseY >= 30) {mouseisinthehouseQuestion = false; mouseisinthehouseEye = false; mouseisinthehouseKey = false;}
  if((mouseisinthehouseQuestion) && ((mouseX <= width-140) || (mouseX > width-100))) {mouseisinthehouseQuestion = false;}
  if((mouseisinthehouseEye) && ((mouseX <=width-100) || (mouseX > width-50))) {mouseisinthehouseEye = false;}
  if((mouseisinthehouseKey) && ((mouseX <= width-50) || (mouseX > width))) {mouseisinthehouseKey = false;}
  
  //now let's render the fiddly bits
  if (mouseisinthehouseQuestion) {
    rect(width-430, 30, 330, 290); 
    fill(255);
    text("What's All This Then?", width-420, 50);
    textFont(font);
    text("Current is a real time data visualization of internet memes as they carry out lifecycle activities of birth, evolution, and decline in reaction to the daily news cycle.  Visualizing the capricious nature of public attention lets us spotlight missed opportunities in news coverage. \n\nThis project has been created by Zoe Fraade-Blanar. She likes messing around with news, visualizations, news visualizations, and visualizations about news.  Like it?  Why don't you tell her! ", width-420, 75, 310, 500);
    textFont(font_navigation);
    text("http://www.binaryspark.com\nfraade@gmail.com", width-420, 275);
  }
  
  else if (mouseisinthehouseEye) {
    rect(width-380, 30, 330, 375); 
    fill(255);
    text("Time Interval at a Glance!", width-370, 50);
    textFont(font);
    text("Most successful meme \n \nMost fertalized meme \n \nMost carnivorous meme \n \nBest bets for journalism coverage", width-370, 75, 310, 500);
    
    textFont(font_navigation);
    text (maxMeme, width-360, 90, 310, 100);
    text (maxFertelized, width-360, 125, 310, 100);
    text (maxCarnivorous, width-360, 155, 310, 100);
    text (suggestion, width-360, 180, 310, 220);
   textFont(font);  
  }//end if
  
  else if (mouseisinthehouseKey) {
    rect(width-331, 30, 330, 400); 
    fill(255);
    text("What's it all mean?", width-320, 50);
    textFont(font);
    strokeCap(SQUARE);
      //coverage
      for (int w = 0; w<40; w++) {
        strokeWeight(6);
        stroke (map(w,0, 40,10, 255), map(w,0, 40,0, 255), map(w,0, 40,100, 255));
        line(map(w, 0, 40, width-300, width-20), 70, map(w, 0, 40, width-300, width-20), 90);
       }
      textFont(font_navigation);
      text("High coverage", width-305, 105);
      text("Low coverage", width-95, 105);
       
      //interest
      strokeWeight(1);
      stroke(255);
      fill(150, 150, 200);
      beginShape();
      vertex(width-305, 130);
      vertex(width-25, 140);
      vertex(width-305, 150);
      endShape(CLOSE);
      fill(255);
      text("High interest", width-305, 165);
      text("Low interest", width-90, 165);
      
      //news
      noStroke();
      fill(sportsColor);
      ellipse(width-290, 210, 20,20);
      fill(255);
      text("Sports News", width-270, 210);
      
      fill(entertainmentColor);
      ellipse(width-290, 240, 20,20);
      fill(255);
      text("Entertainment News", width-270, 240);
      
      fill(businessColor);
      ellipse(width-290, 270, 20,20);
      fill(255);
      text("Business News", width-270, 270);
      
      fill(healthColor);
      ellipse(width-290, 300, 20,20);
      fill(255);
      text("Health News", width-270, 300);
      
      fill(internationalColor);
      ellipse(width-130, 225, 20,20);
      fill(255);
      text("International News", width-110, 225);
      
      fill(nationColor);
      ellipse(width-130, 255, 20,20);
      fill(255);
      text("National News", width-110, 255);
      
      fill(scitechColor);
      ellipse(width-130, 285, 20,20);
      fill(255);
      text("SciTech News", width-110, 285);
 
    //then do press spacebar to toggle visuals
    textFont(font);
    fill(255);
    stroke(0);
    rect(width-300, 335, 120, 25);
    fill(0);
    text("[SPACEBAR]", width-276, 353);
    textFont(font_navigation);
    fill(255);
    text("Toggle data guides", width-170, 350);
    
    
    fill(255);
    stroke(0);
    rect(width-300, 375, 30, 25);
    textFont(font);
    fill(0);
    text("[n]", width-290, 393);
    textFont(font_navigation);
    fill(255);
    text("Toggle news", width-260, 390);
    
  }  
  
}//end rendertop


   
void  clickChecker() {
    if ((mouseX >width-140) && (mouseX <=width-100)) { mouseisinthehouseQuestion = true; mouseisinthehouseEye = false; mouseisinthehouseKey = false; }
    if ((mouseX >width-100) && (mouseX <=width-50)) { mouseisinthehouseQuestion = false; mouseisinthehouseEye = true; mouseisinthehouseKey = false;}
    if ((mouseX >width-50) && (mouseX <=width)) { mouseisinthehouseQuestion = false; mouseisinthehouseEye = false; mouseisinthehouseKey = true;}
  
   //in draw, remember every time through to check the position of the mouse.  If it's not within the spot it was, turn all of them to false!

 //println("question");
 //println("eye");
 //println("key");
 } //end clickchecker 
   
     
}//end class
