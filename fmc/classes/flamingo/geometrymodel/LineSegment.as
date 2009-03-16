/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
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

    function clone():Geometry {
        var clonedPoint0:Point = Point(point0.clone());
        var clonedPoint1:Point = Point(point1.clone());
        return new LineSegment(clonedPoint0, clonedPoint1, n);
    }


    function toString():String {
        return("LineSegment (" + point0.toString() + "," + point1.toString() + ")");
    }
    
}
