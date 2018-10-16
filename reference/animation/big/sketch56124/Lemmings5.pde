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
void setup()
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
void draw()
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
void keyPressed () {
  if (key >= '0' && key <= '9') {
    // take the ascii and make it 0..9
    actionOnMouseClick = int(key)-48;
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

