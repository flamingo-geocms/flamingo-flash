import roo.DynamicLegendItem;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.MapDynamicLegendItemAdapter {

	private var dynamicLegendItem:DynamicLegendItem = null;
    
    function MapDynamicLegendItemAdapter(dynamicLegendItem:DynamicLegendItem) {
        this.dynamicLegendItem = dynamicLegendItem;
    }
    
    function onReallyChangedExtent(map:MovieClip, extent:Object, eventType:Number):Void {
        if (eventType > 1) {
            dynamicLegendItem.setVisible();
        }
    }
    
}
