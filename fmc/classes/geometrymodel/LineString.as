/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

import event.AddRemoveEvent;
import event.GeometryListener;

class geometrymodel.LineString extends Geometry implements GeometryListener {
    
    private var points:Array = null;
    
    function LineString(points:Array) {
        if ((points == null) || (points.length < 2)) {
            _global.flamingo.tracer("Exception in geometrymodel.LineString.<<init>>(" + points.toString() + ")");
            return;
        }
        
        this.points = points;
        for (var i:String in points) {
            addGeometryListener(points[i]);
			points[i].setParent(this);
        }
    }
    
    function addPoint(point:Point):Void {
 
        if (!isClosed()) {
            points.push(point);
        } else if(!(this instanceof LinearRing)){
        	if (points.length == 2 && (points[0] == points[1])) {
            	points[1] = point;
        	}    
        	else {
            	points.push(point);
        	} 	
        } else {
            points[points.length - 1] = point;
            points.push(points[0]);
        }
		
		point.setParent(this);
		
        addGeometryListener(point);
        geometryEventDispatcher.addChild(Geometry(this),Geometry(point));
        
    }
	
	function insertPoint(point:Point, insertIndex:Number):Void {
 
        if(!(this instanceof LinearRing)){
        	if (points.length == 2 && (points[0] == points[1])) {
            	points[1] = point;
        	}    
        	else {
				points.splice(insertIndex, 0, point);
        	} 	
        } else {
            points.splice(insertIndex, 0, point);
        }
		
		point.setParent(this);
		
        addGeometryListener(point);
        geometryEventDispatcher.addChild(Geometry(this),Geometry(point));
		geometryEventDispatcher.changeGeometry(this);
        
    }
	
	function removePoint(point:Point):Void {
		if ((points.length == 3) && (isClosed())) {
            // Point cannot be removed. This is a non-exceptional precondition.
            return;
        }
        
        if (points.length == 2) {
            if (isClosed()) {
                //Point cannot be removed. This is a non-exceptional precondition.
                return;
            } else {
                var otherPoint:Point = null;
                var pointIndex:Number = -1;
                if (point == points[0]) {
                    otherPoint = Point(points[1]);
                    pointIndex = 0;
                } else if (point == points[1]) {
                    otherPoint = Point(points[0]);
                    pointIndex = 1;
                }
                points[pointIndex] = new Point(otherPoint.getX(), otherPoint.getY());
            }
        } else {
            if ((isClosed()) && (point == points[0])) {
                points[0] = points[1];
                points[points.length - 1] = points[1];
                points.splice(1, 1);
            } else {
                for (var i:Number = 0; i < points.length; i++) {
                    if (points[i] == point) {
                        points.splice(i, 1);
                        break;
                    }
                }
            }
        }
		
        point.setParent(null);
        removeGeometryListener(point);
  		point = null;
		geometryEventDispatcher.changeGeometry(this);
        
    }
	
	function removePointNr(pointNr:Number):Void {
		var point:Point = points[pointNr];
		if ((points.length == 3) && (isClosed())) {
            // Point cannot be removed. This is a non-exceptional precondition.
            return;
        }
        
        if (points.length == 2) {
            if (isClosed()) {
                //Point cannot be removed. This is a non-exceptional precondition.
                return;
            } else {
                var otherPoint:Point = null;
                var pointIndex:Number = -1;
                if (point == points[0]) {
                    otherPoint = Point(points[1]);
                    pointIndex = 0;
                } else if (point == points[1]) {
                    otherPoint = Point(points[0]);
                    pointIndex = 1;
                }
                points[pointIndex] = new Point(otherPoint.getX(), otherPoint.getY());
            }
        } else {
            if ((isClosed()) && (point == points[0])) {
                points[0] = points[1];
                points[points.length - 1] = points[1];
                points.splice(1, 1);
            } else {
                if (points[pointNr] instanceof Point) {
					points.splice(pointNr, 1);
					break;
                }
            }
        }

        point.setParent(null);
        removeGeometryListener(point);
        point = null;
		geometryEventDispatcher.changeGeometry(this);
        
    }
	    
	function getChildGeometries():Array {
        var childGeometries:Array = points.concat();
        if (isClosed()) {
            childGeometries.pop();
        }
        
        return childGeometries;
    }
    
    function getPoints():Array {
        return points.concat();
    }
    
    function getEndPoint():Point {
        return Point(points[points.length - 1]);
    }
    
    function getCenterPoint():Point {
        var point:Point = null;
        var sumX:Number = 0;
        var sumY:Number = 0;
        for (var i:String in points) {
            point = Point(points[i]);
            sumX += point.getX();
            sumY += point.getY();
        }
        var numPoints:Number = points.length;
               
        return new Point(sumX / numPoints, sumY / numPoints);
    }
    
   function getEnvelope():Envelope {
        var points:Array = getChildGeometries();
        var point:Point = Point(points[0]);
        var minX:Number = point.getX();
        var minY:Number = point.getY();
        var maxX:Number = point.getX();
        var maxY:Number = point.getY();
        for (var i:String in points) {
            point = Point(points[i]);
            if (minX > point.getX()) {
                minX = point.getX();
            }
            if (minY > point.getY()) {
                minY = point.getY();
            }
            if (maxX < point.getX()) {
                maxX = point.getX();
            }
            if (maxY < point.getY()) {
                maxY = point.getY();
            }
        }
        
        return new Envelope(minX, minY, maxX, maxY);
    }
    
       
    private function isClosed():Boolean {
        if (points[0] == points[points.length - 1]) {
            return true;
        } else {
            return false;
        }
    }
    
	function getLength():Number {
        var point:Point = null;
        var nextPoint:Point = null;
        var dx:Number = -1;
        var dy:Number = -1;
        var length:Number = 0;
        
        for (var i:Number = 0; i < points.length - 1; i++) {
            point = Point(points[i]);
            nextPoint = Point(points[i + 1]);
            dx = nextPoint.getX() - point.getX();
            dy = nextPoint.getY() - point.getY();
            length += Math.sqrt((dx * dx) + (dy * dy));
        }
        
        return length;
    }
    
	function toWKT():String{
		var wktGeom:String="";
		wktGeom+="LINESTRING";		
		wktGeom+=toWKTPart();
		return wktGeom;
	}
	
	function toWKTPart():String{
		var wktGeom:String="";
        var point:Point = null;
		wktGeom+="(";	
		for (var i:Number = 0; i < points.length; i++) {
			if (i!=0){
				wktGeom+=",";
			}
            point = Point(points[i]);            
            wktGeom += (point.getX() + " " + point.getY());
		}
		wktGeom+=")";
		return wktGeom;
	}
	
	function toGMLString():String {
        var point:Point = null;
        
        var gmlString:String = "";
        gmlString += "<gml:LineString srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        gmlString += "  <gml:coordinates cs=\",\" decimal=\".\" ts=\" \">";
        
        for (var i:Number = 0; i < points.length; i++) {
            point = Point(points[i]);
            
            gmlString += (point.getX() + "," + point.getY());
            
            if (i < points.length - 1) {
                gmlString += " ";
            }
        }
        
        gmlString += "</gml:coordinates>\n";
        gmlString += "</gml:LineString>\n";
        
        return gmlString;
    }
    
    function toString():String {
        return("LineString (" + points.toString() + ")");
	}
	
	public function onChangeGeometry(geometry : Geometry) : Void {
		//parent changed
		geometryEventDispatcher.changeGeometry(this);
	}
	
	public function onAddChild(geometry:Geometry,child:Geometry):Void {
		//parent changed
    	geometryEventDispatcher.changeGeometry(this);
	}
	
	public function onRemoveChild(geometry:Geometry,child:Geometry) : Void {
		//parent changed
		geometryEventDispatcher.changeGeometry(this);		
	}
}
