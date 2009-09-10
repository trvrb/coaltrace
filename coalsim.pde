Population population;
float CHARGE;
float MAXVEL;
float MAXRAD;
float DISTBORDER;
int INITIALCOUNT;
float WALLMULTIPLIER;
int TRACEDEPTH;
int TRACESTEP;
int COUNTER;
float SPLITCHANCE;
boolean TWODIMEN;

void setup() {

	CHARGE = 50;
	MAXVEL = 2;
	MAXRAD = 6;
	DISTBORDER = 25;
	INITIALCOUNT = 12;
	WALLMULTIPLIER = 10;
	TRACEDEPTH = 200;
	TRACESTEP = 20;
	COUNTER = 0;
	SPLITCHANCE = 0.2;
	TWODIMEN = false;
	
	size(600, 600);
//	frameRate(200);
//	size(screen.width, screen.height);
	smooth();
	noStroke();
	population = new Population();	// begins with a single individual
}

void draw() {
	background(50); // 255
	population.run();
	COUNTER++;
		
}

// Add a new individual into the population
void mousePressed() {
//	population.addIndividual(new Individual(new PVector(mouseX,mouseY)));
	population.die();
	population.replicate();
}

class Individual {

	PVector loc;
	PVector vel;
	PVector acc;
	float r;  // radius
	boolean growing;
	boolean dying;
	LinkedList trace;
  
	Individual(PVector l) {
		loc = l.get();
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
    	trace = new LinkedList();
    	for (int i = 0; i < TRACEDEPTH; i++) {
    		PVector tl = loc.get();
    		trace.add(tl);
    	}
	}
	
	Individual(PVector l, LinkedList array) {
		loc = l.get();
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
    	trace = new LinkedList();
    	for (int i = 0; i < array.size(); i++) {
    		PVector tl = (PVector) array.get(i);
    		float x = tl.x;
    		float y = tl.y;
    		trace.add(new PVector(x,y));
    	}
	}	
  
	void run() {
		update();
		display();
	}
  
	void update() {
		vel.add(acc);          						// update velocity
		vel.x = constrain(vel.x,-MAXVEL,MAXVEL);	// contrains speed
		vel.y = constrain(vel.y,-MAXVEL,MAXVEL);
		
		loc.add(vel);          						// update location
		
		if (!TWODIMEN) {
			loc.y = height-DISTBORDER;					// constrains to horizontal line	
		}
		
		if (growing) { r = r + 0.9; }
		if (r > 1.3*MAXRAD) { growing = false; }
		if (r > MAXRAD) { r = r - 0.4; }
		if (dying) { r = r - 0.4; }
		
		reset();
	
		if (COUNTER % TRACESTEP == 0) {
			extend();
		}
		
	}
	
	void reset() {
		vel = new PVector(0,0);
		acc = new PVector(0,0);
	}
	
	void extend() {
		PVector tl = loc.get();
    	trace.add(tl);
    	trace.remove();
	}
  
	void display() {
    	
    	// draw tail on each individual
    	float tempx = loc.x;
    	float tempy = loc.y;
		ListIterator itr = trace.listIterator(TRACEDEPTH);
		while (itr.hasPrevious()) {
    //		float trans = ( (trace.size() - i ) / (float )trace.size()) * 255;
    //		stroke(255,255,255,trans);
    		stroke(200);
   			PVector tl = (PVector) itr.previous();
    		if (!TWODIMEN) {
    			tl.y = tl.y - 0.75;
    		}
    		line(tempx, tempy, tl.x, tl.y);
    		tempx = tl.x;
    		tempy = tl.y;
    	}
    	
    	// draw a circle for each individual
		fill(150); // 223,227,197
    //	stroke(255,255,255,255);
    	stroke(255);
    	ellipse(loc.x, loc.y, r*2, r*2);
    	
  	}
  	
}

// The Population (a list of Individual objects)
class Population {
  
  	ArrayList pop; // An arraylist for all the individuals

  	Population() {
    	pop = new ArrayList(); 
    	for (int i=0; i < INITIALCOUNT; i++) {
    		pop.add(new Individual(new PVector(random(0,width),random(0,height))));
    	}
  	}

	void run() {
		
		splitstep();
		repulsion();
		update();
		exclusion();
		cleanup();
		display();
		
	}

  	void addIndividual(Individual ind) {
		pop.add(ind);
	}

	void replicate() {
		int rand = int(random(0,pop.size()));
		Individual ind = (Individual) pop.get(rand);
		float newx = ind.loc.x + random(-1,1);
		float newy = ind.loc.y + random(-1,1);
		pop.add(new Individual(new PVector(newx,newy), ind.trace ));
		
	}
	
	void die() {
		int rand = int(random(0,pop.size()));
		Individual ind = (Individual) pop.get(rand);
		while (ind.dying) {									// pick another
			rand = int(random(0,pop.size()));
			ind = (Individual) pop.get(rand);
		}
		ind.dying = true;
		ind.growing = false;
	}
	
	void splitstep() {
		if (random(0,1) < SPLITCHANCE) {
			die();
			replicate();
		}
	}

	void cleanup() {
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			if (ind.r < 0) { 
				pop.remove(i);
				i = 0;
			}
		}
	}

	void update() {
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			ind.update(); 
		}
	}
	
	void display() {
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			ind.display(); 
		}
	}
	
	void exclusion () {
		
		for (int i = 0 ; i < pop.size(); i++) {
		
			Individual ind = (Individual) pop.get(i);
			
			// repel from other Individuals
	/*		for (int j = 0 ; j < pop.size(); j++) {
				if (i != j) {
					Individual jnd = (Individual) pop.get(j);
					float overlap = ind.r + jnd.r - PVector.dist(ind.loc,jnd.loc);
					if (overlap > 0) {
						ind.reset();
						jnd.reset();
					}
				}
			}
	*/		
			// exclude from walls
			ind.loc.x = constrain(ind.loc.x, ind.r*2, width-ind.r*2);
			ind.loc.y = constrain(ind.loc.y, ind.r*2, height-ind.r*2);
					
		}
		
  	}

	void repulsion () {
		
		for (int i = 0 ; i < pop.size(); i++) {
		
			Individual ind = (Individual) pop.get(i);
			PVector push = new PVector(0,0);
			float distance;
			PVector diff;
			
			// repel from other Individuals
			for (int j = 0 ; j < pop.size(); j++) {
				if (i != j) {
			
					Individual jnd = (Individual) pop.get(j);
					// Calculate vector pointing away from neighbor
					diff = PVector.sub(ind.loc,jnd.loc);
					diff.normalize();
					// weight by Coulomb's law
					distance = PVector.dist(ind.loc,jnd.loc);
					diff.mult( coulomb(distance) );
					push.add(diff);
				
				}
			}
			
			// repel from left wall
			diff = new PVector(1,0);
			distance = ind.loc.x-0;
			diff.mult( WALLMULTIPLIER*coulomb(distance) );
			push.add(diff);

			// repel from right wall
			diff = new PVector(-1,0);
			distance = width-ind.loc.x;
			diff.mult( WALLMULTIPLIER*coulomb(distance) );
			push.add(diff);		
			
			// repel from top wall
			diff = new PVector(0,1);
			distance = ind.loc.y-0;
			diff.mult( WALLMULTIPLIER*coulomb(distance) );
			push.add(diff);

			// repel from bottom wall
			diff = new PVector(0,-1);
			distance = height-ind.loc.y;
			diff.mult( WALLMULTIPLIER*coulomb(distance) );
			push.add(diff);					
				
			// forces accelerate the individual			
			ind.acc.add(push);
			
		}
		


  	}

}

float coulomb(float d) {
	return sq(CHARGE) / sq(d);
}

