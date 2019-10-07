Catcher catcher;
Timer timer;
Fail fail;
Success success;
Drop[] drops;

int totalDrops = 0;

void setup() {
  size(580, 400);
  
  catcher = new Catcher(22);
  drops = new Drop[1000];
  timer = new Timer(300);
  fail = new Fail(10);
  success = new Success(100);
  
  timer.start();
  
  smooth();
}

void draw() {
  background(240);
  catcher.setLocation(mouseX, mouseY);
  catcher.display();
  
  if (timer.isFinished()) {
    drops[totalDrops] = new Drop();
    totalDrops++;
    if (totalDrops >= drops.length) {
      totalDrops = 0;
  }
   timer.start();
  }
  
  for (int i = 0; i < totalDrops; i++) {
    drops[i].display();
    drops[i].move();
    if (catcher.intersect(drops[i])) {
      drops[i].caught();
      success.numberCaught += 1;
    }
     if (drops[i].reachedBottom()) {
       fail.currentScore += 1;
    }
  }
  
  fail.display();
  success.display();
}


class Fail {
  boolean reachedBottom;
  int currentScore;
  int finalScore;
  float h;
  float w;
  color c;
  
  Fail(int tempFinalScore) {
    currentScore = 0;
    finalScore = tempFinalScore;
    h = height/finalScore;
    w = 20;
    c = color(200, 0, 0, 75);
    reachedBottom = false;
  }
  
  void display() {
    noStroke();
    fill(c);
    rect(width-w, h*currentScore, w, height);
    stroke(0);
    line(width-w, 0, width-w, height);
    for (int i = 0; i <= finalScore; i++) {
      stroke(0);
      line(width-w, i*h, width, i*h);
    }
  }
}



class Success {
  boolean caught;
  int numberCaught;
  int targetNumber;
  float h;
  float w;
  color c;
  
  Success(int tempTargetNumber) {
    targetNumber = tempTargetNumber;
    numberCaught = 0;
    h = height/targetNumber;
    w = 20;
    caught = false;
    c = color(0, 200, 0, 75);
  }
  
  void display() {
    noStroke();
    fill(c);
    rect(0, height - h*numberCaught, w, h*numberCaught);
    stroke(0);
    line(w, 0, w, height);
    for (int i = 0; i <= targetNumber; i++) {
      stroke(0);
      line(0, i*h, w, i*h);
    }
  }
}

class Timer {
  int savedTime;
  int totalTime;
  
  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }
  
  void start() {
    savedTime = millis();
  }
  
  boolean isFinished() {
    int passedTime = millis() - savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
