/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.dde.*;

class geometrymodel.dde.Envelope extends Geometry {

    private var minX:Number;
    private var minY:Number;
    private var maxX:Number;
    private var maxY:Number;


    /**
     * Constructor of Envelope
     */
    function Envelope(minX:Number, minY:Number, maxX:Number, maxY:Number) {
        this.minX = minX;
        this.minY = minY;
        this.maxX = maxX;
        this.maxY = maxY;
    }

    /**
     * @return the minimal x value of the envelope.
     */
    function getMinX():Number {
        return minX;
    }

    /**
     * @return the minimal y value of the envelope.
     */
    function getMinY():Number {
        return minY;
    }

    /**
     * @return the maximal x value of the envelope.
     */
    function getMaxX():Number {
        return maxX;
    }

    /**
     * @return the maximal y value of the envelope.
     */
    function getMaxY():Number {
        return maxY;
    }

    function getCoords():Array {
        var coords:Array = new Array();
        coords.push(new Point(minX, minY));
        coords.push(new Point(maxX, maxY));
        return coords;
    }
    
    function getCornerPoints():Array {
        var cornerPoints:Array = new Array();
        cornerPoints.push(new Point(minX, minY));
        cornerPoints.push(new Point(minX, maxY));
        cornerPoints.push(new Point(maxX, maxY));
        cornerPoints.push(new Point(maxX, minY));
        return cornerPoints;
    }

    function equals(envelope:Envelope):Boolean {
        if ((envelope != null) && (minX == envelope.minX) && (minY == envelope.minY) &&
                        (maxX == envelope.maxX) && (maxY == envelope.maxY)) {
            return true;
        } else {
            return false;
        }
    }


    function clone():Envelope {
        return new Envelope(minX, minY, maxX, maxY);
    }
    
    function toString():String {
        return "Envelope(" + minX + ", " + minY + ", " + maxX + ", " + maxY + ")";
    }

}