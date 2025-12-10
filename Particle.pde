class Particle {
  float x, y, r;
  boolean vertical; // true: up/down arrows, false: left/right arrows
  boolean active = true;
  int flashTimer = 0;

  Particle(float x_, float y_, float r_, boolean vertical_) {
    x = x_;
    y = y_;
    r = r_;
    vertical = vertical_;
  }

  void drawme() {
    if (!active) return;
    noStroke();
    if (flashTimer > 0) {
      fill(0, 255, 80); // Green flash
      flashTimer--;
    } else {
      fill(10, 20, 60); // Navy blue
    }
    ellipse(x, y, r*2, r*2);
    stroke(255);
    strokeWeight(2);
    float arrowLen = r * 0.7;
    float arrowW = r * 0.25;
    if (vertical) {
      // Up arrow
      line(x, y, x, y-arrowLen);
      line(x, y-arrowLen, x-arrowW, y-arrowLen+arrowW);
      line(x, y-arrowLen, x+arrowW, y-arrowLen+arrowW);
      // Down arrow
      line(x, y, x, y+arrowLen);
      line(x, y+arrowLen, x-arrowW, y+arrowLen-arrowW);
      line(x, y+arrowLen, x+arrowW, y+arrowLen-arrowW);
    } else {
      // Left arrow
      line(x, y, x-arrowLen, y);
      line(x-arrowLen, y, x-arrowLen+arrowW, y-arrowW);
      line(x-arrowLen, y, x-arrowLen+arrowW, y+arrowW);
      // Right arrow
      line(x, y, x+arrowLen, y);
      line(x+arrowLen, y, x+arrowLen-arrowW, y-arrowW);
      line(x+arrowLen, y, x+arrowLen-arrowW, y+arrowW);
    }
    strokeWeight(1);
  }
}
