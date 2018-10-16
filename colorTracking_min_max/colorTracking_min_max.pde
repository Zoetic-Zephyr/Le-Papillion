// IMA NYU Shanghai
// Kinetic Interfaces
// MOQN
// Sep 28 2016


import processing.video.*;


Capture cam;
PImage img;
color pickedColor;
int threshold = 20;


void setup() {
  size(640, 480);
  cam = new Capture(this, 640, 480);
  cam.start();
  img = createImage(640, 480, ARGB); //not RGBA
}


void draw() {
  if ( cam.available() ) {
    cam.read();
    cam.loadPixels();
  }

  int w = cam.width;
  int h = cam.height;

  int minX = width;
  int maxX = 0;
  int minY = height;
  int maxY = 0;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int i =  x + y*w; // IMPORTANT

      float r = red(cam.pixels[i]);
      float g = green(cam.pixels[i]);
      float b = blue(cam.pixels[i]);

      if ( r > red(pickedColor)   - threshold && r < red(pickedColor)   + threshold
        && g > green(pickedColor) - threshold && g < green(pickedColor) + threshold
        && b > blue(pickedColor)  - threshold && b < blue(pickedColor)  + threshold )
      {
        img.pixels[i] = color(255, 0, 0);
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      } else { 
        img.pixels[i] = color(0, 0);
      }
    }
  }
  img.updatePixels();
  image(cam, 0, 0);
  image(img, 0, 0);

  noStroke();
  fill(pickedColor);
  rect(10, 10, 50, 50);
  fill(255);
  text("Threshold: " + threshold, 70, 30);

  // show the min & max values
  stroke(255, 0, 255);
  line(minX, 0, minX, height);
  line(maxX, 0, maxX, height);
  stroke(255, 255, 0);
  line(0, minY, width, minY);
  line(0, maxY, width, maxY);
}


void mousePressed() {
  pickedColor = cam.get(mouseX, mouseY);
}


void keyPressed() {
  if (keyCode == RIGHT || keyCode == UP) {
    threshold ++;
  } else if (keyCode == LEFT || keyCode == DOWN) {
    threshold --;
  }
  threshold = constrain(threshold, 0, 255);
}
