class SecondaryNavigator  {
   //boolean mouseIsInTheHouse;
   String[] inspectorDate = {"temp"}; 
   int[] inspectorOverallTermLast; 
   int[] inspectorOverallTerm; 
   String[] termHistory;  //we'll use this to populate the submemes
   ArrayList subMemeList;    // An arraylist for all the particles
   
   //standard
   int localInterval;
   boolean isNews;
   int myColor;
   String secondaryName;
   
   //for the terms on the left
   int termTotal;
   float percentageCovered;
   boolean news_Lacking;
   String contributingTerms;
   
SecondaryNavigator () { 
     println("secondaryNav created");
     localInterval = 0;
     subMemeList = new ArrayList();
     contributingTerms = "";
     
}//end constructor  

void fillSubMemes()  {
  //println(myColor);//for testing only

 //arrays to hold the parts of the history
  String[] something;
  String[] individual;
   
  //now we're going to go through termHistory.  For each date, we're going to check...
  for (int j = 0; j < termHistory.length; j++) {  //for every date in the termHistory for this meme
      //print("TERM: " + termHistory[j] + " IS MADE OF ");  //overall terms
      
      if (termHistory[j] != null) { //if there's no term history in this date (if it's 0) don't bother
          something = split(termHistory[j], "-");
          
          for (int k = 0; k < something.length; k++) {  //for each item in the history of this date
            //print(something[k] + " AND ");
            String myTerm = trim(something[k]);  //history (only for places where there is something...some places it will be null.
            individual = split(myTerm, "=");
            //print(trim(individual[0])+" AND ");
            //println(trim(individual[1]));
            
            //Now we're ready
            String title = trim(individual[0]);
            int score = int(trim(individual[1]));
            boolean isMatched = false;
            int matchingTerm = 0;
            
            for (int m = 0; m < subMemeList.size(); m++) { 
                SecondaryTerm s = (SecondaryTerm) subMemeList.get(m);
                //println ("DOES " + s.termName + " EQUAL " + title);
                
                if (s.termName.equals(title)) {isMatched = true; matchingTerm = m; }
                else {
                //println("DOES NOT EQUAL"); 
              }
            }//end for
            //there's no match!  create a new one!
            if (isMatched == false) { 
              //println (title); 
              //subMemeList.add(new SecondaryTerm(title, score, isNews, "none", j)); 
              subMemeList.add(new SecondaryTerm(title, score, isNews, "none", j, localInterval, myColor)); //where j is the order
              contributingTerms =  contributingTerms + "\n" + title;
              //println("Adding new");
            }
            //there was a match!  Add to it!
            else {
              //println ("adding to existing");
              SecondaryTerm s = (SecondaryTerm) subMemeList.get(matchingTerm);
              //I don't need to add a new one, I just need to get the previous number from the last one of this date
              s.insertScore(score, j); //where j is the order
            }//end else
          } //end first for
      }//end if
  }//end second for
    
    //now let's turn those into real numbers!
    cleanup();
}//end fill submemes


//specifically to fill in news!  yay!
void addNews(String tempHeadline, String tempCategory, int tempScore, int tempOrder){
  //println("so make some news at " + tempOrder);
  //println(tempHeadline +" AND "+ tempScore+" AND "+ "true"+" AND "+ "none"+" AND "+ tempOrder+" AND "+ localInterval+" AND "+ myColor);                          
  subMemeList.add(new SecondaryTerm(tempHeadline, tempScore, true, tempCategory, tempOrder, localInterval, myColor)); //where j is the order
  //println(tempScore);
  //we must replace none with the cateogory
}


void cleanup(){
    //once we're done with all,
    //initialize the very bottom line
    int[] previousTermScores = new int[localInterval];  //this is to hold the previous scores and add it to the current one
    for (int i = 0; i < previousTermScores.length; i++) { previousTermScores[i] = inspectorOverallTermLast[i];}// this should be equal to overallInspectorTermLast
    boolean firstNonNews = true;
    int firstNonNewsNumber = 0;
    
    for (int m = 0; m < subMemeList.size(); m++) { 
                SecondaryTerm s = (SecondaryTerm) subMemeList.get(m);
                s.lastTermScores = previousTermScores;
                int largest = 0;
                
                for (int n = 0; n < localInterval; n++){ 
                  if (s.absoluteTermScores[n] > largest) {largest = s.absoluteTermScores[n]; s.maxDiff = n;}//so we know the fattest point
                  
                  s.termScores[n] = s.lastTermScores[n] + s.absoluteTermScores[n];
                  if ((!s.isNews) && (firstNonNews)) {firstNonNews = false; firstNonNewsNumber = m;} //if it's not news and this is the firstt ime we're seen that, 
                  //print (s.termScores[n] + " ");
              }//end second for
              //println();
              //now reset PTS so the next one can be used.  
              previousTermScores = s.termScores;
              inspectorOverallTerm = s.termScores; //when its done we'll be left with the last line on the graph since this wasn't reallly graphic

      //while we're here, find fattest point, use the numbers to update the previous ones with actual numbers so you can render lables.

      
      
    }//end for going through whole list
    
  //Now, we must set inspectorOverallTermLast equal to just the non-news items
  //println(firstNonNewsNumber);
  SecondaryTerm st = (SecondaryTerm) subMemeList.get(firstNonNewsNumber);
  inspectorOverallTermLast = st.lastTermScores;
  
}//end cleanup



void renderBottom(){
  
  fill(255, 150);
  rect(0,0,width, height);
  
  //println("render bottom");
  //stroke(255, 81, 0);
  stroke(100);
  strokeWeight(3);
  rectMode(CORNERS);
  fill(255, 220);
  rect(25, 100, 975, height-25);
  
  fill(100);
  noStroke();
  rect(800, 100, 975, height-25);
  
  rectMode(CORNER);
  fill(100);
  noStroke();
  rect (937, 60, 40, 40);
  stroke(255);
  line (946, 67, 968, 90);
  line (968, 67, 946, 90);
  
  //first lets have some dates and lines
      for (int i = 0; i < localInterval; i++) {   
        fill(0, 50);
        stroke(0, 50);
        strokeWeight(1);
        line(map(i, 0, localInterval-1, 70, 760), 200, map(i, 0, localInterval-1, 60, 760), height-50);
        
        if ((i == 0) || (i == localInterval-1)) {//now render some lables for each hour!  Just do the first or last
          rectMode(CORNER);
          textFont(font); 
          text(inspectorDate[i], map(i, 0, localInterval-1, 70, 760)-15, 170, 50, 200); 
        }//end if 
      }//end for
 
 //let's call a separate function to render all the important text on the right here - break this out once you have the numbers from the front
 
 //now let's render the meme name!  big!
    textFont(font_medium);
    fill(100); 
    text(secondaryName, 40, 140);
 //and the title
    textFont(font_italic);
    fill(100); 
    text("Anatomical Details", 40, 160);
    
  //and the title and details on the right
  //let's call this as a separate function
    memeDetails();
 
   //then, let's render the meme outline (eventually plus news outline)
   //stroke(150);
   strokeWeight(20);
   strokeJoin(ROUND);
   strokeCap(ROUND);


   //fill - fill it with the color of what it is on the other map.  Get this! It will look like:
   fill (map(myColor,0, 255,10, 255), map(myColor,0, 255,0, 255), map(myColor,0, 255,100, 255));
   stroke (map(myColor,0, 255,10, 255), map(myColor,0, 255,0, 255), map(myColor,0, 255,100, 255));
   
   beginShape();
   
           //now plot the upper line!
          curveVertex(760, inspectorOverallTermLast[localInterval-1]);  //repeat the point on the right
          for (int i = localInterval-1; i>=0; i--) {
            curveVertex(map (i, 0, localInterval-1, 70, 760),  inspectorOverallTermLast[i]); //repeat the last one
          }//end for
          curveVertex(70, inspectorOverallTermLast[0]);  //repeat the last one
          
           //plot the lower line!
          curveVertex(70,  inspectorOverallTerm[0]);
          for (int i = 0; i < localInterval; i++) {
            curveVertex(map (i, 0, localInterval-1, 70, 760),  inspectorOverallTerm[i]); //repeat the last one
          }
          curveVertex(750, inspectorOverallTerm[localInterval-1]);  //repeat the point on the right
         
      endShape();
      //now, render an extra line between the right-most items.  Why?  Because for some reason there's a bug.
      line(760, inspectorOverallTermLast[localInterval-1], 760, inspectorOverallTerm[localInterval-1]);
      
      //Render some Undernews!//
      
     //strokeWeight(0);
     noStroke();
     strokeJoin(ROUND);
     strokeCap(ROUND);
      
      //now we need to go through and render just the news as circles to get that background!
       for (int i = 0; i <= subMemeList.size()-1; i++) { 
          SecondaryTerm t = (SecondaryTerm) subMemeList.get(i);
          if(t.isNews){
           
            //int mySize = int(constrain(t.newsScore, 10, 500)/8);
            int mySize = constrain(int(t.absoluteTermScores[t.newsOrder]/1.05), 40, 1000);  //mess with 1.05
            int ypos = t.absoluteTermScores[t.newsOrder]/2+t.lastTermScores[t.newsOrder]-5; //mess with the 15
            ellipse(map(t.newsOrder, 0, localInterval-1, 70, 760), ypos, mySize, mySize);
          }//end if  
      }//end for
    
    //now call render top to get the anatomical details
    renderTop();

    
  }  //end render bottom
     
 
 void renderTop() {
   
   //first render the whooshes
   for (int i = 0; i <= subMemeList.size()-1; i++) { 
      //for (int i = 0; i <=4 ; i++) {  //for testing only
        SecondaryTerm t = (SecondaryTerm) subMemeList.get(i);
        if (!t.isNews) {t.render();}
    }//end for
    
    //then render the news!
      for (int i = 0; i <= subMemeList.size()-1; i++) { 
      //for (int i = 0; i <=4 ; i++) {  //for testing only
        SecondaryTerm t = (SecondaryTerm) subMemeList.get(i);
        if (t.isNews) {t.render();}
    }//end for
    
    //finally, render the meme lables!!!
    
    for (int i = 0; i <= subMemeList.size()-1; i++) { 
      //for (int i = 0; i <=4 ; i++) {  //for testing only
        SecondaryTerm t = (SecondaryTerm) subMemeList.get(i);
        if (!t.isNews) {t.memeLabelRender();}
    }//end for 
 }//end rendertop
     
     
 
 //Meme details
void memeDetails () {
    textFont(font_italic);
    fill(255, 100); 
    stroke(255, 100);
    strokeWeight(1);
    text("Taxonomy", 880, 160); 
    line(810, 165, 960, 165);
    
    //this whole section should be part of TermSystem, a function it calls just once.  tempInterest = interest, tempCoverage=coverage
    String tempInterest;
    int tempInterestScore;
    if (termTotal >700) { tempInterest = "High Interest"; tempInterestScore = 3;}
    else if (termTotal > 200) { tempInterest = "Medium Interest"; tempInterestScore = 2;}
    else { tempInterest = "Low Interest"; tempInterestScore = 1;}
    
    String tempCoverage;
    int tempCoverageScore;
    if (percentageCovered < 1) { tempCoverage = "Very Low Coverage"; tempCoverageScore = 1;}
    else if ((percentageCovered < 3)|| (news_Lacking)) { tempCoverage = "Low Coverage"; percentageCovered = 0; tempCoverageScore = 1;}
    else if (percentageCovered < 7) { tempCoverage = "Medium Coverage"; tempCoverageScore = 2;}
    else  {tempCoverage = "High Coverage"; tempCoverageScore = 3;} 
    
    String reccomendation = "";
    
    if (tempInterestScore > tempCoverageScore) {reccomendation = "Cover this meme. There is significant untapped interest here waiting for media coverage.";} //always cover when there's a gap
    else if (tempCoverageScore == 3) {reccomendation = "Don't bother covering this meme. It is already saturated with media coverage for this level of interest.";} //if it already has high coverage, don't cover
    
    else if ((tempCoverageScore == 2) && (tempInterestScore == 2)) {reccomendation = "Consider covering this meme. There may still be room for more media coverage despite the current levels.";}
    else if ((tempCoverageScore == 2) && (tempInterestScore == 1)) {reccomendation ="Don't bother covering this meme. It is already saturated with media coverage for this level of interest.";}
    
    else if ((tempCoverageScore == 1) && (tempInterestScore == 1)) {reccomendation ="Consider covering this meme. There may still be room for more media coverage despite the relatively low level of interest.";}
    else {reccomendation ="Missed something";}

   //now, render some titles
    textFont(font_bold);
    fill(255); 
    text("Interest", 810, 195);
    text("Media Coverage", 810, 235);
    text("Reccomendation", 810, 280);
    text("Related Topics", 810, 390);
    
    textFont(font);
    text(termTotal + " (" + tempInterest + ") ", 810, 210);
    text(int(percentageCovered) + "% (" + tempCoverage + ") ", 810, 250);
    text(reccomendation, 810, 285, 150, 1000);
    text(contributingTerms, 810, 380, 150, 1000);
}
     
     
     
 void initializeInspector() {
   
  //first, we're going to empty subMemeList
  for (int i = subMemeList.size()-1; i >= 0; i--) { subMemeList.remove(i);}
   
 //Now fill perlin values into inspectorOverallTermLast
  float xoff = 0.1;
  float a = 0.3;
  float inc = TWO_PI/15.0;
  //a temporary array to hold this information
  int[] tempSine = new int[inspectorDate.length];

    for(int i=0; i < inspectorDate.length; i=i+1) {
        xoff = xoff + 50;
        a = a + inc;
        int temp = int((noise(xoff))*130);
        tempSine[i] = temp+270; //mess with 270 to control where it starts
    }//end for
  inspectorOverallTermLast = tempSine;

}//calculate Sine    
     
     
 void clickTracker() {
   if ((mouseX > 937) && (mouseX < 937+40) && (mouseY > 60) && (mouseY < 100)) {
     println ("I don't want a meme anymore!");
     inspecting = false;
   }//end if
 }   //end clicktracker
     
 
     
     
}//end class
