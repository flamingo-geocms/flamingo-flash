import roo.DynamicLegendLayer;
import roo.FilterLayer;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.FilterLayerDynamicLegendLayerAdapter {

	private var dynamicLegendLayer:DynamicLegendLayer = null;
    
    function FilterLayerDynamicLegendLayerAdapter(dynamicLegendLayer:DynamicLegendLayer) {
        this.dynamicLegendLayer = dynamicLegendLayer;
    }
    
    function onAddRemoveFilter(filterLayer:FilterLayer, update:Boolean):Void {
        dynamicLegendLayer.setVisible();
    }
    
}
