import roo.Locations;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.MapLocationsAdapter {

	private var locations:Locations = null;
    
    function MapLocationsAdapter(locations:Locations) {
        this.locations = locations;
    }
    
    function onIdentify(map:MovieClip, extent:Object):Void {
        locations.addLocation(extent.minx, extent.miny);
    }
    
    function onHideIdentifyIcon(map:MovieClip):Void {
        locations.removeLocation();
    }
    
}
