/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
/**
 * geometrymodel.Envelope
 */
class geometrymodel.Envelope extends Geometry {
    
    private var point0:Point = null;
    private var point1:Point = null;
    /**
     * constrcutor
     * @param	minX
     * @param	minY
     * @param	maxX
     * @param	maxY
     */
    function Envelope(minX:Number, minY:Number, maxX:Number, maxY:Number) {
        if (minX == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (minY == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (maxX == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        if (maxY == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Envelope.<<init>>(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")");
            return;
        }
        
        point0 = new Point(minX, minY);
        point1 = new Point(maxX, maxY);
    }
    /**
     * getChildGeometries
     * @return
     */
    function getChildGeometries():Array {
        return new Array(point0, point1);
    }
    /**
     * getPoints
     * @return
     */
    function getPoints():Array {
        return new Array(point0, point1);
    }
    /**
     * getEndPoint
     * @return
     */
    function getEndPoint():Point {
        return point1;
    }
    /**
     * getCenterPoint
     * @return
     */
    function getCenterPoint():Point {
        var centerX:Number = (getMinX() + getMaxX()) / 2;
        var centerY:Number = (getMinY() + getMaxY()) / 2;
        return new Point(centerX, centerY);
    }
    /**
     * getEnvelope
     * @return
     */
    function getEnvelope():Envelope {
        return new Envelope(getMinX(), getMinY(), getMaxX(), getMaxY());
    }
    /**
     * equals
     * @param	geometry
     * @return
     */
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
    /**
     * clone
     * @return
     */
    function clone():Geometry {
        return new Envelope(getMinX(), getMinY(), getMaxX(), getMaxY());
    }
    /**
     * getMinX
     * @return
     */
    function getMinX():Number {
        if (point0.getX() <= point1.getX()) {
            return point0.getX();
        } else {
            return point1.getX();
        }
    }
    /**
     * getMinY
     * @return
     */
    function getMinY():Number {
        if (point0.getY() <= point1.getY()) {
            return point0.getY();
        } else {
            return point1.getY();
        }
    }
    /**
     * getMaxX
     * @return
     */
    function getMaxX():Number {
        if (point0.getX() >= point1.getX()) {
            return point0.getX();
        } else {
            return point1.getX();
        }
    }
    /**
     * getMaxY
     * @return
     */
    function getMaxY():Number {
        if (point0.getY() >= point1.getY()) {
            return point0.getY();
        } else {
            return point1.getY();
        }
    }
	/**
	 * toObject
	 * @return
	 */
	function toObject():Object{
		var o = new Object();
		o["minx"]=getMinX();
		o["miny"]=getMinY();
		o["maxx"]=getMaxX();
		o["maxy"]=getMaxY();
		return o;
	}
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Envelope(" + getMinX() + ", " + getMinY() + ", " + getMaxX() + ", " + getMaxY() + ")"; 
    }
    
}
