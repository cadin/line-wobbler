// instantiate the LineWobbler class
LineWobbler wob = new LineWobbler();

PShape angularShape;
PShape curvyShape;

void setup() {
	size(800, 600);
  
  // import the svgs
  angularShape = loadShape("angular.svg");
  angularShape.disableStyle();
  
  curvyShape = loadShape("curvy.svg");
  curvyShape.disableStyle();
  
  // wobbler settings
  wob.frequency = 8;
  wob.wobbleEndPointAmplitude = false;
  wob.wobbleEndPointPosition = false;
}

void draw() {
	background(255);
	randomSeed(0);

  // draw the svgs as loaded for reference
  shape(angularShape, 50, 50);
  shape(curvyShape, 400, 50);

  // Currently drawShape works by extracting the vertices from the 
  // Shape and drawing straight lines between them (ignoring curve data)
  // This means angular shapes are reproduced somewhat accurately,
  // but shapes with large curves will look bad

	// draw the angular shape (looks OK)
	wob.drawShape(angularShape, 50, 300);
	
	// draw the curvy shape (looks bad)
	wob.drawShape(curvyShape, 400, 300);
}
