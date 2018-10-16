/**
 * Blob Class
 *
 * Based on this example by Daniel Shiffman:
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 * 
 * @author: Jordi Tost (@jorditost)
 * 
 * University of Applied Sciences Potsdam, 2014
 */

class Blob {

  private PApplet parent;

  // Contour
  public Contour contour;

  // Am I available to be matched?
  public boolean available;

  // Should I be deleted?
  public boolean delete;

  // How long should I live if I have disappeared?
  private int initTimer = 5; //127;
  public int timer;

  // Unique ID for each blob
  int id;

  PVector center, prevCenter;

  // Make me
  Blob(PApplet parent, int id, Contour c) {
    this.parent = parent;
    this.id = id;
    this.contour = new Contour(parent, c.pointMat);
    this.prevCenter = new PVector(0, 0);
    this.center = new PVector(0, 0);

    available = true;
    delete = false;

    timer = initTimer;
  }

  PVector calcCenter() {
    MatOfPoint2f m = new MatOfPoint2f(this.contour.pointMat.toArray());
    Point p = new Point(Imgproc.moments(m, false).get_m10()/Imgproc.moments(m, false).get_m00(), Imgproc.moments(m, false).get_m01()/Imgproc.moments(m, false).get_m00());
    float cX = (float)p.x;
    float cY = (float)p.y;
    PVector center = new PVector(cX*scaleW, cY*scaleH);
    return center;
  }
  
  void updatePrevCenter(){
    this.prevCenter = this.center;
  }
  
  PVector getPrevCenter(){
    return this.prevCenter;
  }
  
  PVector getCenter(){
    this.center = calcCenter();
    return this.center;
  }

  // Show me
  void display() {
    Rectangle r = contour.getBoundingBox();

    float opacity = map(timer, 0, initTimer, 0, 127);
    fill(0, 0, 255, opacity);
    stroke(0, 0, 255);
    rect(r.x, r.y, r.width, r.height);
    fill(255, 0, 0, 2*opacity);
    textSize(26);
    text(""+id, r.x+10, r.y+30);
  }

  // Give me a new contour for this blob (shape, points, location, size)
  // Oooh, it would be nice to lerp here!
  void update(Contour newC) {

    contour = new Contour(parent, newC.pointMat);

    // Is there a way to update the contour's points without creating a new one?
    /*ArrayList<PVector> newPoints = newC.getPoints();
     Point[] inputPoints = new Point[newPoints.size()];
     
     for(int i = 0; i < newPoints.size(); i++){
     inputPoints[i] = new Point(newPoints.get(i).x, newPoints.get(i).y);
     }
     contour.loadPoints(inputPoints);*/

    timer = initTimer;
  }

  // Count me down, I am gone
  void countDown() {    
    timer--;
  }

  // I am deed, delete me
  boolean dead() {
    if (timer < 0) return true;
    return false;
  }

  public Rectangle getBoundingBox() {
    return contour.getBoundingBox();
  }
}