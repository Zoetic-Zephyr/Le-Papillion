class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ".gif";
      //print(filename);
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos, float size, color clr) {
    frame = (frame+1) % imageCount;
    scale(size);
    tint(clr);
    image(images[frame], xpos, ypos);
  }
  
  int getWidth() {
    return images[0].width;
  }
}


// Class for animating a sequence of GIFs
