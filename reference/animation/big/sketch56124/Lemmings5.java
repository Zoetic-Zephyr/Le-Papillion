import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Lemmings5 extends PApplet {

//
// ************************************************
// the Main tab
// ************************************************
// 
// The good old DOS Lemmings. 
//
// with platform pattern by quarks (http://www.openprocessing.org/sketch/55500)
// with lemming sprite / sprite Code by Chinchbug (http://www.openprocessing.org/sketch/26391)
// 
// Use 1,2,3,4 to chose the action and 
// click on a lemming to perform it.
// r to restart
// n nuke 
//
// The keyPressed is in this tab, the Mouse 
// gets evaluated in class Lemming - see 
// tab Lemming. 
// For a stopper a invisible Line (Wall) is added.
// When the stopper explodes, the Line gets also 
// removed.
//
// arrayLists -------------------------------------
// use an arrayList to store a list of objects
// Platforms and Walls
ArrayList <Line> lines;
// Lemmings 
ArrayList <Lemming> lemmings; 
// for explosions (these are actually Shrapnels)
ArrayList <Explosion> missiles; 
//
// data -------------------------------------------
// the width of a lemming
final int lemmingWidth = 21;
// Lemming fall out - how fast  
final int DISPLAY_TIME = 1200; // 2000 ms = 2 seconds
int lastTime; // When the last lemming was first displayed
// 
// counting
int counterDead=0; // 
int counterWon=0;
int counter; // how much lemmings fell out already
final int maxCounter=10; // how much do we have in total
//
// Hooray is shown
boolean displayHooray=false;  // Hooray yes / no
final int DISPLAY_TIME_TEXT = 400; // how long the Hooray
int lastTimeText; // When the last Hooray was first displayed
//
// 
// actions for the mouse (keys 0,1,2,3...)
final int actionNone      = 0 ; 
final int actionStopper   = 1 ; 
final int actionExplode   = 2 ; 
final int actionParachute = 3 ; 
final int actionNuke      = 4 ; 
// the text for that; must be exact same values as above
final String actionString  [] = { 
  "None", "Stopper", "Explode", "Parachute", "Nuke", 
  "None", "None", "None", "None", "None"
};
int actionOnMouseClick = actionExplode;  // current action 

// images for Platforms and Lemmings 
PImage PlatformImage ;
PImage spriteSheet;

//
// ---------------------------------------------------------------
//
public void setup()
{
  // runs only once - init
  size(800, 600);
  fullInit();
  PlatformImage = loadImage ( "box.png" );
  if (PlatformImage.width < 2) {
    println("Image box.png to small : "
      +PlatformImage.width+ "px.");
  }
  spriteSheet = loadImage("sprSht1.png");
  //
} // func
//
public void draw()
{
  // runs again and again
  // delete screen
  //  background(255);
  background(0, 64, 0);
  //
  // show the level environment: the Start, the lines, the goal...
  showLevel();
  //
  // Time to drop next lemming at Start?
  startNewLemming () ;
  //
  // do all lemmings
  for (int i = lemmings.size()-1; i >= 0; i--) { 
    // do Lemming number i 
    lemmingManagement (i);
  } // for lemmings...
} // func
//
// ----------------------------------------------------
// 
public void keyPressed () {
  if (key >= '0' && key <= '9') {
    // take the ascii and make it 0..9
    actionOnMouseClick = PApplet.parseInt(key)-48;
  }
  else if (key == 'r') {
    fullInit();
  }
  else if (key == 'n') {
    nukeAll();
  }  
  else {
    // do nothing
  } // else
} // keyPressed
//
// ==================================================




// the tab for Explosions and related and the complete class

public void ExplosionManager() {
  // this is a new for loop. 
  // Actually for the Shrapnels.
  for (Explosion m: missiles) {
    m.decreaseLife(); // call the decrease life (for explosion)
    m.fly();          // call the "fly" method of the missile
    m.display();      // call the "display" method of the missile
  }
  //
  // remove dead ones (you need to have a conventional for-loop here) 
  for (int i=missiles.size()-1; i>=0; i--) {
    Explosion m = (Explosion) missiles.get(i);
    if (m.dead) {
      missiles.remove(i);
    }
  }
} // func

// ===============================================================

class Explosion {
  float startlocX, startlocY; // start pos 
  float x, y;          // current pos 
  float xvel, yvel;    // velocity
  float sizeMissile ;  // size for rect
  float life=20;       // how much lifes does it have
  float lifeDecrease;  // remove lifes
  boolean dead=false;  // is it alive? 
  boolean withLine;    // draw line? Explosion has none.
  //
  // contructor
  Explosion(
  float _startlocX, float _startlocY, 
  float _xvel, float _yvel, 
  float _size, float _lifeDecrease, 
  boolean _withLine) 
  {
    startlocX = _startlocX;
    startlocY = _startlocY;    
    x = startlocX;
    y = _startlocY;
    sizeMissile = _size;
    lifeDecrease=_lifeDecrease;
    xvel = _xvel;
    yvel = _yvel;
    withLine=_withLine;
  }  // contructor
  //
  public void display() {
    //stroke(255, 2, 2);
    fill(255, 2, 2);
    noStroke();
    if (withLine) {
      line(startlocX, startlocY, x, y);
    }
    sizeMissile-=.07f;
    rect(x, y, sizeMissile, sizeMissile);
  } // method
  //
  public void fly() {
    x += xvel;
    y += yvel;
  } // method
  //
  public void decreaseLife() {
    life-=lifeDecrease;
    if (life<=0 || sizeMissile<=0) {
      dead=true;
    }
  } // method
  //
} // class
//
// ======================================================================

//
// the tab for init
//
public void fullInit() {
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



// the tab for Lemmings and related and the complete class
//
public void startNewLemming () {
  // Time to drop next lemming at Start?
  if (millis() - lastTime >= DISPLAY_TIME) {
    // but only so many
    if (counter < maxCounter) {
      lemmings.add ( new Lemming(30, 78, 1.8f, 1.2f, lemmingWidth, 
      color(2, 2, 255)));  
      counter++;
      lastTime = millis();
    }
  }
} // func 
//
public void lemmingManagement (int i) {
  // do all for the Lemming number i (gets called from a loop)
  //
  // An ArrayList doesn't know what it is storing so 
  // we have to cast the object coming out
  Lemming lem = (Lemming) lemmings.get(i);    
  // Update the position of the Lemming
  lem.move();
  //
  // check goal 
  lem.withinGoal();
  //
  // Test to see if the Lemming exceeds the boundaries of the screen
  lem.reflectionOnBoundariesOfTheScreen ();
  //
  // test stairways
  lem.checkOnStairways ();
  //if (!lem.checkOnStairways ()) {
  //
  // Test lines / platforms
  lem.reflectionOnLinesHorizontal ();
  // }
  // Test lines / Walls
  lem.reflectionOnLinesVertical ();  
  //
  // mouse?
  lem.mouseOnLemClicked ();
  //
  // Draw the Lemming
  lem.display();
  //
  if (!lem.alive) {
    lemmings.remove(i);
  }
} // func 
//
public void nukeAll () {
  for (int i = lemmings.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so 
    // we have to cast the object coming out
    Lemming lem = (Lemming) lemmings.get(i);
    lem.alive=false;
    counterDead++;
    lem.explode();
  }
}

// ========================================================

// Lemmings class
class Lemming {
  //
  // this is the Lemming
  //
  float size1 = 3;     // Width of the Lemming
  float xpos, ypos;    // Starting position of Lemming
  float xspeed = 2.8f;  // Speed of the Lemming
  float yspeed = 2.2f;  // Speed of the Lemming
  int xdirection = 0;  // Left or Right (-1,0 or 1)
  int ydirection = 0;  // Top to Bottom
  int oldxdirection = 1;
  int myColor;       // color
  boolean alive = true;
  // when he starts falling we make a note of his 
  // ypos:
  float fallStartY;   
  boolean hasParachute=false;   
  // stopper
  boolean isStopper=false; // is he a stopper?
  Line myline; // his line when he is a stopper

  PImage cell[];
  int cnt = 0, step = 0, dir = 0; 
  int stepAdd=1;
  //
  //
  // constructor 
  Lemming(
  float tempX, float tempY, 
  float tempX2, float tempY2, 
  float tempW, int tempmyColor1) {
    //
    // Set the starting position of the Lemming
    xpos       = tempX;
    ypos       = tempY;
    xspeed     = tempX2;
    yspeed     = tempY2;   
    size1      = tempW;
    myColor    = tempmyColor1;
    fallStartY = ypos;
    dir=3;
    cell = new PImage[12];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 3; x++) {
        cell[y*3+x] = spriteSheet.get(x*24, y*48, 24, 48);
      }
    } // for
  } // constructor 
  //
  public void display() {
    // Display the lemming 
    if (alive) {
      fill(myColor);
      noStroke();
      // ellipse(xpos+size1/2, ypos+size1/2, size1, size1);
      //
      stepAdd=1;
      if (isStopper) {
        stepAdd=0;
        dir = 0;
      } 
      else if (ydirection!=0 && xdirection==0) {
        // is falling
        stepAdd=0;
      }
      if (!isStopper) {      
        if (xdirection==1) { 
          dir = 3;
        } 
        else if (xdirection==-1) { 
          dir = 2;
        } 
        else if (xdirection==0) { 
          //dir = 0;
        } 
        else { 
          println ("Error 133 in tab Lemming");
        }
      }
      // to make movement slower: cnt
      // by Chinchbug (http://www.openprocessing.org/sketch/26391)
      if (cnt++ > 7) {
        cnt = 0;
        step+=stepAdd;
        if (step >= 4) 
          step = 0;
      }
      // by Chinchbug (http://www.openprocessing.org/sketch/26391)
      int idx = dir*3 + (step == 3 ? 1 : step);
      // println (idx+"  " + dir+ "   " + xdirection);
      image(cell[idx], xpos, ypos-15);
      //
      if (hasParachute) {
        // show parachute as closed bag
        if ((xdirection==1) || (xdirection==0 && oldxdirection==1)) {
          // on left side 
          fill(12, 244, 12);
          rect (xpos+0, ypos-0, 7, 12);
        }       
        else {
          // on the right side
          fill(12, 244, 12);
          rect (xpos+14, ypos-0, 7, 12);
        }
      }
    }
    // if falling
    if (ydirection != 0 && hasParachute && ypos-fallStartY>40) {
      // show parachute 
      fill(222, 31, 12);
      arc(xpos+9, ypos, 50, 50, PI+.6f, TWO_PI-.6f);
    }
  } // func
  //
  public void move() {
    if (alive) {
      xpos +=  xspeed * xdirection ;
      ypos +=  yspeed * ydirection ;
    }
  } // func 
  //
  public void reflectionOnLinesHorizontal () {
    // Test to see if the lemming walks on a line / platform
    // or falls.
    // These are only the Horizontal Lines.
    boolean done=false;
    for (int i=0; i < lines.size(); i++) {
      // An ArrayList doesn't know what it is storing so we have to
      // cast the object coming out
      Line myline = (Line) lines.get(i);
      // if line is platform? 
      if ( myline.isHorizontal ) {
        // if xpos on platform 
        if (xpos > myline.x-size1 && xpos < myline.x2) {
          // it is over the platform (not under it)
          if (ypos <= myline.y-size1) {
            // it is very near at the platform
            if ((myline.y-size1-ypos) < 8.6f) {
              // he is falling
              if (xdirection==0) {
                // restore old walking direction
                xdirection = oldxdirection; 
                // when falling long - die
                if (ypos-fallStartY>150) {
                  if (!hasParachute) {
                    explode();
                    alive=false;
                    counterDead++;  // die
                  }
                }
              }
              // stop falling
              ydirection = 0; // walk
              done=true;
            }
          }
          else {
            if (((ypos-myline.y))<8.6f) {
              // ydirection = abs(ydirection);
            }
          }
        }
      }
    } 
    //
    // found no line means: fall!
    if (!done) {
      // fall
      if (xdirection!=0) {
        oldxdirection = xdirection;
        fallStartY=ypos;
      }
      xdirection = 0; // fall
      ydirection = 1;
    }
  } // func
  //
  public boolean checkOnStairways () {
    // Test to see if the lemming goes on to a Stairway. 
    // These are only the Horizontal Lines that are also stairs.
    boolean done=false;
    for (int i=0; i < lines.size(); i++) {
      // An ArrayList doesn't know what it is storing so we have to
      // cast the object coming out
      Line myline = (Line) lines.get(i);
      // if line is platform and stair 
      if ( myline.isHorizontal && myline.stairway ) {
        // if xpos is on stair
        if ((xpos > myline.x) && (xpos < myline.x2)) {
          // it is over the platform (not under it)
          if (ypos+26 > myline.y && ypos < myline.y) {
            // it is very near at the platform
            if ((myline.y-size1-ypos) < 8.86f) {
              ypos-=9.0f;
              done= true;
            }
          }
        }
      }
    } // for 
    //
    return done;
  } // func
  //
  //
  public void reflectionOnLinesVertical () {
    // Test to see if the lemming walks against a wall
    boolean done=false;
    for (int i=0; i < lines.size(); i++) {
      // An ArrayList doesn't know what it is storing so we have to
      // cast the object coming out
      Line myline = (Line) lines.get(i);
      // if it is a wall:
      if ( !myline.isHorizontal ) {
        // if lem is at same height as wall (y check)
        if (ypos > myline.y && ypos < myline.y2) {
          if (xpos <= myline.x-size1) {
            if ((myline.x-size1-xpos)<8.6f) {
              xdirection = -1*abs(xdirection); // walk right now
              done=true;
            }
          }
          else {
            if (((xpos-myline.x))<8.6f) {
              xdirection = abs (xdirection); // walk left now
            }
          }
        }
      }
    } // for
  } // func  
  //
  public void withinGoal () {
    // check Goal
    // make this a class some time because it has 
    // a display and a withinGoal function with the
    // same position...
    if (alive) {
      if (xpos > 10 && ypos > height-50 && 
        xpos < 10 + 50 && ypos < height-50 + 38) {
        alive=false;
        displayHooray=true;
        lastTimeText=millis();
        counterWon++;
      } // if
    } // if
  } // func 
  //
  public void reflectionOnBoundariesOfTheScreen () {
    // Test to see if the lemming exceeds the boundaries of the screen
    // If it does, reverse its direction by multiplying abs by -1 or 
    // take abs
    if (xpos > width-size1) {
      xdirection = -1*abs(xdirection);
    }
    if (xpos < 0) {
      xdirection = abs(xdirection);
    }
  } // method
  //
  public void mouseOnLemClicked () {
    // If the lem is clicked, impose 
    // the current action "actionOnMouseClick" 
    // on the poor guy 
    if (mousePressed && 
      mouseX > xpos-30 && mouseX < xpos+30 && 
      mouseY > ypos-30 && mouseY < ypos+30  ) {
      switch (actionOnMouseClick) {
      case actionNone:
        // do nothing 
        break; 
      case actionStopper:
        oldxdirection=0;
        xdirection=0;
        // make sure he is not a stopper already
        if (!isStopper) {
          // add Wall
          lines.add(new Line(xpos, ypos-30, xpos, ypos+40, 8, 
          color (0, 0, 0), false, false));  
          myline = (Line) lines.get(lines.size()-1);
          isStopper=true;
        }
        break;
      case actionExplode:
        // let him explode
        explode();     // explosion
        alive=false;   // dead 
        counterDead++; // count 
        // if he was a stopper, remove 
        // its invisible Wall!
        if (isStopper) {
          myline.dead=true; // remove wall
        }
        break;
      case actionParachute:
        hasParachute=true; 
        yspeed = .46f;
        break;
      case actionNuke:
        // nuke: no matter who is clicked,
        // all get nuked
        nukeAll();
        break;
      default:
        // unknown action
        println("Error 338");
        break;
      }// switch
    } // if
  } // method
  //
  public void explode () {
    // explode!
    int maxMissiles= PApplet.parseInt(random(4, 222));
    for (int i=0; i<maxMissiles; i+=1) {    
      // this is where explode missile/shrapnel object is created 
      // and added to the missiles arrayList.
      // It is small (4) and life decrease is .72 (how fast it dies), 
      // no Line (false).
      missiles.add( new Explosion(
      random(xpos-3, xpos+3), random(ypos+9, ypos+12), 
      random(-1.3f, 1.3f), random(-2.7f, .6f), 
      4, .72f, false)); //
    }
  } // method
} // class  

// =========================================================================



// the tab for the Level and related 

public void showLevel() {
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



// The tab for the Lines (Platforms/Walls) and related 
// and the complete class.
//
// For init of lines see tab Misc.

//
public void linesManagement () {
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
public void installStairwayUpwards (float startX, float startY, int numOfStairs) {
  int lineWidth=8;
  for (int i=0;i<numOfStairs;i++) {
    lines.add(new Line(startX+i*18, startY-i*8, 
    startX+i*20+20, startY-i*8, lineWidth, 
    color (3, 2, 255), true, true));
    ((Line) lines.get(lines.size()-1)).stairway=true;
  }
}
//
public void installStairwayDownwards (float startX, float startY, int numOfStairs) {
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
  int myColor;
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
  int tempmyColor1, 
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
  public void display() {
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

//
// the tab for Miscellaneous 
//
// 
public void checkGameOver () { 
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
public int countStopper() {
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

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "Lemmings5" });
  }
}
