/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.*;

class flamingo.geometrymodel.PointFactory extends GeometryFactory {
    
    function createGeometry(point:Point):Geometry {
        return point;
    }
    
}
