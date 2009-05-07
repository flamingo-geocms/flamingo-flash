/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.LineSegment extends Geometry {

    private var point0:Point = null;
    private var point1:Point = null;
    private var n:Number = null;

    function LineSegment(point0:Point, point1:Point, n:Number) {
        if (point0 == null) {
            _global.flamingo.tracer("Exception in geometrymodel.LineSegment.<<init>>(" + point0 + ", " + point1 + ")");
            return;
        }
        if (point1 == null) {
            _global.flamingo.tracer("Exception in geometrymodel.LineSegment.<<init>>(" + point0 + ", " + point1 + ")");
            return;
        }
        
        this.point0 = point0;
        this.point1 = point1;
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
    

    function clone():Geometry {
        var clonedPoint0:Point = Point(point0.clone());
        var clonedPoint1:Point = Point(point1.clone());
        return new LineSegment(clonedPoint0, clonedPoint1, n);
    }


    function toString():String {
        return("LineSegment (" + point0.toString() + "," + point1.toString() + ")");
    }
    
}
