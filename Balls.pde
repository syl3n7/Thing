class Balls
{
    //posx, posy, diameter, speed
    float posx;
    float posy;
    float diameter;
    float speed;
    PVector velocity;
    boolean fired;

    Balls (float posx, float posy, float diameter, float speed)
    {
        this.posx = posx;
        this.posy = posy;
        this.diameter = diameter;
        this.speed = speed;
        this.velocity = new PVector(0, 0);
        this.fired = false;
    }

    void drawme()
    {
        circle(posx, posy, diameter);
    }

    void update()
    {
        if (fired) 
        {
            posx += velocity.x;
            posy += velocity.y;
            
            // Bounce off left/right walls
            if (posx - diameter/2 < 0 || posx + diameter/2 > width)
            {
                velocity.x *= -1;
                posx = constrain(posx, diameter/2, width - diameter/2);
            }
            
            // Bounce off top
            if (posy - diameter/2 < 0)
            {
                velocity.y *= -1;
                posy = diameter/2;
            }
            
            // If off bottom, reset (or remove)
            if (posy - diameter/2 > height)
            {
                fired = false;
                posx = 0; // or reset to player position
                posy = 0;
                velocity.set(0, 0);
            }
        }
    }
}
