class Obstacle
{
  int currentFrame;//Current frame of animation to display
  float animationTimer;//Timer to switch to next frame
  
  PVector position;//Position of obstacle
  float radius;//Collision radius
  
  //Constructor
  //Params: x,y - position | rad - obstacle radius
  Obstacle(float x, float y, float rad)
  {   
    position = new PVector(x,y);    
    radius = rad;    
    
    currentFrame = (int)random(0,3);//Start at random frame to avoid animations syncing up
    
  }
  
  //Display this obstacle
  void display()
  {
    animationTimer += deltaTime;//Increment animation timer
    
    //Switch to next frame every 0.2 seconds
    if(animationTimer > 0.2)
    {
      animationTimer = 0;//Reset timer
      currentFrame = (currentFrame+1) % obstacleManager.animFrameCount;//Increment current frame
    }   
    
    pushMatrix();
    translate(position.x,position.y);//Translate to position
    
    image(obstacleManager.frames[currentFrame],0,0);//Draw current animation frame
    
    if(debugColliders)
    {
      stroke(255,0,0);
      noFill();
      ellipse(0,0,2*radius,2*radius);//Red circle for obstacle's avoidance radius
    }
    
    popMatrix();    
  }
  
}