import mx.controls.Label;

import roo.DynamicLegendItem;
import roo.LayerOGWMSDynamicLegendItemAdapter;

class roo.DynamicLegendHeading extends DynamicLegendItem {
    
    function onLoad():Void {
        super.onLoad();
        var initObject:Object = new Object();
        initObject["_x"] = -3;
        initObject["_y"] = -3;
        initObject["text"] = title;
        var label:Label = Label(attachMovie("Label", "mLabel", 0, initObject));
        label.setSize(130, 20);
        label.setStyle("fontSize", 11);
        label.setStyle("fontWeight", "bold");

        var map:String = dynamicLegend.getMap();
        layerOGWMSDynamicLegendItemAdapter = new LayerOGWMSDynamicLegendItemAdapter(this);
        for (var i = 0; i < layers.length; i++) {
            _global.flamingo.addListener(layerOGWMSDynamicLegendItemAdapter, map + "_" + layers[i], this);
        }
        
        setVisible();
    }
    
    function setVisible():Void {
        var map:String = dynamicLegend.getMap();
        _visible = false;
        if (!dynamicLegend.isDynamic()) {
            _visible = true;
        } else {
            if (isOneLayerVisible()) { 
                _visible = true;
            }
        }
        dynamicLegend.refresh();
    }
        
}
