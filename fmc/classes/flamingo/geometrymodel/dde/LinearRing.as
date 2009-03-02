/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.dde.*;

class flamingo.geometrymodel.dde.LinearRing extends LineString {

    function LinearRing(points:Array) {
        super(points);
    }

    function getGeometries():Array {
        var geometries:Array = new Array();
        for (var i:Number = 0; i < points.length - 1; i++) {
            geometries.push(points[i]);
        }
        geometries = geometries.concat(getLineSegments());
        return geometries;
    }

   function addPoint(point:Point) {
	   	var endPoint:Object = points.pop();
		super.addPoint(point);
        points.push(endPoint);
		geometryEventDispatcher.changeGeometry(this);
    }

	
    function removePoint(point:Point, permanent:Boolean):Void {
        if (points.length == 2) {
            // EXCEPTION
            return;
        } else {
            if (point == null) {
                Point(points[points.length - 2]).setSuperGeometry(null);
                points.splice(points.length - 2, 1);
                geometryEventDispatcher.changeGeometry(this, permanent);
            } else if (point == points[0]) {
                Point(points[0]).setSuperGeometry(null);
                points[0] = points[1];
                points[points.length - 1] = points[1];
                points.splice(1, 1);
                geometryEventDispatcher.changeGeometry(this, permanent);
            } else {
                for (var i:Number = 0; i < points.length; i++) {
                    if (points[i] == point) {
                        point.setSuperGeometry(null);
                        points.splice(i, 1);
                        geometryEventDispatcher.changeGeometry(this, permanent);
                        break;
                    }
                }
            }
        }
    }

    function setPointXY(x:Number, y:Number):Void {
        points[points.length - 2].setXY(x, y);
    }

    function toString():String {
        return("LinearRing (" + points.toString() + ")");
    }

    function clone():LinearRing {
        //trace("LinearRing.clone()");
        if ((points == null) || (points.length == 0)) {
            return null;
        }
        var pnts:Array = new Array();
        var pnt0:Point = Point(Point(points[0]).clone());
        pnts.push(pnt0);
        for (var i:Number = 1; i < (points.length -1); i++) {
            var pnt:Point = Point(Point(points[i]).clone());
            pnts.push(pnt);
        }
        pnts.push(pnt0); //first and last point must be the same
        return new LinearRing(pnts);
    }

}
