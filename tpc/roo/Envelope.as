import roo.Geometry;
import roo.Point;

class roo.Envelope extends Geometry {
    
    private var point0:Point = null;
    private var point1:Point = null;
    
    function Envelope(minX:Number, minY:Number, maxX:Number, maxY:Number) {
        point0 = new Point(minX, minY);
        point0.setParent(this);
        point1 = new Point(maxX, maxY);
        point1.setParent(this);
    }
    
    function getChildGeometries():Array {
        return new Array(point0, point1);
    }
    
    function move(dx:Number, dy:Number):Void {
        point0.move(dx, dy);
        point1.move(dx, dy);
    }
    
    function getEndPoint():Point {
        return point1;
    }
    
    function getCenterPoint():Point {
        var centerX:Number = (getMinX() + getMaxX()) / 2;
        var centerY:Number = (getMinY() + getMaxY()) / 2;
        return new Point(centerX, centerY);
    }
    
    function getEnvelope():Envelope {
        return new Envelope(getMinX(), getMinY(), getMaxX(), getMaxY());
    }
    
    function getMinX():Number {
        if (point0.getX() <= point1.getX()) {
            return point0.getX();
        } else {
            return point1.getX();
        }
    }
    
    function getMinY():Number {
        if (point0.getY() <= point1.getY()) {
            return point0.getY();
        } else {
            return point1.getY();
        }
    }
    
    function getMaxX():Number {
        if (point0.getX() >= point1.getX()) {
            return point0.getX();
        } else {
            return point1.getX();
        }
    }
    
    function getMaxY():Number {
        if (point0.getY() >= point1.getY()) {
            return point0.getY();
        } else {
            return point1.getY();
        }
    }
    
    function equals(envelope:Envelope):Boolean {
        if ((getMinX() == envelope.getMinX()) && (getMinY() == envelope.getMinY())
                                && (getMaxX() == envelope.getMaxX()) && (getMaxY() == envelope.getMaxY())) {
            return true;
        } else {
            return false;
        }
    }
    
    function toString():String {
        return "Envelope(" + getMinX() + ", " + getMinY() + ", " + getMaxX() + ", " + getMaxY() + ")"; 
    }
    
}
