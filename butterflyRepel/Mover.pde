// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;

  Mover(float m, float x, float y) {
    mass = m;
    position = new PVector(x, y);
    velocity = new PVector(1, 0);
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    velocity.mult(.98);
    acceleration.mult(0);
    if ((position.x > width) || (position.x < 0)) {
      velocity.x = velocity.x * -1;
    }
    if ((position.y > height) || (position.y < 0)) {
      velocity.y = velocity.y * -1;
    }
  }

  void display() {
    stroke(0);
    strokeWeight(2);
    fill(0, 100);
    ellipse(position.x, position.y, mass*25, mass*25);
  }
}
