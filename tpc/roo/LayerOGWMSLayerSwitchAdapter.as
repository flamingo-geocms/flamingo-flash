import roo.LayerSwitch;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.LayerOGWMSLayerSwitchAdapter {

	private var layerSwitch:LayerSwitch = null;
    
    function LayerOGWMSLayerSwitchAdapter(layerSwitch:LayerSwitch) {
        this.layerSwitch = layerSwitch;
    }
    
    function onUpdateComplete(layer:MovieClip, updateTime:Number):Void {
        layerSwitch.swizch();
    }
    
}
