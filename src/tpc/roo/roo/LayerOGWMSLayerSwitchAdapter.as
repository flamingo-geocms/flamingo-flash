import roo.LayerSwitch;

class roo.LayerOGWMSLayerSwitchAdapter {

	private var layerSwitch:LayerSwitch = null;
    
    function LayerOGWMSLayerSwitchAdapter(layerSwitch:LayerSwitch) {
        this.layerSwitch = layerSwitch;
    }
    
    function onUpdateComplete(layer:MovieClip, updateTime:Number):Void {
        layerSwitch.swizch();
    }
    
}
