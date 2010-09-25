// COALTRACE
// Copyright 2009 Trevor Bedford

/*	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.*/

float CHARGE;
float MAXVEL;
float MAXRAD;
float BASELINE;
float WALLMULTIPLIER;
int TRACEDEPTH;
int TRACESTEP;
float PUSHBACK;
int N;
float MU;
float GEN;
boolean TWODIMEN;
float INDHUE;
boolean LOOPING;
boolean MUTATION;
boolean TRACING;
boolean DYNAMICS;
boolean STATISTICS;
boolean HELP;
boolean FRATE;
boolean GRAYBG;
boolean BRANCHCOLORING;
float BG;
float OUTLINE;

Population population;
PFont fontN;
PFont fontI;

void setup() {

	TWODIMEN = false;
	MUTATION = true;
	TRACING = true;
	DYNAMICS = true;
	STATISTICS = false;
	HELP = false;
	FRATE = false;
	GRAYBG = true;
	BRANCHCOLORING = true;

	CHARGE = 30; // 50
	MAXVEL = 2; // 2
	MAXRAD = 6;
	BASELINE = 25;
	WALLMULTIPLIER = 20;
	TRACEDEPTH = 20; // 300
	TRACESTEP = 18; // 20
	PUSHBACK = 0.75;
	
	if (GRAYBG) {
		BG = 20;
		OUTLINE = 100;
	}
	else {
		BG = 100;
		OUTLINE = 20;
	}
	
	N = 16;
	MU = 0.1;
	GEN = 60.0;			// frames per generation
	
	INDHUE = 95;
	LOOPING = true;

	size(screen.width, screen.height);	
//	size(600,450);
	frameRate(60);	
	colorMode(HSB,100);
	smooth();
	noStroke();
	population = new Population();	// begins with a single individual
	
	fontN = loadFont("GillSans-48.vlw");
	
}

void draw() {
	background(0,0,BG);
	population.run();
	if (STATISTICS) { stats(); }
	if (HELP) { help(); }
	if (FRATE) { showFrameRate(); }
}

void showFrameRate() {
	fill(0,0,OUTLINE);
	stroke(0,0,OUTLINE);
	textFont(fontN, 16);
	int fps = int(frameRate);
	text(fps + " frames / sec", 10, 85);
}

void help() {
	
	fill(0,0,OUTLINE);
	stroke(0,0,OUTLINE);
	smooth();
	textFont(fontN, 14);

	float h = 110;
	float mod = 20;
	float fromleft = 100;
	text("H",10,h); text("-  show/hide keyboard commands",fromleft,h); h += mod;
	text("F",10,h); text("-  show/hide frame rate",fromleft,h); h += mod;
	text("S",10,h); text("-  show/hide statistics",fromleft,h); h += mod;
	text("T",10,h); text("-  show/hide tracing",fromleft,h); h += mod;
	text("C",10,h); text("-  switch between background colors",fromleft,h); h += mod;
	text("B",10,h); text("-  turn on/off branch coloring",fromleft,h); h += mod;	
	text("SPACE",10,h); text("-  start/stop animation",fromleft,h); h += mod;
	text("D",10,h); text("-  start/stop population dynamics",fromleft,h); h += mod;
	text("M",10,h); text("-  start/stop mutation",fromleft,h); h += mod;
	text("2",10,h); text("-  switch between 1 and 2 dimensions",fromleft,h); h += mod;
	text("DOWN / UP",10,h); text("-  decrease / increase population size",fromleft,h); h += mod;
	text("LEFT / RIGHT",10,h); text("-  decrease / increase generation time",fromleft,h); h += mod;
	text(", / .",10,h); text("-  decrease / increase trace rate",fromleft,h); h += mod;
	text("CLICK",10,h); text("-  add migrant to population",fromleft,h); h += mod;
		
	textFont(fontN, 12);
	text("Copyright 2009-2010 Trevor Bedford",width-205,20);
	
}

void stats() {

	fill(0,0,OUTLINE);
	stroke(0,0,OUTLINE);
	textFont(fontN, 16);

	// population size
	text(N + " individuals",10,25);

	// generation time
	if (DYNAMICS) {
		float grate = round(( (float) GEN / (float) frameRate ) * 10.0)/10.0;
		text(grate + " sec / gen", 10, 45);
	}
	
	// trace time
	if (!TWODIMEN && TRACING) {
		int trate = int(round(frameRate * PUSHBACK));
		text(trate + " pixels / sec", 10, 65);	
	}
	
	// intervals
	if (!TWODIMEN && DYNAMICS && TRACING) {
		textFont(fontN, 12);
		float t = 0;		
		if (N>0) { line(width-34,height-BASELINE,width-10,height-BASELINE); }
		for (int k = N; k > 1; k--) {
			float mod = (float) coalInterval(k);
			if (mod > 10) { 
				if (k < 10) { text(k,width-24,height-t-mod/2-BASELINE+5); }
				else { text(k,width-27.5,height-t-mod/2-BASELINE+5); }
			}
			t += mod;
			line(width-34,height-t-BASELINE,width-10,height-t-BASELINE);	
		}
	}
	
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
		else if (!TRACING) { 
			population.resetTrace();
			TRACING = true; 
		}
  	} 
  	if (key == 'd') {
		if (DYNAMICS) { DYNAMICS = false; }
		else if (!DYNAMICS) { DYNAMICS = true; }
  	}  
  	if (key == 's') {
		if (STATISTICS) { STATISTICS = false; }
		else if (!STATISTICS) { STATISTICS = true; }
  	}    
  	if (key == 'b') {
		if (BRANCHCOLORING) { BRANCHCOLORING = false; }
		else if (!BRANCHCOLORING) { BRANCHCOLORING = true; }
  	}      	
  	if (key == 'h') {
		if (HELP) { HELP = false; }
		else if (!HELP) { HELP = true; }
  	}      	
  	if (key == 'f') {
		if (FRATE) { FRATE = false; }
		else if (!FRATE) { FRATE = true; }
  	}      	  	
	if (keyCode == UP) { 
		population.replicate();
		N++;
  	} 
	if (keyCode == DOWN) {
		boolean success = population.die();
		if (success) { N--; }
  	}   
	if (keyCode == RIGHT) { 
		GEN += 1.0;
  	} 
	if (keyCode == LEFT) { 
		GEN -= 1.0;
  	}   
	if (key == '.') { 
		PUSHBACK += 0.01;
  	}  
	if (key == ',') { 
		PUSHBACK -= 0.01;
  	}  
	if (key == 'c') {
		if (GRAYBG) {
			GRAYBG = false;
			BG = 100;
			OUTLINE = 20;
		}
		else if (!GRAYBG) {
			GRAYBG = true;
			BG = 20;
			OUTLINE = 100;
		}
  	}   	
}


float coulomb(float d) {
	float force;
	if (d > 0) {
		force = sq(CHARGE) / sq(d);
	}
	else {
		force = 10000;
	}
	return force;
}

int poissonSample(float lambda) {
	float t = exp(-1*lambda);
	int k = 0;
	float p = 1;
	while (p > t) {
		k++;
		p *= random(0,1);
	}
	return k - 1;
}

// coalescent intervals calculation, returns number of pixels in interval of k lineages
// every frame each member of trace is decremented by PUSHBACK pixels
float coalInterval(int k) {

	// Moran model with overlapping generations, k concurrent lineages
	float cof = 2.0 / (float) ( (k-1) * k); 
	float generations = cof * (float) N * 0.5;
	// converting from generations to frames
	float frames = generations * GEN;
	// converting from frames to pixels
	float mod = frames * PUSHBACK;
	
	return mod;
}