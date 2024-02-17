class Wobbler {
	PApplet p;

	int frequency = 20;
	float amplitude = 0.5;
	float frequencyJitter = 0.2f;
	boolean wobbleEndPointAmplitude = true;
	boolean wobbleEndPointPosition = true;
	boolean drawGuides = false;


	Wobbler(PApplet p) {
		this.p = p;
	}

	void drawGuideline(float x1, float y1, float x2, float y2) {
		stroke(0, 255, 255);
		p.line(x1, y1, x2, y2);
	}

	void drawPoints(PVector[] points) {
		// draw an ellipse at each point
		noStroke();
		fill(255, 0, 0);
		for (int i = 0; i < points.length; i++) {
			PVector p1 = points[i];
			p.ellipse(p1.x, p1.y, 5, 5);
		}
	}
	
	void rect(float x, float y, float w, float h, boolean connectCorners) {
		boolean prevWobbleAmp = wobbleEndPointAmplitude;
		boolean prevWobblePos = wobbleEndPointPosition;

		if(connectCorners) {
			wobbleEndPointAmplitude = false;
			wobbleEndPointPosition = false;
		}

		line(x, y, x + w, y);
		line(x + w, y, x + w, y + h);
		line(x, y + h, x + w, y + h);
		line(x, y, x, y + h);

		wobbleEndPointAmplitude = prevWobbleAmp;
		wobbleEndPointPosition = prevWobblePos;
	}

	void rect(float x, float y, float w, float h) {
		rect(x, y, w, h, true);
	}

	PVector[] line(float x1, float y1, float x2, float y2) {
		PVector[] points = calculatePoints(x1, y1, x2, y2);
		if(drawGuides) {
			drawGuideline(x1, y1, x2, y2);
			drawPoints(points);
		}

		// draw a curved line through the points
		p.noFill();
		p.stroke(0);
		p.beginShape();
		p.curveVertex(x1, y1);
		for (int i = 0; i < points.length; i++) {
			PVector p1 = points[i];
			p.curveVertex(p1.x, p1.y);
		}
		p.curveVertex(x2, y2);
		p.endShape();

		return points;
	}

	PVector[] calculatePoints(float x1, float y1, float x2, float y2) {
		
		float lengthOfLine = p.dist(x1, y1, x2, y2);
		int numberOfSegments = (int) (lengthOfLine / frequency);
		PVector[] points = new PVector[numberOfSegments + 1];
		points[0] = new PVector(x1, y1);
		points[points.length - 1] = new PVector(x2, y2);
		float jitter = frequencyJitter * frequency;

		float slope = (y2 - y1) / (x2 - x1);
		float angle = atan(slope);

		// find the points in between
		for (int i = 1; i < points.length - 1; i++) {
			float t = (float) i / (points.length - 1);
			points[i] = PVector.lerp(new PVector(x1, y1), new PVector(x2, y2), t);
			// offset the point perpendicular to the line
			points[i] = offsetPointPerpendicularToLine(points[i], angle, p.random(-amplitude, amplitude));
			// offset the point parallel to the line
			points[i] = offsetPointParallelToLine(points[i], angle, p.random(-jitter, jitter));
			
		}

		if(wobbleEndPointAmplitude) {
			points[0] = offsetPointPerpendicularToLine(points[0], angle, p.random(-amplitude, amplitude));
			points[points.length - 1] = offsetPointPerpendicularToLine(points[points.length - 1], angle, p.random(-amplitude, amplitude));
		}

		if(wobbleEndPointPosition) {
			points[0] = offsetPointParallelToLine(points[0], angle, p.random(-jitter, jitter));
			points[points.length - 1] = offsetPointParallelToLine(points[points.length - 1], angle, p.random(-jitter, jitter));
		}

		return points;
	}

	PVector offsetPointPerpendicularToLine(PVector point, float angleOfLine, float distance) {
		float x = point.x + p.cos(angleOfLine + p.PI / 2) * distance;
		float y = point.y + p.sin(angleOfLine + p.PI / 2) * distance;
		point.x = x;
		point.y = y;
		return point;
	}

	PVector offsetPointParallelToLine(PVector point, float angleOfLine, float distance) {
		float x = point.x + p.cos(angleOfLine) * distance;
		float y = point.y + p.sin(angleOfLine) * distance;
		point.x = x;
		point.y = y;
		return point;
	}


	

}