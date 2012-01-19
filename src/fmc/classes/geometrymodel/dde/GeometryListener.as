/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.dde.*;

interface geometrymodel.dde.GeometryListener {
    
    function onChangeGeometry(geometry:Geometry):Void;
    

    function onFinishGeometry(geometry:Geometry):Void;
    
}
