//Flocking by Daniel Shiffman. 
//An implementation of Craig Reynold's Boids program to simulate the flocking behavior of birds. Each boid steers itself based on rules of avoidance, alignment, and coherence. 

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import controlP5.*;


ControlP5 cp5;

Kinect2 kinect2;
PImage depthImg;

int thresholdMin = 0;
int thresholdMax = 4499;

float rectW;
float rectH;

Flock flock;
Animation butterfly;

float textWidth = 512;
float textHeight = 424;


void setup() {
  //fullScreen();
  size(1280, 1060);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  // Blank image
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);

  // add gui
  int sliderW = 100;
  int sliderH = 20;
  cp5 = new ControlP5( this );
  cp5.addSlider("thresholdMin")
    .setPosition(10, 40)
    .setSize(sliderW, sliderH)
    .setRange(1, 4499)
    //.setValue(720)
    // full range in dorm
    .setValue(540)
    ;
  cp5.addSlider("thresholdMax")
    .setPosition(10, 70)
    .setSize(sliderW, sliderH)
    .setRange(1, 4499)
    //.setValue(1300)
    //.setValue(1530)
    // full range in dorm
    .setValue(1800)
    ;

  float frameOfst = 0.1;
  flock = new Flock();
  butterfly = new Animation("fly_", 40);
  // Add an initial set of boids into the system
  //
  for (int i = 0; i < 41; i++) {
    color clr = color(random(255), random(255), random(255), random(150, 255));
    if (random(1)<0.25) {
      flock.addBoid(new Boid(random(-width*(frameOfst), 0), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.5) {
      flock.addBoid(new Boid(random(width, width*(1+frameOfst)), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.75) {
      flock.addBoid(new Boid(random(0, width), random(-height*(frameOfst), 0), random(0.5, 1.5), clr));
    } else {
      flock.addBoid(new Boid(random(0, width), random(height, height*(1+frameOfst)), random(0.5, 1.5), clr));
    }
  }
}

void draw() {
  background(0);
  rectMode(CENTER);

  float sumX = 0;
  float sumY = 0;
  int count = 0;
  int[] rawDepth = kinect2.getRawDepth();
  depthImg.loadPixels();

  //need to get spanX & spanY to draw the approximating rectangle around the person
  //int spanX = rawDepth.length % kinect2.depthWidth - 0 % kinect2.depthWidth;
  //int spanY = floor(rawDepth.length / kinect2.depthWidth) - floor(0 / kinect2.depthWidth);

  for (int i=0; i < rawDepth.length; i++) {
    int depth = rawDepth[i];

    if (depth >= thresholdMin
      && depth <= thresholdMax
      && depth != 0) {

      int x = i % kinect2.depthWidth;
      int y = floor(i / kinect2.depthWidth);

      float r = map(depth, thresholdMin, thresholdMax, 255, 0);
      float b = map(depth, thresholdMin, thresholdMax, 0, 255);

      depthImg.pixels[i] = color(r, 0, b);

      sumX += x;
      sumY += y;
      count++;
    } else {
      depthImg.pixels[i] = color(0, 0);
    }
  }
  depthImg.updatePixels();

  pushMatrix();
  translate(width/2, height/2);
  imageMode(CENTER);
  //image(kinect2.getDepthImage(), 0, 0);
  image(depthImg, 0, 0);
  popMatrix();

  // get the center position
  float avgX = 0;
  float avgY = 0;
  if (count > 0) {
    avgX = sumX / count;
    avgY = sumY / count;
  }

  // draw the center position
  stroke(0, 255, 0);
  pushMatrix();
  translate(width/2-kinect2.depthWidth/2, height/2-kinect2.depthHeight/2);
  line(avgX, 0, avgX, kinect2.depthHeight);
  line(0, avgY, kinect2.depthWidth, avgY);
  ellipse(avgX, avgY, 50, 50);
  // approximating rectangle
  rectW = sumX/80000;
  rectH = sumY/30000;
  //rect(avgX, avgY, rectW, rectH);
  //rect(avgX, avgY, spanX, spanY);
  popMatrix();


  fill(255);
  text(frameRate, 10, 20);

  pushMatrix();
  translate(width/2, height/2);
  noFill();
  stroke(100);
  rect(0, 0, textWidth, textHeight);
  popMatrix();

  flock.run();
}
