/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/


import mx.controls.Label;

import roo.DynamicLegendItem;
import roo.LayerOGWMSDynamicLegendItemAdapter;

class roo.DynamicLegendHeading extends DynamicLegendItem {
    
    private var layers:String = null; // Set by init object;
    private var layerArray:Array = null;
    
    function onLoad():Void {
        super.onLoad();
        layerArray = layers.split(",");
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
        for (var i = 0; i < layerArray.length; i++) {
            _global.flamingo.addListener(layerOGWMSDynamicLegendItemAdapter, map + "_" + layerArray[i], this);
        }
        
        setVisible();
    }
    
    function setVisible():Void {
        var map:String = dynamicLegend.getMap();
        _visible = false;
        if (!dynamicLegend.isDynamic()) {
            _visible = true;
        } else {
            var layer:MovieClip = null;
            for (var i = 0; i < layerArray.length; i++) {
              layer = _global.flamingo.getComponent(map + "_" + layerArray[i]);
              //_global.flamingo.tracer("layer = " + layerArray[i] + " comp = " + layer + " visible = " + layer.getVisible());
              if (_global.flamingo.getComponent(map + "_" + layerArray[i]).getVisible() == 1) { 
                  _visible = true;
              }
            }        
        }
        dynamicLegend.refresh();
    }
        
}
