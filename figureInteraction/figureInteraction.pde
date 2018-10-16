import codeanticode.syphon.*;
import java.awt.Rectangle;
import java.lang.reflect.*;
import java.lang.Object;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import controlP5.*;

import java.util.Map;

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Point;
import org.opencv.core.MatOfPoint2f;

ControlP5 cp5;

Kinect2 kinect2;
PImage depthImg, dst;
int thresholdMin = 1;
int thresholdMax = 3194;

OpenCV opencv;
OpenCV opencv2;
ArrayList<Contour> polygons;
boolean isInside = false;

float scaleW;
float scaleH;

Flock flock;
Animation butterfly;

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
  //fullScreen(P3D);
  size(1280, 720, P3D);
  frameRate(25);

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

  float frameOfst = 0.1;
  borderMask = loadImage("borderMask.png");
  flock = new Flock();
  butterfly = new Animation("fly_", 40);
  // Add an initial set of boids into the system
  for (int i = 0; i < 41; i++) {
    color clr = color(random(255), random(255), random(255), 255);
    flock.addBoid(new Boid(random(0, width), random(0,height), random(0.5, 1.5), clr));
    //if (random(1)<0.25) {
    //  flock.addBoid(new Boid(random(-width*(frameOfst), 0), random(0, height), random(0.5, 1.5), clr));
    //} else if (random(1)<0.5) {
    //  flock.addBoid(new Boid(random(width, width*(1+frameOfst)), random(0, height), random(0.5, 1.5), clr));
    //} else if (random(1)<0.75) {
    //  flock.addBoid(new Boid(random(0, width), random(-height*(frameOfst), 0), random(0.5, 1.5), clr));
    //} else {
    //  flock.addBoid(new Boid(random(0, width), random(height, height*(1+frameOfst)), random(0.5, 1.5), clr));
    //}
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

  opencv.loadImage(depthImg);
  opencv.gray();
  opencv.threshold(70);
  opencv.blur(10);
  dst = opencv.getOutput();

  for (Blob b : blobList) {
    PVector currentPos=b.getCenter();
    PVector prevPos = b.getPrevCenter();
    float d = dist(currentPos.x, currentPos.y, prevPos.x, prevPos.y);
    PVector force = currentPos.copy().sub(prevPos);
    if (d<5) {
      addContourAttractor(currentPos);
    } else {
      addContourRepeller(force, currentPos);
    }
    b.updatePrevCenter();
  }
  detectBlobs();


  ////pushMatrix();
  ////pushStyle();
  ////scale(scaleW, scaleH);
  //if (prevPosDict.size()==0) {
  //  for (Contour c : contours) {
  //    PVector initPos = getCenterOfContour(c);
  //    prevPosDict.put(str(c.hashCode()), initPos);
  //  }
  //}

  //for (Contour c : contours) {
  //  PVector currentPos=getCenterOfContour(c);
  //  PVector prevPos = prevPosDict.get(str(c.hashCode()));
  //  //float d = dist(currentPos.x, currentPos.y, prevPos.x, prevPos.y);
  //  //println(prevPos);
  //  //if (dist(currentPos.x, currentPos.y, prevPos.x, prevPos.y)<30) {
  //  //  addContourAttractor(currentPos);
  //  //} else {
  //  //  addContourRepeller(currentPos);
  //  //}
  //  prevPosDict.put(str(c.hashCode()), currentPos);
  //}
  //println(prevPosDict.size());
  //println(contours.size());
  //println("next");

  //popStyle();
  //popMatrix();


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
  //displayBlobs();
  //for (Contour c : contours) {
  //  noStroke();
  //  fill(0);
  //  stroke(0, 0, 255);
  //  strokeWeight(10);
  //  //PVector center = getCenterOfContour(c);
  //  c.draw();
  //  //fill(255,0,0);
  //  //text(c.hashCode(),center.x*scaleW,center.y*scaleH);
  //}
  popStyle();
  popMatrix();

  opencv2.loadImage(dst);
  opencv2.invert();
  dst=opencv2.getOutput();

  pushMatrix();
  imageMode(CORNER);
  scale(scaleW, scaleH);
  image(dst, 0, 0);
  popMatrix();

  fill(0);
  text(frameRate, 100, 100);

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

void addContourAttractor(PVector target) {
  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    Boid b =tmpBoids.get(i);
    b.attract(target);
  }
}

void addContourRepeller(PVector force, PVector target) {
  ArrayList<Boid> tmpBoids =flock.getBoids();
  for (int i = 0; i < tmpBoids.size(); i++) {
    Boid b =tmpBoids.get(i);
    b.repel(force, target);
  }
}

PVector getCenterOfContour(Contour c) {
  MatOfPoint2f m = new MatOfPoint2f(c.pointMat.toArray());
  Point p = new Point(Imgproc.moments(m, false).get_m10()/Imgproc.moments(m, false).get_m00(), Imgproc.moments(m, false).get_m01()/Imgproc.moments(m, false).get_m00());
  float cX = (float)p.x;
  float cY = (float)p.y;
  PVector center = new PVector(cX*scaleW, cY*scaleH);
  return center;
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

void displayBlobs() {

  for (Blob b : blobList) {
    strokeWeight(1);
    b.display();
  }
}