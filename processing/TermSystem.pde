  //for some reason these have to be super global
  int[] sineArray; 
  int[] sineArray_bottom;

class TermSystem {

  ArrayList terms;    // An arraylist for all the particles

  TermSystem() {
    
    //before anything else, calculate the array of sine values to start at
    sineArray = new int[interval]; 
    sineArray_bottom = new int[interval]; 
    calculateSine();
    
    //now let's get this show on the road.  Start by initializing the hell out of everything
    println("Making a term system");
    terms = new ArrayList();              // Initialize the arraylist that will hold all term objects
    
    int[] previousTermScores = new int[interval];  //this is to hold the previous scores and add it to the current one
    for (int i = 0; i < previousTermScores.length; i++) { previousTermScores[i] = 0;}//initialize it with 0's.  
    String currentName = null; //this will hold the terms we are currently on
  
    //Go through each item and, if this is a new term, add it.  If it's not, add the rank to its info  
    for (int i = 0; i < name.length; i++) {  //for every item in the doner list
   
        if ((name[i].equals(currentName)) == false) {  //this is the first time we've seen this term
              //println ("New item with name " + name[i]);
               //get the last item's score array to use in the new Term
              if(terms.size() >= 1){
                Term t = (Term) terms.get(terms.size()-1);
                arraycopy(t.termScores, previousTermScores);  
                t.cleanup(); //clean the last one, since it means we must be done with that one.  We must find a way to do this to the last one!
              }//end second if
              
              //create the new item.  Let's add in some news information now
              //if (boolean(is_news[i]) == false) {
                terms.add(new Term(int(order[i]), name[i], int(score[i]), previousTermScores, all_terms[i], is_news[i], has_news[i], news_headline[i], int(news_score[i]), news_category[i], term_history[i]));
                currentName =  name[i];   //save the name so we know if this is a new term or a continuation
              //}//end test if
      
    }//end if it's the first one
        
        else { //it's the second or third or fourthone!
              
              //println ("Duplicate item, "+  name[i]);
              Term t = (Term) terms.get(terms.size()-1);
              
              //println("OLD ITEM");
              t.insertNews(boolean(has_news[i]), int(order[i]), news_headline[i], int(news_score[i]), news_category[i]);
              
              t.insertScore(int(score[i]), int(order[i]), term_history[i]);
              
        }//end else
     }//end for
     
     //You're done!  Now you must "clean up" the very last item in that list, becuase it never got a chance to!
     Term t = (Term) terms.get(terms.size()-1);
     t.cleanup();
     
  }//end constructor
  
  
void display () {

  //first, let's render some underNews!  that is to say, if (isNews == true) {  
   if (showNews) {
        for (int i = 0; i <= terms.size()-1; i++) { 
          //for (int i = 0; i <=4 ; i++) {  //for testing only
            Term t = (Term) terms.get(i);
            if (t.isNews == true) {t.isNewsRender();}
          
        }//end for
    }//end if
  
    //Now let's render the terms!
    for (int i = 0; i <= terms.size()-1; i++) { 
      //for (int i = 0; i <=4 ; i++) {  //for testing only
        Term t = (Term) terms.get(i);
        if (t.isNews == false) {t.render();}
       //t.newsRender
    }//end for
    
    //now go through and display any stuff that should be rendered on top
     for (int i = 0; i <= terms.size()-1; i++) { 
      //for (int i = 0; i <=50 ; i++) {  //for testing only
        Term t = (Term) terms.get(i);
        //t.printContents();
        t.topRender();
    }//end for
    
}//end display  
  
void highlight() {

  float mappedNo = map(mouseX, 0, width, 0, interval-1);
  int floorNo =floor(mappedNo);
  int ceilNo =ceil(mappedNo);
  //println(mouseX + " MAPS TO " +  mappedNo + " WHICH IS BETWEEN " + floorNo + " AND " + ceilNo);
  
  //Calculate out the X values for floor and ceil
  int floorX = int(map (floorNo, 0, interval-1, 0, width));
  int ceilX = int(map (ceilNo, 0, interval-1, 0, width));
  
  //Itterate through the arraylist 
  for (int i = 0; i <= terms.size()-1; i++) { 
      //for (int i = 0; i <=50 ; i++) {  //for testing only
       Term t = (Term) terms.get(i);
       
       //highY
       int slope = (t.termScores[ceilNo] - t.termScores[floorNo])/(ceilX-floorX);
       int yIntersect = t.termScores[floorNo] - (slope*floorX);
       int highY = (slope*mouseX) + yIntersect;
       
       //LowY
       int slope1 = (t.lastTermScores[ceilNo] - t.lastTermScores[floorNo])/(ceilX-floorX);
       int yIntersect1 = t.lastTermScores[floorNo] - (slope1*floorX);
       int lowY = (slope1*mouseX) + yIntersect1;
       
       if ((mouseY <= highY) && (mouseY >= lowY)) {
           //println (t.percentageCovered + " " + t.news_Lacking + " " + t.myColor);
           //println (t.termName);
           //println (mouseX + " top: " + highY + " AND bottom: " + lowY);
           
             //note - if it finds something, check if somethingSelected.  If it isyes, go to currentSelected and turn its counter to 0
            if (somethingSelected) {Term old = (Term) terms.get(currentSelected); old.selected = 0; } 
            currentSelected = i;
            somethingSelected = true;  
            
           //finally set the timer on t
            t.selected = 20;  //which is the whole point of this function
       }//end if
    }//end for
}  //end hilight




//this is a function that's called whenever there's a click and somethingSelected.  
//It checks if someone wants to inspect a meme.  If not, it calls highlight() to see if someone wants to highlight a meme
void inspect() {
 
  Term selected = (Term) terms.get(currentSelected);
  if ((mouseX > selected.xText+5) && (mouseX < selected.xLink) && (mouseY > selected.yText+60) && (mouseY < selected.yText+85)) {
     println ("i want meme!");
     inspecting = true;
  
     //make secondary navigator's dates equal to this.  
      int[] tempScores = new int[interval];
      int startNumber = 0;
      int stopNumber = interval-1;
      boolean alreadyStarted = false;
      boolean alreadyFinished = false;
      
      //first get the actual numbers
      for (int i = 0; i < interval; i++) {
         tempScores[i] = selected.termScores[i]-selected.lastTermScores[i];
         //println (tempScores[i]);
      }
      
      //now get the start and stop
      for (int i = 0; i < interval; i++) {
         if ((tempScores[i] == 0) && (alreadyStarted == false)) {startNumber = i; }
         //if (tempScores[i] == 0) {startNumber = i+1; }
         else {alreadyStarted = true;}
         //println (i + " " + tempScores[i] + " STARTED AT " + startNumber);
      }
    
      for (int x = interval-1; x >= 0; x--) {
         if ((tempScores[x] == 0) && (alreadyFinished == false)) {stopNumber = x; }
         else {alreadyFinished = true;}
      }
      //you've got the information, now use it to make the bottom and top! 
      secondaryNavBar.inspectorDate = subset(date, startNumber, stopNumber-startNumber+1);
      secondaryNavBar.initializeInspector(); //Create the bottom array, get arraylist ready

      //now let's set some more variables!
      secondaryNavBar.termHistory = subset(selected.termHistory, startNumber, stopNumber-startNumber+1);
      secondaryNavBar.localInterval = secondaryNavBar.inspectorDate.length; //set the interval there.  it will be usefull.
      secondaryNavBar.isNews = selected.isNews;
      secondaryNavBar.myColor = selected.myColor;
      secondaryNavBar.secondaryName = selected.termName;
      secondaryNavBar.termTotal= selected.termTotal;
      secondaryNavBar.percentageCovered= selected.percentageCovered;
      secondaryNavBar.news_Lacking=selected.news_Lacking;
      secondaryNavBar.contributingTerms = ""; //make this 0 again
      
      //Now here's where we want to bring in the news!  
      //iterate through those numbers of Selected.
       int itterationCounter = 0; //simple way of keeping track what cell we're on
       for (int z = startNumber; z <= stopNumber; z++) {
          if (selected.newsArray[z].newsExists == true){
            //println(itterationCounter + " has news");
            secondaryNavBar.addNews(selected.newsArray[z].Headline, selected.newsArray[z].Category, selected.newsArray[z].Score, itterationCounter);//get the order
          }//end if
          itterationCounter++;
        }//end for
      
      //Allright, now call a function in secondaryNavBar that populates the submemes from TermHistory
      secondaryNavBar.fillSubMemes();
 
      //for testing
      //for (int z = 0; z < secondaryNavBar.localInterval; z++) {
        //print(secondaryNavBar.inspectorOverallTerm[z] + " " );
        //println (z);
      //}
  }//end if
  
  else {termSystem.highlight();}  //they didn't want a meme.
}//end inspect




void calculateSine() {
 //fill values into sineArray
  float xoff = 0.1;
  float a = 0.3;
  float inc = TWO_PI/15.0;

    for(int i=0; i < sineArray.length; i=i+1) {
        xoff = xoff + 50;
        a = a + inc;
        int temp = int((noise(xoff))*125);
        //temp =temp + int(100+sin(a)*50.0);
        sineArray[i] = constrain(temp, 50, height)+40; //play with the 100
  }//end for

  
}//calculate Sine


}//end object




