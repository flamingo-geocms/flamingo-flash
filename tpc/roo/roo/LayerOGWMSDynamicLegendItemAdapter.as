import roo.DynamicLegendItem;

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
    
    function onUpdate():Void {
        dynamicLegendItem.setVisible();
    }
    
}
