import codeanticode.syphon.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import controlP5.*;

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Point;
import org.opencv.core.MatOfPoint2f;

ControlP5 cp5;

Kinect2 kinect2;
PImage depthImg, dst;
//int thresholdMin = 0;
//int thresholdMax = 4499;
int thresholdMin = 1;
int thresholdMax = 3194;

OpenCV opencv;
OpenCV opencv2;
ArrayList<Contour> contours;
ArrayList<Contour> polygons;

float scaleW;
float scaleH;

Flock flock;
Animation butterfly;
Animation butterflyL;
Animation butterflyR;

int textX = 1280/2-25;
int text1W = 290;
int text1H = 50;
int text1Y = 215;
int text2W = 170;
int text2H = 50;
int text2Y = 280;
int text3W = 180;
int text3H = 50;
int text3Y = 355;
PImage borderMask;

SyphonServer server;

void setup() {
  fullScreen(P3D);
  //size(1280, 720, P3D);
  frameRate(30);

  PJOGL.profile=1;  // ***
  server = new SyphonServer(this, "Processing Syphon");

  //initialize kinect
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  // Blank image from kinect, and initialize opencv
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);
  dst = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);
  opencv = new OpenCV(this, depthImg);
  opencv2 = new OpenCV(this, dst);

  //add gui
  //int sliderW = 100;
  //int sliderH = 20;
  //cp5 = new ControlP5( this );
  //cp5.addSlider("thresholdMin")
  //  .setPosition(10, 40)
  //  .setSize(sliderW, sliderH)
  //  .setRange(1, 4499)
  //  .setValue(1080)
  //  ;
  //cp5.addSlider("thresholdMax")
  //  .setPosition(10, 70)
  //  .setSize(sliderW, sliderH)
  //  .setRange(1, 4499)
  //  .setValue(3104)
  //  ;

  float frameOfst = 0.1;
  borderMask = loadImage("borderMask.png");
  flock = new Flock();
  butterfly = new Animation("fly_", 40);
  butterflyL = new Animation("left_", 40);
  butterflyR = new Animation("right_", 40);
  // Add an initial set of boids into the system
  for (int i = 0; i < 41; i++) {
    color clr = color(random(255), random(255), random(255), 255);
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

  //setup scale between screen and depthImg
  scaleW = width/parseFloat(depthImg.width);
  scaleH = height/parseFloat(depthImg.height);
}

void draw() {
  background(255);
  rectMode(CENTER);

  //draw depthImg
  int[] rawDepth = kinect2.getRawDepth();
  depthImg.loadPixels();
  for (int i=0; i < rawDepth.length; i++) {
    int depth = rawDepth[i];
    if (depth >= thresholdMin
      && depth <= thresholdMax
      && depth != 0) {
      depthImg.pixels[i] = color(255, 0, 0);
    } else {
      depthImg.pixels[i] = color(0, 0);
    }
  }
  depthImg.updatePixels();

  //display depthImg
  //pushMatrix();
  //imageMode(CORNER);
  //scale(scaleW, scaleH);
  //image(kinect2.getDepthImage(),0,0);
  //image(depthImg, 0, 0);
  //popMatrix();

  opencv.loadImage(depthImg);
  //opencv.calculateOpticalFlow();
  opencv.gray();
  opencv.threshold(70);
  opencv.blur(10);
  dst = opencv.getOutput();
  opencv.dilate();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.dilate();
  contours = opencv.findContours(); 

  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    boolean outsideAllC=true;
    Boid b =tmpBoids.get(i);
    int tmpX=parseInt(b.getPos().x);
    int tmpY=parseInt(b.getPos().y);
    for (Contour c : contours) {
      boolean isInside = inContour(tmpX, tmpY, c);
      if (isInside) {
        b.insideContour();
        outsideAllC = false;
      }
    }
    if (outsideAllC) {
      b.outsideContour();
    }
  }

  //pushMatrix();
  //pushStyle();
  //scale(scaleW, scaleH);
  //for (Contour c : contours) {
  //  noStroke();
  //  fill(0);
  //  //stroke(0, 0, 255);
  //  c.draw();
  //}
  //popStyle();
  //popMatrix();

  opencv2.loadImage(dst);
  opencv2.invert();
  dst=opencv2.getOutput();

  pushMatrix();
  imageMode(CORNER);
  scale(scaleW, scaleH);
  image(dst, 0, 0);
  popMatrix();

  //fill(0);
  //text(frameRate, 100, 100);

  flock.run();

  //fade out border
  pushMatrix();
  pushStyle();
  translate(0, 0);
  imageMode(CORNER);
  image(borderMask, 0, 0);
  popStyle();
  popMatrix();

  server.sendScreen();

  //map text
  //stroke(0);
  //strokeWeight(2);
  //rect(textX, text1Y, text1W, text1H);
  //rect(textX, text2Y, text2W, text2H);
  //rect(textX, text3Y, text3W, text3H);
}

boolean inContour(int x, int y, Contour c) {
  Point p = new Point(x/scaleW, y/scaleH);
  MatOfPoint2f m = new MatOfPoint2f(c.pointMat.toArray());
  double r = Imgproc.pointPolygonTest(m, p, false);
  return r == 1;
}
