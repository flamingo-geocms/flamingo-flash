/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
import tools.Logger;
/**
 * geometrymodel.LinearRing
 */
class geometrymodel.LinearRing extends LineString {
	private var log:Logger=null;
    /**
     * constructor
     * @param	points
     */
    function LinearRing(points:Array) {
        super(points);
        this.log = new Logger("geometrymodel.LinearRing",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        if (!isClosed()) {
            _global.flamingo.tracer("Exception in geometrymodel.LinearRing.<<init>>");
            return;
        }
    }
    /**
     * getEnvelope
     * @return
     */
    function getEnvelope():Envelope{
    	return super.getEnvelope();
    }
    /**
     * getEndPoint
     * @return
     */
     function getEndPoint():Point {
     	return Point(points[points.length - 2]);
     }
	 /**
	  * removePoint
	  * @param	point
	  */
	 function removePoint(point:Point):Void {
		if (points.length <=4) {
			log.debug("Can not remove point. Linearring needs to have at least 3 points");
			// Point cannot be removed. This is a non-exceptional precondition.
			return;
		}
		super.removePoint(point);
	}
        
	 /**
	  * removeConsecutiveDoubles
	  */
	 function removeConsecutiveDoubles():Void {
		if (points.length >=3) {
			for (var i=0; i<points.length - 1; i++) {
				if ( points[i].getX() == points[i+1].getX()  && points[i].getY() == points[i+1].getY() ) {
					//delete point i because its exactly the same as point i+1
					points.splice(i,1); 
				}
			}
		}
	}
	 /**
	  * toString
	  * @return
	  */
    function toString():String {
        return("LinearRing (" + points.toString() + ")");
    }
    
}
