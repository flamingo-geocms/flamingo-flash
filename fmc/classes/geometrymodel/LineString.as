/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
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
        }
    }
    
    function addPoint(point:Point):Void {
 
        if(!(this instanceof LinearRing)){
        	if (points.length == 2 && (points[0] == points[1])) {
            	points[1] = point;
        	}    
        	else {
            	points.push(point);
        	} 	
        } else { // ((isClosed()) && ((points.length > 2) || (this instanceof LinearRing)))
            points[points.length - 1] = point;
            points.push(points[0]);
        }
        addGeometryListener(point);
        geometryEventDispatcher.addChild(Geometry(this),Geometry(point));
        
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
}
