class Agent {
  float r;
  int x, y;
  
  Agent(float reward) {
    r = reward;
    x = 0;
    y = 0;
  }
  
  void setLocation(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }
  
  void display() {
    stroke(0);
    fill(175);
    ellipse(x, y, r*2, r*2);
  }
  
  boolean intersect(Drop d) {
    float distance = dist(x, y, d.x, d.y);
    if (distance < r + d.r) {
      return true;
    } else {
      return false;
    }
  }
}
