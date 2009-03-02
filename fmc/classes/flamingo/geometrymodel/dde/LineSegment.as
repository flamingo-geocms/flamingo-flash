/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.dde.*;

class flamingo.geometrymodel.dde.LineSegment extends Geometry {

    private var point0:Point = null;
    private var point1:Point = null;
    private var n:Number = -1;

    function LineSegment(point0:Point, point1:Point, n:Number) {
        this.point0 = point0;
        this.point1 = point1;
        this.n = n;
    }

    function move(dx:Number,dy:Number, permanent:Boolean):Void {}

    function getCoords():Array {
        return new Array(point0, point1);
    }

    function getPoints():Array {
        return new Array(point0, point1);
    }

    function getCenterPoint():Point {
        return point0; // TODO
    }

    function getNearestPoint(point:Point):Point {
        return point0; // TODO
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
    
 

    function clone():Geometry {
        var clone0:Point = Point(point0.clone());
        var clone1:Point = Point(point1.clone());
        return new LineSegment(clone0, clone1, n);
    }

    function toString():String {
        return("LineSegment (" + point0.toString() + "," + point1.toString() + ")");
    }

    function getN():Number {
        return n;
    }
    
}
