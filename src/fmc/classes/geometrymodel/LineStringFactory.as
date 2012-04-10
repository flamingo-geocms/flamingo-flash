/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
/**
 * geometrymodel.LineStringFactory
 */
class geometrymodel.LineStringFactory extends GeometryFactory {
    /**
     * createGeometry
     * @param	point
     * @return
     */
    function createGeometry(point:Point):Geometry {
        var points:Array = new Array(point, point.clone());
        var lineString:LineString = new LineString(points);
        return lineString;
    }
    
}
