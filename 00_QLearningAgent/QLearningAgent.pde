import grafica.*;

int cellSize = 50;
Cell[][] grid;

PVector goal;
PVector agent;

int gridSize = 15;

int trainStep = 0;
int moveStep = 0;
boolean reset = true;

PrintWriter output;

int nPoints = 500;
GPointsArray points = new GPointsArray(nPoints);
GPlot plot;

void setup() {
  size(1000, 700, P3D);
    
  grid = new Cell[gridSize][gridSize];    
  
  for(int i = 0; i < gridSize; i++){
    for(int j = 0; j < gridSize; j++){
      grid[i][j] = new Cell(i*cellSize, j*cellSize, cellSize);
    }
  }
  
  goal = new PVector(int(gridSize/2), int(gridSize/2));    // initializing goal cell (x, y)
  for(int i = 0; i < gridSize; i++){                       // initializing grid cells 
    for(int j = 0; j < gridSize; j++){
      if(j == 0){
        grid[i][j].reward[3] = -1;        // Top boundary
      } else if(j == gridSize - 1){  
        grid[i][j].reward[1] = -1;        // Bottom boundary 
      }
      if(i == 0){
        grid[i][j].reward[2] = -1;        // Left boundary
      } else if(i == gridSize - 1){
        grid[i][j].reward[0] = -1;        // Right boundary
      }
    }
  }

  // To set rewards around goal destination
  grid[int(goal.x) - 1][int(goal.y)].reward[0] = 1000;
  grid[int(goal.x)][int(goal.y) - 1].reward[1] = 1000;
  grid[int(goal.x) + 1][int(goal.y)].reward[2] = 1000;
  grid[int(goal.x)][int(goal.y) + 1].reward[3] = 1000;
  grid[int(goal.x)][int(goal.y)].goal = true;

  plot = new GPlot(this);

  plot.setPos(5, 5);
  plot.setTitleText("Training result");
  plot.getXAxis().setAxisLabelText("Episodes");
  plot.getYAxis().setAxisLabelText("Move steps");
  plot.setDim(150, 150);
  plot.activatePanning();
  
}

void draw() {
  background(0);
  if (reset == true) {
    if(trainStep > 500){
      noLoop();
    }
    points.add(trainStep, moveStep);
    plot.setPoints(points);
    moveStep = 0;
    trainStep++;
    agent = new PVector(int(random(0, gridSize-1)), int(random(0, gridSize-1)));  // initial location setting
    reset = false;
  }

  int move = 0;
  do move = int(random(4));  // random choose
  while(grid[int(agent.x)][int(agent.y)].reward[move] == -1);

  for(int i = 0; i < 4; i++) {
    if (grid[int(agent.x)][int(agent.y)].qValue[i] > grid[int(agent.x)][int(agent.y)].qValue[move])  // Move to a place where the q value is greater.
      move = i;
  }

  PVector nextAgent = new PVector(agent.x, agent.y);

  if(move == 0){
    nextAgent.x++;
  } else if(move == 1){
    nextAgent.y++;
  } else if(move == 2){
    nextAgent.x--;
  } else{
    nextAgent.y--;
  }
  
  moveStep++;

  int nextQvalue = 0;
  for(int i = 0; i < 4; i++) {
    if(grid[int(nextAgent.x)][int(nextAgent.y)].qValue[i] > nextQvalue)  // Get maximum q value in next state
      nextQvalue = grid[int(nextAgent.x)][int(nextAgent.y)].qValue[i];
  }

  grid[int(agent.x)][int(agent.y)].qValue[move] = grid[int(agent.x)][int(agent.y)].reward[move] + int(0.5 * nextQvalue);  //Update q value
  agent = nextAgent;

  if (goal.x == agent.x && goal.y == agent.y){
        reset = true;
  }
  grid[int(agent.x)][int(agent.y)].agent = true;
  
  pushMatrix();
  camera(width/2, 1100, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  translate(200, 0, 0);
  for ( int i = 0; i < gridSize; i++) {
    for ( int j = 0; j < gridSize; j++) {
      grid[i][j].display();
    }
  }
  popMatrix();
  
  grid[int(agent.x)][int(agent.y)].agent = false;
  
  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTopAxis();
  plot.drawRightAxis();
  plot.drawTitle();
  plot.getMainLayer().drawPoints();
  plot.endDraw();
}
