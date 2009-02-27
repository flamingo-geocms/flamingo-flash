import roo.DynamicLegend;
import roo.MapDynamicLegendItemAdapter;
import roo.LayerOGWMSDynamicLegendItemAdapter;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.DynamicLegendItem extends MovieClip {
    
    private var dynamicLegend:DynamicLegend = null; // Set by init object.
    private var mapDynamicLegendItemAdapter:MapDynamicLegendItemAdapter = null;
    private var layerOGWMSDynamicLegendItemAdapter:LayerOGWMSDynamicLegendItemAdapter = null;
    private var title:String = null; // Set by init object;
    
    function onLoad():Void {
        var map:String = dynamicLegend.getMap();
        mapDynamicLegendItemAdapter = new MapDynamicLegendItemAdapter(this);
        _global.flamingo.addListener(mapDynamicLegendItemAdapter, map, this);
    }
    
    function setVisible():Void { }
    
    function isVisible():Boolean {
        return _visible;
    }
    
    function getTitle():String {
      return title;
    }
    
}
