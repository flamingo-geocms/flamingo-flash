import roo.DynamicLegendItem;

class roo.MapDynamicLegendItemAdapter {

	private var dynamicLegendItem:DynamicLegendItem = null;
    
    function MapDynamicLegendItemAdapter(dynamicLegendItem:DynamicLegendItem) {
        this.dynamicLegendItem = dynamicLegendItem;
    }
    
    function onUpdate():Void {
            dynamicLegendItem.setVisible();
    }
/*
    function onReallyChangedExtent(map:MovieClip, extent:Object, eventType:Number):Void {
        _global.flamingo.tracer("onReallyChangedExtent, eventType = " + eventType);
        if (eventType > 1) {
            dynamicLegendItem.setVisible();
        }
    }
*/    
}
