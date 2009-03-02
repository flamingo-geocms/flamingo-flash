/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.dde.*;

class flamingo.geometrymodel.dde.Point extends Geometry {

    private var x:Number;
    private var y:Number;

    function Point(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }

    function getGeometries():Array {
        return new Array();
    }

    function addPoint(point:Point, permanent:Boolean):Void {
        // EXCEPTION
    }

    function addPointN(point:Point, number:Number, permanent:Boolean):Void {
        // EXCEPTION
    }

    function removePoint(point:Point, permanent:Boolean):Void {
        // EXCEPTION
    }

    function setPointXY(x:Number, y:Number):Void {
        // EXCEPTION
    }

    function move(dx:Number, dy:Number, permanent:Boolean):Void {
        x += dx;
        y += dy;
        geometryEventDispatcher.changeGeometry(this, permanent);
        getMostSuperGeometry().geometryEventDispatcher.changeGeometry(this, false); // TODO event model
    }

    function setXY(x:Number, y:Number, permanent:Boolean):Void {
        this.x = x;
        this.y = y;
        geometryEventDispatcher.changeGeometry(this, permanent);
        getMostSuperGeometry().geometryEventDispatcher.changeGeometry(this, false); // TODO event model
    }

    function setX(x:Number, permanent:Boolean):Void {
        this.x = x;
        geometryEventDispatcher.changeGeometry(this, permanent);
    }

    function getX():Number {
        return x;
    }

    function setY(y:Number, permanent:Boolean):Void {
        this.y = y;
        geometryEventDispatcher.changeGeometry(this, permanent);
    }

    function getY():Number {
        return y;
    }

    function getCoords():Array {
        return new Array(this);
    }

    function getCenterPoint():Point {
        var centerPoint:Point = new Point(x, y);
        return centerPoint;
    }

    function getNearestPoint(point:Point):Point {
        return this;
    }

   // function getEnvelope():Envelope {
     //   return new Envelope(x, y, x, y);
    //}
    

    function clone():Geometry {
        return new Point(x, y);
    }

    function toString():String {
        return "Point (" + x + "," + y + ")";
    }

    function getDistance(point:Point):Number {
        var dx:Number = x - point.getX();
        var dy:Number = y - point.getY();
        var distance:Number = Math.sqrt((dx * dx) + (dy * dy));
        return distance;
    }
    
    function equals(point:Point):Boolean {
        if ((x == point.getX()) && (y == point.getY())) {
            return true;
        }
        return false;
    }
    
}
