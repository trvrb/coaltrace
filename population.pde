// The Population (a list of Individual objects)
class Population {
  
  	ArrayList pop; // An arraylist for all the individuals

  	Population() {
    	pop = new ArrayList(); 
    	for (int i=0; i < N; i++) {
    		float w = random(0,width);
    		float h = random(0,height);
    		if (!TWODIMEN) {
    			h = height-BASELINE;
    		}
    		pop.add(new Individual(new PVector(w,h)));
    	}
  	}

	void run() {
		
		if (DYNAMICS) { splitstep(); }
		if (MUTATION) { mutate(); }
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
			pop.add(new Individual(new PVector(w,h)));
		}
		
	}
	
	boolean die() {					// return true if successful
		boolean success = false;
		// how many are not dying
		int livecount = 0;
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i); 
			if (!ind.dying) {
				livecount++;
			}
		}
		if (livecount > 0) {
			int rand = int(random(0,pop.size()));
			Individual ind = (Individual) pop.get(rand);
			while (ind.dying) {									// pick another
				rand = int(random(0,pop.size()));
				ind = (Individual) pop.get(rand);
			}
			ind.dying = true;
			ind.growing = false;
			success = true;
		}
		return success;
	}
	
	void splitstep() {									// called once per frame
		float popBD = (1 / (float)GEN) * (float) N;		// population birth-death rate
		int events = poissonSample(popBD);	
		for (int i = 0; i < events; i++) {
			die();
			replicate();
		}
	}
	
	void mutate() {
		float popMu = (1/(float)GEN) * (float)N * MU;
		int events = poissonSample(popMu);
		for (int i = 0; i < events; i++) {
			int rand = int(random(0,pop.size()));
			Individual ind = (Individual) pop.get(rand);
			ind.mutate();
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
		if (TRACING) {
			for (int i = 0; i < pop.size(); i++) {
				Individual ind = (Individual) pop.get(i);  
				ind.displayTrace(); 
			}
		}
		for (int i = 0; i < pop.size(); i++) {
			Individual ind = (Individual) pop.get(i);  
			ind.displayInd(); 
		}
	}
	
	void exclusion () {
		
		for (int i = 0 ; i < pop.size(); i++) {
		
			Individual ind = (Individual) pop.get(i);
			
			// freeze on contact with other individuals
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