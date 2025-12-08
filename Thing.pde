Player p;
Enemies e = new Enemies(25, 25, 10, 10);

void setup() 
{
    size(500, 500);
    pixelDensity(2);
    frameRate(23);

    float playerW = 25;
    float playerH = 25;
    p = new Player(width/2 - playerW/2, height - playerH, playerW, playerH);
    for(int i = 0; i <= width-8; i += 8)
    {
        println(i);
        for(int j = 0; j <= height-8; j += 8)
        {
            println(j);

        }
    }
}

void draw()
{
    background(0);
    p.drawme();
    e.drawme();
}

void mousePressed() 
{
    p.fireBall();
}
