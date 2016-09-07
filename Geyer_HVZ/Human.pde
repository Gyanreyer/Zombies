class Human extends Vehicle
{
  int currentFrame;//Current frame of animation to display
  float animationTimer;//Timer to switch to next frame
  
  PVector wanderForce, inBoundsForce, evadeForce, separateForce, obstacleForce, sumForces;//Forces to update and apply each frame
  float wanderWeight, inBoundsWeight, evadeWeight, separateWeight, obstacleWeight;//Weights for forces to give them priorites when being applied
  
  boolean alive;//Whether human is alive or not
  
  float eatTimer;//Timer for how long to stay in place while being eaten
  
  //Constructor
  //Params: x,y - x and y positions on map | rad - collision radius | avRad - obstacle avoidance radius | chRad - radius to chase humans in | maxS - max speed | maxF - max force
  public Human(float x, float y, float rad, float avRad, float chRad, float maxS, float maxF)
  {
    super(x,y,rad,avRad,chRad,maxS,maxF);
    
    sumForces = new PVector();
    evadeForce = new PVector();
    
    wanderWeight = 1;//Wander force has weight of 1 (should be low priority)
    inBoundsWeight = 25;//Force to stay in bounds has weight of 25 (highest priority)
    evadeWeight = 10;//Force to run from zombies has weight of 10 (moderate/high priority)
    separateWeight = 5;//Force to separate from other humans has weight of 5 (moderate/low priority)
    obstacleWeight = 25;//Force to avoid obstacles has weight of 25 (highest priority)
    
    alive = true;
    
    currentFrame = (int)random(0,20);//Start at random frame to avoid animations syncing up
    animationTimer = 0;
    
    eatTimer = 0;
    
  }
    
  //Update forces, sum them up, and apply them
  void updateForces()
  {    
    //If being eaten, stay still and die after certain amount of time
    if(state == VehicleState.eat)
    {
      eatTimer += deltaTime;//Increment eat timer
      
      //Set velocity and acceleration to 0 to stay stationary
      velocity.set(0,0);
      acceleration.set(0,0);
      
      //If timer greater than 2 seconds, die and turn into zombie
      if(eatTimer > 2)
      {
        alive = false;
      }      
    }
    //If not being eaten, update forces
    else
    {
      sumForces.set(0,0);//Reset sum forces
      
      //Force to stay in bounds
      inBoundsForce = stayInBounds().mult(inBoundsWeight);
      sumForces.add(inBoundsForce);
      
      //Reset state to wander, will change to chase if any zombies in chase radius detected in checkZombies()
      state = VehicleState.wander;
      
      //Force to evade zombies
      evadeForce = checkZombies().mult(evadeWeight);
      sumForces.add(evadeForce);
      
      //If not running from any zombies, wander
      if(state == VehicleState.wander)
      {
        //Force to wander randomly
        wanderForce = wander().mult(wanderWeight);
        sumForces.add(wanderForce);
      }
      
      //Force to separate human from other humans that it could collide with
      separateForce = separate().mult(separateWeight);
      sumForces.add(separateForce);
      
      
      //Force to avoid obstacles
      obstacleForce = avoidAllObstacles().mult(obstacleWeight);
      sumForces.add(obstacleForce);
      
      
      //Apply sum of all these forces
      sumForces.limit(maxForce);
      applyForce(sumForces);
    }
    
  }
  
  //Display this human
  void display()
  {
    animationTimer+= deltaTime;//Increment animation timer
    
    pushMatrix();
    fill(255);
    translate(position.x,position.y);//Translate to position
    
      pushMatrix();
      rotate(rotation+HALF_PI);//Rotate to human's rotation
      
      //Switch to next frame every 0.04 seconds
      if(animationTimer > 0.04 && state != VehicleState.eat)
      {
        animationTimer = 0;//Reset timer
        currentFrame = (currentFrame+1) % humanManager.animFrameCount;//Increment current frame
      }
        
      image(humanManager.walkFrames[currentFrame],0,0);//Draw current frame
      
      popMatrix();
    
    
    //Debug lines
    if(debugColliders)
    { 
      noFill();
      stroke(255,0,0);
      ellipse(0,0,2*radius,2*radius);//Red circle to show collision radius
    }
    if(debugMovement)
    {
      stroke(255,255,0);
      line(0,0,sumForces.x*100,sumForces.y*100);//Yellow line to show forces being applied
      
      stroke(0,0,255);
      line(0,0,velocity.x*50,velocity.y*50);//Blue line to show direction moving in
    }
    if(debugChase)
    { 
      stroke(0,0,255);
      noFill();
      ellipse(0,0,2*chaseRadius,2*chaseRadius);//Blue circle for chase radius
      stroke(0);      
    }
    popMatrix();
     
  }
  
  //Check all zombies and calculate force to evade if necessary
  PVector checkZombies()
  {
    steer.set(0,0);
    
    PVector threatZombieVector = new PVector();//Sum of vectors from position to threatening zombies, used to calculate overall evading force
    PVector predictedPos;//Predicted position of zombie being checked based on its velocity
    
    Zombie zombie;//Zombie to be checked
    float dist;//Distance to zombie being checked
    
    //Run through list of zombies
    for(int i = 0; i < zombieManager.zombieList.size(); i++)
    {
      zombie = zombieManager.zombieList.get(i);
      dist = zombie.position.dist(position);
      
      //If zombie is within chase radius...
      if(dist < chaseRadius)
      {             
        //If zombie is too close and has collided with human, set state to being eaten
        if(dist < radius + zombie.radius)
        {
          state = VehicleState.eat;
          return new PVector(0,0);
        }
        //Otherwise, need to evade
        else
        {
          predictedPos = PVector.add(zombie.position,PVector.mult(zombie.velocity,50));//Calculate predicted position of zombie based on velocity * 50
          
          threatZombieVector.add(PVector.sub(predictedPos,position).mult(predictedPos.dist(position)));//Sum up all of the vectors from human to zombies' predicted positions
          
          //Debug lines
          if(debugChase)
          {
            stroke(0,128,0);
            fill(128,128,0);
            line(position.x,position.y,predictedPos.x,predictedPos.y);//Dark green line to predicted position of each threatening zombie
            ellipse(predictedPos.x,predictedPos.y,10,10);//Orange circle at predicted position of each threatening zombie to make it more visible
          }
                     
          state = VehicleState.chase;//Set state to being chased
        }
      } 
    }   
    
   steer = threatZombieVector.mult(-1);//Get inverse of sum vectors to zombies to steer in opposite direction of them
    
    
    steer.limit(maxForce);
    
    return steer;//Return steering force, will be zero vector if no zombies chasing
    
  }
  
  //Separates human from other humans
  PVector separate()
  {
    PVector steerForce = new PVector();
    
    //Run through all humans
    for(int i = 0; i < humanManager.humanList.size(); i++)
    {
      //Use avoidObstacle() to check if any humans are in the way and add force to avoid them
      steerForce.add(avoidObstacle(humanManager.humanList.get(i).position,radius,obstacleAvoidRadius*velocity.mag()));      
    }
    
    steerForce.limit(maxForce);
    
    return steerForce;//Return steering force, will be zero vector if don't need to separate from any humans
    
  }
  
  
  

  
  
  
  
  
  
}