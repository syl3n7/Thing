import java.awt.*;

Player p;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Balls> staticBalls = new ArrayList<Balls>();
int level = 1;
boolean gameOver = false;
LevelGenerator lg;
int collectedBalls = 0;
String deathText = "Game Over";
String displayText = "";
int textIndex = 0;
boolean animatingDown = false;
float downSpeed = 2;
float moveDownRemaining = 0;
// Grid & enemy constants
int ENEMY_W = 28;
int ENEMY_H = 20;
int ENEMY_GAP = 8;
int VERTICAL_SPACING = ENEMY_H + ENEMY_GAP;

void setup() 
{
    surface.setTitle("Thing by syl3n7");
    
    smooth(8);
    size(500, 500);
    pixelDensity(2);
    frameRate(144);

    float playerW = 25;
    float playerH = 25;
    p = new Player(width/2 - playerW/2, height - playerH, playerW, playerH);
    lg = new LevelGenerator();
    lg.generate(level);
    p.resetBalls(collectedBalls);
}

void draw()
{
    background(0);
    if (!gameOver)
    {
        p.moveme();
        p.drawme(collectedBalls);
        
        // Check collisions
        for (Enemy en : enemies)
        {
            if (en.alive)
            {
                for (Balls b : p.balls)
                {
                    if (b.fired && b.posx >= en.posx && b.posx <= en.posx + en.w && b.posy >= en.posy && b.posy <= en.posy + en.h)
                    {
                        en.hit();
                        // Bounce ball away from enemy center
                        float centerX = en.posx + en.w/2;
                        float centerY = en.posy + en.h/2;
                        if (b.posx < centerX) b.velocity.x = -abs(b.velocity.x);
                        else b.velocity.x = abs(b.velocity.x);
                        if (b.posy < centerY) b.velocity.y = -abs(b.velocity.y);
                        else b.velocity.y = abs(b.velocity.y);
                    }
                }
            }
        }
        
        for(Enemy en : enemies) { en.update(); en.drawme(); }
        
        // Draw and check static balls with catch animation
        for(int i = staticBalls.size()-1; i >= 0; i--)
        {
            Balls sb = staticBalls.get(i);
            // update any animation
            sb.update(p.posx + p.w/2, p.posy);
            if (sb.destroyed)
            {
                // finalize catch
                p.addBall(sb.posx, sb.posy, sb.diameter, sb.speed);
                collectedBalls++;
                staticBalls.remove(i);
                continue;
            }
            fill(0, 200, 255, sb.caught ? map(sb.catchTimer, 10, 0, 255, 0) : 255); // Aqua to stand out
            circle(sb.posx, sb.posy, sb.diameter);
            fill(255);
            if (!sb.caught)
            {
                for(Balls b : p.balls)
                {
                    if (b.fired && dist(b.posx, b.posy, sb.posx, sb.posy) < (b.diameter + sb.diameter)/2 )
                    {
                        // start catch animation
                        sb.caught = true;
                        sb.catchTimer = 10;
                        break;
                    }
                }
            }
        }
        
        // Remove destroyed enemies
        for(int i = enemies.size()-1; i >= 0; i--)
        {
            if (enemies.get(i).destroyed)
            {
                enemies.remove(i);
            }
        }
        
        // Check if all balls are back to player
        boolean allBallsBack = true;
        for (Balls b : p.balls)
        {
            if (b.fired || b.attracting)
            {
                allBallsBack = false;
                break;
            }
        }
        if (p.firedThisLevel && p.ballsLaunched > 0 && allBallsBack && !animatingDown)
        {
            animatingDown = true;
            moveDownRemaining = VERTICAL_SPACING;
        }
        
        // Animate moving down
        if (animatingDown)
        {
            for (Enemy en : enemies)
            {
                en.posy += downSpeed;
            }
            moveDownRemaining -= downSpeed;
            if (moveDownRemaining <= 0)
            {
                animatingDown = false;
                level++;
                lg.generate(level);
                p.resetBalls(collectedBalls);
            }
        }
    }
    else
    {
        // Animate death text
        if (frameCount % 5 == 0 && textIndex < deathText.length())
        {
            displayText += deathText.charAt(textIndex);
            textIndex++;
        }
        
        // Debug overlay HUD
        fill(0, 0, 0, 120);
        rect(5, 5, 230, 156);
        fill(255);
        textSize(12);
        textAlign(LEFT);
        text("Lvl: " + level, 10, 20);
        text("Enemies: " + enemies.size(), 10, 36);
        text("Static: " + staticBalls.size(), 10, 52);
        text("FiredThisLevel: " + p.firedThisLevel, 10, 68);
        text("BallsLaunched: " + p.ballsLaunched, 10, 84);
        text("CanFire: " + p.canFire, 10, 100);
        text("AnimatingDown: " + animatingDown, 10, 116);
        text("AllBallsBack: " + allBallsBack, 10, 132);
        textAlign(CENTER);
        textSize(24);
        fill(255);
        text(displayText, width/2, height/2);
        textSize(16);
        text("Press R to restart", width/2, height/2 + 30);
    }
}

void keyPressed()
{
    if (gameOver && key == 'r')
    {
        gameOver = false;
        level = 1;
        lg.generate(level);
        p.resetBalls(collectedBalls);
        displayText = "";
        textIndex = 0;
    }
}

void mousePressed() 
{
    //println("mouse pressed");
    if (!animatingDown)
    {
        p.fireBall();
    }
}
