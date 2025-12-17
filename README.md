# Thing ✅

**A small Processing game** where you launch bouncing balls to break enemies, collect extra balls, and use special particles to clear rows or columns.

**Inspired by BBTAN** — the core ball-launching and brick-clearing mechanics are based on the popular mobile game BBTAN.

---

## 🎮 Quick Overview

- Launch balls from the player at the bottom to hit and destroy enemies.
- Collect static balls to increase your ammo for future rounds.
- Special particles appear on the field — when hit they clear an entire **row** (horizontal particle) or **column** (vertical particle).
- When all balls return, enemies move down one step; survive as long as you can.

## ⚙️ Requirements

- Processing 3.x or 4.x (Java mode)
- Optional: `processing.sound` library (used for .wav files)

## ▶️ How to run

- Open the `Thing` sketch in the Processing IDE (open the folder and run `Thing.pde`).
- Or use the command-line tool `processing-java` (if installed):

```
processing-java --sketch=/path/to/Thing --run
```

> Note: Sound files referenced in the sketch (e.g., `pickup.wav`, `spawn.wav`) should be placed in the sketch folder for sound effects to play. The game will still run without them.

## ⌨️ Controls

- Move left: `A` or `a`
- Move right: `D` or `d`
- Aim: move your mouse
- Fire: click the mouse (launches the balls in sequence)
- Restart after Game Over: press `R`

## �️ Gameplay

- Launch a volley of balls from the player at the bottom of the screen to hit and destroy enemies.
- Balls are launched sequentially (small delay between each ball) toward the mouse cursor.- The core gameplay loop is heavily inspired by **BBTAN** (a brick-breaking / ball-launching mobile game): aim, launch, collect, repeat.- When all balls have returned to the player, enemies shift downward one row and the next level is generated.
- Collect static (blue/aqua) balls to permanently increase your available balls for future rounds.
- Special particles (navy circles with arrows) clear an entire row (horizontal particle) or column (vertical particle) when hit.
- The game ends when enemies reach the player area (Game Over); press `R` to restart.

## ⚙️ Mechanics (detailed)

- Player
  - Moves left/right with `A`/`D` keys. The player's rectangle and an aim line show the current aim toward the mouse.
  - `baseBalls` starts at 10; collecting static balls increments your count for future levels.

- Firing & Balls
  - Clicking the mouse starts firing. Balls are launched one-by-one in the same direction (small per-ball delay controlled by `fireDelayFrames`).
  - Balls bounce off the left/right walls and the top of the screen. If a ball reaches the bottom, it becomes "attracting" and returns to the player.
  - If balls become inactive (no hits for a configurable timeout), the game will fast-forward and attract all fired balls back to the player.

- Collisions
  - Ball vs enemy collisions use circle-rectangle collision detection; collisions reflect the ball's velocity across the collision normal.
  - Enemies have a `hits`/`maxHits` counter; `hit()` reduces hits and triggers a death animation when hits reach zero.
  - Particles: when a particle is hit, the game iterates enemies and calls `hit()` for every enemy in the same row (horizontal) or column (vertical).
  - Static (grid) balls are spawned by the level generator in free columns; hitting one starts a short "caught" animation and adds the ball to the player.

- Level generation
  - `LevelGenerator` adds one new row per level increase and scales enemy `hits` with `lvl * 10`.
  - A boss enemy (larger, heavy HP) is spawned every 10 levels.
  - Static collectible balls are spawned per-level and avoid columns that already contain enemies or other static balls.

- Visual aids & UI
  - A dotted predicted trajectory line is drawn to preview bounces and up to a few future collisions.
  - Ball count is shown near the player as `(x base + collected)`.
  - Sounds (if present): `pickup.wav`, `enemy_gone.wav`, `enemy_hit.wav`, `spawn.wav` are played at relevant events.

## 🛠️ Developer notes

- Tweak these constants in `Thing.pde` to change gameplay pacing:
  - `ENEMY_W`, `ENEMY_H`, `ENEMY_GAP` — enemy grid sizing
  - `VERTICAL_SPACING` — how far rows move down each level
  - `fastForwardThresholdFrames` — how long to wait before fast-forwarding inactive balls
  - `baseBalls` in `Player.pde` — starting number of balls
- `LevelGenerator.generate(level)` determines enemies, static ball placement, and boss spawns.
- Collision logic and bounce/reflection behaviour are implemented in `Thing.pde` (circle-rectangle collision with normal reflection) and `Balls.pde` (wall/top bounce, bottom attract).
- For sounds, drop the `.wav` files into the sketch folder (same directory as the `.pde` files).

## 🗂️ Project files (high level)

- `Thing.pde` — main loop, collision handling, level/particle spawning, UI, and game state
- `Player.pde` — player movement, firing logic, ball management
- `Balls.pde` — ball movement, bounce/attract logic and static-ball catching animation
- `Enemies.pde` — enemy state, hit/dying animation
- `Particle.pde` — particle appearance (vertical/horizontal) and flash effect when triggered
- `LevelGenerator.pde` — logic for spawning rows, bosses, and static balls
- `Data/` — optional assets (sound files)

## 👤 Author

**Cláudio da Silva Pinheiro**

## 👩‍💻 Contributing

- Pull requests and issues are welcome. Suggested improvements: balance tuning, additional enemy types, shader/visual polish, accessibility controls, or more sound/assets.

## 📝 License

This project is released under the **MIT License** — see the `LICENSE` file for details.

---
