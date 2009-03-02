/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.dde.*;

class flamingo.geometrymodel.dde.Circle extends LinearRing {

    private var numPoints:Number = 20; // Actual number of points in ring will be 1 more, because first/last point will occur twice.
    private var centerPoint:Point = null;

     function Circle(points:Array) {
        super(points);
        centerPoint = super.getCentroid();
    }

    function setPointXY(x:Number, y:Number):Void {
        var radiusPoint:Point = Point(getPoints()[0]);
        radiusPoint.setXY(x, y);
		//_global.flamingo.tracer("cirkel radius " + radiusPoint.toString());
        //var centerPoint:Point = getCenterPoint();
        var radius:Number = getRadius();
        var angle:Number = getAngle();
        points = new Array(radiusPoint, radiusPoint);
        var dx:Number = -1;
        var dy:Number = -1;
        var xpoint:Number = -1;
        var ypoint:Number = -1;
        for (var i:Number = 1; i < numPoints; i++) {
            dx = radius * Math.cos((2 * Math.PI) * i * (1 / numPoints) + angle);
            dy = radius * Math.sin((2 * Math.PI) * i * (1 / numPoints) + angle);
            xpoint = centerPoint.getX() + dx;
            ypoint = centerPoint.getY() + dy;
            addPoint(new Point(xpoint, ypoint),true);
        }

       geometryEventDispatcher.changeGeometry(this, true);
    }

    function move(dx:Number, dy:Number):Void {
        super.move(dx, dy);
        centerPoint.move(dx, dy);
    }

    function getCenterPoint():Point {
        return centerPoint;
    }

    function setRadius(radius:Number):Void {
        var centerPoint:Point = super.getCentroid();
        setPointXY(centerPoint.getX() + radius, centerPoint.getY());
    }

    function getRadius():Number{
        var radiusPoint:Point = Point(getPoints()[0]);
        var centerPoint:Point = super.getCentroid();
        var distanceX:Number = radiusPoint.getX() - centerPoint.getX();
        var distanceY:Number = radiusPoint.getY() - centerPoint.getY();
        var radius:Number = Math.sqrt((distanceX * distanceX) + (distanceY * distanceY));
        if (radius < 1) {
            radius = 1;
        }
        return radius;
    }

    function getAngle():Number {
        var radiusPoint:Point = Point(getPoints()[0]);
        var centerPoint:Point = super.getCentroid();
        var dx:Number = radiusPoint.getX() - centerPoint.getX();
        var dy:Number = radiusPoint.getY() - centerPoint.getY();
        var angle:Number = Math.atan2(dy, dx);

        return angle;
    }

    function clone():Circle {
        var cloneRing:LinearRing = super.clone();
        return new Circle(cloneRing.getPoints());
    }

}
