// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

class flamingo.geometrymodel.LineStringFactory extends GeometryFactory {
    
    function createGeometry(point:Point):Geometry {
        var points:Array = new Array(point, point.clone());
        var lineString:LineString = new LineString(points);
        return lineString;
    }
    
}
