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
int thresholdMin = 1080;
int thresholdMax = 3104;

OpenCV opencv;
ArrayList<Contour> contours;
ArrayList<Contour> polygons;
boolean isInside = false;

float scaleW;
float scaleH;

Flock flock;
Animation butterfly;
Animation butterflyW;

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

int resolutionx = 32;
int resolutiony = 32;


void setup() {
  //fullScreen(P3D);
  size(1280, 720, P3D);
  //initialize kinect
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  // Blank image from kinect, and initialize opencv
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, GRAY);
  println(kinect2.depthWidth);
  println(kinect2.depthHeight);
  opencv = new OpenCV(this, depthImg);

  // add gui
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
  butterflyW = new Animation("flyw_", 40);
  // Add an initial set of boids into the system
  for (int i = 0; i < 4; i++) {
    color clr = color(random(50, 255), random(50, 255), random(50, 255), 255);
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
  background(0);
  //rectMode(CENTER);

  //fade out border
  pushMatrix();
  pushStyle();
  imageMode(CORNER);
  image(borderMask, 0, 0);
  popStyle();
  popMatrix();

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
  opencv.gray();
  opencv.threshold(70);
  opencv.blur(10);
  opencv.dilate();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.erode();
  opencv.dilate();
  dst = opencv.getOutput();
  contours = opencv.findContours(); 
  opencv.calculateOpticalFlow();
  //PVector regionFlow = opencv.getAverageFlowInRegion(384, 64, 32, 32);
  //println(regionFlow);
  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    Boolean outsideAllC=true;
    Boid b =tmpBoids.get(i);
    int tmpX=parseInt(b.getPos().x);
    int tmpY=parseInt(b.getPos().y);
    for (Contour c : contours) {
      isInside = inContour(tmpX, tmpY, c);
      if (isInside) {
        b.insideContour();
        outsideAllC = false;
      }
    }
    if (outsideAllC) {
      b.outsideContour();
    }
  }

  pushMatrix();
  pushStyle();
  scale(scaleW, scaleH);
  for (Contour c : contours) {
    noStroke();
    fill(30);
    //stroke(0, 0, 255);
    c.draw();
  }
  popStyle();
  popMatrix();


  pushMatrix();
  imageMode(CORNER);
  scale(scaleW, scaleH);
  image(dst, 0, 0);
  //filter(INVERT);
  //image(depthImg, 0, 0);
  popMatrix();

  //fill(255);
  //text(frameRate, 10, 20);

  flock.run();
}

boolean inContour(int x, int y, Contour c) {
  Point p = new Point(x/scaleW, y/scaleH);
  MatOfPoint2f m = new MatOfPoint2f(c.pointMat.toArray());
  double r = Imgproc.pointPolygonTest(m, p, false);
  return r == 1;
}
