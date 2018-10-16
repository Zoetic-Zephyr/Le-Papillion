// IMA NYU Shanghai
// Kinetic Interfaces
// MOQN
// Nov 3 2016


import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;


Kinect2 kinect2;
PImage depthImg;

int thresholdMin = 1; // let's not use 0
int thresholdMax = 4499;


void setup() {
  size(512, 424, P2D);
  kinect2 = new Kinect2(this);

  kinect2.initDepth();
  //kinect2.initVideo();
  //kinect2.initIR();
  //kinect2.initRegistered();

  // Start all data
  kinect2.initDevice();

  // Allocate a blank image
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);
}


void draw() {
  int[] rawDepth = kinect2.getRawDepth();

  depthImg.loadPixels();
  for (int i=0; i < rawDepth.length; i++) {
    int x = i % kinect2.depthWidth;
    int y = floor(i / kinect2.depthWidth);
    int depth = rawDepth[i]; // z
    
    // reset the pixel value (make it transparent)
    depthImg.pixels[i] = color(0, 0);
    if ( depth >= thresholdMin
      && depth <= thresholdMax
      && depth != 0) {

      float r = map(depth, thresholdMin, thresholdMax, 255, 0);
      float b = map(depth, thresholdMin, thresholdMax, 0, 255);

      depthImg.pixels[i] = color(r, 0, b);
    }
  }
  depthImg.updatePixels();

  background(0);
  image(kinect2.getDepthImage(), 0, 0);
  image(depthImg, 0, 0);

  fill(255);
  text(frameRate, 10, 20);
  text("Drag your mouse to adjust the thresholds.", 10, 60);
  text(thresholdMin + " - " + thresholdMax, 10, 80);
}


void mousePressed() {
  thresholdMin = (int)map(mouseX, 0, width, 0, 4499);
}


void mouseDragged() {
  thresholdMax = (int)map(mouseX, 0, width, 0, 4499);
}
