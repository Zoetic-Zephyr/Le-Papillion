Oiseau[] oiseaux = new Oiseau[500];

PImage img;
void setup() {
  size(900,600);
  smooth();
  img = loadImage("https://www.openprocessing.org/sketch/531427/files/CielSimple2Small.jpg");
  frameRate(38);
  //création de tous les oiseaux
  for (int i = 0; i<oiseaux.length; i=i+1) {
    oiseaux[i] = new Oiseau();
  }
}

void draw() {
  //dessiner le fond : recharger l'image (photo du ciel ou dégradé) avec une légère transparence pour garder un peu des traces des oiseaux 
  tint(255, 230);
  image(img, 0, 0);
  
  //dessiner la ligne haute tension
  stroke(0);
  line(0,height/1.87,width,height/1.90);
  line(0,height/1.97,width,height/1.93);
  line(0,height/2,width,height/2.01);
  line(0,height/2.05,width,height/2.07);
  line(0,height/2.14,width,height/2.12);
  fill(0);
  
  //appeller les comportements qui font s'activer et se déplacer les oiseaux
  for (int i =0; i < oiseaux.length; i=i+1) {
    oiseaux[i].update();
    oiseaux[i].display();
  }
}
