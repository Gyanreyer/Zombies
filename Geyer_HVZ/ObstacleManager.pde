class ObstacleManager
{
  int animFrameCount = 3;//Animation has 3 frames
  PImage[] frames = new PImage[animFrameCount];//Array of animation frames
  
  //ArrayList of all obstacles
  ArrayList<Obstacle> obstacleList;
  
  //Default constructor, spawns 3 obstacles at predetermined positions
  ObstacleManager()
  {
    obstacleList = new ArrayList<Obstacle>();
    
    //Spawn 3 obstacles at predefined positions
    obstacleList.add(new Obstacle(300,300, 100));
    obstacleList.add(new Obstacle(700,450, 100));
    obstacleList.add(new Obstacle(1000,300, 100));
    
    loadFrames();//Load frames for animation
  }
  
  //Alternative constructor
  //Param: numObstacles - number of obstacles to spawn at random locations
  ObstacleManager(int numObstacles)
  {
    obstacleList = new ArrayList<Obstacle>();
    
    //Spawn given number of obstacles at random positions
    for(int i = 0; i < numObstacles; i++)
    {
      obstacleList.add(new Obstacle(random(EDGE_WIDTH,width-EDGE_WIDTH), random(EDGE_WIDTH,height-EDGE_WIDTH), 100)); 
    }
    
    loadFrames();//Load frames for animation
  }
  
  //Display all obstacles
  void displayObstacles()
  {
    for(int i = 0; i < obstacleList.size(); i++)
    {
      obstacleList.get(i).display(); 
    }  
  }
  
  //Load frames for animation
  void loadFrames()
  {
    for(int i = 0; i < animFrameCount; i++)
    {
      frames[i] = loadImage("Sprites/Animations/Obstacle/Tree_Ripple" + i + ".png");
      frames[i].resize(200,200);      
    }       
    
  }
  
  
}