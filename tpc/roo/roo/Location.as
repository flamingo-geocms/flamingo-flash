import roo.MapLocationAdapter;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.Location extends MovieClip {
    
    private var map:Object = null;
    private var mapLocationAdapter:MapLocationAdapter = null;
    
    private var x:Number = null;
    private var y:Number = null;
    
    function onLoad():Void {
        mapLocationAdapter = new MapLocationAdapter(this);
        _global.flamingo.addListener(mapLocationAdapter, map, this);
        
        attachMovie("HairTarget", "mHairTarget", 0);
        setXY();
    }
    
    function setXY():Void {
        var extent:Object = new Object();
        extent["minx"] = x;
        extent["miny"] = y;
        extent["maxx"] = x;
        extent["maxy"] = y;
        var rect = map.extent2Rect(extent);
        _x = rect.x + (rect.width / 2);
        _y = rect.y + (rect.height / 2);
    }
    
}
