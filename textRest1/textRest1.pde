Flock flock;
Animation butterfly;

void setup() {
  size(1366, 768);
  //fullScreen();

  frameRate(30);

  noFill();
  stroke(255);
  rectMode(CENTER);

  flock = new Flock();
  butterfly = new Animation("fly_", 40);
  // Add a set of boids into the system
  for (int i = 0; i < 41; i++) {
    color clr = color(random(50, 255), random(50, 255), random(50, 255), random(150, 255));
    flock.addBoid(new Boid(random(width), random(height), random(0.5, 1.4), clr));
  }
}

void draw() {
  background(0);
  flock.run();
  rect(width/2, height/2, width/2, height/2);
}

// Add a new boid into the System
//void mousePressed() {
//  color clr = color(random(255),random(255),random(255));
//  flock.addBoid(new Boid(mouseX, mouseY, random(0.2, 2), clr));
//}


/**
 * Flocking 
 * by Daniel Shiffman.  
 * 
 * An implementation of Craig Reynold's Boids program to simulate
 * the flocking behavior of birds. Each boid steers itself based on 
 * rules of avoidance, alignment, and coherence.
 * 
 * Click the mouse to add a new boid.
 */
