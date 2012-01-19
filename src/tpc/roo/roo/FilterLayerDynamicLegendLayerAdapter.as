import roo.DynamicLegendLayer;
import roo.FilterLayer;

class roo.FilterLayerDynamicLegendLayerAdapter {

	private var dynamicLegendLayer:DynamicLegendLayer = null;
    
    function FilterLayerDynamicLegendLayerAdapter(dynamicLegendLayer:DynamicLegendLayer) {
        this.dynamicLegendLayer = dynamicLegendLayer;
    }
    
    function onAddRemoveFilter(filterLayer:FilterLayer, update:Boolean):Void {
        dynamicLegendLayer.setVisible();
    }
    
}
