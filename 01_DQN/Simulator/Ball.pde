class Ball {
  float x, y;
  float speed;
  float r;
  color c;
  
  Ball() {
    r = 8;
    x = random(40, width-40);
    y = -r*4;
    speed = random(1, 5);
    c = color(50, 100, 100);
  }
  
  void move() {
    y += speed;
  }
  
  void display() {
    stroke(0);
    fill(c);
    for (int i = 2; i < 8; i++) {
      noStroke();
      fill(c);
      ellipse(x, y + i*4, i*2, i*2);
    }
  }
}
