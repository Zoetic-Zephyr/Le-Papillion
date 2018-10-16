import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class AnimTest extends PApplet {

sprite walker;
PImage spriteSheet;

public void setup() {
  size(136, 200);
  smooth();
  
  spriteSheet = loadImage("sprSht1.png");
  walker = new sprite();
}

public void draw() {
  background(180);
  image(spriteSheet, 0, 4);
  walker.check();
}

public void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case DOWN:  walker.turn(0); break;
      case UP:    walker.turn(1); break;
      case LEFT:  walker.turn(2); break;
      case RIGHT: walker.turn(3); break;
    }
  }
}

class sprite {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;
  
  sprite() {
    cell = new PImage[12];
    for (int y = 0; y < 4; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet.get(x*24,y*48, 24,48);
  }
  
  public void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
    println (dir);
  }
  
  public void check() {
    if (cnt++ > 7) {
      cnt = 0;
      step++;
      if (step >= 4) 
        step = 0;
    }
    int idx = dir*3 + (step == 3 ? 1 : step);
    image(cell[idx], 88, 76);
  }
}


  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "AnimTest" });
  }
}
