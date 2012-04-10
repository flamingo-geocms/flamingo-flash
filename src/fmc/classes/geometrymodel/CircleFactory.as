/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
/**
 * geometrymodel.CircleFactory
 */
class geometrymodel.CircleFactory extends GeometryFactory {
    /**
     * createGeometry
     * @param	point
     * @return
     */
    function createGeometry(point:Point):Geometry {
        var circle:Circle = new Circle(point, Point(point.clone()));
        return circle;
    }
    
}
