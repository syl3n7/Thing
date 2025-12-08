class Enemy
{
  //posx, posy, w, h
  float posx;
  float posy;
  float w;
  float h;
  boolean alive = true;
  int hits = 0;
  int maxHits = 2;

  Enemy (float posx, float posy, float w, float h)
  {
    this.posx = posx;
    this.posy = posy;
    this.w = w;
    this.h = h;
    
  }

  void hit()
  {
    hits--;
    if (hits <= 0)
    {
      alive = false;
    }
  }

  void drawme()
  {
      if (alive)
      {
        if (maxHits >= 50)
        {
          fill(255, 0, 0); // Red for bosses
        }
        else
        {
          fill(255); // White for normal
        }
        rect(posx, posy, w, h);
        fill(0); // Black text
        textSize(12);
        textAlign(CENTER);
        text(str(hits), posx + w/2, posy + h/2 + 4);
      }
  }
}