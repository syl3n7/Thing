class LevelGenerator
{
    int lastLevelGenerated = 0;
    
    int safeRandomIndex(int n)
    {
        if (n <= 0) return 0;
        int r = (int)random(n);
        if (r < 0) r = 0;
        if (r >= n) r = n - 1;
        return r;
    }
    void generate(int lvl)
    {
        // enemies.clear(); // Keep old enemies
        ArrayList<Float> columns = new ArrayList<Float>();
        int spacing = ENEMY_W + ENEMY_GAP;
        for (int i = 0; i <= width - ENEMY_W; i += spacing)
        {
            columns.add((float)i);
        }

        // Ensure we only spawn new rows when lvl > lastLevelGenerated
        if (lvl <= lastLevelGenerated) {
            // Spawn static balls only if needed
        } else {
            int rowsToAdd = 1; // spawn one new row per level increment
            int hits = lvl * 10; // new enemies get hits based on current level
            for(int row = 0; row < rowsToAdd; row++)
        {
                // Determine number of blocks to spawn for this level
                int numBlocks = min(columns.size(), 3 + lvl - 1); // e.g., lvl1=3, lvl2=4, lvl3=5
                // Cap the number of blocks to a maximum so it won't keep increasing indefinitely
                int maxBlocks = 5; // cap per design
                numBlocks = min(numBlocks, maxBlocks);
                numBlocks = min(numBlocks, choices.size());
                // Build choices excluding columns reserved by existing static balls
                ArrayList<Integer> choices = new ArrayList<Integer>();
                ArrayList<Integer> reservedCols = new ArrayList<Integer>();
                for (Balls sb : staticBalls)
                {
                    if (sb.gridCol >= 0) reservedCols.add(sb.gridCol);
                }
                for (int c = 0; c < columns.size(); c++) if (!reservedCols.contains(c)) choices.add(c);
                // shuffle choices
                for (int s = 0; s < choices.size(); s++)
                {
                    int swapIdx = (int)random(choices.size());
                    int tmp = choices.get(s);
                    choices.set(s, choices.get(swapIdx));
                    choices.set(swapIdx, tmp);
                }
                // pick first numBlocks columns
                for (int b = 0; b < numBlocks; b++)
                {
                    int colIdx = choices.get(b);
                            int swapIdx = safeRandomIndex(choices.size());
                    // spawn slightly above so animation brings them into view
                    float startY = 100 - VERTICAL_SPACING;
                    Enemy e = new Enemy(i, startY + row * VERTICAL_SPACING, ENEMY_W, ENEMY_H);
                    e.maxHits = hits;
                    e.hits = hits;
                    enemies.add(e);
                }
            }
            // add any boss if relevant
            if (lvl % 10 == 0)
            {
                Enemy boss = new Enemy(width/2 - ENEMY_W, 100 - VERTICAL_SPACING + VERTICAL_SPACING * rowsToAdd, ENEMY_W*2, ENEMY_H*2);
                boss.maxHits = 50;
                boss.hits = 50;
                enemies.add(boss);
            }
        }
        // Add static balls: spawn on enemy columns (grid), bigger than normal balls
        int numStatic = 1;
        if (lvl % 10 == 0) numStatic = 2;
        for (int i = 0; i < numStatic; i++)
        {
            // pick a random grid column
            // pick a random free column (not occupied by an enemy or another static ball)
            ArrayList<Integer> freeCols = new ArrayList<Integer>();
            ArrayList<Integer> reservedCols2 = new ArrayList<Integer>();
            for (Balls sb : staticBalls)
            {
                if (sb.gridCol >= 0) reservedCols2.add(sb.gridCol);
            }
            // also avoid columns where an alive enemy exists
            for (Enemy en : enemies)
            {
                for (int c = 0; c < columns.size(); c++)
                {
                    float columnX = columns.get(c);
                    if (abs(en.posx - columnX) < 0.1 && en.alive)
                    {
                        if (!reservedCols2.contains(c)) reservedCols2.add(c);
                    }
                }
            }
            for (int c = 0; c < columns.size(); c++) if (!reservedCols2.contains(c)) freeCols.add(c);
            if (freeCols.size() == 0) break;
            int colIndex = freeCols.get((int)random(freeCols.size()));
            float columnX = columns.get(colIndex);
            float centerX = columnX + ENEMY_W/2.0; // center of enemy column
            float dia = 12; // a little bit tinier than player balls (10) but visible
            staticBalls.add(new Balls(centerX, 50, dia, 5, colIndex));
            staticBalls.get(staticBalls.size()-1).isStatic = true;
        }

        lastLevelGenerated = lvl;
                    int colIndex = freeCols.get(safeRandomIndex(freeCols.size()));
}