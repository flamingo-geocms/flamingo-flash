/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

import geometrymodel.LinearRing;
import geometrymodel.Point;
import geometrymodel.Polygon;
import geometrymodel.Envelope;
import geometrymodel.LineString;
import gismodel.Feature;

class gui.EditMapPolygon extends EditMapGeometry {

	private var intersectionPixel:Pixel;
	private var drawFillPattern:Boolean;
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
		drawFillPattern = false;
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    function doDraw():Void {
		if (editMapEditable) {
			var feature:Feature = this.getFirstAncestor()._parent.getFeature();
			if (feature.getValue("app:strokecolor") != null){
				strokeColor = Number(feature.getValue("app:strokecolor"));
			}
			if (feature.getValue("app:strokeopacity") != null){
				strokeOpacity = Number(feature.getValue("app:strokeopacity"));
			}
			if (feature.getValue("app:fillcolor") != null){
				fillColor = Number(feature.getValue("app:fillcolor"));
			}
			if (feature.getValue("app:fillopacity") != null){
				fillOpacity = Number(feature.getValue("app:fillopacity"));
			}
			
			fillPatternUrl = String(feature.getValue("app:fillpattern"));
			
			drawFillPattern = !(fillPatternUrl == null || fillPatternUrl == "null" || fillPatternUrl == NaN || fillPatternUrl == undefined);
			//trace("EditMapPolygon.as doDraw() drawFillPattern = "+drawFillPattern);
			
			
			/*
			trace("EditMapPolygon.as doDraw() feature = "+feature);
			trace("EditMapPolygon.as doDraw() app:strokecolor value = "+feature.getValue("app:strokecolor"));
			trace("EditMapPolygon.as doDraw() app:strokeopacity value = "+feature.getValue("app:strokeopacity"));
			trace("EditMapPolygon.as doDraw() app:fillcolor value = "+feature.getValue("app:fillcolor"));
			trace("EditMapPolygon.as doDraw() app:fillopacity value = "+feature.getValue("app:fillopacity"));
			trace("EditMapPolygon.as doDraw() app:fillpattern value = "+fillPatternUrl);
			*/
			
			doDrawEditable();
		}
		else {
			var polygon:Polygon = Polygon(_geometry);
			var exteriorRing:LinearRing = polygon.getExteriorRing();
			var points:Array = exteriorRing.getPoints();
			var pixel:Pixel = point2Pixel(points[0]);
			var x:Number = pixel.getX();
			var y:Number = pixel.getY();
			
			clear();
			moveTo(x, y);
			if (type == ACTIVE) {
				lineStyle(0, strokeColor, strokeOpacity);
			} else {
				lineStyle(strokeWidth , strokeColor, strokeOpacity);
			}
			if (style.getFillOpacity() > 0) {
				beginFill(fillColor, fillOpacity);
			}
			for (var i:Number = 1; i < points.length; i++) {
				pixel =  point2Pixel(points[i]);
				lineTo(pixel.getX(), pixel.getY());
			}
			if (fillOpacity > 0) {
				endFill();
			}
			
			if (type != ACTIVE) {
				moveTo(x, y);
				lineStyle(strokeWidth * 2, 0, 0);
				for (var i:Number = 1; i < points.length; i++) {
					pixel =  point2Pixel(points[i]);
					lineTo(pixel.getX(), pixel.getY());
				}
			}
		}
	}
		
		
    private function doDrawEditable():Void {
        var polygon:Polygon = Polygon(_geometry);
        var exteriorRing:LinearRing = polygon.getExteriorRing();
        var points:Array = exteriorRing.getPoints();
        var pixel:Pixel = point2Pixel(points[0]);
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
            lineStyle(0, strokeColor, strokeOpacity);
        } else {
            lineStyle(strokeWidth , strokeColor, strokeOpacity);
        }
		
		if (!drawFillPattern) {
			if (style.getFillOpacity() > 0) {
				beginFill(fillColor, fillOpacity);
			}
			for (var i:Number = 1; i < points.length; i++) {
				pixel =  point2Pixel(points[i]);
				lineTo(pixel.getX(), pixel.getY());
			}
			if (fillOpacity > 0) {
				endFill();
			}
		} else {
			//load fill pattern png
			//fillPatternUrl
		}
        
        if (type != ACTIVE) {
            moveTo(x, y);
            lineStyle(strokeWidth * 2, 0, 0);
            for (var i:Number = 1; i < points.length; i++) {
                pixel =  point2Pixel(points[i]);
                lineTo(pixel.getX(), pixel.getY());
            }
        }
    }
	
	private function intersectWithViewPort(startPixel:Pixel, endPixel:Pixel):Boolean {
		var startPixelNC:Pixel = startPixel.clone(); 	//Not Clipped
		var endPixelNC:Pixel = endPixel.clone(); 	//Not Clipped
		
		//viewport corner pixel points
		var pOO:Pixel = new Pixel(0, 0);
		var pOH:Pixel = new Pixel(0, height);
		var pWO:Pixel = new Pixel(width, 0);
		var pWH:Pixel = new Pixel(width, height);
		
		var intersection:Boolean = false;
		
		//vertical line 1 at x = 0
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOO, pOH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getX() < pOO.getX()) {
				startPixel = intersectionPixel.clone();
			}
			else {
				endPixel = intersectionPixel.clone();
			}
		}
		//vertical line 2 at x = width
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pWO, pWH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getX() > pWO.getX()) {
				startPixel = intersectionPixel.clone();
			}
			else {
				endPixel = intersectionPixel.clone();
			}
		}
		//horizontal line 3 at y = 0
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOO, pWO) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getY() < pOO.getY()) {
				startPixel = intersectionPixel.clone();
			}
			else {
				endPixel = intersectionPixel.clone();
			}
		}
		//horizontal line 4 at y = height
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOH, pWH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getY() > pOH.getY()) {
				startPixel = intersectionPixel.clone();
			}
			else {
				endPixel = intersectionPixel.clone();
			}
		}
		return intersection;
	}
	
	private function lineSegmentIntersectionTest_px(p1:Pixel, p2:Pixel, p3:Pixel, p4:Pixel):String {
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
    
}
