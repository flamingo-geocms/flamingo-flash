/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

import geometrymodel.Geometry;
import geometrymodel.Envelope;
import geometrymodel.LineString;
import geometrymodel.Point;
import gismodel.CreateGeometry;
import event.GeometryListener;

class gui.EditMapLineString extends EditMapGeometry implements GeometryListener {
    
	private var editMapLineStringGraphics:Array = null;
	private var intersectionPoint:Point;
	private var intersectionPixel:Pixel;
	
	private var thisObj:Object;
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
		thisObj = this;
		intersectionPoint = new Point(0,0);
		intersectionPixel = new Pixel(0,0);
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
		super.setSize(width, height);
    }
	
	function onChangeGeometry(geometry:Geometry):Void {
		cleanChildDrawing();
		removeEditMapGeometries();
		addChildGeometries();
		draw();
 	}
	
    function onAddChild(geometry:Geometry,child:Geometry):Void{
    	//do nothing
    }
	
	function onRemoveChild(geometry:Geometry,child:Geometry) : Void {
		//do nothing
    }
    
	
	function polygonIsSimpleTest():Boolean {
		var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
		
		var isClosed:Number = 0;
		if (points.length >=2) {
			if (Point(points[0]) == Point(points[points.length - 1])){
				isClosed = 1;
			}
		}
	
		var intersection:Boolean = false;
		var polygonSimple:Boolean = true;
		//test on line segment length != 0
		for (var i:Number = 0; i < points.length - isClosed - 1; i++) {
			//test on line segment length != 0
			if (points[i].getDistance(points[i+1] == 0)) {
				polygonSimple = false;
				break;
			}
			else {	
				//test if connected line segments are parallel
				if ( i < points.length - isClosed - 1) {
					if (lineSegmentIntersectionTest(points[i], points[i+1], points[i+1], points[i+2]) == "PARALLEL") {
						polygonSimple = false;
						break;
					}
				}
			}
		
		}
		
		if (selfIntersectionTest()){
			polygonSimple = false;
		}
		return polygonSimple;
	}
    
	function selfIntersectionTest():Boolean {
		var intersection:Boolean = false;
		
		var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
		
		var isClosed:Number = 0;
		if (points.length >=2) {
			if (Point(points[0]) == Point(points[points.length - 1])){
				isClosed = 1;
			}
		}
			
		//test selfintersection 
		for (var i:Number = 0; i < points.length - isClosed; i++) {
			for (var j:Number = i + 2; j < points.length - isClosed - 1; j++) {
				if (points[i] != points[i+1] && points[j] != points[j+1]) {
					if (lineSegmentIntersectionTest(points[i], points[i+1], points[j], points[j+1]) == "INTERSECTING") {
						intersection = true;
						break;
					}
				}
			}
		}
		
		return intersection;
	}
	
	function selfIntersectionTestDragPoint(dragPointNr:Number, testPoint:Point):Boolean {
		var intersection:Boolean = false;
		
		var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
		
		var isClosed:Number = 0;
		if (points.length >=2) {
			if (Point(points[0]) == Point(points[points.length - 1])){
				isClosed = 1;
			}
		}
		
		//previous & next points
		var dragPointNrPrev:Number = dragPointNr - 1;
		if (dragPointNr == 0) {
			dragPointNrPrev = points.length - isClosed - 1;
		}
		var dragPointNrNext:Number = dragPointNr + 1;
		if (isClosed && (dragPointNr >= points.length - isClosed - 1) ) {
			dragPointNrNext = 0;
		}
		
		
		var polygonSimple:Boolean = true;
		//test on line segment length != 0
		if (points[dragPointNrPrev].getDistance(points[dragPointNr]) == 0
			|| points[dragPointNr].getDistance(points[dragPointNrNext]) == 0) {
			polygonSimple = false;
			break;
		}
		//test if connected line segments are parallel
		else if (lineSegmentIntersectionTest(points[dragPointNrPrev], points[dragPointNr], points[dragPointNr], points[dragPointNrNext]) == "PARALLEL") {
			polygonSimple = false;
			break;
		}
		//test selfintersection 
		for (var i:Number = 0; i < points.length - isClosed; i++) {
			if (i != dragPointNr && i != dragPointNrPrev ) {
				if (i != dragPointNrPrev - 1 && i != points.length - isClosed - 1 &&
					lineSegmentIntersectionTest(points[dragPointNrPrev], testPoint, points[i], points[i+1]) == "INTERSECTING") {
					var ipp:Number = i+1;
					//trace("Line intersection between line "+dragPointNrPrev+" - "+dragPointNr+"  and line " +i+" - "+ipp);
					intersection = true;
				}
				
				if (i != dragPointNr + 1 && dragPointNr != points.length - isClosed - 1 &&
					lineSegmentIntersectionTest(testPoint, points[dragPointNrNext], points[i], points[i+1]) == "INTERSECTING") {
					var ipp:Number = i+1;
					//trace("Line intersection between line "+dragPointNr+" - "+dragPointNrNext+"  and line " +i+" - "+ipp);
					intersection = true;
				}
				
				if (i == points.length - isClosed - 1 && dragPointNr != points.length - isClosed - 1 && dragPointNr != 1 &&
					lineSegmentIntersectionTest(points[dragPointNrPrev], testPoint, points[i], points[0]) == "INTERSECTING") {
					//trace("Line intersection between line "+dragPointNrPrev+" - "+dragPointNr+"  and line " +i+" - "+0);
					intersection = true;
				}
				
				if (dragPointNr == points.length - isClosed - 1 && i != 0 &&
					lineSegmentIntersectionTest(points[0], testPoint, points[i], points[i+1]) == "INTERSECTING") {
					var ipp:Number = i+1;
					//trace("Line intersection between line "+0+" - "+dragPointNr+"  and line " +i+" - "+ipp);
					intersection = true;
				}

			}
		
		}
		if (polygonSimple == false) {
			//intersection = true;
		}
		//trace("*** Result Selfintersection test: selfintersection = "+intersection+"     polygonSimple = "+polygonSimple);
		return intersection;
	}
	
	function lineSegmentIntersectionTest(p1:Point, p2:Point, p3:Point, p4:Point):String {
		//Line Segment A: point p1 & p2
		//Line Segment B: point p3 & p4
		var denom:Number = 	((p4.getY() - p3.getY())*(p2.getX() - p1.getX())) - ((p4.getX() - p3.getX())*(p2.getY() - p1.getY()));
		var nume_a:Number = ((p4.getX() - p3.getX())*(p1.getY() - p3.getY())) - ((p4.getY() - p3.getY())*(p1.getX() - p3.getX()));
		var nume_b:Number = ((p2.getX() - p1.getX())*(p1.getY() - p3.getY())) - ((p2.getY() - p1.getY())*(p1.getX() - p3.getX()));
		
		if (denom == 0) {
            if(nume_a == 0.0 && nume_b == 0.0) {
                return "COINCIDENT";
            }
            return "PARALLEL";
        }

        var ua:Number = nume_a / denom;
        var ub:Number = nume_b / denom;

        if(ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0) {
            // Get the intersection point.
            intersectionPoint.setX(p1.getX() + ua*(p2.getX() - p1.getX()));
            intersectionPoint.setY(p1.getY() + ua*(p2.getY() - p1.getY()));
            return "INTERSECTING";
        }

		return "NOT_INTERSECTING";
	
	}
	
	function lineSegmentIntersectionPixel(p1:Pixel, p2:Pixel, p3:Pixel, p4:Pixel):String {
		//Line Segment A: Pixel p1 & p2
		//Line Segment B: Pixel p3 & p4
		var denom:Number = 	((p4.getY() - p3.getY())*(p2.getX() - p1.getX())) - ((p4.getX() - p3.getX())*(p2.getY() - p1.getY()));
		var nume_a:Number = ((p4.getX() - p3.getX())*(p1.getY() - p3.getY())) - ((p4.getY() - p3.getY())*(p1.getX() - p3.getX()));
		var nume_b:Number = ((p2.getX() - p1.getX())*(p1.getY() - p3.getY())) - ((p2.getY() - p1.getY())*(p1.getX() - p3.getX()));
		
		if (denom == 0) {
            if(nume_a == 0.0 && nume_b == 0.0) {
                return "COINCIDENT";
            }
            return "PARALLEL";
        }

        var ua:Number = nume_a / denom;
        var ub:Number = nume_b / denom;

        if(ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0) {
            // Get the intersection Pixel.
            intersectionPixel.setX(p1.getX() + ua*(p2.getX() - p1.getX()));
            intersectionPixel.setY(p1.getY() + ua*(p2.getY() - p1.getY()));

            return "INTERSECTING";
        }

		return "NOT_INTERSECTING";
	
	}
	
	function doDrawPointDrag(dragPointNr:Number, dragPixel:Pixel):Void {
		var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
		
		//check if closed
		var isClosed:Boolean = false;
		if (points.length >=2) {
			isClosed = (Point(points[0]) == Point(points[points.length - 1]));
		}

		//previous & next points
		var dragPointNrPrev:Number = dragPointNr - 1;
		if (dragPointNr == 0) {
			dragPointNrPrev = points.length - isClosed - 1;
		}
		var dragPointNrNext:Number = dragPointNr + 1;
		if (isClosed && (dragPointNr >= points.length - isClosed - 1) ) {
			dragPointNrNext = 0;
		}
		
		//We need to redraw the line segments: 
		var prevPixel:Pixel = point2Pixel(Point(points[dragPointNrPrev]));
		var nextPixel:Pixel = point2Pixel(Point(points[dragPointNrNext]));
		
		//(A) from previous point to dragpoint and
		if ( ! (isClosed == false && dragPointNr == 0) ) {//do not draw if you are for example dragging point 0 from a open linestring
			drawLineStringGraphics(dragPointNrPrev, prevPixel, dragPixel);
		}
		//(B) from dragpoint to next point.
		if (isClosed || (dragPointNr < points.length - 1)) {
			drawLineStringGraphics(dragPointNr, dragPixel, nextPixel);
		}
		
	}
	
	
	private function drawLineStringGraphics(i:Number, startPixel:Pixel, endPixel:Pixel):Void {
		var x:Number = startPixel.getX();
		var y:Number = startPixel.getY();
		
		var performClipping:Boolean = false;
		if (startPixel.getDistance(endPixel) > 5600 - width) {
			performClipping = true;
		}
				
		if (performClipping) {
			//perform clipping operation
			var startPixelNC:Pixel = startPixel.clone(); 	//Not Clipped
			var endPixelNC:Pixel = endPixel.clone();	//Not Clipped
			
			//set helper pixels of envelope corners
			var pOO:Pixel = new Pixel(0, 0);
			var pOH:Pixel = new Pixel(0, height);
			var pWO:Pixel = new Pixel(width, 0);
			var pWH:Pixel = new Pixel(width, height);
			
			//vertical line 1 at x = 0
			if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOO, pOH) == "INTERSECTING") {
				if (startPixelNC.getX() < pOO.getX()) {
					startPixel = intersectionPixel.clone();
				}
				else {
					endPixel = intersectionPixel.clone();
				}
			}
			//vertical line 2 at x = width
			if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pWO, pWH) == "INTERSECTING") {
				if (startPixelNC.getX() > pWO.getX()) {
					startPixel = intersectionPixel.clone();
				}
				else {
					endPixel = intersectionPixel.clone();
				}
			}
			//horizontal line 3 at y = 0
			if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOO, pWO) == "INTERSECTING") {
				if (startPixelNC.getY() < pOO.getY()) {
					startPixel = intersectionPixel.clone();
				}
				else {
					endPixel = intersectionPixel.clone();
				}
			}
			//horizontal line 4 at y = height
			if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOH, pWH) == "INTERSECTING") {
				if (startPixelNC.getY() > pOH.getY()) {
					startPixel = intersectionPixel.clone();
				}
				else {
					endPixel = intersectionPixel.clone();
				}
			}
		}
		
		var lineX:Number = endPixel.getX() - startPixel.getX();
		var lineY:Number = endPixel.getY() - startPixel.getY();
		
		if (editMapLineStringGraphics[i] != undefined) {
			with (editMapLineStringGraphics[i]) {
				_x = x;
				_y = y;
			}
			
			with (editMapLineStringGraphics[i].mEditMapLineGraphicNormal) {
				_x = 0;
				_y = 0;
				clear();
				lineStyle(6, 0xffff00, 50);
				moveTo(0, 0);
				lineTo(lineX, lineY);
			}
										
			
			with (editMapLineStringGraphics[i].mEditMapLineGraphicRollOver) {
				_x = 0;
				_y = 0;
				clear();
				lineStyle(6, 0xff0000, 50);
				moveTo(0, 0);
				lineTo(lineX, lineY);
			}
		}
		else {
			//trace("EditMapLineString: doDraw: editMapLineStringGraphics undefined");
		}
		
	}
	
	function doDraw():Void {
		if (editMapEditable) {
			doDrawEditable();
		}
		else {
			var lineString:LineString = LineString(_geometry);
			var points:Array = lineString.getPoints();
			var pixel:Pixel = point2Pixel(points[0]);
			
			var x:Number = pixel.getX();
			var y:Number = pixel.getY();
			clear();
			moveTo(x, y);
			if (type == ACTIVE) {
				if(isChild){
					lineStyle(strokeWidth * 2, strokeColor, strokeOpacity);
				} else {
					lineStyle(strokeWidth * 2, strokeColor, strokeOpacity);
				}
			} else {
				if(isChild){
					lineStyle(0, 0, 0);
				} else {	
					lineStyle(strokeWidth, strokeColor, strokeOpacity);
				}	
			}
			for (var i:Number = 1; i < points.length; i++) {
				pixel = point2Pixel(points[i]);
				lineTo(pixel.getX(), pixel.getY());
			}
		}
	}
		
	
	function doDrawEditable():Void {
        var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
        var thisObj:Object = this;
		
		//check if closed
		var isClosed:Boolean = false;
		if (points.length >=2) {
			isClosed = (Point(points[0]) == Point(points[points.length - 1]));
		}
		
		//clean from mEditMapLineGraphic members
		for (_name in this) {
			//if (this[_name] instanceof MovieClip) {
			if (this[_name] instanceof EditMapLineGraphic) {
				this[_name].removeMovieClip();
			}
		}
		
		if (type == ACTIVE) {
			//Draw linepieces: each linesegment is  a seperate mEditMapLineGraphic movieclip
			
			//container for LineStringGraphics
			editMapLineStringGraphics = null;
			editMapLineStringGraphics = new Array();
			
			//check if closed
			var isClosed:Boolean = false;
			if (points.length >=2) {
				isClosed = (Point(points[0]) == Point(points[points.length - 1]));
			}
											
			//create for each linepieces, i.e. the graphical presentation of line segments that built up the linestring 
			for (var i:Number = 0; i < points.length - isClosed; i++) {
			
				var iNext:Number = i + 1;
				if (isClosed && (i == points.length - isClosed - 1) ) {
					iNext = 0;
				}
				
				var depth:Number= 5000 + 1 + i;
				var IDnr:Number = i;
				editMapLineStringGraphics.push(this.attachMovie("EditMapLineGraphic", "mEditMapLineGraphic"+IDnr, depth));
				
				//set start- and endpoint
				editMapLineStringGraphics[i].setStartPointNr(i + 10000);
				editMapLineStringGraphics[i].setStartPoint(points[i]);
				editMapLineStringGraphics[i].setEndPointNr(iNext + 10000);
				editMapLineStringGraphics[i].setEndPoint(points[iNext]);
				
				var startPixelNC:Pixel = point2Pixel(Point(points[i])); 	//Not Clipped
				var endPixelNC:Pixel = point2Pixel(Point(points[iNext]));	//Not Clipped
				var startPixel:Pixel = point2Pixel(Point(points[i]));
				var endPixel:Pixel = point2Pixel(Point(points[iNext]));
				
				//perform clipping operation
				var pOO:Pixel = new Pixel(0, 0);
				var pOH:Pixel = new Pixel(0, height);
				var pWO:Pixel = new Pixel(width, 0);
				var pWH:Pixel = new Pixel(width, height);
				
				
				//vertical line 1 at x = 0
				if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOO, pOH) == "INTERSECTING") {
					if (startPixelNC.getX() < pOO.getX()) {
						startPixel = intersectionPixel.clone();
					}
					else {
						endPixel = intersectionPixel.clone();
					}
				}
				//vertical line 2 at x = width
				if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pWO, pWH) == "INTERSECTING") {
					if (startPixelNC.getX() > pWO.getX()) {
						startPixel = intersectionPixel.clone();
					}
					else {
						endPixel = intersectionPixel.clone();
					}
				}
				//horizontal line 3 at y = 0
				if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOO, pWO) == "INTERSECTING") {
					if (startPixelNC.getY() < pOO.getY()) {
						startPixel = intersectionPixel.clone();
					}
					else {
						endPixel = intersectionPixel.clone();
					}
				}
				//horizontal line 4 at y = height
				if (lineSegmentIntersectionPixel(startPixelNC, endPixelNC, pOH, pWH) == "INTERSECTING") {
					if (startPixelNC.getY() > pOH.getY()) {
						startPixel = intersectionPixel.clone();
					}
					else {
						endPixel = intersectionPixel.clone();
					}
				}
				
				var x:Number = startPixel.getX();
				var y:Number = startPixel.getY();				
				var lineX:Number = endPixel.getX() - x;
				var lineY:Number = endPixel.getY() - y;
				
				if (editMapLineStringGraphics[i] != undefined) {
					with (editMapLineStringGraphics[i]) {
						_x = x;
						_y = y;
						
						createEmptyMovieClip("mEditMapLineGraphicNormal", 1 );
						with (mEditMapLineGraphicNormal) {
							lineStyle(6, 0xffff00, 50);
							moveTo(0, 0);
							lineTo(lineX, lineY);
						}
						
						createEmptyMovieClip("mEditMapLineGraphicRollOver", 0 );
						with (mEditMapLineGraphicRollOver) {
							lineStyle(6, 0xff0000, 50);
							moveTo(0, 0);
							lineTo(lineX, lineY);
						}
						
					}
					
					enablePseudoButtonEvents(editMapLineStringGraphics[i]);
					
					editMapLineStringGraphics[i].onRollOverHandler = function(){
						// onRollOver
						if (this.mEditMapLineGraphicRollOver.getDepth() < this.mEditMapLineGraphicNormal.getDepth()) {
							this.mEditMapLineGraphicRollOver.swapDepths(this.mEditMapLineGraphicNormal);
						}
					}
					editMapLineStringGraphics[i].onRollOutHandler = function(){
						// onRollOut
						if (this.mEditMapLineGraphicRollOver.getDepth() > this.mEditMapLineGraphicNormal.getDepth()) {
							this.mEditMapLineGraphicNormal.swapDepths(this.mEditMapLineGraphicRollOver);
						}
						
					}
					editMapLineStringGraphics[i].onDragOutHandler = function(){
						// onDragOutHandler
						if (this.mEditMapLineGraphicRollOver.getDepth() > this.mEditMapLineGraphicNormal.getDepth()) {
							this.mEditMapLineGraphicNormal.swapDepths(this.mEditMapLineGraphicRollOver);
						}
						
					}
					
					
					editMapLineStringGraphics[i].onPressHandler = function(){
						var pix:Pixel = new Pixel(this._x+_xmouse, this._y+_ymouse);
						var point:geometrymodel.Point = thisObj.pixel2Point(pix);
						
						if (thisObj._geometry == null) {
							
						} else {
							//check if start and/or endpoint are not pressed too
							var mSP:String = "mEditMapPoint"+this.getStartPointNr();
							var startPointHit:Boolean = false;
							if (thisObj[mSP]._x >= 0 &&  thisObj[mSP]._x <= thisObj.width 
								&& thisObj[mSP]._y >= 0 &&  thisObj[mSP]._y <= thisObj.height) {
								startPointHit = thisObj[mSP].mPointGraphic.hitTest(_root._xmouse, _root._ymouse, true);
							}
							var mEP:String = "mEditMapPoint"+this.getEndPointNr();
							var endPointHit:Boolean = false;
							if (thisObj[mEP]._x >= 0 &&  thisObj[mEP]._x <= thisObj.width 
								&& thisObj[mEP]._y >= 0 &&  thisObj[mEP]._y <= thisObj.height) {
								endPointHit = thisObj[mEP].mPointGraphic.hitTest(_root._xmouse, _root._ymouse, true);
							}							
							if (!startPointHit && !endPointHit) {
								var insertIndex:Number = this.getStartPointNr() - 10000 + 1;
								thisObj._geometry.insertPoint(point, insertIndex);
							}
						}
					}
				}
			}
		}
		else {
			//clean from mEditMapLineGraphic members
			for (_name in this) {
				if (this[_name] instanceof EditMapLineGraphic) {		
					this[_name].removeMovieClip();
				}
			}
			for (var i in editMapLineStringGraphics){
				disablePseudoButtonEvents(editMapLineStringGraphics[i]);
				editMapLineStringGraphics[i] = null;
			}
			editMapLineStringGraphics = null;
			
			//draw non-active lines
			var pixel:Pixel = point2Pixel(Point(points[0]));
			var x:Number = pixel.getX();
			var y:Number = pixel.getY();
		
			clear();
			moveTo(x, y);
			lineStyle(style.getStrokeWidth(), style.getStrokeColor(), style.getStrokeOpacity());
			for (var i:Number = 1; i < points.length; i++) {
				pixel = point2Pixel(Point(points[i]));
				lineTo(pixel.getX(), pixel.getY());
			}
			
			moveTo(x, y);
            lineStyle(style.getStrokeWidth() * 2, 0, 0);
            for (var i:Number = 1; i < points.length; i++) {
                pixel = point2Pixel(Point(points[i]));
                lineTo(pixel.getX(), pixel.getY());
            }
		}
	}
	
	function cleanChildDrawing():Void {
		for (var children in this) {
			if (this[children] instanceof MovieClip) {
				if (this[children] instanceof EditMapPoint) {
					this[children].removeMovieClip();
				}
			}
		}
	}
	
	private function pixel2Point(pixel:Pixel):geometrymodel.Point {
		var extent:Object = map.getCurrentExtent();
        var minX:Number = extent.minx;
        var minY:Number = extent.miny;
        var maxX:Number = extent.maxx;
        var maxY:Number = extent.maxy;
		
		var pointX:Number = pixel.getX() * (maxX - minX) / width + minX;
        var pointY:Number = -pixel.getY() * (maxY - minY) / height + maxY;
        
        return new geometrymodel.Point(pointX, pointY);
    }

	function enablePseudoButtonEvents(target){
		target.isPressed = false; // flag
		target.isMouseOver = false; // flag
		
		target.onMouseDown = function(){
			if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
				this.isPressed = true;
				// onPress
				this.onPressHandler();
			}else{
				this.isPressed = false;
			}
		}
		
		target.onMouseUp = function(){
			if (this.isPressed){
				if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
					// onRelease
					this.onReleaseHandler();
				}else{
					// onReleaseOutside
					this.onReleaseOutsideHandler();
				}
			}
			this.isPressed = false;
		}
		
		target.onMouseMove = function(){
			var lastIsOver = this.isMouseOver;
			if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
				this.isMouseOver = true;
				if (this.isMouseOver != lastIsOver){
					if (this.isPressed){
						// onDragOver
						this.onDragOverHandler();
					}else{
						// onRollOver
						this.onRollOverHandler();
					}
				}
			}else{
				this.isMouseOver = false;
				if (this.isMouseOver != lastIsOver){
					if (this.isPressed){
						// onDragOut
						this.onDragOutHandler();
					}else{
						// onRollOut
						this.onRollOutHandler();
					}
				}
			}
		}
	}
	
	function disablePseudoButtonEvents(target){
		delete target.onMouseDown; 
		delete target.onMouseUp;
		delete target.onMouseMove;
	}
	
	
    
}
