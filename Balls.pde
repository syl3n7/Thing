class Balls
{
    //posx, posy, diameter, speed
    float posx;
    float posy;
    float diameter;
    float speed;
    PVector velocity;
    boolean fired;
    boolean isStatic = false;

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
        fill(255, 0, 0); // Red for visibility
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
            
            // Bounce off bottom
            if (posy + diameter/2 > height)
            {
                velocity.y *= -1;
                posy = height - diameter/2;
            }
            
            // Bounce off top
            if (posy - diameter/2 < 0)
            {
                velocity.y *= -1;
                posy = diameter/2;
            }
        }
    }
}
