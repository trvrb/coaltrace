Population population;

void setup() {
	size(640, 360);
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
	float q;  // charge
  
	Individual(PVector l) {
		loc = l.get();
//    	vel = new PVector(random(-1,1),random(-1,1));
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 4.0;
    	q = 1.0;
	}
  
	void run() {
		update();
		display();
	}
  
	void update() {
		vel.add(acc);          						// update velocity
		loc.add(vel);          						// update location
		
		loc.x = constrain(loc.x, r*2, width-r*2);	// horizontal edge 
	//	loc.y = constrain(loc.y, r*2, height-r*2);	// vertical edge
		loc.y = height/2;							// constrains to horizontal line
		
	}
  
	void display() {
    	// Draw an elipse
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
		// run each member of population
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			ind.run();  // Passing the entire list of pop to each ind
		}
		// run population
		repel();
		exclude();
	}

  	void addIndividual(Individual ind) {
		pop.add(ind);
	}

	void exclude () {
		
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
					distance = constrain(distance,10,width+height);
//					diff.mult( (ind.q*jnd.q) / sq(distance) );
					diff.mult( (ind.q*jnd.q) / distance);
					push.add(diff);
				
				}
			}
			
			// repel from left wall
			diff = new PVector(1,0);
			distance = ind.loc.x-0;
			distance = constrain(distance,10,width+height);
//			diff.mult( (ind.q*1.0) / sq(distance) );
			diff.mult( (ind.q*1.0) / distance);
			push.add(diff);

			// repel from right wall
			diff = new PVector(-1,0);
			distance = width-ind.loc.x;
			distance = constrain(distance,10,width+height);
//			diff.mult( (ind.q*1.0) / sq(distance) );
			diff.mult( (ind.q*1.0) / distance);
			push.add(diff);			
			
			// forces accelerate the individual
			ind.acc.add(push);
			
		}
		
  	}

	void repel () {
		
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
					distance = constrain(distance,10,width+height);
//					diff.mult( (ind.q*jnd.q) / sq(distance) );
					diff.mult( (ind.q*jnd.q) / distance);
					push.add(diff);
				
				}
			}
			
			// repel from left wall
			diff = new PVector(1,0);
			distance = ind.loc.x-0;
			distance = constrain(distance,10,width+height);
//			diff.mult( (ind.q*1.0) / sq(distance) );
			diff.mult( (ind.q*1.0) / distance);
			push.add(diff);

			// repel from right wall
			diff = new PVector(-1,0);
			distance = width-ind.loc.x;
			distance = constrain(distance,10,width+height);
//			diff.mult( (ind.q*1.0) / sq(distance) );
			diff.mult( (ind.q*1.0) / distance);
			push.add(diff);			
			
			// forces accelerate the individual
			ind.acc.add(push);
			
		}
		


  	}

}
