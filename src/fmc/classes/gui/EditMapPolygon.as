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
import gismodel.Layer;
import gismodel.GeometryProperty;
import tools.Logger;

class gui.EditMapPolygon extends EditMapGeometry {

	private var intersectionPixel:Pixel;
	private var drawFillPattern:Boolean;
	var dragging:Boolean = false;

	function onLoad():Void {// This method is a stub. It is necessary though, because of the "super" bug in Flash.
		super.onLoad();
		drawFillPattern = false;
	}
	
	function dragFeature():Void {
		var thisObj = this;
		if (this.gis.getFeaturesDraggable()) {
			if (!thisObj.pointsPressed(thisObj)) {
				thisObj.dragging = true;
				this.startDrag(false);
			}
		}
			
		this.onMouseUp = function() {
			if (thisObj.dragging) {
				this.stopDrag();
				var displacementX = this.map.getMapScale()*thisObj._x;
				var displacementY = -1*this.map.getMapScale()*thisObj._y;
				var g = thisObj._geometry;
				(thisObj._geometry).translatePos(displacementX,displacementY);
				thisObj.dragging = false;
				thisObj._x = 0;
				thisObj._y = 0;
				thisObj.reDraw();
				thisObj.gis.geometryUpdate();
			}
		};
		
	}
	
	function pointsPressed(thisObj):Boolean {
		var pointDragged = false;
		for (var i:Number = 0; i<thisObj.editMapGeometries.length; i++) {
			if (thisObj.editMapGeometries[i] instanceof EditMapPoint) {
				if (thisObj.editMapGeometries[i].mPointGraphic.isPressed) {
					pointDragged = true;
					break;
				}
			} else {
				pointDragged = pointsPressed(editMapGeometries[i]);
				if (pointDragged) {
					break;
				}
			}
		}
		return pointDragged;
	}
	
	function setSize(width:Number, height:Number):Void {// This method is a stub. It is necessary though, because of the "super" bug in Flash.
		super.setSize(width,height);
	}
	
	private function getFlashValue(feature:Feature, layer:Layer, propType:String):String {
		var geometryProperty:GeometryProperty = layer.getPropertyWithType(propType);
		var val:String = feature.getValueWithPropType(propType);
		return geometryProperty.getFlashValue(val);
	}
	function doDraw():Void {
		if (editable) {
			var feature:Feature = this.getFirstAncestor()._parent.getFeature();
			var layer:Layer = feature.getLayer();
			var flashValue:String;

			flashValue = getFlashValue(feature, layer, "strokecolor");
			if (flashValue != null) {
				strokeColor = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "strokeopacity");
			if (flashValue != null) {
				strokeOpacity = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "fillcolor");
			if (flashValue != null) {
				fillColor = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "fillopacity");
			if (flashValue != null) {
				fillOpacity = Number(flashValue);
			}
			fillPatternUrl = getFlashValue(feature, layer, "fillpattern");

			drawFillPattern = !(fillPatternUrl == null || fillPatternUrl == "null" || fillPatternUrl == NaN || fillPatternUrl == undefined);
		}
		var polygon:Polygon = Polygon(_geometry);
		var exteriorRing:LinearRing = polygon.getExteriorRing();
		var interiorRings:Array = polygon.getInteriorRings();
		var points:Array = exteriorRing.getPoints();
		var pixel:Pixel = point2Pixel(points[0]);
		var x:Number = pixel.getX();
		var y:Number = pixel.getY();

		clear();
		moveTo(x,y);
		if (type == ACTIVE) {
			lineStyle(0,strokeColor,strokeOpacity);
		} else {
			lineStyle(strokeWidth,strokeColor,strokeOpacity);
		}
		if (style.getFillOpacity()>0) {
			beginFill(fillColor,fillOpacity);
		}
		for (var i:Number = 1; i<points.length; i++) {
			pixel = point2Pixel(points[i]);
			lineTo(pixel.getX(),pixel.getY());
		}
		//walk over the interior rings
		for (var i:Number = 0; i<interiorRings.length; i++) {
			var innerPoints:Array = LinearRing(interiorRings[i]).getPoints();
			moveTo(point2Pixel(innerPoints[0]).getX(),point2Pixel(innerPoints[0]).getY());
			for (var i:Number = 1; i<innerPoints.length; i++) {
				pixel = point2Pixel(innerPoints[i]);
				lineTo(pixel.getX(),pixel.getY());
			}
		}
		if (fillOpacity>0) {
			endFill();
		}
		if (type != ACTIVE) {
			moveTo(x,y);
			lineStyle(strokeWidth*2,0,0);
			for (var i:Number = 1; i<points.length; i++) {
				pixel = point2Pixel(points[i]);
				lineTo(pixel.getX(),pixel.getY());
			}
		}
	}
	private function intersectWithViewPort(startPixel:Pixel, endPixel:Pixel):Boolean {
		var startPixelNC:Pixel = startPixel.clone();//Not Clipped
		var endPixelNC:Pixel = endPixel.clone();//Not Clipped

		//viewport corner pixel points
		var pOO:Pixel = new Pixel(0, 0);
		var pOH:Pixel = new Pixel(0, height);
		var pWO:Pixel = new Pixel(width, 0);
		var pWH:Pixel = new Pixel(width, height);

		var intersection:Boolean = false;

		//vertical line 1 at x = 0
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOO, pOH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getX()<pOO.getX()) {
				startPixel = intersectionPixel.clone();
			} else {
				endPixel = intersectionPixel.clone();
			}
		}
		//vertical line 2 at x = width 
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pWO, pWH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getX()>pWO.getX()) {
				startPixel = intersectionPixel.clone();
			} else {
				endPixel = intersectionPixel.clone();
			}
		}
		//horizontal line 3 at y = 0 
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOO, pWO) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getY()<pOO.getY()) {
				startPixel = intersectionPixel.clone();
			} else {
				endPixel = intersectionPixel.clone();
			}
		}
		//horizontal line 4 at y = height 
		if (lineSegmentIntersectionTest_px(startPixelNC, endPixelNC, pOH, pWH) == "INTERSECTING") {
			intersection = true;
			if (startPixelNC.getY()>pOH.getY()) {
				startPixel = intersectionPixel.clone();
			} else {
				endPixel = intersectionPixel.clone();
			}
		}
		return intersection;
	}
	private function lineSegmentIntersectionTest_px(p1:Pixel, p2:Pixel, p3:Pixel, p4:Pixel):String {
		//Line Segment A: Pixel p1 & p2
		//Line Segment B: Pixel p3 & p4
		var denom:Number = ((p4.getY()-p3.getY())*(p2.getX()-p1.getX()))-((p4.getX()-p3.getX())*(p2.getY()-p1.getY()));
		var nume_a:Number = ((p4.getX()-p3.getX())*(p1.getY()-p3.getY()))-((p4.getY()-p3.getY())*(p1.getX()-p3.getX()));
		var nume_b:Number = ((p2.getX()-p1.getX())*(p1.getY()-p3.getY()))-((p2.getY()-p1.getY())*(p1.getX()-p3.getX()));

		if (denom == 0) {
			if (nume_a == 0.0 && nume_b == 0.0) {
				return "COINCIDENT";
			}
			return "PARALLEL";
		}

		var ua:Number = nume_a/denom;
		var ub:Number = nume_b/denom;

		if (ua>=0.0 && ua<=1.0 && ub>=0.0 && ub<=1.0) {
			// Get the intersection Pixel.
			intersectionPixel.setX(p1.getX()+ua*(p2.getX()-p1.getX()));
			intersectionPixel.setY(p1.getY()+ua*(p2.getY()-p1.getY()));

			return "INTERSECTING";
		}

		return "NOT_INTERSECTING";

	}
}