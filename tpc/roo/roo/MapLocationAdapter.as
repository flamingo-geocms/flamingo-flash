import roo.Location;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.MapLocationAdapter {

	private var location:Location = null;
    
    function MapLocationAdapter(location:Location) {
        this.location = location;
    }
    
    function onChangeExtent(map:MovieClip):Void {
        location.setXY();
    }
    
}
