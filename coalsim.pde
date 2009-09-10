Population population;
float CHARGE;
float MAXVEL;
float MAXRAD;
float DISTBORDER;
int INITIALCOUNT;

void setup() {

	CHARGE = 40.0;
	MAXVEL = 5.0;
	MAXRAD = 6;
	DISTBORDER = 25;
	INITIALCOUNT = 5;
	
	size(640, 360);
//	frameRate(1000);
//	size(screen.width, screen.height);
	smooth();
	noStroke();
	population = new Population();	// begins with a single individual
}

void draw() {
	background(50); // 255
	population.run();
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
  
	Individual(PVector l) {
		loc = l.get();
//    	vel = new PVector(random(-1,1),random(-1,1));
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
	}
  
	void run() {
		update();
		display();
	}
  
	void update() {
		vel.add(acc);          						// update velocity
		vel.x = constrain(vel.x,-MAXVEL,MAXVEL);	// contrains speed
		
		loc.add(vel);          						// update location
		loc.y = height-DISTBORDER;					// constrains to horizontal line	
		
		vel = new PVector(0,0);
		acc = new PVector(0,0);
			
		if (growing) { r = r + 0.9; }
		if (r > 1.3*MAXRAD) { growing = false; }
		if (r > MAXRAD) { r = r - 0.4; }
		if (dying) { r = r - 0.4; }
		
	}
  
	void display() {
    	fill(150); // 223,227,197
    	stroke(255); // 50
    	ellipse(loc.x, loc.y, r*2, r*2);
  	}
  	
}

// The Population (a list of Individual objects)
class Population {
  
  	ArrayList pop; // An arraylist for all the individuals

  	Population() {
    	pop = new ArrayList(); // Initialize the arraylist
    	for (int i=0; i < INITIALCOUNT; i++) {
    		pop.add(new Individual(new PVector(random(0,width),random(0,height))));
    	}
  	}

	void run() {
		
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
		pop.add(new Individual(new PVector(newx,newy)));
		
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
			
			// exclude from other Individuals
			for (int j = 0; j < pop.size(); j++) {
				if (i != j) {
			
					Individual jnd = (Individual) pop.get(j);
					
					if (ind.loc.x < jnd.loc.x) {			// ind is to the left of jnd
					
						// test if the right side of ind is right of left side of jnd
						float overlap = (ind.loc.x + ind.r) - (jnd.loc.x - jnd.r);
						if (overlap > 0) {
							ind.loc.x = ind.loc.x - overlap/2;
							jnd.loc.x = jnd.loc.x + overlap/2;
						}
					
					}
					
					if (ind.loc.x > jnd.loc.x) {			// ind is to the right of jnd
					
						// test if the left side of ind is left of right side of jnd
						float overlap = (jnd.loc.x + ind.r) - (ind.loc.x - jnd.r);
						if (overlap > 0) {
							ind.loc.x = ind.loc.x + overlap/2;
							jnd.loc.x = jnd.loc.x - overlap/2;
						}
					
					}					
						
				}
			}
			
			// exclude from walls
			ind.loc.x = constrain(ind.loc.x, ind.r*2, width-ind.r*2);
					
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
			diff.mult( 10*coulomb(distance) );
			push.add(diff);

			// repel from right wall
			diff = new PVector(-1,0);
			distance = width-ind.loc.x;
			diff.mult( 10*coulomb(distance) );
			push.add(diff);			
				
			// forces accelerate the individual			
			ind.acc.add(push);
			
		}
		


  	}

}

float coulomb(float d) {
	return sq(CHARGE) / sq(d);
}

