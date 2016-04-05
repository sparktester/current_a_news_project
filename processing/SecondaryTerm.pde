class SecondaryTerm {
  
  int[] absoluteTermScores; //the set scores as reported form the internet
  int[] termScores; //the set scores as reported form the internet
  int[] lastTermScores; //the last term's plotted points
  
  String termName;
  String shortName;
  boolean isNews; //this will store if this is a real term or only here for a news reason
  int localInterval;
  int myColor;
  int newsScore; //the actual, unchanged score for each news item
  int newsOrder;
  int termTotal;
  String newsCategory;
  int maxDiff;
;
  
  //these are to tell us where to start our pointer
  //int xPointer, yPointer;
  //int xBox, yBox;
  //int xBox1, yBox1;
  //int xText, yText;
  //int xLink;
  

  //CONSTRUCTOR
  SecondaryTerm(String tempName, int tempScore, boolean tempIs_news, String category, int tempOrder, int tempInterval, int tempColor) {
    
    ///////////Set up the universal constants!///////////
    termName= tempName;   
    isNews = tempIs_news;
 
      if ((!isNews) || (tempName.length() <= 22)) {shortName = tempName;}
      else {shortName = tempName.substring(0, 21); shortName = shortName+"...";}
      
    localInterval = tempInterval;
    myColor = tempColor;
    newsOrder = 0;
    if (isNews){newsOrder = tempOrder;}
    //newsCategory = "none";
    newsCategory = category;
    
    //create everything
    termScores= new int[localInterval];
    lastTermScores = new int[localInterval];  //I'll use this to plot the bottom of the curve, and calculate color
    absoluteTermScores = new int[localInterval];
   
    //initialize the additive item
    for (int i = 0; i < termScores.length; i++) {
      termScores[i] =  0;
      lastTermScores[i] = 0;
      absoluteTermScores[i] = 0;
    }//end for
        
        
    //now call a function to insert the first score (tempScore) in the proper (termOrder) slot of (termScore)
    insertScore(tempScore, tempOrder);

  }//end constructor
  
  
  
void insertScore(int theScore, int theOrder) {
    newsScore = theScore; //this stores the real score before we make it all big and small and stuff
    
    if (!isNews){absoluteTermScores[theOrder] = int(theScore*2.2);}  //maybe shouldn't do the 2.o here.  Constrained for now
    
    else {absoluteTermScores[theOrder] = constrain(theScore, 10, 750)/8; }
    //we'll fill in the other two arrays once everything is filled in
    
}//end insertScore  


void render() {

     if (!isNews) { //if it's not news
          
          if (myColor >230) { stroke(0);} //if it's white
          else {stroke (map(myColor,0, 255,10, 255), map(myColor,0, 255,0, 255), map(myColor,0, 255,100, 255));}
          
         
          strokeWeight(3);
          fill (255);
     
          beginShape();
               //plot the bottom!
              curveVertex(70,  termScores[0]);
              for (int i = 0; i < termScores.length; i++) {
                curveVertex(map (i, 0, termScores.length-1, 70, 760),  termScores[i]); //repeat the last one
              }
              curveVertex(760, termScores[localInterval-1]);  //repeat the point on the right
             
             //now plot the top!
              curveVertex(760, lastTermScores[localInterval-1]);  //repeat the point on the right
              for (int i = lastTermScores.length-1; i>=0; i--) {
                curveVertex(map (i, 0, lastTermScores.length-1, 70, 760),  lastTermScores[i]); //repeat the last one
              }//end for
              curveVertex(70, lastTermScores[0]);  //repeat the point on the left
         
          endShape();
          
           //add an extra line to the beginning
           line(70, lastTermScores[0], 70,  termScores[0]);
                   
 }//end if isNews == false
 
 else{
  //render it as some news!!!!! you'll want to use the category color here
            //noStroke();
            strokeWeight(2);
            stroke (map(myColor,0, 255,10, 255), map(myColor,0, 255,0, 255), map(myColor,0, 255,100, 255));
            //fill(255);
            
            if (newsCategory.equals("international")) {fill(internationalColor); }
            else if (newsCategory.equals("nation")) {fill(nationColor);}
            else if (newsCategory.equals("scitech")) {fill(scitechColor);}
            else if (newsCategory.equals( "sports")) {fill(sportsColor);}
            else if (newsCategory.equals("entertainment")) {fill(entertainmentColor); }
            else if (newsCategory.equals("business")) {fill(businessColor);}
            else if (newsCategory.equals("health")) {fill(healthColor);}
            else {fill(0, 255, 255);}
            
            int mySize = constrain(int(absoluteTermScores[newsOrder]/2), 4, 1000);
            int ypos = absoluteTermScores[newsOrder]/2+lastTermScores[newsOrder]-5; //mess with the 5
            int xpos = int(map(newsOrder, 0, localInterval-1, 70, 760));
            ellipse(xpos, ypos, mySize, mySize);
            
            //now, if the actual score is over 3000, render a small plus in the center
            if (newsScore > 3500) {
              strokeWeight(1);
              stroke(0, 100);
              line(xpos-2, ypos, xpos+2, ypos);
              line(xpos, ypos-2, xpos, ypos+2);
              //println("got in");
            }
            
            //now we have to render the lables!!!!!
            
            strokeWeight(1);
            stroke(50);
            line(xpos, ypos-mySize/2, xpos-10, ypos-mySize/2-40);
            
            rectMode(CORNER);
            textFont(font_small);
            fill(50); 
            pushMatrix();
              translate(xpos-10, ypos-mySize/2-40);
              rotate(PI/-3.2);
              text(shortName, 0,0);
            popMatrix();
 }//end else
}//end render



void memeLabelRender(){
  
            //everything here needs be be a separate function
            int xpos = int(map(maxDiff, 0, localInterval-1, 70, 760));
            int ypos = lastTermScores[maxDiff]+int((absoluteTermScores[maxDiff]/2));
            
            strokeWeight(1);
            stroke(50);
            fill (50);
            line(xpos, ypos, xpos-20, lastTermScores[maxDiff]+80);
            ellipse(xpos, ypos, 4, 4);
            
            
            rectMode(CORNER);
            textFont(font_small);
            fill(50); 
            pushMatrix();
              translate(xpos-20, lastTermScores[maxDiff]+85);
              rotate(PI/5.2);
              text(shortName, 0,0);
            popMatrix();
 
}//end meme lable render


//for testing only  
void printContents() {
    //for testing, print out previousTermScores
     print (termName + ": ");
     for (int x = 0; x < termScores.length; x++) { print(termScores[x] + "-");}
     println("");
}//end Printcontents  

}

