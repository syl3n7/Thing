class Enemies
{
  //posx, posy, w, h, balls, ismoving
  float posx;
  float posy;
  float w;
  float h;
  ArrayList<Balls> balls = new ArrayList<Balls>();
  boolean ismoving;

  Enemies (float posx, float posy, float w, float h)
  {
    this.posx = posx;
    this.posy = posy;
    this.w = w;
    this.h = h;
    
  }

  void drawme()
  {
      rect(posx, posy, w, h);
  }

  void drawBalls()
  {
    for (Balls b : balls)
    {
      b.drawme();
    }
  }

  void addBall(float posx, float posy, float diameter, float speed)
  {
    balls.add(new Balls(posx, posy, diameter, speed));
  }

}
