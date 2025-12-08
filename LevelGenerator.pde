class LevelGenerator
{
    void generate(int lvl)
    {
        enemies.clear();
        staticBalls.clear();
        int numLines = lvl / 3 + 1; // Increase lines more frequently
        int hits = lvl * 10; // Hits increase by 10 per level
        for(int row = 0; row < numLines; row++)
        {
            for(int i = 0; i <= width - 20; i += 28)
            {
                Enemy e = new Enemy(i, 100 + row * 18, 20, 10);
                e.maxHits = hits;
                e.hits = hits;
                enemies.add(e);
            }
        }
        // Add boss every 10 levels
        if (lvl % 10 == 0 && lvl > 0)
        {
            Enemy boss = new Enemy(width/2 - 20, 100 + numLines * 18, 40, 20);
            boss.maxHits = 50;
            boss.hits = 50;
            enemies.add(boss);
        }
        // Add static balls: 1-2 per 3 levels, more on 10
        staticBalls.clear();
        int numStatic = 0;
        if (lvl % 10 == 0) numStatic = 2;
        else if (lvl % 3 == 0) numStatic = 1;
        for (int i = 0; i < numStatic; i++)
        {
            float x = width/2 + (i - (numStatic-1)/2.0) * 150; // Spread apart
            staticBalls.add(new Balls(x, 50, 10, 5));
            staticBalls.get(staticBalls.size()-1).isStatic = true;
        }
    }
}