class ZombieManager
{
  int animFrameCount = 20;//Animation has 20 frames
  PImage[] walkFrames = new PImage[animFrameCount];//Array of animation frames for walking
  
  
  //ArrayList of all zombies
  ArrayList<Zombie> zombieList;
  
  //Constructor
  //Param: numStartZombies - number of zombies to spawn
  ZombieManager(int numStartZombies)
  {
    zombieList = new ArrayList<Zombie>();
    
    for(int i = 0; i < numStartZombies; i++)
    {
      spawnZombie(random(EDGE_WIDTH,width-EDGE_WIDTH), random(EDGE_WIDTH,height-EDGE_WIDTH));//Spawn zombies at random positions
    }
    
    loadFrames();//Load images for animation
    
  }
  
  //Update all zombies
  void updateZombies()
  {
    for(int i = 0; i < zombieList.size(); i++)
    {
      zombieList.get(i).update();
    }
  }
  
  //Display all zombies
  void displayZombies()
  {
    for(int i = 0; i < zombieList.size(); i++)
    {
      zombieList.get(i).display();            
    }
  } 
  
  //Spawn a zombie at given position
  void spawnZombie(float x, float y)
  {
    //Spawns zombie at given x,y coords with radius 10, obstacle avoidance radius 100, chase radius 150, max speed 1, max force 0.05
    zombieList.add(new Zombie(x, y, 10,100,150,1,0.05));
  }
  
  //Load frames for animation
  void loadFrames()
  {
    for(int i = 0; i < animFrameCount; i++)
    {
      walkFrames[i] = loadImage("Sprites/Animations/Zombie/Walk/Zombie_Walk" + i + ".png");
      walkFrames[i].resize(100,100);     
    }           
  }
  
  
}