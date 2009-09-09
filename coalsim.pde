Population population;
float CHARGE;
float MAXVEL;

void setup() {
	CHARGE = 40.0;
	MAXVEL = 1.0;
	size(640, 360);
//	frameRate(1000);
//	size(screen.width, screen.height);
	smooth();
	noStroke();
	population = new Population();	// begins with a single individual
}

void draw() {
	background(50);
	fill(204);
	population.run();
}

// Add a new individual into the population
void mousePressed() {
	population.addIndividual(new Individual(new PVector(mouseX,mouseY)));
}

class Individual {

	PVector loc;
	PVector vel;
	PVector acc;
	float r;  // radius
  
	Individual(PVector l) {
		loc = l.get();
//    	vel = new PVector(random(-1,1),random(-1,1));
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 4.0;
	}
  
	void run() {
		update();
		display();
	}
  
	void update() {
		vel.add(acc);          				// update velocity
		vel.x = constrain(vel.x,-MAXVEL,MAXVEL);
		loc.add(vel);          				// update location
		loc.y = height/2;					// constrains to horizontal line
		vel = new PVector(0,0);
		acc = new PVector(0,0);
		
	}
  
	void display() {
    	fill(200,100);
    	stroke(255);
    	ellipse(loc.x, loc.y, r*2, r*2);
  	}
  	
}

// The Population (a list of Individual objects)
class Population {
  
  	ArrayList pop; // An arraylist for all the individuals

  	Population() {
    	pop = new ArrayList(); // Initialize the arraylist
    	pop.add(new Individual(new PVector(width/2,height/2)));
  	}

	void run() {
		
		repulsion();
		update();
		exclusion();
		display();
		
	}

  	void addIndividual(Individual ind) {
		pop.add(ind);
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
//	return sq(CHARGE) / d;
}

