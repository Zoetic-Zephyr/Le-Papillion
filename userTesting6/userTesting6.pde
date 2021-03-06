import codeanticode.syphon.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import controlP5.*;

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Point;
import org.opencv.core.MatOfPoint2f;

import java.awt.Rectangle;

ControlP5 cp5;

Kinect2 kinect2;
PImage depthImg, dst;
//int thresholdMin = 0;
//int thresholdMax = 4499;
int thresholdMin = 1;
int thresholdMax = 3194;

OpenCV opencv;
OpenCV opencv2;
ArrayList<Contour> polygons;

float scaleW;
float scaleH;

Flock flock;
Animation butterfly;
Animation butterflyL;
Animation butterflyR;

PVector txtPos = new PVector(1280/2.0-25, 275);

PImage borderMask;

int blobSizeThreshold = 40;

SyphonServer server;

ArrayList<Contour> contours;
// List of detected contours parsed as blobs (every frame)
ArrayList<Contour> newBlobContours;
// List of my blob objects (persistent)
ArrayList<Blob> blobList;
// Number of blobs detected over all time. Used to set IDs.
int blobCount = 0;

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

  contours = new ArrayList<Contour>();
  // Blobs list
  blobList = new ArrayList<Blob>();

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

  borderMask = loadImage("borderMask.png");
  flock = new Flock();
  butterfly = new Animation("fly_", 40);
  butterflyL = new Animation("left_", 40);
  butterflyR = new Animation("right_", 40);
  // Add an initial set of boids into the system
  for (int i = 0; i < 41; i++) {
    color clr = color(random(100, 255), random(100, 255), random(100, 255), 255);
    // possible change here regarding butterfly initial position
    flock.addBoid(new Boid(random(0, width), random(0, height), random(0.8, 1.5), clr));
  }

  //setup scale between screen and depthImg
  scaleW = width/parseFloat(depthImg.width);
  scaleH = height/parseFloat(depthImg.height);
}

void draw() {
  background(255);
  rectMode(CENTER);

  addTxtRepeller(txtPos);

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
  //opencv.dilate();
  //opencv.erode();
  //opencv.erode();
  //opencv.erode();
  //opencv.erode();
  //opencv.erode();
  //opencv.dilate();
  //contours = opencv.findContours(); 

  for (Blob b : blobList) {
    PVector currentPos=b.getCenter();
    PVector prevPos = b.getPrevCenter();
    float d = dist(currentPos.x, currentPos.y, prevPos.x, prevPos.y);
    if (d < 6) {
      //addContourAttractor(currentPos);
    } else {
      addContourRepeller(d, currentPos);
    }
    b.updatePrevCenter();
  }
  detectBlobs();

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
  //line(textX - text1W/2, text1Y, textX + text1W/2, text1Y);
  //ellipse(txtPos.x, txtPos.y, 100, 100);
}

boolean inContour(int x, int y, Contour c) {
  Point p = new Point(x/scaleW, y/scaleH);
  MatOfPoint2f m = new MatOfPoint2f(c.pointMat.toArray());
  double r = Imgproc.pointPolygonTest(m, p, false);
  return r == 1;
}

//void addContourAttractor(PVector target) {
//  ArrayList<Boid> tmpBoids =flock.getBoids();
//  for (int i = 0; i < tmpBoids.size(); i++) {
//    Boid b =tmpBoids.get(i);
//    b.attract(target);
//  }
//}

void addTxtRepeller(PVector target) {
  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    Boid b =tmpBoids.get(i);
    PVector dist = target.copy();
    dist.sub(b.pos);
    if (dist.mag()<120)
      b.repelTxt(target);
  }
}

void addContourRepeller(float d, PVector target) {
  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    Boid b =tmpBoids.get(i);
    PVector dist = target.copy();
    dist.sub(b.pos);
    if (dist.mag()<250)
      b.repel(d, target);
  }
}

ArrayList<Contour> getBlobsFromContours(ArrayList<Contour> newContours) {

  ArrayList<Contour> newBlobs = new ArrayList<Contour>();

  // Which of these contours are blobs?
  for (int i=0; i<newContours.size(); i++) {

    Contour contour = newContours.get(i);
    Rectangle r = contour.getBoundingBox();

    if (//(contour.area() > 0.9 * src.width * src.height) ||
      (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;

    newBlobs.add(contour);
  }

  return newBlobs;
}

void detectBlobs() {

  // Contours detected in this frame
  // Passing 'true' sorts them by descending area.
  contours = opencv.findContours(true, true);

  newBlobContours = getBlobsFromContours(contours);

  //println(newBlobContours.size());

  // Check if the detected blobs already exist are new or some has disappeared. 

  // SCENARIO 1 
  // blobList is empty
  if (blobList.isEmpty()) {
    // Just make a Blob object for every face Rectangle
    for (int i = 0; i < newBlobContours.size(); i++) {
      //println("+++ New blob detected with ID: " + blobCount);
      blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
      blobCount++;
    }

    // SCENARIO 2 
    // We have fewer Blob objects than face Rectangles found from OpenCV in this frame
  } else if (blobList.size() <= newBlobContours.size()) {
    boolean[] used = new boolean[newBlobContours.size()];
    // Match existing Blob objects with a Rectangle
    for (Blob b : blobList) {
      // Find the new blob newBlobContours.get(index) that is closest to blob b
      // set used[index] to true so that it can't be used twice
      float record = 50000;
      int index = -1;
      for (int i = 0; i < newBlobContours.size(); i++) {
        float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
        //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
        if (d < record && !used[i]) {
          record = d;
          index = i;
        }
      }
      // Update Blob object location
      used[index] = true;
      b.update(newBlobContours.get(index));
    }
    // Add any unused blobs
    for (int i = 0; i < newBlobContours.size(); i++) {
      if (!used[i]) {
        //println("+++ New blob detected with ID: " + blobCount);
        blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
        //blobList.add(new Blob(blobCount, blobs[i].x, blobs[i].y, blobs[i].width, blobs[i].height));
        blobCount++;
      }
    }

    // SCENARIO 3 
    // We have more Blob objects than blob Rectangles found from OpenCV in this frame
  } else {
    // All Blob objects start out as available
    for (Blob b : blobList) {
      b.available = true;
    } 
    // Match Rectangle with a Blob object
    for (int i = 0; i < newBlobContours.size(); i++) {
      // Find blob object closest to the newBlobContours.get(i) Contour
      // set available to false
      float record = 50000;
      int index = -1;
      for (int j = 0; j < blobList.size(); j++) {
        Blob b = blobList.get(j);
        float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
        //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
        if (d < record && b.available) {
          record = d;
          index = j;
        }
      }
      // Update Blob object location
      Blob b = blobList.get(index);
      b.available = false;
      b.update(newBlobContours.get(i));
    } 
    // Start to kill any left over Blob objects
    for (Blob b : blobList) {
      if (b.available) {
        b.countDown();
        if (b.dead()) {
          b.delete = true;
        }
      }
    }
  }

  // Delete any blob that should be deleted
  for (int i = blobList.size()-1; i >= 0; i--) {
    Blob b = blobList.get(i);
    if (b.delete) {
      blobList.remove(i);
    }
  }
}
