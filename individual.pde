class Individual {

	PVector loc;
	PVector vel;
	PVector acc;
	float r;  // radius
	boolean growing;
	boolean dying;
	float hue;
	ArrayList trace;

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
			loc.y = height-BASELINE;					// constrains to horizontal line	
		}
  
    	trace = new ArrayList();
    	for (int i = 0; i < TRACEDEPTH; i++) {
    		PVector tl = new PVector(loc.x,loc.y,hue);
    		trace.add(tl);
    	}
	}
	
	Individual(PVector l, Float h, ArrayList array) {
		loc = l.get();
    	vel = new PVector(0,0);
    	acc = new PVector(0,0);
    	r = 0.001;
    	growing = true;
    	dying = false;
    	hue = h;
    	trace = new ArrayList();
    	for (int i = 0; i < array.size(); i++) {
    		PVector tl = (PVector) array.get(i);
    		float x = tl.x;
    		float y = tl.y;
    		float z = tl.z;
    		trace.add(new PVector(x,y,z));
    	}
	}	
    
	void update() {
		vel.add(acc);          						// update velocity
		vel.x = constrain(vel.x,-MAXVEL,MAXVEL);	// contrains speed
		vel.y = constrain(vel.y,-MAXVEL,MAXVEL);
		
		loc.add(vel);          						// update location
		
		if (!TWODIMEN) {
			loc.y = height-BASELINE;				// constrains to horizontal line	
		}
		
		if (growing) { r = r + 0.9; }
		if (r > 1.3*MAXRAD) { growing = false; }
		if (r > MAXRAD) { r = r - 0.4; }
		if (dying) { r = r - 0.4; }
		
		reset();
		
		// dynamically calculate TRACESTEP
		TRACESTEP = int( (float)height / (float) (TRACEDEPTH * PUSHBACK) ) + 1;
		if (frameCount % TRACESTEP == 0) {
			extendTrace();
		}
		
	}
	
	void reset() {
		vel = new PVector(0,0);
		acc = new PVector(0,0);
	}
	
	void extendTrace() {
    	PVector tl = new PVector(loc.x,loc.y,hue);
    	trace.add(tl);
    	trace.remove(0);
	}
	
	void resetTrace() {
	    trace = new ArrayList();
    	for (int i = 0; i < TRACEDEPTH; i++) {
    		PVector tl = new PVector(loc.x,loc.y,hue);
    		trace.add(tl);
    	}
	}
	
	void mutate() {
		hue = random(0,100);
	}
  
	void display() {
    	if (TRACING) { displayTrace(); }
		displayInd();
  	}
  	
  	void displayTrace() {
  	    // draw tail on each individual
  	    // this is counting down from the tail of the trace
    	float tempx = loc.x;
    	float tempy = loc.y;
    	float temph = hue;
    	for (int i = TRACEDEPTH - 1; i > 0; i--) {
   			PVector tl = (PVector) trace.get(i);
    		if (!TWODIMEN) {
    			tl.y = tl.y - PUSHBACK;
    		}
    		if (BRANCHCOLORING) { stroke(tl.z,90,100); }
    		else {
    			if (GRAYBG) { stroke(tl.z,0,100); }
    			else { stroke(tl.z,0,0); }
    		}
    		line(tempx, tempy, tl.x, tl.y);
    		tempx = tl.x;
    		tempy = tl.y;
    	}
  	}
  	
  	void displayInd() {
  	    // draw a circle for each individual
		fill(hue,90,100); // 223,227,197
    	stroke(0,0,OUTLINE);
    	ellipse(loc.x, loc.y, r*2, r*2);
  	}
  	
}