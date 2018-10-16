AnimatedSpriteObject knight;

void setup()
{
  size(500, 500);

  knight = new AnimatedSpriteObject("knight.png");
  knight.x = width/2;
  knight.y = height/2;
  knight.frameSpeed = 6.0; // 6fps
  knight.frameWidth = 32;
  knight.frameHeight = 64;
  knight.startFrame = 1;
  knight.endFrame = 5;
  //knight.scaleX = 2.0;
  //knight.scaleY = 5.0;
}

void draw()
{
  background(0);

  knight.x = mouseX;
  knight.y = mouseY;
  knight.update();
  knight.render(); 
}


void keyReleased()
{

  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      knight.startFrame = 7;
      knight.endFrame = 11;
      knight.currentFrame = knight.startFrame;
    }
    if (keyCode == RIGHT)
    {
      // or use the helper function that does the same thing.
      // start, end, looping
      knight.setAnimation(19, 23, true);
    }
    if (keyCode == UP)
    {
      knight.setAnimation(13, 17, true);
    }
    if (keyCode == DOWN)
    {
      knight.startFrame = 1;
      knight.endFrame = 5;
      knight.currentFrame = knight.startFrame;
    }
  }
}
