enum VehicleState
{
  wander,
  chase,
  eat
}

abstract class Vehicle
{
  //UPDATE EACH FRAME WITH MOVEMENT
  PVector position, velocity, acceleration;//Movement vectors
  PVector forward, right;//Normal vectors for forward direction and perpendicular direction to the right
  float rotation;//Rotation for drawing at correct angle
  
  //CONSTANTS FOR VEHICLE, SET IN CONSTRUCTOR
  float radius, obstacleAvoidRadius, chaseRadius;//Radii for collision, obstacle avoidance zone, and zone in which vehicle will notice another vehicle to flee from/chase
  float maxSpeed, maxForce;//Max speed of movement and max force that can be applied
  
  VehicleState state;//Vehicle's current state, can be wander, chase, or eat
  
  PVector desiredVelocity, steer;//Temporary vectors for calculations of forces that involve steering forces and desired velocity
  PVector wanderPoint;//Point that vehicle seeks when wandering, updated once every decision interval

  float decisionTimer, decisionInterval;//Timer counts down until next decision when a new wander point should be selected to change course

  //Constructor
  //Params: x,y - starting x and y positions on map | rad - collision radius | obstAvRad - radius for avoiding obstacles | chRad - radius to chase humans in | maxS - max speed | maxF - max force
  public Vehicle(float x, float y, float rad, float obstAvRad, float chRad, float maxS, float maxF)
  {
    position = new PVector(x,y);
    wanderPoint = position.copy();
     
    velocity = new PVector();
    acceleration = new PVector();
    
    forward = new PVector();
    right = new PVector();
    
    steer = new PVector();
    desiredVelocity = new PVector();
    
    radius = rad;
    obstacleAvoidRadius = obstAvRad;
    chaseRadius = chRad;
    maxSpeed = maxS;
    maxForce = maxF;
    
    
    decisionTimer = 0;
    decisionInterval = 0.1;//Make 10 decisions a second when wandering
    
    
    state = VehicleState.wander;//Default state is wander
    
  }
  
  abstract void updateForces();//Calculate and apply all necessary forces to vehicle
  abstract void display();//Display vehicle to screen
  
  //Updates vehicle
  void update()
  {
    decisionTimer+=deltaTime;//Increment decision timer
    
    //Update forces and movement
    updateForces();
    updateMovement();
  }
  
  //Update velocity and position, calculate direction vectors
  void updateMovement()
  {
    velocity.add(PVector.mult(acceleration,deltaTime*60));//Change velocity based on acceleration and limit to max speed
    velocity.limit(maxSpeed);
    
    position.add(PVector.mult(velocity,deltaTime*60));//Change position based on velocity
    
    forward = velocity.copy();//Set forward vector to normal vector of velocity
    forward.normalize();
    
    right.set(forward.y,-forward.x);//Right vector perpendicular to forward
    
    if(state != VehicleState.eat)
      rotation = forward.heading();//Get rotation from angle of forward vector
    
    acceleration.set(0,0);//Reset acceleration    
  }
  
  //Apply force to vehicle to change acceleration
  void applyForce(PVector appliedForce) 
  {    
    //Change acceleration based on force, scale by delta time
    acceleration.add(PVector.mult(appliedForce,deltaTime*60));
  }
  
  //Returns force to seek given point
  PVector seek(PVector seekPoint)
  {
    //Get desired velocity needed to go from this position to other point
    desiredVelocity = PVector.sub(seekPoint, position);  
    desiredVelocity.limit(maxSpeed);
    
    //Calculate steering force to be applied by subtracting actual velocity from desired velocity
    steer = PVector.sub(desiredVelocity, velocity);
    steer.limit(maxForce);
    
    return steer;//Return steering force
    
  }
  
  
  //Return force to keep vehicle within bounds of map
  PVector stayInBounds()
  {    
    desiredVelocity.set(0,0);
    steer.set(0,0);
    
    //If out of bounds on x axis, desired velocity is in the opposite x direction while still maintaining y velocity
    if(position.x > width - EDGE_WIDTH)
        desiredVelocity.add(-maxSpeed, velocity.y);
      
    else if(position.x < EDGE_WIDTH)
        desiredVelocity.add(maxSpeed, velocity.y);
    
    //If out of bounds on y axis, desired velocity is in opposite y dir with same x velocity
    if(position.y > height - EDGE_WIDTH)
      desiredVelocity.add(velocity.x, -maxSpeed);
    
    else if(position.y < EDGE_WIDTH)
      desiredVelocity.add(velocity.x, maxSpeed);      
    
    //At this point, if desired velocity isn't a zero vector, calculate steering force from desired velocity
    if(desiredVelocity.mag() > 0)
    {
      steer = PVector.sub(desiredVelocity, velocity);
      steer.limit(maxForce);
    }
        
    return steer;//Return steering force, will be zero vector if within bounds
    
  }
  
  
  //Returns force to avoid obstacles if any are in vehicle's way
  PVector avoidObstacle(PVector obstaclePos, float obstacleRadius, float safeDistance)
  {
    steer.set(0,0);
    
    PVector vecToC = PVector.sub(obstaclePos,position);//Vector to obstacle center
    float sumRadii = obstacleRadius + radius;//Sum of seeker radius and the obstacle being checked
    float dist = PVector.dist(position, obstaclePos);//Distance to obstacle
                     
    //If the object is within avoiding radius AND is in front of the vehicle AND is within distance horizontally so that action is required to avoid it...
    if(dist > 0 && dist-sumRadii < safeDistance && PVector.dot(forward,vecToC) > 0 && PVector.dot(right, vecToC) < sumRadii)
    {              
      //If obstacle is to left, steer right and vice versa
      if(PVector.dot(right,vecToC) < 0)
      {
        desiredVelocity = PVector.mult(right,maxSpeed);          
      }
      else
      {
        desiredVelocity = PVector.mult(right,-maxSpeed);
      }         
      
      //Calculate steering force and scale it based on how close obstacle is
      steer = PVector.sub(desiredVelocity,velocity);
      steer.setMag(maxForce * safeDistance/(dist-radius));
    }
    
    //Return steering force, will be zero vector if action was not required to avoid any objects
    return steer;
    
  }
  
  //Go through list of obstacles and return forces to avoid them if necessary
  PVector avoidAllObstacles()
  {
    PVector steerForce = new PVector();
    
    Obstacle obst;//Obstacle to check
    
   //Go through list of obstacles
   for(int i = 0; i < obstacleManager.obstacleList.size(); i++)
   {
     obst = obstacleManager.obstacleList.get(i);
     steerForce.add(avoidObstacle(obst.position, obst.radius, obstacleAvoidRadius*velocity.mag()));//Get force to avoid this obstacle if necessary
   }   
   
   steerForce.limit(maxForce);
   
   //Return steering force
   return steerForce;
   
  }
  
 
  //Wander toward randomly determined points in front of vehicle
  PVector wander()
  {     
    steer.set(0,0);
    
    //Pick a new wander point every given period of time rather than every frame, makes things look smoother and keeps independent of framerate
    if(decisionTimer > decisionInterval)
    {
      decisionTimer = 0;//Reset timer
      
      wanderPoint =  PVector.add(position,PVector.mult(forward,50));//Vector out in front of vehicle      
                  
      float wanderShiftAngle = (random(0,TWO_PI));//Get a random angle on unit circle
      
      //Modify wander point with this random angle so that vehicle will steer toward it instead of straight forward
      wanderPoint.add(2*radius*cos(wanderShiftAngle), 2*radius*sin(wanderShiftAngle));                 
    }    
    
    steer = seek(wanderPoint);//Steer toward current wander point point 
    
    return steer;//Return steering force
  }
  
}