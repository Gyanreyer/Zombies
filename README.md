# Zombies
This is a simple simulation of humans and zombies using steering behaviors to randomly wander, avoid obstacles, and pursue/evade each other.

It was made using Processing, a Java-based language focused on simple graphical output.
For more information on Processing, visit https://processing.org/

This was a project for my Interactive Media Development course, I received a grade of 100% on this assignment.

The "Geyer_HVZ" folder contains all of my source code in pde files, which can be read using any text editor, although it is intended to be used with the official Processing IDE.

---

CONTROLS:

Left mouse click to spawn a human at the mouse position

Right mouse click to spawn a zombie at the mouse position

Number keys 1-4 display different debug information:

	1: display collision radii for all objects
	
	2: display movement information for forces and velocity direction/magnitude
	
	3: display chase information for what characters are pursuing or evading and show their chase radius
	
	4: display all of these at once

---

GUIDE FOR DEBUG INFORMATION SHOWN:

Red transparent box = Edge zone of map in which vehicles will turn around to stay in bounds

Red circle = collision radius

Yellow line = sum of forces being applied this frame	

Human-

	Blue line = velocity of human
	
	Blue circle = chase radius for zombies to evade
	
	Dark green line with orange circle at end = line to predicted positions of zombies evading

Zombie-

	Green line = velocity of zombie
	
	Green circle = chase radius for humans to pursue
	
	Red line with orange circle at end = line to predicted position of human currently chasing
