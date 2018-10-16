//
// the tab for init
//
void fullInit() {
  // full init at Game start and 
  // at Game restart (with r).
  //
  // Lemmings 
  // Create an empty ArrayList
  lemmings = new ArrayList();
  counter=0; 
  counterDead=0;
  counterWon=0;
  //
  // explosions
  // Create an empty ArrayList
  missiles = new ArrayList<Explosion>();   
  //
  // Lines: 
  //Create an empty ArrayList
  lines = new ArrayList();
  final int lineWidth = 8;
  final boolean isHorizontal = true;
  final boolean isVertical = false;  
  final boolean isVisible1 = true;  
  //
  // A new line object is added to the ArrayList (by default to the end)
  //
  // Horizontal --- Plattforms --------------------------------------
  //
  lines.add(new Line(50, 250, 170, 250, lineWidth, 
  color (255, 2, 2), isHorizontal, isVisible1 ));

  lines.add(new Line(30, 180, 100, 180, lineWidth, 
  color (2, 2, 2), isHorizontal, isVisible1));  

  lines.add(new Line(210, 140, 290, 140, lineWidth, 
  color (3, 255, 2), isHorizontal, isVisible1));
  //

  lines.add(new Line(160, 380, 330, 380, lineWidth, 
  color (3, 155, 192), isHorizontal, isVisible1));

  lines.add(new Line(-50, 440, 395, 440, lineWidth, 
  color (3, 2, 255), isHorizontal, isVisible1));

  lines.add(new Line(400, 500, 495, 500, lineWidth, 
  color (3, 2, 255), isHorizontal, isVisible1));  
  // floor 
  lines.add(new Line(-50, height-20, width+20, height-18, lineWidth, 
  color (3, 2, 255), isHorizontal, isVisible1));

  // the stairs
  installStairwayUpwards   (   90, 180, 6 );
  installStairwayDownwards (  290, 140, 6 );  
  installStairwayUpwards   (  420, 220, 6 );
  installStairwayUpwards   (  540, 220, 6 );  
  installStairwayDownwards (  170, 230, 6 );  
  installStairwayDownwards (  -17, 270, 9 );  

  //   
  lines.add(new Line(240, 270, width-150, 270, lineWidth, 
  color (3, 2, 255), isHorizontal, isVisible1));  

  // vertical ---Walls ---------------------------------------
  // 
  lines.add(new Line(330, 340, 330, 400, lineWidth, 
  color (3, 2, 255), isVertical, isVisible1));  
  //
  /*lines.add(new Line(660, 140, 660, 200, lineWidth, 
   color (3, 222, 255), isVertical, isVisible1)); */
  //
  // Timers
  lastTime = millis();
  lastTimeText=0;
}

