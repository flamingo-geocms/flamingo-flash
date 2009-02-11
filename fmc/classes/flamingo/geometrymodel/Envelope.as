// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

class flamingo.geometrymodel.Envelope extends Geometry {
    
    private var point0:Point = null;
    private var point1:Point = null;
    
    function Envelope(minX:Number, minY:Number, maxX:Number, maxY:Number) {
        if (minX == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (minY == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (maxX == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (maxY == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        
        point0 = new Point(minX, minY);
        point0.setParent(this);
        point1 = new Point(maxX, maxY);
        point1.setParent(this);
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
        var centerX:Number = (getMinX() + getMaxX()) / 2;
        var centerY:Number = (getMinY() + getMaxY()) / 2;
        return new Point(centerX, centerY);
    }
    
    function getEnvelope():Envelope {
        return new Envelope(getMinX(), getMinY(), getMaxX(), getMaxY());
    }
    
    function equals(geometry:Geometry):Boolean {
        if (!(geometry instanceof Envelope)) {
            return false;
        }
        if ((getMinX() == Envelope(geometry).getMinX()) && (getMinY() == Envelope(geometry).getMinY())
                                                        && (getMaxX() == Envelope(geometry).getMaxX())
                                                        && (getMaxY() == Envelope(geometry).getMaxY())) {
            return true;
        }
        return false;
    }
    
    function clone():Geometry {
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
    
    function toString():String {
        return "Envelope(" + getMinX() + ", " + getMinY() + ", " + getMaxX() + ", " + getMaxY() + ")"; 
    }
    
}
