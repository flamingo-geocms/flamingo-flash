/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

interface event.GeometryListener {

	public function onChangeGeometry(geometry:Geometry):Void;
    	
	public function onAddChild(geometry:Geometry,child:Geometry) : Void;
	
	public function onRemoveChild(geometry:Geometry,child:Geometry) : Void;

}