/**
 * Animated Sprite (Shifty + Teddy)
 * by James Paterson. 
 * 
 * Press the mouse button to change animations.
 * Demonstrates loading, displaying, and animating GIF images.
 * It would be easy to write a program to display 
 * animated GIFs, but would not allow as much control over 
 * the display sequence and rate of display. 
 */

Animation animation1, animation2, animation3;

float xpos;
float ypos;
//float drag = 30.0;

void setup() {
  size(800, 600);
  background(0);
  imageMode(CENTER);

  frameRate(30);

  //animation1 = new Animation("PT_Shifty_", 38);
  //animation2 = new Animation("PT_Teddy_", 60);
  animation3 = new Animation("fly_", 40);
  //ypos = height * 0.25;
}

void draw() { 
  //float dx = mouseX - xpos;
  //xpos = xpos + dx/drag;
  //float dy = mouseY - ypos;
  //ypos = ypos + dy/drag;

  xpos = mouseX;
  ypos = mouseY;

  background(0);
  // Display the sprite at the position xpos, ypos
  //if (mousePressed) {
  //  background(153, 153, 0);
  //  animation1.display(xpos-animation1.getWidth()/2, ypos);
  //} else {
  //  background(255, 204, 0);
  //  animation2.display(xpos-animation1.getWidth()/2, ypos);
  //}
  animation3.display(xpos, ypos);
}
