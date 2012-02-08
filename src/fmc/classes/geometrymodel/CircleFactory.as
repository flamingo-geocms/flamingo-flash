/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.CircleFactory extends GeometryFactory {
    
    function createGeometry(point:Point):Geometry {
        var circle:Circle = new Circle(point, Point(point.clone()));
        return circle;
    }
    
}