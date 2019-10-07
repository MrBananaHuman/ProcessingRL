class Cell{
  int x;
  int y;
  int size;
  boolean goal;
  boolean agent;
  
  int[] reward;
  int[] qValue;
  
  Cell (int x_, int y_, int size_){
    x = x_;
    y = y_;
    size = size_;
    goal = false;
    agent = false;
    
    reward = new int[4];
    qValue = new int[4];

    for(int i = 0; i < 4; i++){
      reward[i] = 0;
      qValue[i] = 0;
    }
  }
  void display(){
    stroke(200);
    if(goal){
      fill(100, 255, 100);
      rect(x, y, size, size);
    } else if(agent){
      fill(255, 100, 100);
      pushMatrix();
      translate(x + size/2, y + size/2);
      box(size);
      popMatrix();
      rect(x, y, size, size);
    } else{
      fill(255);
      rect(x, y, size, size);
    }
  }
}
