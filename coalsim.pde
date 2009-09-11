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
float MUTCHANCE;
boolean TWODIMEN;
float INDHUE;
boolean LOOPING;
boolean MUTATION;
boolean TRACING;
boolean DYNAMICS;

Population population;

PFont fontA;

void setup() {

	TWODIMEN = false;
	MUTATION = false;
	TRACING = true;
	DYNAMICS = false;

	CHARGE = 30; // 50
	MAXVEL = 2; // 2
	MAXRAD = 6;
	DISTBORDER = 25;
	INITIALCOUNT = 12; // 12
	WALLMULTIPLIER = 10;
	TRACEDEPTH = 300; // 200
	TRACESTEP = 20; // 20
	COUNTER = 0;
	SPLITCHANCE = 0.2;  // 0.2
//	MUTCHANCE = 0.01;
	INDHUE = 95;
	LOOPING = true;
	
	size(600, 600);
	colorMode(HSB,100);
//	frameRate(1000);
//	size(screen.width, screen.height);
	smooth();
	noStroke();
	population = new Population();	// begins with a single individual
	
	fontA = loadFont("GillSans-48.vlw");
	textFont(fontA, 20);
	
}

void draw() {
	background(0,0,20); // 255
	population.run();
	COUNTER++;
	MUTCHANCE = 1 / (float) population.size();
	
//	float fps = 1000 * frameCount / (float) millis();
//	fill(0,0,100);
//	text(fps, 10, 20);
	
//	if (frameCount == 100) {
//		fill(0,0,100);
//		text(millis(), 10, 20);
//		noLoop();
//	}
		
}

// Add a new individual into the population
void mousePressed() {
	population.die();
	population.addIndividual(new Individual(new PVector(mouseX,mouseY)));
}

void keyPressed() {
	if (key == ' ') {
		if (LOOPING) {
			LOOPING = false;
			noLoop();
		}
		else if (!LOOPING) {
			LOOPING = true;
			loop();
		}
  	} 
  	if (key == '2') {
		if (TWODIMEN) { 
			population.resetTrace();
			TWODIMEN = false; 
		}
		else if (!TWODIMEN) { 
			population.resetTrace();
			TWODIMEN = true; 
		}
  	} 
  	if (key == 'm') {
		if (MUTATION) { MUTATION = false; }
		else if (!MUTATION) { MUTATION = true; }
  	}   
  	if (key == 't') {
		if (TRACING) { TRACING = false; }
		else if (!TRACING) { TRACING = true; }
  	} 
  	if (key == 'd') {
		if (DYNAMICS) { DYNAMICS = false; }
		else if (!DYNAMICS) { DYNAMICS = true; }
  	}  
	if (keyCode == UP) { 
		population.replicate();
  	} 
	if (keyCode == DOWN) {
		population.die();
  	}   	
}

class Individual {

	PVector loc;
	PVector vel;
	PVector acc;
	float r;  // radius
	boolean growing;
	boolean dying;
	float hue;
	LinkedList trace;

	Individual(PVector l) {
		loc = l.get();
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
    	
    	if (MUTATION) { hue = random(0,100); }
  		else { hue = INDHUE; }
  		
  		if (!TWODIMEN) {
			loc.y = height-DISTBORDER;					// constrains to horizontal line	
		}
  
    	trace = new LinkedList();
    	for (int i = 0; i < TRACEDEPTH; i++) {
    		PVector tl = new PVector(loc.x,loc.y,hue);
    		trace.add(tl);
    	}
	}
	
	Individual(PVector l, Float h, LinkedList array) {
		loc = l.get();
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
    	hue = h;
    	trace = new LinkedList();
    	for (int i = 0; i < array.size(); i++) {
    		PVector tl = (PVector) array.get(i);
    		float x = tl.x;
    		float y = tl.y;
    		float z = tl.z;
    		trace.add(new PVector(x,y,z));
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
		
		if (MUTATION) {
			mutate();
		}
	
		if (frameCount % TRACESTEP == 0) {
			extendTrace();
		}
		
	}
	
	void reset() {
		vel = new PVector(0,0);
		acc = new PVector(0,0);
	}
	
	void extendTrace() {
	//	PVector tl = loc.get();
    	PVector tl = new PVector(loc.x,loc.y,hue);
    	trace.add(tl);
    	trace.remove();
	}
	
	void resetTrace() {
	    trace = new LinkedList();
    	for (int i = 0; i < TRACEDEPTH; i++) {
    		PVector tl = new PVector(loc.x,loc.y,hue);
    		trace.add(tl);
    	}
	}
	
	void mutate() {
		if (random(0,100) < MUTCHANCE) {
			hue = random(0,100);
		}
	}
  
	void display() {
    	if (TRACING) { displayTrace(); }
		displayInd();
  	}
  	
  	void displayTrace() {
  	    // draw tail on each individual
    	float tempx = loc.x;
    	float tempy = loc.y;
    	float temph = hue;
    	float sat = 100;
		ListIterator itr = trace.listIterator(TRACEDEPTH);
		while (itr.hasPrevious()) {
    //		float trans = ( (trace.size() - i ) / (float )trace.size()) * 255;
    //		stroke(255,255,255,trans);
   			PVector tl = (PVector) itr.previous();
    		if (!TWODIMEN) {
    			tl.y = tl.y - 0.75;
    		}
    //		stroke(tl.z,sat,100,sat);
    		stroke(tl.z,100,100,sat);
    		line(tempx, tempy, tl.x, tl.y);
    		tempx = tl.x;
    		tempy = tl.y;
    		sat = sat - 2;
    	}
  	}
  	
  	void displayInd() {
  	    // draw a circle for each individual
		fill(hue,90,100); // 223,227,197
    //	stroke(255,255,255,255);
    	stroke(0,0,100);
    	ellipse(loc.x, loc.y, r*2, r*2);
  	}
  	
}

// The Population (a list of Individual objects)
class Population {
  
  	ArrayList pop; // An arraylist for all the individuals

  	Population() {
    	pop = new ArrayList(); 
    	for (int i=0; i < INITIALCOUNT; i++) {
    		float w = random(0,width);
    		float h = random(0,height);
    		if (!TWODIMEN) {
    			h = height-DISTBORDER;
    		}
    		pop.add(new Individual(new PVector(w,h)));
    	}
  	}

	void run() {
		
		if (DYNAMICS) { splitstep(); }
		repulsion();
		update();
		exclusion();
		cleanup();
		display();
		
	}
	
	int size() {
		return pop.size();
	}

  	void addIndividual(Individual ind) {
		pop.add(ind);
	}

	void replicate() {
		if (pop.size() > 0) {
			int rand = int(random(0,pop.size()));
			Individual ind = (Individual) pop.get(rand);
			float newx = ind.loc.x + random(-1,1);
			float newy = ind.loc.y + random(-1,1);
			pop.add(new Individual(new PVector(newx,newy), ind.hue, ind.trace ));
			
		}
		else {
			float w = width/2 + random(-1,1);
			float h = height/2 + random(-1,1);
			population.addIndividual(new Individual(new PVector(w,h)));
		}
		
	}
	
	void die() {
		if (pop.size() > 0) {
			int rand = int(random(0,pop.size()));
			Individual ind = (Individual) pop.get(rand);
			while (ind.dying) {									// pick another
				rand = int(random(0,pop.size()));
				ind = (Individual) pop.get(rand);
			}
			ind.dying = true;
			ind.growing = false;
		}
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
	
	void resetTrace() {
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			ind.resetTrace(); 
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

