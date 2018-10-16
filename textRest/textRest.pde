//Flocking by Daniel Shiffman. 

//An implementation of Craig Reynold's Boids program to simulate the flocking behavior of birds. Each boid steers itself based on rules of avoidance, alignment, and coherence. 

//Click the mouse to add a new boid.


Flock flock;
Animation butterfly;

int textX = 1280/2;
int text1W = 360;
int text1H = 65;
int text1Y = 100;
int text2W = 210;
int text2H = 65;
int text2Y = 190;
int text3W = 225;
int text3H = 65;
int text3Y = 280;
PImage borderMask;


void setup() {
  float offset = 0.1;
  borderMask = loadImage("borderMask.png");
  //fullScreen();
  size(1280, 720);
  flock = new Flock();
  butterfly = new Animation("flyw_", 40);
  // Add an initial set of boids into the system
  //
  for (int i = 0; i < 41; i++) {
    color clr = color(random(255), random(255), random(255), random(150, 255));
    if (random(1)<0.25) {
      flock.addBoid(new Boid(random(-width*(offset), 0), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.5) {
      flock.addBoid(new Boid(random(width, width*(1+offset)), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.75) {
      flock.addBoid(new Boid(random(0, width), random(-height*(offset), 0), random(0.5, 1.5), clr));
    } else {
      flock.addBoid(new Boid(random(0, width), random(height, height*(1+offset)), random(0.5, 1.5), clr));
    }
  }
}

void draw() {
  background(0);
  pushMatrix();
  pushStyle();
  imageMode(CORNER);
  image(borderMask, 0, 0);
  popStyle();
  popMatrix();
  //noFill();
  //stroke(100);
  //rectMode(CENTER);
  //rect(textX, text1Y, text1W, text1H);
  //rect(textX, text2Y, text2W, text2H);
  //rect(textX, text3Y, text3W, text3H);

  flock.run();
}
