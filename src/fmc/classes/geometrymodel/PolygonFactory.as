/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
/**
 * geometrymodel.PolygonFactory
 */
class geometrymodel.PolygonFactory extends GeometryFactory {
    /**
     * createGeometry
     * @param	point
     * @return
     */
    function createGeometry(point:Point):Geometry {
        var points:Array = new Array(point, point);
        var exteriorRing:LinearRing = new LinearRing(points);
        var polygon:Polygon = new Polygon(exteriorRing);
        polygon.addPoint(point.clone());
        return polygon;
    }
    
}
