/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.LinearRing extends LineString {
    
    function LinearRing(points:Array) {
        super(points);
        
        if (!isClosed()) {
            _global.flamingo.tracer("Exception in geometrymodel.LinearRing.<<init>>");
            return;
        }
    }
    
     function getEndPoint():Point {
     	return Point(points[points.length - 2]);
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
