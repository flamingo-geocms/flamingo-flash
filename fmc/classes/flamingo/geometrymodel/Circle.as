// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

class flamingo.geometrymodel.Circle extends Geometry {
    
    private var centerPoint:Point = null;
    private var circlePoint:Point = null;
    
    function Circle(centerPoint:Point, circlePoint:Point) {
        if (centerPoint == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Circle.<<init>>()");
        }
        if (circlePoint == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Circle.<<init>>()");
        }
        
        this.centerPoint = centerPoint;
        centerPoint.setParent(this);
        this.circlePoint = circlePoint;
        circlePoint.setParent(this);
    }
    
    function getChildGeometries():Array {
        return new Array(centerPoint, circlePoint);
    }
    
    function getPoints():Array {
        return new Array(centerPoint, circlePoint);
    }
    
    function getEndPoint():Point {
        return circlePoint;
    }
    
    function getCenterPoint():Point {
        return centerPoint;
    }
    
    function getEnvelope():Envelope {
        var centerX:Number = centerPoint.getX();
        var centerY:Number = centerPoint.getY();
        var radius:Number = getRadius();
        var minX:Number = centerX - radius;
        var minY:Number = centerY - radius;
        var maxX:Number = centerX + radius;
        var maxY:Number = centerY + radius;
        
        return new Envelope(minX, minY, maxX, maxY);
    }
    
    function clone():Geometry {
        return new Circle(Point(centerPoint.clone()), Point(circlePoint.clone()));
    }
    
    function getRadius():Number {
        var dx:Number = circlePoint.getX() - centerPoint.getX();
        var dy:Number = circlePoint.getY() - centerPoint.getY();
        
        return Math.sqrt((dx * dx) + (dy * dy));
    }
    
    function toGMLString():String {
        var gmlString:String = "";
        gmlString += "<gml:Circle>\n";
        gmlString += "  <gml:coordinates>9000,5000 9500,5500 8500,5000</gml:coordinates>\n";
        gmlString += "</gml:Circle>\n";
        
        return gmlString;
    }
    
    function toString():String {
        return "Circle(" + centerPoint.toString() + ", " + circlePoint.toString() + ")"; 
    }
    
}
