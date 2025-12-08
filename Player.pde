class Player
{
    //posx, posy, w, h, balls, ismoving
    float posx;
    float posy;
    float w;
    float h;
    Balls[] balls;
    int nextBall;
    boolean firing = false;
    int fireDelayFrames = 2; // Delay for one ball to travel its own diameter (10 units at speed 5 = 2 frames)
    int lastFireFrame = 0;

    Player (float posx, float posy, float w, float h)
    {
        this.posx = posx;
        this.posy = posy;
        this.w = w;
        this.h = h;
        this.balls = new Balls[10]; // Array of 10 balls
        this.nextBall = 0;
        
        // Initialize balls at player position
        for (int i = 0; i < balls.length; i++) 
        {
            balls[i] = new Balls(posx + w/2, posy, 10, 5); // diameter 10, speed 5
        }
    }

    void drawme()
    {
        rect(posx, posy, w, h);
        
        // Draw aim line to mouse
        stroke(255);
        line(posx + w/2, posy, mouseX, mouseY);
        noStroke();
        
        // Handle sequential firing with delay
        if (firing && frameCount - lastFireFrame > fireDelayFrames) 
        {
            if (nextBall < balls.length) 
            {
                PVector dir = new PVector(mouseX - (posx + w/2), mouseY - posy);
                dir.normalize();
                balls[nextBall].velocity = dir.mult(balls[nextBall].speed);
                balls[nextBall].fired = true;
                nextBall++;
                lastFireFrame = frameCount;
            }
            else 
            {
                firing = false;
            }
        }
        
        // Draw balls
        for (Balls b : balls)
        {
            b.update();
            b.drawme();
        }
    }
    
    void fireBall()
    {
        firing = true;
        nextBall = 0;
        lastFireFrame = frameCount;
    }

    void moveme()
    {

    }
}
