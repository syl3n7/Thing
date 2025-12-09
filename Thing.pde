import processing.sound.*;
// Sound objects
SoundFile sndPickup, sndEnemyGone, sndEnemyHit, sndSpawn;
// Fast-forward logic
int lastActiveFrame = 0;
int fastForwardThresholdFrames = 60 * 10; // 10 seconds at 60 fps
boolean fastForwarding = false;
import java.awt.*;
import java.util.ArrayList;
import processing.core.PVector;

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
boolean allBallsBack = true;

void setup() 
{
    // Load sound files (place these .wav files in your sketch folder)
    sndPickup = new SoundFile(this, "spawn.mp3");
    sndEnemyGone = new SoundFile(this, "enemy_hit.mp3");
    sndEnemyHit = new SoundFile(this, "enemy_hit.mp3");
    sndSpawn = new SoundFile(this, "spawn.mp3");
    
    smooth(8);
    size(500, 500);
    pixelDensity(2);
    frameRate(60);
    
    surface.setTitle("Thing by syl3n7");

    float playerW = 25;
    float playerH = 25;
    p = new Player(width/2 - playerW/2, height - playerH, playerW, playerH);
    lg = new LevelGenerator();
    lg.generate(level);
    p.resetBalls(collectedBalls);
}

// Compute a predicted path from a starting point along a normalized direction directionDir
// steps size determines the simulation resolution; maxHits indicates how many enemy collisions to simulate
ArrayList<PVector> computePredictedPath(PVector start, PVector directionDir, int maxHits, float stepSize)
{
    ArrayList<PVector> path = new ArrayList<PVector>();
    PVector pos = start.copy();
    PVector v = directionDir.copy().normalize().mult(stepSize);
    path.add(pos.copy());
    int hits = 0;
    int maxSteps = 2000;
    float radius = (p.balls.size() > 0) ? p.balls.get(0).diameter/2 : 5;
    for (int s = 0; s < maxSteps && hits < maxHits; s++)
    {
        PVector nextPos = PVector.add(pos, v);
        boolean hitSomething = false;
        // check collision with enemies
        for (Enemy en : enemies)
        {
            if (!en.alive) continue;
            if (nextPos.x + radius >= en.posx && nextPos.x - radius <= en.posx + en.w && nextPos.y + radius >= en.posy && nextPos.y - radius <= en.posy + en.h)
            {
                // register collision at nextPos
                path.add(nextPos.copy());
                float centerX = en.posx + en.w/2;
                float centerY = en.posy + en.h/2;
                if (nextPos.x < centerX) v.x = -abs(v.x);
                else v.x = abs(v.x);
                if (nextPos.y < centerY) v.y = -abs(v.y);
                else v.y = abs(v.y);
                hitSomething = true;
                hits++;
                pos = nextPos.copy();
                break;
            }
        }
        if (hitSomething) continue;
        // check screen bounds bounce (left/right/top); bottom stops simulation
        if (nextPos.x - radius < 0)
        {
            nextPos.x = radius;
            v.x *= -1;
            path.add(nextPos.copy());
            pos = nextPos.copy();
            continue;
        }
        if (nextPos.x + radius > width)
        {
            nextPos.x = width - radius;
            v.x *= -1;
            path.add(nextPos.copy());
            pos = nextPos.copy();
            continue;
        }
        if (nextPos.y - radius < 0)
        {
            nextPos.y = radius;
            v.y *= -1;
            path.add(nextPos.copy());
            pos = nextPos.copy();
            continue;
        }
        // if bottom - stop prediction; ball magnetizes on bottom, so break
        if (nextPos.y + radius > height)
        {
            path.add(nextPos.copy());
            break;
        }
        // no collisions - continue
        pos = nextPos.copy();
    }
    path.add(pos.copy());
    return path;
}

void draw()
{
    background(0);
    if (!gameOver)
    {
        // Draw thick, dotted predicted trajectory line
        if (!p.firedThisLevel && p.canFire)
        {
            PVector start = new PVector(p.posx + p.w/2, p.posy);
            PVector dir = new PVector(mouseX - start.x, mouseY - start.y);
            if (dir.mag() > 0.01)
            {
                ArrayList<PVector> path = computePredictedPath(start, dir, 3, 4); // 3 enemy bounces, step size 4
                stroke(0, 255, 255);
                strokeWeight(5);
                float dotLen = 12;
                float gapLen = 8;
                for (int i = 0; i < path.size() - 1; i++)
                {
                    PVector a = path.get(i);
                    PVector b = path.get(i+1);
                    float segLen = dist(a.x, a.y, b.x, b.y);
                    PVector dirSeg = PVector.sub(b, a).normalize();
                    float drawn = 0;
                    while (drawn < segLen)
                    {
                        float d1 = min(dotLen, segLen - drawn);
                        float x1 = a.x + dirSeg.x * drawn;
                        float y1 = a.y + dirSeg.y * drawn;
                        float x2 = a.x + dirSeg.x * (drawn + d1);
                        float y2 = a.y + dirSeg.y * (drawn + d1);
                        line(x1, y1, x2, y2);
                        drawn += d1 + gapLen;
                    }
                }
                strokeWeight(1);
                stroke(255);
            }
        }
        boolean anyBallActive = false;
        boolean anyBallHit = false;
        p.moveme();
        p.drawme(collectedBalls);
        
        // Improved: Check collisions using circle-rectangle collision and reflect velocity
        for (Enemy en : enemies)
        {
            if (en.alive)
            {
                for (Balls b : p.balls)
                {
                    if (b.fired)
                    {
                        anyBallActive = true;
                        // Find closest point on enemy rectangle to ball center
                        float closestX = constrain(b.posx, en.posx, en.posx + en.w);
                        float closestY = constrain(b.posy, en.posy, en.posy + en.h);
                        float dx = b.posx - closestX;
                        float dy = b.posy - closestY;
                        float distSq = dx*dx + dy*dy;
                        float radius = b.diameter/2;
                        if (distSq <= radius*radius)
                        {
                            en.hit();
                            anyBallHit = true;
                            // Calculate collision normal
                            PVector normal = new PVector(dx, dy);
                            if (normal.magSq() == 0) {
                                // Ball center is inside rectangle; pick largest penetration axis
                                float left = abs(b.posx - en.posx);
                                float right = abs(b.posx - (en.posx + en.w));
                                float top = abs(b.posy - en.posy);
                                float bottom = abs(b.posy - (en.posy + en.h));
                                float minDist = min(min(left, right), min(top, bottom));
                                if (minDist == left) normal = new PVector(-1, 0);
                                else if (minDist == right) normal = new PVector(1, 0);
                                else if (minDist == top) normal = new PVector(0, -1);
                                else normal = new PVector(0, 1);
                            } else {
                                normal.normalize();
                            }
                            // Reflect velocity
                            float dot = b.velocity.dot(normal);
                            b.velocity = PVector.sub(b.velocity, PVector.mult(normal, 2 * dot));
                            // Move ball out of collision
                            float overlap = radius - sqrt(distSq) + 0.1;
                            b.posx += normal.x * overlap;
                            b.posy += normal.y * overlap;
                        }
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
            // If the static ball is close enough to the player, catch it immediately
            float playerCatchX = p.posx + p.w/2;
            float playerCatchY = p.posy;
            float catchDist = (sb.diameter + 10) / 2 + 2; // 10 is player ball diameter, add small buffer
            if (dist(sb.posx, sb.posy, playerCatchX, playerCatchY) < catchDist)
            {
                p.addBall(sb.posx, sb.posy, sb.diameter, sb.speed);
                collectedBalls++;
                staticBalls.remove(i);
                if (sndPickup != null) sndPickup.play();
                continue;
            }
            if (sb.destroyed)
            {
                // finalize catch (fallback)
                p.addBall(sb.posx, sb.posy, sb.diameter, sb.speed);
                collectedBalls++;
                staticBalls.remove(i);
                if (sndPickup != null) sndPickup.play();
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

        // Fast-forward logic: if no ball hit for 10 seconds, attract all balls
        if (anyBallHit) {
            lastActiveFrame = frameCount;
            fastForwarding = false;
        }
        if (anyBallActive && !anyBallHit && frameCount - lastActiveFrame > fastForwardThresholdFrames) {
            // Fast-forward: attract all balls
            for (Balls b : p.balls) {
                if (b.fired) {
                    b.fired = false;
                    b.attracting = true;
                }
            }
            fastForwarding = true;
        }
        if (!anyBallActive) {
            lastActiveFrame = frameCount;
            fastForwarding = false;
        }
        
        // Remove destroyed enemies
        for(int i = enemies.size()-1; i >= 0; i--)
        {
            if (enemies.get(i).destroyed)
            {
                if (sndEnemyGone != null) sndEnemyGone.play();
                enemies.remove(i);
            }
        }
        
        // Check if all balls are back to player
        allBallsBack = true;
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
