/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.GeometryTools {
    
    static function getGeometryClass(geometryType:String):Function {
        if (geometryType == "Point") {
            return Point;
        } else if (geometryType == "LineString") {
            return LineString;
        } else if (geometryType == "Polygon") {
            return Polygon;
        } else if (geometryType == "Circle") {
            return Circle;
        }
        
        _global.flamingo.tracer("Exception in geometrymodel.GeometryTools.getGeometryClass(" + geometryType + ")");
        return null;
    }
    
}