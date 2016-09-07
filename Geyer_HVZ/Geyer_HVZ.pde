static final int EDGE_WIDTH = 75;//Width of edges of map

float oldTime,newTime,deltaTime;//Use to calculate delta time between frames

HumanManager humanManager;//Manages updating and displaying humans
ZombieManager zombieManager;//Manages updating and displaying zombies
ObstacleManager obstacleManager;//Manages spawning and drawing obstacles

PImage backgroundImage;

boolean debugColliders;//Show vehicle and obstacle colliders, activated with 1 key
boolean debugMovement;//Show vehicle forces and velocity, activated with 2 key
boolean debugChase;//Show lines to points pursuing toward or evading from, activated with 3

boolean debugShowAll;//Show all debug information at once, activated with 4


void setup()
{
  size(1280,720,P2D);//Set size to 720p
  frameRate(999);//Unlock framerate 
 
  //Start with 5 humans and 5 zombies
  humanManager = new HumanManager(5);
  zombieManager = new ZombieManager(5);
  obstacleManager = new ObstacleManager();
  
  debugColliders = false;
  debugMovement = false;
  debugChase = false;  
  debugShowAll = false;
  
  imageMode(CENTER);//Set image mode to center for drawing sprites
  
  backgroundImage = loadImage("Sprites/MapTexture.png");//Load image for background
  
  newTime = 0;
  
}

void draw()
{
  //Calculate deltaTime
  oldTime = newTime;
  newTime = millis();
  deltaTime = (newTime-oldTime)/1000;
  
  //Use background image as background
  background(backgroundImage);
  
  //If in debug movement mode, draw red, transparent edge zones where vehicles will turn around
  if(debugMovement)
  {
    noStroke();
    fill(255,0,0,128);
    rect(0,0,width,EDGE_WIDTH); 
    rect(0,0,EDGE_WIDTH,height);
    rect(width-EDGE_WIDTH,0,EDGE_WIDTH,height);
    rect(0,height-EDGE_WIDTH,width,EDGE_WIDTH);
    stroke(0);
    
  }
    
  //Update and display humans
  humanManager.updateHumans();
  humanManager.displayHumans();
  
  //Update and display zombies
  zombieManager.updateZombies();
  zombieManager.displayZombies();
  
  //Display obstacles
  obstacleManager.displayObstacles();
}

void keyReleased()
{
  //If pressed and released 1 key, show collision information for obstacles and vehicles
  if(key == '1')
  {
    debugColliders = !debugColliders;

    debugShowAll = false;
  }
  //If pressed and released 2 key, show forces and velocity of vehicles
  else if(key == '2')
  {
    debugMovement = !debugMovement;

    debugShowAll = false;
  }
  //If pressed and released 3 key, show information related to pursuing/evading
  else if(key == '3')
  {
    debugChase = !debugChase;
    
    debugShowAll = false;
  }
  //If pressed and released 4 key, show all debug information at once
  else if(key == '4')
  {
    debugShowAll = !debugShowAll;
    
    debugMovement = debugShowAll;
    debugColliders = debugShowAll;
    debugChase = debugShowAll;
  }
  
}

void mouseReleased()
{
  //If left mouse button clicked, spawn a human
  if(mouseButton == LEFT)
    humanManager.spawnHuman(mouseX,mouseY); 
  //If right mouse button clicked, spawn a zombie
  else if(mouseButton == RIGHT)
    zombieManager.spawnZombie(mouseX,mouseY);
  
}