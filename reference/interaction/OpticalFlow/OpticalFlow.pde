import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;

void setup() {
  size(1136, 320);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  video.loop();
  video.play();  
}

void draw() {
  background(0);
  opencv.loadImage(video);
  opencv.calculateOpticalFlow();

  image(video, 0, 0);
  translate(video.width,0);
  stroke(255,0,0);
  //opencv.drawOpticalFlow();
  
  pushStyle();
  noFill();
  float x = 200;
  float y = 200;
  int w=60;
  rect(x,y,w,w);
  popStyle();
  PVector regionFlow = opencv.getAverageFlowInRegion(100,100,60,60);
  //regionFlow.mult(.1);
  line(x+w/2,y+w/2,x+w/2+regionFlow.x,y+w/2+regionFlow.y);
  PVector aveFlow = opencv.getAverageFlow();
  int flowScale = 50;
  
  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);
}

void movieEvent(Movie m) {
  m.read();
}
