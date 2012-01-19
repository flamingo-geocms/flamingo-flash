import roo.DynamicLegend;
import roo.MapDynamicLegendItemAdapter;
import roo.LayerOGWMSDynamicLegendItemAdapter;

class roo.DynamicLegendItem extends MovieClip {
    
    private var dynamicLegend:DynamicLegend = null; // Set by init object.
    private var mapDynamicLegendItemAdapter:MapDynamicLegendItemAdapter = null;
    private var layerOGWMSDynamicLegendItemAdapter:LayerOGWMSDynamicLegendItemAdapter = null;
    private var title:String = null; // Set by init object;
    private var id:String = null; // Set by init object;
    private var layers:Array = null; // Set by init object.
    
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
    
    function getId():String {
      return id;
    }
    
    function getLayers():Array {
    	return layers;
    }

	function isOneLayerVisible():Boolean {
        var atLeast1LayerVisible:Boolean = false;
        var map:String = dynamicLegend.getMap();
        var layer:MovieClip = null;
        for (var i:String in layers) {
            layer = _global.flamingo.getComponent(map + "_" + layers[i]);
            //_global.flamingo.tracer("DynamicLegendLayer.setVisible(), layers[" + i + "] = " + layer + " visible = " + layer.getVisible());
            if (layer.getVisible() == 1) {
                atLeast1LayerVisible = true;
            }
        }
        return atLeast1LayerVisible;
    }
		    
}
