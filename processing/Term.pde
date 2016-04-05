class Term {
  
  int[] termScores; //the set scores as reported form the internet
  int[] lastTermScores; //the last term's plotted points
  String [] termHistory; //the last term's history for each item
  //int[] absoluteTermScores; //the actual datapoints to plot.  Might be helpfull

  //the Array of new items associated
  NewsItem[] newsArray;
  
  int selected; //this will be a timer to see if this item has been selected
  String termName;
  
  String all_terms;
  boolean isNews; //this will store if this is a real term or only here for a news reason
  String isNews_headline; //just for isNews items
  
  int myColor;//these are used to calculate the news/request overlap
  int termTotal;
  int newsTotal; 
  
  boolean news_Lacking;
  
  //these are to tell us where to start our pointer
  int xPointer, yPointer;
  int xBox, yBox;
  int xBox1, yBox1;
  int xText, yText;
  int xLink;
  int boxHeight;
  int boxWidth;
  float percentageCovered;


  //CONSTRUCTOR
  Term(int tempOrder, String tempName, int tempScore, int[] tempPreviousTermScores, String tempAll_Terms, String tempIs_news, String tempHas_news, String tempNewsHeadline, int tempNewsScore, String tempNewsCategory, String tempTermHistory) {
    
    ///////////Set up the universal constants!///////////
    termName= tempName;
    myColor = 255;
    isNews = boolean(tempIs_news);
    //println("IsNews: " + isNews);
    selected = 0;  //if there needs to be word baloon
    newsTotal = 1;
    termTotal = 1;
    percentageCovered = 0;
    news_Lacking = false;
    termHistory = new String[interval];
    
    isNews_headline = " ";
   
    ///////////Deal with the news//////////////
     //create and initialize the newsArray
      newsArray = new NewsItem[interval];
      for (int i = 0; i < newsArray.length; i++) {
        newsArray[i] = new NewsItem("none", "none", "none", 0);
      }//end for
      
      //Now insert the first one!
      //println("NEW ITEM");
      insertNews(boolean(tempHas_news), tempOrder, tempNewsHeadline, int(tempNewsScore), tempNewsCategory);


    /////////////new get that term info in there!////////////
    //create everything
    termScores= new int[interval];
    lastTermScores = new int[interval];  //I'll use this to plot the bottom of the curve, and calculate color
    //println(tempHas_news);
   
    //initialize the additive item
    for (int i = 0; i < termScores.length; i++) {
      termScores[i] =  tempPreviousTermScores[i];
      lastTermScores[i] = tempPreviousTermScores[i];
    }//end for
        
    //get the string of all the terms
    all_terms = tempAll_Terms.replace('-', '\n');
    //boxHeight = all_terms.length();
    if (!isNews) {boxWidth = termName.length();}
    else {boxWidth = isNews_headline.length();}
    //println (boxWidth);

    //now call a function to insert the first score (tempScore) in the proper (termOrder) slot of (termScore)
    if (isNews == false) {insertScore(tempScore, tempOrder, tempTermHistory);}
    else { insertScore(newsArray[tempOrder].getSize(), tempOrder, tempTermHistory); }
     
    //before we go, count the dashes in the history 
     int count = tempAll_Terms.split("-").length-1;
     if (maxCarnivorousNumber < count) {maxCarnivorousNumber = count; maxCarnivorous = termName;} 

  }//end constructor
  
  
  
void insertScore(int theScore, int theOrder, String theTermHistory) {
    //termScores[theOrder] = termScores[theOrder]+int(theScore*2.0);  //play with that 2.5!!!
    if (isNews ==false) {termScores[theOrder] = termScores[theOrder]+int(theScore*1.8) + newsArray[theOrder].getSize();}  //play with that 2.5!!!
    else {termScores[theOrder] = termScores[theOrder]+newsArray[theOrder].getSize()/7; }  //play with 5
    termHistory[theOrder] = theTermHistory;
}//end insertScore  


void insertNews(boolean hasNews, int theOrder, String tempHeadline, int tempScore, String tempCategory) {
    //calculate what the real score will be, based on the last score for that slot and put it in there
    
    //println ("HAS NEWS? " + hasNews);
    if (hasNews == true) { 
        newsArray[theOrder].newsExists = true;
        newsArray[theOrder].Headline = tempHeadline;
        newsArray[theOrder].Score = tempScore;
        newsArray[theOrder].Category = tempCategory;
        
        if (isNews) {isNews_headline = tempHeadline;} //so we can access it easily later
    }//end if
}//end insertNews
  
  
void render() {
  
  //////////////////////////////////////////////
  //////first, let's render just the whooshes///
  /////////////////////////////////////////////
  if (isNews == false) {  //if there's more here than just news
     //println("about to render something");
      //stroke(255);
      stroke(220);
      strokeWeight(1);
      
      fill (map(myColor,0, 255,10, 255), map(myColor,0, 255,0, 255), map(myColor,0, 255,100, 255));

      //except when it's selected
      if (selected >1) {fill(0);}
      
      beginShape();
      
           //plot the bottom!
          curveVertex(0,  termScores[0]);
          for (int i = 0; i < termScores.length; i++) {
            curveVertex(map (i, 0, termScores.length-1, 0, width),  termScores[i]); //repeat the last one
          }
          curveVertex(width, termScores[interval-1]);  //repeat the point on the right
         
         //now plot the top!
          curveVertex(width, lastTermScores[interval-1]);  //repeat the point on the right
          for (int i = lastTermScores.length-1; i>=0; i--) {
            curveVertex(map (i, 0, lastTermScores.length-1, 0, width),  lastTermScores[i]); //repeat the last one
          }//end for
          curveVertex(0, lastTermScores[0]);  //repeat the point on the right
     
      endShape();
      
  //////////////////////////////////////////////
  //////Now, render some news!!!!!!!!!!!!!!!///
  /////////////////////////////////////////////
  
  if(showNews){
    fill (0, myColor);
    stroke(255);
  
      for (int i = 0; i < newsArray.length; i++) {
          if (newsArray[i].newsExists==true) {
             newsArray[i].render(int(map(i, 0, interval-1, 0, width)), (termScores[i] - lastTermScores[i])/2 + lastTermScores[i]);
          }//end if
        }//end for 
    }//end if
  }//end if
}//end render


//A special render just for items that are only news
void isNewsRender() {
  
  //If isNews=true, let's render it separately!  We may want to separate this out and move this to the term system so it always happens first.
  for (int i = 0; i < newsArray.length; i++) {
      if (newsArray[i].newsExists==true) {
         newsArray[i].renderExtra(int(map(i, 0, interval-1, 0, width)), (termScores[i] - lastTermScores[i])/2 + lastTermScores[i]);
      }//end if
  }//end for 
}//isNewsRender



void topRender(){
  // check if you need to render a wordBaloon
  if (selected != 0) {
    //calculate the thickest part of the bubble
    fill(100);
    stroke(100);
    
    //make the line
    ellipse(xPointer, yPointer, 5, 5);
    strokeWeight(2);
    line(xPointer, yPointer, xBox, yBox);
    
    //make a rectangle somewhere on the screen where it will be visible
    strokeWeight(1);
    rectMode(CORNERS);
    fill(255, 220);
    rect(xBox, yBox, xBox1, yBox1);
    
    //first, get the text ready for the box.  SHould this all be moved to part of cleanup?  Probably.
    String tempInterest;
    String tempCoverage;
    
    if (termTotal >700) { tempInterest = "High Interest";}
    else if (termTotal > 200) { tempInterest = "Medium Interest";}
    else { tempInterest = "Low Interest";}
    
    if (percentageCovered < 1) { tempCoverage = "Very Low Media Coverage";}
    else if ((percentageCovered < 3)|| (news_Lacking)) { tempCoverage = "Low Media Coverage";}
    else if (percentageCovered < 7) { tempCoverage = "Medium Media Coverage";}
    else  {tempCoverage = "High Media Coverage";}
       
    if (!isNews) {
      //now make a secondary rectangle to click on!
      fill(150);
      noStroke();
      rect(xText+5, yText+60, xLink, yText+85);
      
      rectMode(CORNER);
      textFont(font); 
      fill(0);
      text("Term:", xText+20, yText+10);  
      text("Interest:", xText+9, yText+30); 
      text("Coverage:", xText+5, yText+50); 

      fill(100);
      text(termName, xText+70, yText, 400, 360); 
      text(tempInterest, xText+70, yText+20, 350, 300);
      text(tempCoverage, xText+70, yText+40, 350, 300);
   
      fill(255);
      textFont(font_bold); 
      text("Inspect This Meme!", xText+10, yText+68, 350, 300);
    //text(all_terms, xText+50, yText+50, 350, 300);
    }
    
    else {
      rectMode(CORNER);
      textFont(font); 
      fill(0);
      text("Unsuccessfull News Item", xText+10, yText+10);  
      text("headline:", xText+10, yText+30); 

      fill(100);
      text(isNews_headline, xText+70, yText+20, 400, 300);

    }//if it is just news
    
    //now give it a time out so it will go away eventually
    selected = (selected-1);
    selected = constrain(selected, 0, 1000);
    if (selected == 1) {somethingSelected = false;} //right before turning off, get the system ready to select something else if it hasn't already.
    
      //println (selected);
  }//end if
  
}//end top render

//for testing only  
void printContents() {
    //for testing, print out previousTermScores
     print (termName + ": ");
     for (int x = 0; x < termScores.length; x++) { print(termScores[x] + "-");}
     println("");
}//end Printcontents  



void cleanup() {
    //int runningTotal = 0;
    int maxDiff = 0;
   
    //Cycle through everything
     for (int i = 0; i<=lastTermScores.length-1; i++) {
       
       //first we want to get the total before we resize everything.  Otherwise stuff will be random
        termTotal = termTotal + (termScores[i] - lastTermScores[i]);
        
        //while we're here...make sure you're dealing with !isNews
        if ((termTotal > maxMemeNumber) && (!isNews)) {maxMemeNumber = termTotal; maxMeme = termName;} //somaday change this to longest, not biggest!!! 
       
       //Now, let's resize everything.  I'm unsure why I have to constrain these.
       termScores[i] = constrain(int(map(termScores[i], 0, 920, sineArray[i], height)),0, height-sineArray_bottom[i]);
       lastTermScores[i] = constrain(int(map(lastTermScores[i], 0, 920, sineArray[i], height)),0, height-sineArray_bottom[i]);
       
       //now get the new difference so we can place the box correctly
       int temp = termScores[i] - lastTermScores[i];  //this is the actual height at each hour (without news)
       //runningTotal = runningTotal + temp;
       
       if (temp >= maxDiff) {
         maxDiff = temp;
         yPointer = termScores[i] - temp/2;
         xPointer = int(map (i, 0, termScores.length-1, 0, width));
         
         //set the box height - depending on if this is news or not.
         int boxHeight;
         if (!isNews) {boxHeight = 150;}
         else {boxHeight = 100;}
         
         //xbox is either above, below, to the right, or to the left of xyPointer by 100 px, depending on the quadrant
         //also set the point at which to start text
         if (xPointer <= width/2) {xBox = xPointer+50; xBox1 = xPointer+150+constrain(boxWidth*6, 140, 1000); xText = xBox+5; xLink = xBox1-10;}   //if it's on the righ side
         else{ xBox = xPointer-50; xBox1 = xPointer-150-constrain(boxWidth*6, 140, 1000); xText = xBox1+5; xLink = xBox-10;} //if its on the left

         if (yPointer <= height/2) {yBox = yPointer+50; yBox1 = int(yPointer+boxHeight); yText = yBox + 6;}   //if it's on the top
         else{ yBox = yPointer-50; yBox1 = int(yPointer-boxHeight); yText = yBox1 +6;}  //if its on the bottom  
       }
       
     }//end for
      
      //one more thing to do - we have to make the newsTotal for each item! 
      for (int i = 0; i<=interval-1; i++) {
          if (newsArray[i].newsExists==true) { 
              newsTotal = newsTotal + newsArray[i].Score;
          }//end if
      }//end for
      
       float temp = 1;
       
        //before we do anything else, check the news score and update maxFertelized and maxFertelizedNumber
         if ((newsTotal > maxFertelizedNumber) && (!isNews)) {maxFertelizedNumber = newsTotal; maxFertelized = termName;} 
       
       //White: When news is lacking compared to intrest (news_lacking = true)
       if (termTotal >= newsTotal) {  
         temp = newsTotal*100/termTotal; 
         news_Lacking = true; 
         myColor = int(map(constrain(temp, 0, 5), 0, 5, 255, 140));
         percentageCovered = temp; 
        //println (temp); 
        
        //one more thing
        if (temp <= 2.0) {suggestion = suggestion + " \n" + termName;}  //now make it so this has five max
     }
     
     //when there's already too much news
       else { 
          temp = termTotal*100/newsTotal;  
          myColor = int(map(constrain(temp, 0, 15), 0, 15, 140, 0)); 
          percentageCovered = temp;  
   }
       //println(percentageCovered + " " + news_Lacking) ;
       //println("TERMS: " + termTotal + " COVERAGE: " + newsTotal + " SO: " + temp + "%" + "AND NEWS LACKING= " + news_Lacking);  

 }//end cleanup  
  
}

