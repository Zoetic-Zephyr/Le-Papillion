// The Boid class

class Boid {

  PVector pos;
  PVector vel;
  PVector acc;
  float borderOffset;
  float maxSpd;
  float maxForce;

  float size;
  color plainClr;
  color oriClr;
  int currAniState;
  int stopAniState;
  PVector flyAcc;

  int flowX;
  int flowY;

  boolean insideC;
  boolean atText;
  boolean inspired;

  Boid(float x, float y, float size, color colorB) {
    this.acc = new PVector(0, 0);
    float angle = random(TWO_PI);
    this.vel = new PVector(cos(angle), sin(angle));
    this.pos = new PVector(x, y);

    this.borderOffset = 0.0;
    this.maxSpd = 4;
    this.maxForce = 0.02;

    this.size = size;
    this.plainClr = color(0);
    this.oriClr = colorB;
    this.currAniState = 0;
    this.stopAniState = floor(random(1, 3));
    this.flyAcc = new PVector(0, 0);

    this.insideC = false;
    this.atText = false;
    this.inspired = false;

    this.flowX =parseInt(this.pos.x/scaleW);
    this.flowY =parseInt(this.pos.y/scaleH);
  }

  PVector getPos() {
    return pos;
  }

  void run(ArrayList<Boid> boids) {
    //figureRest
    if (this.insideC) {
      stopAtContour();
      this.currAniState = this.stopAniState;
      this.inspired = true;
      //PVector regionFlow=opencv.getFlowAt(this.flowX,this.flowY);
      //println(regionFlow);
      //applyForce(regionFlow);
      //if (random(1)>0.95) {
      //  outsideContour();
      //  flyAway();
      //}
    } else {
      this.currAniState = 0;
      flock(boids);
    }

    //textRest
    if (touchTexts() == 0) {
      flock(boids);
    } else if (touchTexts() == 1) {
      restText(1);
    } else if (touchTexts() == 2) {
      restText(2);
    } else if (touchTexts() == 3) {
      restText(3);
    }

    update();
    borders();
    render();
  }

  int touchTexts () {
    if (this.pos.x <= textX + text1W/2 && this.pos.x >= textX - text1W/2 && 
      this.pos.y <= text1Y + text1H/2 && this.pos.y >= text1Y - text1H/2 ) {
      return 1;
    } else if (this.pos.x <= textX + text2W/2 && this.pos.x >= textX - text2W/2 && 
      this.pos.y <= text2Y + text2H/2 && this.pos.y >= text2Y - text2H/2 ) {
      return 2;
    } else if (this.pos.x <= textX + text3W/2 && this.pos.x >= textX - text3W/2 && 
      this.pos.y <= text3Y + text3H/2 && this.pos.y >= text3Y - text3H/2 ) {
      return 3;
    } else {
      return 0;
    }
  }

  void restText(int textID) {
    if (random(10) < 9.9) {
      this.atText = true;
      this.currAniState = this.stopAniState;
      this.vel.mult(0);
    } else {
      this.atText = false;
      this.currAniState = 0;
      leaveText(textID);
    }
  }

  void leaveText(int textID) {
    PVector centerPos = new PVector(0, 0);
    if (textID == 1) {
      centerPos = new PVector(textX, text1Y);
    } else if (textID == 2) {
      centerPos = new PVector(textX, text2Y);
    } else if (textID == 3) {
      centerPos = new PVector(textX, text3Y);
    }
    this.flyAcc =  centerPos.sub(this.pos);
    this.flyAcc.mult(-0.03);
    applyForce(this.flyAcc);
  }

  void stopAtContour() {
    this.vel = new PVector(0, 0);
  }

  void insideContour() {
    this.insideC=true;
  }

  void outsideContour() {
    this.insideC=false;
  }

  void applyForce(PVector force) {
    this.acc.add(force);
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void update() {
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpd);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS this.this.vel
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.pos);  // A vector pointing from the this.pos to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(this.maxSpd);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(this.maxSpd);

    // Steering = Desired minus this.this.vel
    PVector steer = PVector.sub(desired, this.vel);
    steer.limit(this.maxForce);  // Limit to maximum steering force
    return steer;
  }

  void checkAniState(boolean atText, boolean inContour) {
    color displayClr = this.plainClr;
    // inContour not atText, display oriClr
    if (inContour && !atText) {
      displayClr = this.oriClr;
    } 
    if (atText && !inContour) {
      // if not inspired, atText display plainClr
      if (this.inspired) {
        displayClr = this.oriClr;
      } else {
        displayClr = this.plainClr;
      }
    }

    if (this.currAniState == 1) {
      //insideC
      butterflyL.display(0, 0, this.size, displayClr);
      butterfly.displayHidden(0, 0, this.size, this.plainClr);
      butterflyR.displayHidden(0, 0, this.size, this.plainClr);
    } else if (this.currAniState == 2) {
      //insideC
      butterflyR.display(0, 0, this.size, displayClr);
      butterfly.displayHidden(0, 0, this.size, this.plainClr);
      butterflyL.displayHidden(0, 0, this.size, this.oriClr);
    } else {
      if (this.inspired) {
        butterfly.display(0, 0, this.size, this.oriClr);
      } else {
        butterfly.display(0, 0, this.size, this.plainClr);
      }

      butterflyL.displayHidden(0, 0, this.size, this.oriClr);
      butterflyR.displayHidden(0, 0, this.size, this.oriClr);
    }
  }

  void render() {
    // Draw a triangle rotated in the direction of this.this.vel
    // theta is modified to make butterflies fly in a more realistic way
    float theta = this.vel.heading() + PI/2;
    //theta = map(theta, -PI, PI, PI/2, -PI/2);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(theta);
    if (this.atText && this.insideC) {
      checkAniState(true, true);
    } else if (!this.atText && !this.insideC) {
      checkAniState(false, false);
    } else if (this.atText & ! this.insideC) {
      checkAniState(true, false);
    } else {
      checkAniState(false, true);
    }
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (this.pos.x < -this.borderOffset) {
      this.pos.x = width+this.borderOffset;
      this.inspired = false;
    }
    if (this.pos.y < -this.borderOffset) {
      this.pos.y = height+this.borderOffset;
      this.inspired = false;
    }
    if (this.pos.x > width+this.borderOffset) {
      this.pos.x = -this.borderOffset;
      this.inspired = false;
    }
    if (this.pos.y > height+this.borderOffset) {
      this.pos.y = -this.borderOffset;
      this.inspired = false;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(this.pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(this.pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(this.maxSpd);

      // Implement Reynolds: Steering = Desired - this.this.vel
      steer.normalize();
      steer.mult(this.maxSpd);
      steer.sub(this.vel);
      steer.limit(this.maxForce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average this.this.vel
  PVector align (ArrayList<Boid> boids) {
    //float neighbordist = 50;
    float neighbordist = 60;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(this.pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(this.maxSpd);

      // Implement Reynolds: Steering = Desired - this.this.vel
      sum.normalize();
      sum.mult(this.maxSpd);
      PVector steer = PVector.sub(sum, this.vel);
      steer.limit(this.maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average this.pos (i.e. center) of all nearby boids, calculate steering vector towards that this.pos
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all this.poss
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(this.pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.pos); // Add this.pos
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the this.pos
    } else {
      return new PVector(0, 0);
    }
  }
}
