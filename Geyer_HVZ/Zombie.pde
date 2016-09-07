class Zombie extends Vehicle
{  
  int currentFrame;//Current frame of animation to display
  float animationTimer;//Timer to switch to next frame
  
  PVector wanderForce, inBoundsForce, chaseForce, separateForce, obstacleForce, sumForces;//Forces to update and apply each frame
  float wanderWeight, inBoundsWeight, chaseWeight, separateWeight, obstacleWeight;//Weights for forces to give them priorites when being applied
  
  float eatTimer;//Timer for how long to stay in place while eating a human
    
  Human closestHuman;//Closest human to chase
  
  //Constructor
  //Params: x,y - x and y positions on map | rad - collision radius | avRad - obstacle avoidance radius | chRad - radius to chase humans in | maxS - max speed | maxF - max force
  Zombie(float x, float y, float rad, float avRad, float chRad, float maxS, float maxF)
  {
    super(x,y,rad,avRad,chRad,maxS,maxF);
    
    sumForces = new PVector();//Sum of all forces to be applied each frame
    
    chaseForce = new PVector();
    separateForce = new PVector();
    
    wanderWeight = 1;//Wander force has weight of 1 (should be low priority)
    inBoundsWeight = 25;//Force to stay in bounds has weight of 25 (highest priority)
    chaseWeight = 10;//Force to run from zombies has weight of 10 (moderate priority)
    separateWeight = 5;//Force to separate from other humans has weight of 5 (moderate/low priority)
    obstacleWeight = 25;//Force to avoid obstacles has weight of 25 (highest priority)
    
    currentFrame = (int)random(0,20);//Start at a random frame so animations won't all be weirdly synced up
    animationTimer = 0;
    
    eatTimer = 0;
    
  }
  
  //Update forces, sum them up, and apply them
  void updateForces()
  {
    //If eating a human, don't move for a given amount of time
    if(state == VehicleState.eat)
    {      
      //Timer for how long to stay stationary and eat human
      eatTimer += deltaTime;
      
      //Set velocity and acceleration to 0 to stay stationary
      velocity.set(0,0);
      acceleration.set(0,0);
      
      //If timer is greater than 2 seconds, return to wander
      if(eatTimer > 2)
      {
       state = VehicleState.wander;
      }      
    }
    //If not eating, update forces
    else
    {
      sumForces.set(0,0);//Reset sum forces
      state = VehicleState.wander;//Reset state to wander by default
      
      //Force to stay in bounds
      inBoundsForce = stayInBounds().mult(inBoundsWeight);
      sumForces.add(inBoundsForce);
      
      //Force to chase humans, will set state to chase if human in chase radius
      chaseForce = checkHumans().mult(chaseWeight);
      sumForces.add(chaseForce);
      
      //If not chasing any humans, wander
      if(state == VehicleState.wander)
      {
        //Force to wander randomly
        wanderForce = wander().mult(wanderWeight);
        sumForces.add(wanderForce);
      }
  
      //Force to separate from other zombies
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
  
  //Display this zombie
  void display()
  {
    animationTimer+= deltaTime;//Increment animation timer
    
    pushMatrix();
    translate(position.x,position.y);//Translate to position
    
      pushMatrix();
      rotate(rotation+HALF_PI);//Rotate to zombie's rotation
      
      //Switch to next frame ever 0.04 seconds
      if(animationTimer > 0.04 && state != VehicleState.eat)
      {
        animationTimer = 0;//Reset timer
        currentFrame = (currentFrame+1) % zombieManager.animFrameCount;//Increment current frame
      }
            
      image(zombieManager.walkFrames[currentFrame],0,0);//Draw current frame
      
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
      
      stroke(0,255,0);
      line(0,0,velocity.x*50,velocity.y*50);//Green line to show direction moving in
    }
    if(debugChase)
    {
      stroke(0,255,0);
      noFill();
      ellipse(0,0,2*chaseRadius,2*chaseRadius);//Green circle to show chase radius
      stroke(0);     
    }
    
    popMatrix();
      
  }
  
  //Check all humans and see if any need to be chased
  PVector checkHumans()
  {    
    steer.set(0,0);
       
    Human human;//Human to check
    float dist;//Distance to human being checked
    
    //If closest human isn't null and is being eaten, set to null to ignore it
    if(closestHuman != null && closestHuman.state == VehicleState.eat)
    {
      closestHuman = null;  
    }
    
    //Go through all active humans
    for(int i = 0; i < humanManager.humanList.size(); i++)
    { 
      human = humanManager.humanList.get(i);//Current human being checked
      dist = human.position.dist(position);//Distance to human
      
      //If human is within chase radius
      if(dist < chaseRadius)
      {
        //If no closest human has been selected or the one being checked is closer and not being eaten...
        if(closestHuman == null || (dist < closestHuman.position.dist(position)) && human.state != VehicleState.eat)
        {
          closestHuman = human;//Select a new closest human, only chase this one
          
          //If this zombie is colliding with the human, set state to eating human and return early
          if(dist < radius + closestHuman.radius)
          {
           state = VehicleState.eat;    
           return new PVector(0,0);
          }
        }
         
        state = VehicleState.chase;//Set state to chasing
      }
    }
    
    //If in chase state, chase selected closest human
    if(state == VehicleState.chase)
    {
      PVector predictedPos = PVector.add(closestHuman.position,PVector.mult(closestHuman.velocity,50));//Get predicted position based on human's velocity * 50
      
      //Seek closest human's predicted position
      steer = seek(predictedPos);
      steer.limit(maxForce);
      
      //Draw a debug line to point this zombie is chasing
      if(debugChase)
      {
        stroke(255,0,0);
        fill(255,128,0);
        line(position.x,position.y,predictedPos.x,predictedPos.y);//Red line to desired position
        ellipse(predictedPos.x,predictedPos.y,10,10);//Orange circle at desired position
      }            
    }
    
    return steer;//Return steering force, will be zero vector if no humans in chase radius
    
  } 
  
  //Separates zombie from other zombies
  PVector separate()
  {
    PVector steerForce = new PVector();
    
    //Run through all zombies
    for(int i = 0; i < zombieManager.zombieList.size(); i++)
    {
      //Use avoidObstacle() to check if any zombies are in the way and add force to avoid them
      steerForce.add(avoidObstacle(zombieManager.zombieList.get(i).position,radius,obstacleAvoidRadius*velocity.mag()));      
    }
    
    steerForce.limit(maxForce);
    
    return steerForce;//Return steering force, will be zero vector if don't need to avoid any zombies
    
  }
  
  
  
  
  
  
  
}