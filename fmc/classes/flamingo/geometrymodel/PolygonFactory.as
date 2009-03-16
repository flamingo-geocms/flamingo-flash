/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.*;

class flamingo.geometrymodel.PolygonFactory extends GeometryFactory {
    
    function createGeometry(point:Point):Geometry {
        var points:Array = new Array(point, point);
        var exteriorRing:LinearRing = new LinearRing(points);
        var polygon:Polygon = new Polygon(exteriorRing);
        polygon.addPoint(point.clone());
        return polygon;
    }
    
}
