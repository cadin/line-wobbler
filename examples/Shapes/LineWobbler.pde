import java.util.Arrays; 

class LineWobbler {

	/**
	 * The distance between subpoints (in pixels)
	 */
	int frequency = 10;

	/** 
	 * How much the subpoints can deviate from the line (in pixels)
	 */
	float amplitude = 0.5;

	/**
	 * How much the subpoints can deviate along the line (percentage of frequency)
	 */
	float frequencyJitter = 0.2f;

	/**
	 * Whether or not to wobble the end points (perpendicular to the line)
	 */
	boolean wobbleEndPointAmplitude = true;

	/**
	 * Whether or not to wobble the end points (parallel to the line)
	 */
	boolean wobbleEndPointPosition = true;

	/**
	 * Whether or not to draw the guides
	 */
	boolean drawGuides = false;

	/**
	 * The minimum size of a break in a line (in pixels)
	 */
	float minBreakSize = 0.2;

	/**
	 * The maximum size of a break in a line (in pixels)
	 */
	float maxBreakSize = 5;

	/**
	 * The minimum length of a broken line segment (in pixels)
	 */
	float minLineSegmentLength = 5;

	/**
	 * The frequency of breaks in a line
	 */
	float breakFrequency = 0.3;

	// ------------------------------------------------
	// CONSTRUCTORS
	LineWobbler() {}

	/**
	 * @param frequency the distance between subpoints (in pixels)
	 * @param amplitude how much the subpoints can deviate from the line (in pixels)
	 */
	LineWobbler(int frequency, float amplitude ) {
		this.frequency = frequency;
		this.amplitude = amplitude;
	}

	/**
	 * @param frequency the distance between subpoints (in pixels)
	 * @param amplitude how much the subpoints can deviate from the line (in pixels)
	 * @param frequencyJitter how much the subpoints can deviate along the line (percentage of frequency)
	 */
	LineWobbler(int frequency, float amplitude, float frequencyJitter) {
		this.frequency = frequency;
		this.amplitude = amplitude;
		this.frequencyJitter = frequencyJitter;
	}

	// ------------------------------------------------
	// LINE DRAWING

	/**
	 * Draw a line between two points
	 * @param x1 the x-coordinate of the first point
	 * @param y1 the y-coordinate of the first point
	 * @param x2 the x-coordinate of the second point
	 * @param y2 the y-coordinate of the second point
	 * @return an array of PVector points
	 */
	PVector[] drawLine(float x1, float y1, float x2, float y2) {
		PVector[] points = calculatePoints(x1, y1, x2, y2);
		color prevStroke = g.strokeColor;
		if(drawGuides) {
			drawGuideline(x1, y1, x2, y2);
			drawPoints(points);
			drawEndPoints(new PVector(x1, y1), new PVector(x2, y2));
		}
		noFill();
		stroke(prevStroke);
		renderLine(points);
		return points;
	}

	/**
	 * Draw a broken line between two points
	 * @param x1 the x-coordinate of the first point
	 * @param y1 the y-coordinate of the first point
	 * @param x2 the x-coordinate of the second point
	 * @param y2 the y-coordinate of the second point
	 * @return an array of PVector points
	 */
	PVector[] drawBrokenLine(float x1, float y1, float x2, float y2) {
		PVector[][] segments = breakLineIntoSegments(x1, y1, x2, y2);
		PVector[] points = new PVector[0];
		for (int i = 0; i < segments.length; i++) {
			PVector[] pts = drawLine(segments[i][0].x, segments[i][0].y, segments[i][1].x, segments[i][1].y);
			points = (PVector[]) concat(points, pts);
		}

		return points;
	}

	// ------------------------------------------------
	// POLY LINE DRAWING

	/**
	 * Draw a polyline through an array of points
	 * @param vertices an array of PVector points
	 */
	void drawPolyline(PVector[] vertices ) {
		drawPolyline(vertices, false);
	}

	/**
	 * Draw a polyline through an array of points
	 * @param vertices an array of PVector points
	 * @param connectEnds whether or not to connect the first and last points
	 */
	void drawPolyline(PVector[] vertices, boolean connectEnds) {
		PVector[] points = new PVector[0];
		color prevStroke = g.strokeColor;

		for (int i = 0; i < vertices.length - 1; i++) {
			PVector[] subPoints = calculatePoints(vertices[i].x, vertices[i].y, vertices[i + 1].x, vertices[i + 1].y);
			if(drawGuides) {
				drawGuideline(vertices[i].x, vertices[i].y, vertices[i + 1].x, vertices[i + 1].y);
				drawPoints(subPoints);
				drawEndPoints(vertices[i], vertices[i + 1]);
			}
			if(i > 0 && subPoints.length > 1){
				subPoints = Arrays.copyOfRange(subPoints, 1, subPoints.length);
			}
			if(i == 0) {
				points = subPoints;
			} else {
				points = (PVector[]) concat(points, subPoints);
			}
		}

		if(connectEnds) {
			boolean prevWobbleAmp = wobbleEndPointAmplitude;
			boolean prevWobblePos = wobbleEndPointPosition;

			wobbleEndPointAmplitude = false;
			wobbleEndPointPosition = false;
			PVector[] subPoints = calculatePoints(points[points.length - 1].x, points[points.length - 1].y, points[0].x, points[0].y);
			if(drawGuides) {
				drawGuideline(points[points.length - 1].x, points[points.length - 1].y, points[0].x, points[0].y);
				drawPoints(subPoints);
			}
			if(subPoints.length > 1){
				subPoints = Arrays.copyOfRange(subPoints, 1, subPoints.length);
			}
			points = (PVector[]) concat(points, subPoints);

			wobbleEndPointAmplitude = prevWobbleAmp;
			wobbleEndPointPosition = prevWobblePos;
		}

		noFill();
		stroke(prevStroke);
		renderLine(points);

	}

	/**
	 * Draw a broken polyline through an array of points
	 * @param vertices an array of PVector points
	 */
	void drawBrokenPolyline(PVector[] vertices) {
		drawBrokenPolyline(vertices, false);
	}

	/**
	 * Draw a broken polyline through an array of points
	 * @param vertices an array of PVector points
	 * @param connectEnds whether or not to connect the first and last points
	 */
	void drawBrokenPolyline(PVector[] vertices, boolean connectEnds) {
		boolean prevWobbleAmp = wobbleEndPointAmplitude;
		boolean prevWobblePos = wobbleEndPointPosition;

		wobbleEndPointAmplitude = false;
		wobbleEndPointPosition = false;

		if(connectEnds) {
			PVector[] subPoints = calculatePoints(vertices[vertices.length - 1].x, vertices[vertices.length - 1].y, vertices[0].x, vertices[0].y);
			if(drawGuides) {
				drawGuideline(vertices[vertices.length - 1].x, vertices[vertices.length - 1].y, vertices[0].x, vertices[0].y);
				drawPoints(subPoints);
			}
			if(subPoints.length > 1){
				subPoints = Arrays.copyOfRange(subPoints, 1, subPoints.length);
			}
			vertices = (PVector[]) concat(vertices, subPoints);
		}


		// TODO: drawing separate lines here creates sharp corners between segments
		// figure out how to combine adjacent segments without closing gaps
		for (int i = 0; i < vertices.length - 1; i++) {
			drawBrokenLine(vertices[i].x, vertices[i].y, vertices[i + 1].x, vertices[i + 1].y);
		}

		wobbleEndPointAmplitude = prevWobbleAmp;
		wobbleEndPointPosition = prevWobblePos;
	}

	// ------------------------------------------------
	// RECTANGLE DRAWING

	/**
	 * Draw a rectangle
	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 * @param w the width of the rectangle
	 * @param h the height of the rectangle
	 */
	void drawRect(float x, float y, float w, float h) {
		drawRect(x, y, w, h, true, false);
	}

	/**
	 * Draw a rectangle with broken lines
 	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 * @param w the width of the rectangle
	 * @param h the height of the rectangle
	 */
	void drawBrokenRect(float x, float y, float w, float h) {
		drawRect(x, y, w, h, true, true);
	}

	/**
	 * Draw a rectangle with broken lines
 	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 * @param w the width of the rectangle
	 * @param h the height of the rectangle
	 * @param connectCorners whether or not to connect the corners
	 */
	void drawBrokenRect(float x, float y, float w, float h, boolean connectCorners) {
		drawRect(x, y, w, h, connectCorners, true);
	}
	
	/**
	 * Draw a rectangle
	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 * @param w the width of the rectangle
	 * @param h the height of the rectangle
	 * @param connectCorners whether or not to connect the corners
	 */
	void drawRect(float x, float y, float w, float h, boolean connectCorners) {
		drawRect(x, y, w, h, connectCorners, false);
	}

	void drawRect(float x, float y, float w, float h, boolean connectCorners, boolean broken) {
		boolean prevWobbleAmp = wobbleEndPointAmplitude;
		boolean prevWobblePos = wobbleEndPointPosition;

		if(connectCorners) {
			wobbleEndPointAmplitude = false;
			wobbleEndPointPosition = false;
		}

		if(broken) {
			drawBrokenLine(x, y, x + w, y);
			drawBrokenLine(x + w, y, x + w, y + h);
			drawBrokenLine(x, y + h, x + w, y + h);
			drawBrokenLine(x, y, x, y + h);
		} else {
			drawLine(x, y, x + w, y);
			drawLine(x + w, y, x + w, y + h);
			drawLine(x, y + h, x + w, y + h);
			drawLine(x, y, x, y + h);
		}

		wobbleEndPointAmplitude = prevWobbleAmp;
		wobbleEndPointPosition = prevWobblePos;
	}

	// ------------------------------------------------
	// SHAPE DRAWING

	/**
	 * Draw a shape
	 * @param shape the PShape to draw
	 * @param broken whether or not to draw the shape as a broken line
	 */
	void drawShape(PShape shape, boolean broken) {
		if(shape.getChildCount() == 0) {
			renderShape(shape, broken);
			return;
		}

		for(int i = 0; i < shape.getChildCount(); i++) {
			PShape child = shape.getChild(i);
			// This is kind of useless because Processing thinks everything is a group for some reason
			if(child.getKind() == PShape.GROUP) {

				drawShape(child, broken);
			} else {
				renderShape(child, broken);
			}
		}
	}

	/**
	 * Draw a shape
	 * @param shape the PShape to draw
	 */
	void drawShape(PShape shape) {
		drawShape(shape, false);
	}

	/**
	 * Draw a shape
	 * @param shape the PShape to draw
	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 */
	void drawShape(PShape shape, float x, float y) {
		pushMatrix();
		translate(x, y);
		drawShape(shape, false);
		popMatrix();
	
	}

	/**
	 * Draw a broken shape
	 * @param shape the PShape to draw
	 */
	void drawBrokenShape(PShape shape) {
		drawShape(shape, true);
	}

	/**
	 * Draw a broken shape
	 * @param shape the PShape to draw
	 * @param x the x-coordinate of the top-left corner
	 * @param y the y-coordinate of the top-left corner
	 */
	void drawBrokenShape(PShape shape, float x, float y) {
		pushMatrix();
		translate(x, y);
		drawShape(shape, true);
		popMatrix();
	}

	// ------------------------------------------------
	// CIRCLE DRAWING

	/**
	 * Draw a circle
	 * @param x the x-coordinate of the center
	 * @param y the y-coordinate of the center
	 * @param r the radius of the circle
	 */
	void drawCircle(float x, float y, float r) {
		float circumference = 2 * PI * r;
		float segmentLength = sqrt(r) * 3 ;
		int segments = max(8, floor(circumference / segmentLength));

		drawCircle(x, y, r, segments, false);
	}

	/**
	 * Draw a circle
	 * @param x the x-coordinate of the center
	 * @param y the y-coordinate of the center
	 * @param r the radius of the circle
	 * @param numSegments the number of segments split the circle into
	 */
	void drawCircle(float x, float y, float r, int numSegments) {
		drawCircle(x, y, r, numSegments, false);
	}

	/**
	 * Draw a broken circle
	 * @param x the x-coordinate of the center
	 * @param y the y-coordinate of the center
	 * @param r the radius of the circle
	 */
	void drawBrokenCircle(float x, float y, float r) {
		float circumference = 2 * PI * r;
		float segmentLength = sqrt(r) * 3 ;
		int segments = max(8, floor(circumference / segmentLength));

		drawCircle(x, y, r, segments, true);
	}

	/**
	 * Draw a circle
	 * @param x the x-coordinate of the center
	 * @param y the y-coordinate of the center
	 * @param r the radius of the circle
	 * @param numSegments the number of segments split the circle into
	 * @param broken whether or not to draw the circle as a broken line
	 */
	void drawCircle(float x, float y, float r, int numSegments, boolean broken) {
		boolean prevWobbleAmp = wobbleEndPointAmplitude;
		boolean prevWobblePos = wobbleEndPointPosition;

		wobbleEndPointAmplitude = true;
		wobbleEndPointPosition = true;

		float angle = 0;
		float angleStep = PI / (numSegments / 2);
		PVector[] points = new PVector[numSegments];
		for (int i = 0; i < numSegments; i++) {
			float x1 = x + cos(angle) * r;
			float y1 = y + sin(angle) * r;
			points[i] = new PVector(x1, y1);
			angle += angleStep;
		}

		if(broken) {
			drawBrokenPolyline(points, true);
		} else {
			drawPolyline(points, true);
		}

		wobbleEndPointAmplitude = prevWobbleAmp;
		wobbleEndPointPosition = prevWobblePos;
	}

	// ------------------------------------------------
	// PRIVATE METHODS
	
	private void renderLine(PVector[] points) {
		// draw a curved line through the points
		beginShape();
		curveVertex(points[0].x, points[0].y);
		for (int i = 0; i < points.length; i++) {
			PVector p1 = points[i];
			curveVertex(p1.x, p1.y);
		}
		curveVertex(points[points.length - 1].x, points[points.length - 1].y);
		endShape();
	}

	private void renderShape(PShape shape, boolean broken) {
		int vertexCount = shape.getVertexCount();
		if(vertexCount < 1) {
			return;
		}

		int[] codes = shape.getVertexCodes();
		int codesCount = shape.getVertexCodeCount();

		PVector[] points = new PVector[0];
		int vIndex = 0;
		for (int i = 0; i < codesCount; i++) {
			if(codes[i] == VERTEX) {
				points = (PVector[]) append(points, shape.getVertex(vIndex));
				vIndex ++;
			} else {
				// if this is a curve, skip the control points
				points = (PVector[]) append(points, shape.getVertex(vIndex + 2));
				vIndex += 3;
			}
		}

		if(broken) {
			drawBrokenPolyline(points);
		} else {
			drawPolyline(points, false);
		}
	}

	private void renderShape(PShape shape) {
		renderShape(shape, false);
	}

	private PVector[][] breakLineIntoSegments(float x1, float y1, float x2, float y2) {
		float lengthOfLine = dist(x1, y1, x2, y2);
		if(lengthOfLine <= minLineSegmentLength) {
			PVector[][] seg =  new PVector[1][2];
			seg[0][0] = new PVector(x1, y1);
			seg[0][1] = new PVector(x2, y2);
			return seg;
		}

		PVector[][] segments = new PVector[0][0];
		float angle = atan2(y2 - y1, x2 - x1);
		float currentX = x1;
		float currentY = y1;
		float remainingLength = lengthOfLine;

		int count = 0;

		while(remainingLength > 0) {
			segments = (PVector[][]) append(segments, new PVector[2]);
			float segmentLength = random(minLineSegmentLength, lengthOfLine / breakFrequency);
			segmentLength = min(segmentLength, remainingLength);

			float nextX = currentX + cos(angle) * segmentLength;
			float nextY = currentY + sin(angle) * segmentLength;
			segments[segments.length - 1][0] = new PVector(currentX, currentY);
			segments[segments.length - 1][1] = new PVector(nextX, nextY);
			remainingLength -= segmentLength;

			// Move the current point along the line by the gap distance
			float gap = random(minBreakSize, maxBreakSize); 
			currentX = nextX + cos(angle) * gap;
			currentY = nextY + sin(angle) * gap;
			remainingLength = max(remainingLength - gap, 0);
			count++;
		}
		return segments;
	}

	private PVector[] calculatePoints(float x1, float y1, float x2, float y2) {
		
		float lengthOfLine = dist(x1, y1, x2, y2);
		int numberOfSegments = (int) max(lengthOfLine / frequency, 1);
		PVector[] points = new PVector[numberOfSegments + 1];
		points[0] = new PVector(x1, y1);
		points[points.length - 1] = new PVector(x2, y2);
		float jitter = max(frequencyJitter * frequency, 0.001);

		float slope = (y2 - y1) / (x2 - x1);
		float angle = atan(slope);

		// find the points in between
		for (int i = 1; i < points.length - 1; i++) {
			float t = (float) i / (points.length - 1);
			points[i] = PVector.lerp(new PVector(x1, y1), new PVector(x2, y2), t);
			// offset the point perpendicular to the line
			points[i] = offsetPointPerpendicularToLine(points[i], angle, random(-amplitude, amplitude));
			// offset the point parallel to the line
			points[i] = offsetPointParallelToLine(points[i], angle, random(-jitter, jitter));
			
		}

		if(wobbleEndPointAmplitude) {
			points[0] = offsetPointPerpendicularToLine(points[0], angle, random(-amplitude, amplitude));
			points[points.length - 1] = offsetPointPerpendicularToLine(points[points.length - 1], angle, random(-amplitude, amplitude));
		}

		if(wobbleEndPointPosition) {
			points[0] = offsetPointParallelToLine(points[0], angle, random(-jitter, jitter));
			points[points.length - 1] = offsetPointParallelToLine(points[points.length - 1], angle, random(-jitter, jitter));
		}

		return points;
	}

	private PVector offsetPointPerpendicularToLine(PVector point, float angleOfLine, float distance) {
		float x = point.x + cos(angleOfLine + PI / 2) * distance;
		float y = point.y + sin(angleOfLine + PI / 2) * distance;
		point.x = x;
		point.y = y;
		return point;
	}

	private PVector offsetPointParallelToLine(PVector point, float angleOfLine, float distance) {
		float x = point.x + cos(angleOfLine) * distance;
		float y = point.y + sin(angleOfLine) * distance;
		point.x = x;
		point.y = y;
		return point;
	}

	// ------------------------------------------------
	// DEBUG GUIDES

	private void drawGuideline(float x1, float y1, float x2, float y2) {
		stroke(0, 255, 255);
		float prevStrokeWeight = g.strokeWeight;
		strokeWeight(1);
		line(x1, y1, x2, y2);
		strokeWeight(prevStrokeWeight);
	}

	private void drawPoints(PVector[] points) {
		noStroke();
		fill(255, 0, 0);
		for (int i = 0; i < points.length; i++) {
			PVector p1 = points[i];
			circle(p1.x, p1.y, 6);
		}
	}

	private void drawEndPoints(PVector p1, PVector p2) {
		noStroke();
		fill(0, 255, 0, 200);
		circle(p1.x, p1.y, 10);
		circle(p2.x, p2.y, 10);
	}

}