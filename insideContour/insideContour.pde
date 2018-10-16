import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Point;
import org.opencv.core.MatOfPoint2f;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;
//int currentContour = 30;
boolean isInside = false;
boolean mm = false;

void setup() {
  src = loadImage("images.png"); 
  size(175, 170);
  opencv = new OpenCV(this, src);

  opencv.gray();
  opencv.threshold(70);
  opencv.blur(10);
  dst = opencv.getOutput();

  contours = opencv.findContours(); 
  println("found " + contours.size() + " contours");
}

boolean inContour(int x, int y, Contour c) {
  Point p = new Point(x, y);
  MatOfPoint2f m = new MatOfPoint2f(c.pointMat.toArray());

  double r = Imgproc.pointPolygonTest(m, p, false);

  return r == 1;
}

void draw() {
  image(src, 0, 0);

  noFill();
  strokeWeight(3);

  for (Contour c : contours) {
    if (mm)
      isInside = inContour(mouseX, mouseY, c);
    stroke(0, 255, 0);
    c.draw();
  }
  mm = false;
  //Contour c= contours.get(currentContour);


  pushStyle();
      noStroke();

  if(isInside){
    fill(0,255,0);
  } else {
    fill(255,0,0);
  }
  ellipse(mouseX, mouseY, 10, 10);
  popStyle();
}


void mouseMoved() {
  
  //Contour c= contours.get(currentContour);
  //isInside = inContour(mouseX, mouseY, c);
  mm = true;
}

void keyPressed() {
  //currentContour++;
  //println(currentContour);

  //if (currentContour > contours.size()-1) {
  //  currentContour = 0;
  //}
}
