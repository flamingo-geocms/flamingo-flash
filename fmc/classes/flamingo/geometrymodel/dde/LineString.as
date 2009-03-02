/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/import flamingo.geometrymodel.dde.*;


class flamingo.geometrymodel.dde.LineString extends Geometry {

    private var points:Array = null;

    function LineString(points:Array) {
        this.points = points;

        for (var i:String in points) {
            Point(points[i]).setSuperGeometry(this);
        }
    }

    function getGeometries():Array {
        var lineSegments:Array = getLineSegments();
        var geometries:Array = points.concat(lineSegments);
        return geometries;
    }

    function addPoint(point:Point):Void {
        if ((points.length == 2) && (points[0] == points[1])) {	
            points[1] = point;
        } else {
            points.push(point);
        }
        point.setSuperGeometry(this);
        geometryEventDispatcher.changeGeometry(this);
    }

    function addPointN(point:Point, num:Number):Void {
        if ((num < 1) || (num > (points.length - 1))) {
            // EXCEPTION
            return;
        }

        points.splice(num, 0, point);
        point.setSuperGeometry(this);
        geometryEventDispatcher.changeGeometry(this);
    }

    function addPoints(points:Array):Void {
        for (var i:Number = 0; i < points.length; i++) {
            addPoint(Point(points[i]));
        }
    }

    function removePoint(point:Point):Void {
        if (points.length == 2) {
            if (point == null) {
                return;
            } else if (points[0] == points[1]) {
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
                point.setSuperGeometry(null);
                points[pointIndex] = new Point(otherPoint.getX(), otherPoint.getY());
                geometryEventDispatcher.changeGeometry(this);
            }
        } else {
            if (point == null) {
                Point(points[points.length - 1]).setSuperGeometry(null);
                points.pop();
                geometryEventDispatcher.changeGeometry(this);
            } else {
                for (var i:Number = 0; i < points.length; i++) {
                    if (points[i] == point) {
                        point.setSuperGeometry(null);
                        points.splice(i, 1);
                        geometryEventDispatcher.changeGeometry(this);
                        break;
                    }
                }
            }
        }
    }

    function setPointXY(x:Number, y:Number):Void {
        points[points.length - 1].setXY(x, y);
    }

    function removePointN(num:Number):Void {
       // if ((num < 1) || (num > (points.length - 1))) {
       //     // EXCEPTION
       //     return;
       // }

        if (points.length == 2) {
            if (points[0] == points[1]) {
                // EXCEPTION
                return;
            } else {
                points[1] = points[0];
            }
        } else {
            Point(points[num]).setSuperGeometry(null);
            points.splice(num, 1);
        }
        geometryEventDispatcher.changeGeometry(this);
    }

    function move(dx:Number, dy:Number):Void {
        var n:Number = null;
        if (points[0] == points[points.length - 1]) {
            n = 1;
        } else {
            n = 0;
        }
        for (var i:Number = n; i < points.length; i++) {
            Point(points[i]).move(dx, dy);
        }
    }

    function getCoords():Array {
        return points;
    }

    function getPoints():Array {
        return points;
    }

    function getLineSegments():Array {
        var lineSegment:LineSegment = null;
        var lineSegments:Array = new Array();
        for (var i:Number = 0; i < points.length - 1; i++) {
            lineSegment = new LineSegment(points[i], points[i + 1], i + 1);
            lineSegment.setSuperGeometry(this);
            lineSegments.push(lineSegment);
        }
        return lineSegments;
    }

    function getCentroid():Point {
        var sumX:Number = 0;
        var sumY:Number = 0;
        var numUniquePoints:Number = 0;

        var n:Number = null;
        if (points[0] == points[points.length - 1]) {
            n = 1;
        } else {
            n = 0;
        }
        var point:Point = null;
        for (var i:Number = n; i < points.length; i++) {
            point = Point(points[i]);
            sumX = sumX + point.getX();
            sumY = sumY + point.getY();
            numUniquePoints++;
        }
        var centroid:Point = new Point(sumX / numUniquePoints, sumY / numUniquePoints);
        return centroid;
    }

  
    


    function clone():Geometry {
        if ((points == null) || (points.length == 0)) {
            return null;
        }
        var pnts:Array = new Array();
        for (var i:String in points) {
            pnts.push(Point(points[i]).clone());
        }
        return new LineString(pnts);
    }

    function toString():String {
        return("LineString (" + points.toString() + ")");
    }
    
    function getLength():Number {
        var length:Number = 0;
        var point:Point = null;
        var previousPoint:Point = null;
        var dx:Number = -1;
        var dy:Number = -1;
        for (var i:Number = 1; i < points.length; i++) {
            point = Point(points[i]);
            previousPoint = Point(points[i - 1]);
            dx = point.getX() - previousPoint.getX();
            dy = point.getY() - previousPoint.getY();
            length += Math.sqrt(dx * dx + dy * dy);
        }
        return length;
    }

    function isClosed():Boolean {
        if (points[0] == points[points.length - 1]) {
            return true;
        } else {
            return false;
        }
    }
    
}
