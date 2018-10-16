//
// the tab for Miscellaneous 
//
// 
void checkGameOver () { 
  // check Game over  
  int countStopperVariable=countStopper();
  //
  if (counterWon==maxCounter) {    
    text ("You won. All saved.", width-190, 60);
    text ("Press r to play again.", width-190, 80);
    noFill();
    stroke(255, 0, 0);
    rect(width-195, 40, 180, 57);
  }
  else if (counterWon+counterDead==maxCounter) {    
    text ("Game over. "
      + counterWon
      + " saved, "
      + counterDead
      + " dead.", width-190, 60);
    text ("Press r to play again.", width-190, 80);
    noFill();
    stroke(255, 0, 0);
    rect(width-199, 40, 185, 60);
  }
  else if (counterWon
    +counterDead
    +countStopperVariable==maxCounter) {    
    text ("Game over. "
      + counterWon
      + " saved, "
      + counterDead
      + " dead, "
      + countStopperVariable
      + " Stopper.", width-240, 60);
    text ("Press r to play again.", width-240, 80);
    noFill();
    stroke(255, 0, 0);
    rect(width-250, 40, 245, 67);
  }
  else if ( counterDead>0 ) {
    text(counterDead + " dead.", width-100, 60);
  }

  // error check ------
  if (counterWon>maxCounter) {
    println("Error Game over 1");
  }
  if (counterDead>maxCounter) {
    println("Error Game over 2");
  }  
  if (counterWon+counterDead>maxCounter) {
    println("Error Game over 3");
  }  
  if ( counterWon+counterDead+countStopperVariable>maxCounter) {
    println("Error Game over 4");
  }
} // func 
// 
int countStopper() {
  int buffer=0;
  Lemming lem;
  // do all lemmings
  for (int i = lemmings.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so 
    // we have to cast the object coming out
    lem = lemmings.get(i);
    if (lem.isStopper && lem.alive) {
      buffer++;
    }
  }
  return buffer;
} // func 
//
// ===============================================

