/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
/**
 * geometrymodel.PointFactory
 */
class geometrymodel.PointFactory extends GeometryFactory {
    /**
     * createGeometry
     * @param	point
     * @return
     */
    function createGeometry(point:Point):Geometry {
        return point;
    }
    
}
