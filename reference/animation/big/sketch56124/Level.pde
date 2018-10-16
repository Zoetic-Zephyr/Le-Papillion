

// the tab for the Level and related 

void showLevel() {
  fill(255, 2, 2);
  text("START", 20, 70);
  text(counter, 62, 55);
  noFill();
  stroke(255, 2, 2);
  strokeWeight(1);
  rect( 10, height-60, 50, 38);
  fill(255, 2, 2);
  text("GOAL", 20, height-40);  
  // show current action type
  text (actionString[actionOnMouseClick] + 
    " (change with 1,2,3...)", width-190, 20);  
  //
  // check Game over  
  checkGameOver ();
  // 
  // Time to display hooray (above the "Goal")
  if (displayHooray) {
    if (millis() < lastTimeText +  DISPLAY_TIME_TEXT) { 
      text("Hooray", 17, height-70 );
    } 
    else 
    {
      displayHooray=false;
    }
  } // if ... else ...
  //
  // lines show
  linesManagement () ;
  // explosions
  ExplosionManager();
  //
} // func
// ==================================================

