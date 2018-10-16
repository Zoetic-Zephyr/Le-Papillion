//Définition de ce qu'est un oiseau : la classe oiseau

class Oiseau {

  // Les paramètres liés aux oiseaux
  PVector position;
  PVector velocity;
  PVector acceleration;

  float vitesseMax;

  float largeur;
  float hauteur;

  float angle_cos;


  Oiseau() { // Le constructeur : quand on crée un objet oiseau, il s'initialise avec ça
    position = new PVector(random(1, width), height/2); //La position est un vecteur au point sur la moitié de l'écran (point défini via vecteur)
    velocity = new PVector(2, 10); //La vélocité
    vitesseMax = 7; //La vitesse max atteinte par les oiseau ===> Changer ça pour donner des mouvements différents !
  }

  void update() { //Le comportement des oiseaux

    // Incrémentation de l'angle pour la fonction cosinus --> variation du diametre de la "boule" d'oiseaux
    angle_cos += random(-6, 6);

    //calcul des accélérations
    PVector mouse = new PVector(mouseX+(random(-200, 200) + sin(angle_cos)*500), mouseY+(random(-200, 200)) + sin(angle_cos)*500); //On défini un nouveau vecteur au point x,y de la souris (point défini via vecteur)
    PVector direction = PVector.sub(mouse, position); //On soustrait les 2 vecteurs déjà existants (la position et la souris) pour créer un vecteur direction qui pointe vers la souris
    direction.normalize(); //On ramene la valeur de ce vecteur à 1, sans perdre sa direction
    direction.mult(0.5); //On le divise de moitié
    acceleration = direction; //le vecteur qui donne l'accélération correspond à celui de la direction

      //Mouvement en chaine : L'acceleration fait changer la vélocité qui fait changer la position
    velocity.add(acceleration); //on ajoute le vecteur acceleration au vecteur velocity
    position.add(velocity); //On ajoute le vecteur velocity à la position
    velocity.limit(vitesseMax); //La valeur vitesseMac est la limite de l'augmentation de velocity (après velocity n'augmente plus et reste au max)

    //Variation de la forme des oiseaux
    largeur = random(1.7, 8);
    hauteur = random(1, 3);
  }


  void display() { //Quand on dessine l'oiseau
    noStroke(); 
    fill(0);
    ellipse(position.x, position.y, largeur, hauteur); //sa position correspond aux coordonnées x,y du vecteur position
  }
}
