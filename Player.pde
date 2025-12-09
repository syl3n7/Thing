class Player
{
    //posx, posy, w, h, balls, ismoving
    float posx;
    float posy;
    float w;
    float h;
    int nextBall;
    boolean firing = false;
    int fireDelayFrames = 2; // Delay for one ball to travel its own diameter (10 units at speed 5 = 2 frames)
    int lastFireFrame = 0;
    ArrayList<Balls> balls = new ArrayList<Balls>();
    float speed = 5; // Movement speed
    boolean canFire = true;
    PVector fireDir;
    boolean firedThisLevel = false;
    int baseBalls = 10;
    int ballsLaunched = 0; // Track how many balls launched this round

    Player (float posx, float posy, float w, float h)
    {
        this.posx = posx;
        this.posy = posy;
        this.w = w;
        this.h = h;
        // balls is already declared as ArrayList
        this.nextBall = 0;
        
        // Initialize balls at player position
        for (int i = 0; i < 10; i++) 
        {
            balls.add(new Balls(posx + w/2, posy, 10, 5)); // diameter 10, speed 5
        }
    }

    void addBall(float posx, float posy, float diameter, float speed)
    {
        balls.add(new Balls(posx, posy, diameter, speed));
    }

    void resetBalls(int extra)
    {
        balls.clear();
        nextBall = 0;
        firing = false;
        canFire = true;
        firedThisLevel = false;
        ballsLaunched = 0;
        for (int i = 0; i < baseBalls + extra; i++)
        {
            balls.add(new Balls(posx + w/2, posy, 10, 5));
        }
    }

    void drawme(int collected)
    {
        fill(255);
        rect(posx, posy, w, h);
        
        // Draw aim line to mouse
        stroke(255);
        line(posx + w/2, posy, mouseX, mouseY);
        noStroke();
        
        // Draw ball count
        fill(0);
        textSize(12);
        textAlign(LEFT);
        text("(x" + baseBalls + " + " + collected + ")", posx + w + 5, posy + h/2);
        
        // Handle sequential firing with delay
        
        // Handle sequential firing with delay
        if (firing && frameCount - lastFireFrame > fireDelayFrames) 
        {
            if (nextBall < balls.size()) 
            {
                balls.get(nextBall).velocity = fireDir.copy().mult(balls.get(nextBall).speed);
                balls.get(nextBall).fired = true;
                if (ballsLaunched == 0) firedThisLevel = true; // only mark as fired when first ball actually launches
                ballsLaunched++; // increment
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
            if (!b.fired && !b.attracting)
            {
                b.posx = posx + w/2;
                b.posy = posy;
            }
            b.update(posx + w/2, posy);
            b.drawme();
        }
    }
    
    void fireBall()
    {
        if (canFire && !firedThisLevel)
        {
            PVector mousePos = new PVector(mouseX, mouseY);
            PVector firePos = new PVector(posx + w/2, posy);
            fireDir = PVector.sub(mousePos, firePos);
            if (fireDir.mag() < 0.01) return; // don't start firing if the aim is too close to player
            fireDir.normalize();
            firing = true;
            nextBall = 0;
            lastFireFrame = frameCount;
        }
    }

    void moveme()
    {
        if (keyPressed)
        {
            if (key == 'a' || key == 'A') {
                posx -= speed;
            } else if (key == 'd' || key == 'D') {
                posx += speed;
            }
        }
        posx = constrain(posx, 0, width - w);
    }
}
