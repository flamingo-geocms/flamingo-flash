/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.dde.*;

interface flamingo.geometrymodel.dde.GeometryListener {
    
    function onChangeGeometry(geometry:Geometry):Void;
    
}
