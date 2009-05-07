/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.PointFactory extends GeometryFactory {
    
    function createGeometry(point:Point):Geometry {
        return point;
    }
    
}
