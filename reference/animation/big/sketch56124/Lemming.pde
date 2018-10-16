

// the tab for Lemmings and related and the complete class
//
void startNewLemming () {
  // Time to drop next lemming at Start?
  if (millis() - lastTime >= DISPLAY_TIME) {
    // but only so many
    if (counter < maxCounter) {
      lemmings.add ( new Lemming(30, 78, 1.8, 1.2, lemmingWidth, 
      color(2, 2, 255)));  
      counter++;
      lastTime = millis();
    }
  }
} // func 
//
void lemmingManagement (int i) {
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
void nukeAll () {
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
  float xspeed = 2.8;  // Speed of the Lemming
  float yspeed = 2.2;  // Speed of the Lemming
  int xdirection = 0;  // Left or Right (-1,0 or 1)
  int ydirection = 0;  // Top to Bottom
  int oldxdirection = 1;
  color myColor;       // color
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
  float tempW, color tempmyColor1) {
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
  void display() {
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
      arc(xpos+9, ypos, 50, 50, PI+.6, TWO_PI-.6);
    }
  } // func
  //
  void move() {
    if (alive) {
      xpos +=  xspeed * xdirection ;
      ypos +=  yspeed * ydirection ;
    }
  } // func 
  //
  void reflectionOnLinesHorizontal () {
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
            if ((myline.y-size1-ypos) < 8.6) {
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
            if (((ypos-myline.y))<8.6) {
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
  boolean checkOnStairways () {
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
            if ((myline.y-size1-ypos) < 8.86) {
              ypos-=9.0;
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
  void reflectionOnLinesVertical () {
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
            if ((myline.x-size1-xpos)<8.6) {
              xdirection = -1*abs(xdirection); // walk right now
              done=true;
            }
          }
          else {
            if (((xpos-myline.x))<8.6) {
              xdirection = abs (xdirection); // walk left now
            }
          }
        }
      }
    } // for
  } // func  
  //
  void withinGoal () {
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
  void reflectionOnBoundariesOfTheScreen () {
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
  void mouseOnLemClicked () {
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
        yspeed = .46;
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
  void explode () {
    // explode!
    int maxMissiles= int(random(4, 222));
    for (int i=0; i<maxMissiles; i+=1) {    
      // this is where explode missile/shrapnel object is created 
      // and added to the missiles arrayList.
      // It is small (4) and life decrease is .72 (how fast it dies), 
      // no Line (false).
      missiles.add( new Explosion(
      random(xpos-3, xpos+3), random(ypos+9, ypos+12), 
      random(-1.3, 1.3), random(-2.7, .6), 
      4, .72, false)); //
    }
  } // method
} // class  

// =========================================================================

