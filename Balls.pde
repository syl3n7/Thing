class Balls
{
    //posx, posy, diameter, speed
    float posx;
    float posy;
    float diameter;
    float origDiameter;
    float speed;
    PVector velocity;
    boolean fired;
    boolean isStatic = false;
    int gridCol = -1; // index of column grid the static ball sits in
    boolean caught = false;
    int catchTimer = 0;
    boolean destroyed = false;
    int defaultLife = 0;
    boolean attracting = false;
    float targetX;
    float targetY;

    Balls (float posx, float posy, float diameter, float speed)
    {
        this.posx = posx;
        this.posy = posy;
        this.diameter = diameter;
        this.origDiameter = diameter;
        this.speed = speed;
        this.velocity = new PVector(0, 0);
        this.fired = false;
    }

    // Overload: for static grid balls, include column index
    Balls (float posx, float posy, float diameter, float speed, int gridCol)
    {
        this(posx, posy, diameter, speed);
        this.gridCol = gridCol;
        this.isStatic = true;
        this.catchTimer = 0;
        this.drawScale = 1;
        this.destroyed = false;
    }

    float drawScale = 1;
    void drawme()
    {
        float d = origDiameter * drawScale;
        if (isStatic)
        {
            fill(0, 200, 255, caught ? map(catchTimer, 10, 0, 255, 0) : 255);
            circle(posx, posy, d);
        }
        else
        {
            fill(255, 0, 0); // Red for visibility
            circle(posx, posy, d);
        }
    }

    void update(float playerX, float playerY)
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
            
            // Hit bottom - start attracting
            if (posy + diameter/2 > height)
            {
                attracting = true;
                fired = false;
                targetX = playerX;
                targetY = playerY;
            }
        }
        else if (attracting)
        {
            PVector target = new PVector(targetX, targetY);
            PVector current = new PVector(posx, posy);
            PVector dir = PVector.sub(target, current);
            float dist = dir.mag();
            if (dist > 1)
            {
                dir.normalize();
                dir.mult(speed * 0.5);
                posx += dir.x;
                posy += dir.y;
            }
            else
            {
                attracting = false;
                posx = targetX;
                posy = targetY;
                velocity.set(0, 0);
            }
        }
        else if (isStatic)
        {
            // If caught, animate disappearance
            if (caught)
            {
                if (catchTimer == 0) catchTimer = 10;
                catchTimer--;
                // simple shrink effect
                float s = map(catchTimer, 10, 0, 1.0, 0);
                drawScale = s;
                if (catchTimer <= 0)
                {
                    destroyed = true;
                }
            }
        }
    }
}
