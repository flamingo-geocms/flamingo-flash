// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

class flamingo.geometrymodel.LineSegment extends Geometry {

    private var point0:Point = null;
    private var point1:Point = null;
    private var n:Number = null;

    function LineSegment(point0:Point, point1:Point, n:Number) {
        if (point0 == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.LineSegment.<<init>>(" + point0 + ", " + point1 + ")");
            return;
        }
        if (point1 == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.LineSegment.<<init>>(" + point0 + ", " + point1 + ")");
            return;
        }
        
        this.point0 = point0;
        point0.setParent(this);
        this.point1 = point1;
        point1.setParent(this);
        this.n = n;
    }
    
    function getChildGeometries():Array {
        return new Array(point0, point1);
    }
    
    function getPoints():Array {
        return new Array(point0, point1);
    }
    
    function getEndPoint():Point {
        return point1;
    }

    function getCenterPoint():Point {
        var point0X:Number = point0.getX();
        var point0Y:Number = point0.getY();
        var point1X:Number = point1.getX();
        var point1Y:Number = point1.getY();
        var centerX:Number = (point1X - point0X) / 2 + point0X;
        var centerY:Number = (point1Y - point0Y) / 2 + point0Y;
        
        return new Point(centerX, centerY);
    }

    function getEnvelope():Envelope {
        var minX:Number = point0.getX();
        var minY:Number = point0.getY();
        var maxX:Number = point0.getX();
        var maxY:Number = point0.getY();
        if (minX > point1.getX()) {
            minX = point1.getX();
        } else {
            maxX = point1.getX();
        }
        if (minY > point1.getY()) {
            minY = point1.getY();
        } else {
            maxY = point1.getY();
        }
        
        return new Envelope(minX, minY, maxX, maxY);
    }
    
    function equals(geometry:Geometry):Boolean {
        if (!(geometry instanceof LineSegment)) {
            return false;
        }
        var points:Array = geometry.getPoints();
        if ((point0.equals(Point(points[0]))) && (point1.equals(Point(points[1])))) {
            return true;
        }
        return false;
    }
    
    function clip(envelope:Envelope):Geometry {
        
        // Convenience variables.
        var p0X:Number = point0.getX();
        var p0Y:Number = point0.getY();
        var p1X:Number = point1.getX();
        var p1Y:Number = point1.getY();
        var eMinX:Number = envelope.getMinX();
        var eMinY:Number = envelope.getMinY();
        var eMaxX:Number = envelope.getMaxX();
        var eMaxY:Number = envelope.getMaxY();
        
        // Preconditions.
        if ((p0X < eMinX) && (p1X < eMinX)) {
            return null;
        }
        if ((p0X > eMaxX) && (p1X > eMaxX)) {
            return null;
        }
        if ((p0Y < eMinY) && (p1Y < eMinY)) {
            return null;
        }
        if ((p0Y > eMaxY) && (p1Y > eMaxY)) {
            return null;
        }
        var point0IsWithin:Boolean = point0.isWithin(envelope);
        var point1IsWithin:Boolean = point1.isWithin(envelope);
        if ((point0IsWithin) && (point1IsWithin)) {
            return clone();
        }
        
        // Calculates the function y = ax + b for the linestring.
        var a:Number = null; 
        if ((p1X - p0X) == 0) {
            a = 99999999;
        } else if ((p1Y - p0Y) == 0) {
            a = 0.0000001;
        } else {
            a = (p1Y - p0Y) / (p1X - p0X);
        }
        var b:Number = p0Y - a * p0X;
        
        // Calculates the intersection points of the linestring and the given envelope.
        var yMinX = a * eMinX + b;
        var yMaxX = a * eMaxX + b;
        var xMinY = (eMinY - b) / a;
        var xMaxY = (eMaxY - b) / a;
        var intersectionPoints:Array = new Array();
        if ((yMinX >= eMinY) && (yMinX <= eMaxY)) {
            intersectionPoints.push(new Point(eMinX, yMinX));
        }
        if ((yMaxX >= eMinY) && (yMaxX <= eMaxY)) {
            intersectionPoints.push(new Point(eMaxX, yMaxX));
        }
        if ((xMinY >= eMinX) && (xMinY <= eMaxX)) {
            intersectionPoints.push(new Point(xMinY, eMinY));
        }
        if ((xMaxY >= eMinX) && (xMaxY <= eMaxX)) {
            intersectionPoints.push(new Point(xMaxY, eMaxY));
        }
        
        // In-between condition.
        if (intersectionPoints.length == 0) {
            return null;
        }
        var intersectionPoint0:Point = Point(intersectionPoints[0]);
        var intersectionPoint1:Point = Point(intersectionPoints[1]);
        
        // If one of the segment's own points is within the envelope, chooses which one of the intersection points will join it in the clip.
        if ((point0IsWithin) || (point1IsWithin)) {
            var distance0:Number = point0.getDistance(intersectionPoint0) + point1.getDistance(intersectionPoint0);
            var distance1:Number = point0.getDistance(intersectionPoint1) + point1.getDistance(intersectionPoint1);
            if (distance0 < distance1) {
                if (point0IsWithin) {
                    return new LineSegment(Point(point0.clone()), intersectionPoint0, n);
                }
                return new LineSegment(intersectionPoint0, Point(point1.clone()), n);
            }
            if (point0IsWithin) {
                return new LineSegment(Point(point0.clone()), intersectionPoint1, n);
            }
            return new LineSegment(intersectionPoint1, Point(point1.clone()), n);
        }
        
        // If none of the segment's own points is within the envelope, both intersection points go into the clip.
        if ((point1.getX() - point0.getX()) * (intersectionPoint1.getX() - intersectionPoint0.getX()) > 0) { // If either both dxs positive or both dxs negative.
            return new LineSegment(intersectionPoint0, intersectionPoint1, n);
        }
        return new LineSegment(intersectionPoint1, intersectionPoint0, n);
    }

    function clone():Geometry {
        var clonedPoint0:Point = Point(point0.clone());
        var clonedPoint1:Point = Point(point1.clone());
        return new LineSegment(clonedPoint0, clonedPoint1, n);
    }

    function getN():Number {
        return n;
    }

    function toString():String {
        return("LineSegment (" + point0.toString() + "," + point1.toString() + ")");
    }
    
}
