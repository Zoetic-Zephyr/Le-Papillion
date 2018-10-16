

// The tab for the Lines (Platforms/Walls) and related 
// and the complete class.
//
// For init of lines see tab Misc.

//
void linesManagement () {
  // delete and draw lines 
  // remove lines 
  for (int i = lines.size()-1; i>0 ;i--) {
    // An ArrayList doesn't know what it is 
    // storing so we have to cast the object coming out
    Line myline = (Line) lines.get(i);
    if (myline.dead) {
      lines.remove(i);
    }
  }  
  // display all lines
  for (int i=0; i < lines.size(); i++) {
    // An ArrayList doesn't know what it is storing so 
    // we have to cast the object coming out
    Line myline = (Line) lines.get(i);
    myline.display();
  }
} // func
//
void installStairwayUpwards (float startX, float startY, int numOfStairs) {
  int lineWidth=8;
  for (int i=0;i<numOfStairs;i++) {
    lines.add(new Line(startX+i*18, startY-i*8, 
    startX+i*20+20, startY-i*8, lineWidth, 
    color (3, 2, 255), true, true));
    ((Line) lines.get(lines.size()-1)).stairway=true;
  }
}
//
void installStairwayDownwards (float startX, float startY, int numOfStairs) {
  int lineWidth=8;
  for (int i=0;i<numOfStairs;i++) {
    lines.add(new Line(startX+i*18, startY+i*8, 
    startX+i*20+20, startY+i*8, lineWidth, 
    color (3, 2, 255), true, true));
    ((Line) lines.get(lines.size()-1)).stairway=true;
  }
}

// ===================================================

// Simple Line class
class Line {
  float x;
  float y;
  float x2, y2;
  color myColor;
  float w;  // the width / strokeWeight 
  boolean isHorizontal = true;  
  boolean visible = true;  
  boolean dead = false; 
  boolean stairway = false; 
  //
  // constructor 
  Line(
  float tempX, float tempY, 
  float tempX2, float tempY2, 
  float tempW, 
  color tempmyColor1, 
  boolean tempisHorizontal, 
  boolean tempVisible) {
    //
    x  = tempX;
    y  = tempY;
    x2 = tempX2;
    y2 = tempY2;   
    w  = tempW;
    myColor      = tempmyColor1;
    isHorizontal = tempisHorizontal;
    visible      = tempVisible;
  }
  //
  void display() {
    // Display the line
    stroke(myColor);
    strokeWeight(w);
    noFill();
    /* if (stairway) {
     stroke(0, 255, 255);
     } */
    if (visible) {
      //line (x, y, x2, y2);      
      if (isHorizontal) { 
        for (int i = 0 ; i < (x2-x) / PlatformImage.width; i++) {
          image (PlatformImage, x+i*20, y);
        } // for
      } 
      else 
      {
        for (int i = 0 ; i < (y2-y) / PlatformImage.height; i++) {
          image (PlatformImage, x, y + (i*20) );
        } // for
      } // if else
    }
  }
} 
//
// =====================================================================

