// instantiate the LineWobbler class
LineWobbler wob = new LineWobbler();

// create an array of points to draw as a polyline
PVector[] polylinePoints = {
	new PVector(0, 0), 
	new PVector(100, 100), 
	new PVector(200, 0), 
	new PVector(300, 100),
	new PVector(370, 100)
};


void setup() {
	size(800, 600);

	// exaggerate the frequency of the break effect 
	// so we can see it clearly in this example
	wob.breakFrequency = 1.5; 
}


void draw() {
	background(255);

	// if you don't set this, the lines get re-randomized every frame
	randomSeed(1000);
	
	// draw horizontal lines
	wob.drawLine( 20, 20, 780, 20);
	wob.drawBrokenLine( 20, 40, 780, 40);
	
	// draw zigzag polylines
	pushMatrix();
	translate(20, 60);
	wob.drawPolyline(polylinePoints);
	translate(380, 0);
	wob.drawBrokenPolyline(polylinePoints);
	popMatrix();
	
	// draw rectangles
	wob.drawRect(20, 180, 370, 100);
	wob.drawBrokenRect(410, 180, 370, 100);
	
	// draw circles
	wob.drawCircle(210, 400, 100);
	wob.drawBrokenCircle(590, 400, 100);
}
