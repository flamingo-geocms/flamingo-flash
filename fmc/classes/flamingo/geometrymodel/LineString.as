/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.*;

import flamingo.event.AddRemoveEvent;

class flamingo.geometrymodel.LineString extends Geometry {
    
    private var points:Array = null;
    
    function LineString(points:Array) {
        if ((points == null) || (points.length < 2)) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.LineString.<<init>>(" + points.toString() + ")");
            return;
        }
        
        this.points = points;
        for (var i:String in points) {
            Point(points[i]).setParent(this);
        }
    }
    
    function addChild(child:Geometry):Void {
        if (isChild(child)) {
            // Child already exists. This is a non-exceptional precondition.
            return;
        }
        if (child instanceof LineSegment) {
            // Strange kind of child. This is a non-exceptional precondition.
            return;
        }
        if (!(child instanceof Point)) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.LineString.addChild(" + child.toString() + ")");
            return;
        }
        
        if (!isClosed()) {
            points.push(child);
        } else if ((points.length == 2) && (!(this instanceof LinearRing))) {
            points[1] = child;
        } else { // ((isClosed()) && ((points.length > 2) || (this instanceof LinearRing)))
            points[points.length - 1] = child;
            points.push(points[0]);
        }
        child.setParent(this);
        
        dispatchEvent(new AddRemoveEvent(this, "Geometry", "childGeometries", new Array(child), null, eventComp));
    }
    
    function removeChild(child:Geometry):Void {
        if (!isChild(child)) {
            // Child does not exist. This is a non-exceptional precondition.
            return;
        }
        if (!(child instanceof Point)) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.LineString.removeChild(" + child.toString() + ")");
            return;
        }
        if ((points.length == 3) && (isClosed())) {
            // Child cannot be removed. This is a non-exceptional precondition.
            return;
        }
        
        if (points.length == 2) {
            if (isClosed()) {
                // Child cannot be removed. This is a non-exceptional precondition.
                return;
            } else {
                var otherPoint:Point = null;
                var pointIndex:Number = -1;
                if (child == points[0]) {
                    otherPoint = Point(points[1]);
                    pointIndex = 0;
                } else if (child == points[1]) {
                    otherPoint = Point(points[0]);
                    pointIndex = 1;
                }
                points[pointIndex] = new Point(otherPoint.getX(), otherPoint.getY());
            }
        } else {
            if ((isClosed()) && (child == points[0])) {
                points[0] = points[1];
                points[points.length - 1] = points[1];
                points.splice(1, 1);
            } else {
                for (var i:Number = 0; i < points.length; i++) {
                    if (points[i] == child) {
                        points.splice(i, 1);
                        break;
                    }
                }
            }
        }
        child.setParent(null);
        
        dispatchEvent(new AddRemoveEvent(this, "Geometry", "childGeometries", null, new Array(child), eventComp));
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
        var points:Array = getChildGeometries();
        return Point(points[points.length - 1]);
    }
    
    function getCenterPoint():Point {
        var points:Array = getChildGeometries();
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
    
    function clip(envelope:Envelope):Geometry {
        var lineSegments:Array = getLineSegments();
        var lineSegment:LineSegment = null;
        
        var clippedLineSegments:Array = new Array();
        for (var i:Number = 0; i < lineSegments.length; i++) {
            lineSegment = LineSegment(LineSegment(lineSegments[i]).clip(envelope));
            if (!(lineSegment == null)) {
                clippedLineSegments.push(lineSegment);
            }
        }
        
        var points:Array = new Array();
        var point0:Point = null;
        var point1:Point = null;
        var previousPoint:Point = null;
        for (var i:Number = 0; i < clippedLineSegments.length; i++) {
            lineSegment = LineSegment(clippedLineSegments[i]);
            point0 = lineSegment.getPoints()[0];
            point1 = lineSegment.getPoints()[1];
            if (i == 0) {
                points.push(point0);
            } else { // i > 0
                previousPoint = Point(points[points.length - 1]);
                if (!point0.equals(previousPoint)) {
                    //points = points.concat(GeometryTools.getCornersInBetween(previousPoint, point0, envelope));
                    points.push(point0);
                }
            }
            points.push(point1);
        }
        
        if (points.length >= 2) {
            return new LineString(points);
        }
        return null;
    }

    function clone():Geometry {
        var clonedPoints:Array = new Array();
        for (var i:Number = 0; i < points.length; i++) {
            clonedPoints.push(Point(points[i]).clone());
        }
        return new LineString(clonedPoints);
    }

    function getLineSegments():Array {
        var lineSegments:Array = new Array();
        var point0:Point = null;
        var point1:Point = null;
        var lineSegment:LineSegment = null;
        for (var i:Number = 0; i < points.length - 1; i++) {
            point0 = Point(Point(points[i]).clone());
            point1 = Point(Point(points[i + 1]).clone());
            lineSegment = new LineSegment(point0, point1, i);
            lineSegment.setParent(this);
            lineSegments.push(lineSegment);
        }
        return lineSegments;
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
    
}
