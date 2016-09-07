class HumanManager
{
  int animFrameCount = 20;//Animation has 20 frames
  PImage[] walkFrames = new PImage[animFrameCount];//Array of animation frames
   
 //ArrayList of all currently living humans
  ArrayList<Human> humanList;
  
  //Constructor
  //Param: numStartHumans - number of humans to initially spawn
  HumanManager(int numStartHumans)
  {
    humanList = new ArrayList<Human>();
    
    //Spawn given number of humans
    for(int i = 0; i < numStartHumans; i++)
    {
      spawnHuman(random(EDGE_WIDTH,width-EDGE_WIDTH), random(EDGE_WIDTH,height-EDGE_WIDTH));
    }
    
    loadFrames();//Load images for animation
    
  }
  
  //Run through all humans and update them
  void updateHumans()
  {
    for(int i = 0; i < humanList.size(); i++)
    {
      //If a human is now dead, turn it into a zombie, remove it from the list, and decrement i
      if(!humanList.get(i).alive)
      {
        turnToZombie(i);
        i--;
      }
      //Otherwise, update the human
      else
      {
        humanList.get(i).update();
      }            
    }
  }
  
  //Display all humans
  void displayHumans()
  {
    for(int i = 0; i < humanList.size(); i++)
    {
      humanList.get(i).display();
    }
  }
  
  //Turn human at given index into a zombie
  void turnToZombie(int index)
  {    
    //Spawn a zombie at their position
    zombieManager.spawnZombie(humanList.get(index).position.x,humanList.get(index).position.y);
    
    humanList.remove(index);//Destroy human by removing them from list
    
  }
  
  //Spawn a human at given position
  void spawnHuman(float x, float y)
  {
    //Humans spawn at x,y and have radius 10, obstacle avoidance radius 100, chase radius 150, max speed 1.25, max force 0.1
    humanList.add(new Human(x,y, 10,100,150,1.25,0.1));  
  }
  
  //Load frames for animation
  void loadFrames()
  {
    for(int i = 0; i < animFrameCount; i++)
    {
      walkFrames[i] = loadImage("Sprites/Animations/Human/Walk/Human_Walk" + i + ".png");
      walkFrames[i].resize(100,100);      
    }       
    
  }
  
  
  
}