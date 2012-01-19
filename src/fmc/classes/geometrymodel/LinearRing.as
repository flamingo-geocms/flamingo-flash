/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
import tools.Logger;

class geometrymodel.LinearRing extends LineString {
	private var log:Logger=null;
    
    function LinearRing(points:Array) {
        super(points);
        this.log = new Logger("geometrymodel.LinearRing",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        if (!isClosed()) {
            _global.flamingo.tracer("Exception in geometrymodel.LinearRing.<<init>>");
            return;
        }
    }
    
    function getEnvelope():Envelope{
    	return super.getEnvelope();
    }
    
     function getEndPoint():Point {
     	return Point(points[points.length - 2]);
     }
	 function removePoint(point:Point):Void {
		if (points.length <=4) {
			log.debug("Can not remove point. Linearring needs to have at least 3 points");
			// Point cannot be removed. This is a non-exceptional precondition.
			return;
		}
		super.removePoint(point);
	}
        
	 
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
	 
    function toString():String {
        return("LinearRing (" + points.toString() + ")");
    }
    
}
