import roo.DynamicLegendItem;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.LayerOGWMSDynamicLegendItemAdapter {

	private var dynamicLegendItem:DynamicLegendItem = null;
    
    function LayerOGWMSDynamicLegendItemAdapter(dynamicLegendItem:DynamicLegendItem) {
        this.dynamicLegendItem = dynamicLegendItem;
    }
    
    function onShow():Void {
        //_global.flamingo.tracer("onShow, item = " + dynamicLegendItem.getTitle());
        dynamicLegendItem.setVisible();
    }
    
    function onHide():Void {
        dynamicLegendItem.setVisible();
    }
    
}
