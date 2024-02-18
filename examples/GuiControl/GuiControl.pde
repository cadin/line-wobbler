//import the LazyGUI library
import com.krab.lazy.*;
LazyGui gui;

// instantiate the LineWobbler
LineWobbler wob = new LineWobbler();

void setup() {
	size(1200, 800, P2D);
	pixelDensity(2);

	// set up LazyGUI controls
	gui = new LazyGui(this);
	gui.pushFolder("wobbler"); 
		gui.toggle("drawGuides", wob.drawGuides);
		
		gui.pushFolder("basic");
			gui.slider("amplitude", wob.amplitude, 0, 50);
			gui.sliderInt("frequency", wob.frequency, 1, 100);
			gui.slider("frequencyJitter", wob.frequencyJitter, 0, 1);
		gui.popFolder();
		
		gui.pushFolder("endPoints");
			gui.toggle("wobbleEndPointAmplitude", wob.wobbleEndPointAmplitude);
			gui.toggle("wobbleEndPointPosition", wob.wobbleEndPointPosition);
		gui.popFolder();
		
		gui.pushFolder("breaks");
			gui.slider("minBreakSize", wob.minBreakSize, 0.1, 20);
			gui.slider("maxBreakSize", wob.maxBreakSize, 0.1, 20);
			gui.slider("minLineSegmentLength", wob.minLineSegmentLength, 5, 100);
			gui.slider("breakFrequency", wob.breakFrequency, 0.1, 5);
		gui.popFolder();
	gui.popFolder();
}

void draw() {
	background(255);
	randomSeed(1000);

	// read LineWobbler settings from LazyGUI
	gui.pushFolder("wobbler"); 
		wob.drawGuides = gui.toggle("drawGuides");
		gui.pushFolder("basic");
			wob.amplitude = gui.slider("amplitude");
			wob.frequency = gui.sliderInt("frequency");
			wob.frequencyJitter = gui.slider("frequencyJitter");
		gui.popFolder();
		gui.pushFolder("endPoints");
			wob.wobbleEndPointAmplitude = gui.toggle("wobbleEndPointAmplitude");
			wob.wobbleEndPointPosition = gui.toggle("wobbleEndPointPosition");
		gui.popFolder();
		gui.pushFolder("breaks");
			wob.minBreakSize = gui.slider("minBreakSize");
			wob.maxBreakSize = gui.slider("maxBreakSize");
			wob.minLineSegmentLength = gui.slider("minLineSegmentLength");
			wob.breakFrequency = gui.slider("breakFrequency");
		gui.popFolder();
	gui.popFolder();
	
	// draw some lines using the LineWobbler
	wob.drawLine(50, 300, width - 50, 300);
	wob.drawBrokenLine(50, 400, width - 50, 400);
}
