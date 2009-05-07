/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
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
    function toString():String {
        return("LinearRing (" + points.toString() + ")");
    }
    
}
