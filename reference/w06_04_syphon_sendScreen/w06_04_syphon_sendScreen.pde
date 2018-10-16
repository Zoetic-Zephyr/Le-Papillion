// https://github.com/Syphon/Processing


import codeanticode.syphon.*;

SyphonServer server;


void settings() {
  size(400,400, P3D);
  PJOGL.profile=1;  // ***
}


void setup() {
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  background(255,0,0);
  fill(255);
  noStroke();
  ellipse(width/2,height/2,200,200);
  server.sendScreen();
  
  // something for debugging or displaying info.
}