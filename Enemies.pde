class Enemy
{
  //posx, posy, w, h
  float posx;
  float posy;
  float w;
  float h;
  boolean alive = true; // collidable
  boolean dying = false; // flagged for death animation
  boolean destroyed = false; // remove from list when true
  int deathTimer = 0;
  float deathScale = 1.0;
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
      dying = true;
      alive = false; // stop further collisions
      deathTimer = 20; // frames for death animation
    }
  }

  void update()
  {
    if (dying)
    {
      deathTimer--;
      deathScale = map(deathTimer, 20, 0, 1.0, 0);
      if (deathTimer <= 0)
      {
        destroyed = true;
      }
    }
  }

  void drawme()
  {
      if (alive || dying)
      {
        if (maxHits >= 50)
        {
          fill(255, 0, 0); // Red for bosses
        }
        else
        {
          fill(255); // White for normal
        }
        pushMatrix();
        translate(posx + w/2, posy + h/2);
        if (dying)
        {
          float s = deathScale;
          scale(s);
          fill(255, 100, 100, map(deathTimer, 20, 0, 255, 0));
        }
        rect(-w/2, -h/2, w, h);
        popMatrix();
        fill(0); // Black text
        textSize(12);
        textAlign(CENTER);
        text(str(max(0, hits)), posx + w/2, posy + h/2 + 4);
      }
  }
}