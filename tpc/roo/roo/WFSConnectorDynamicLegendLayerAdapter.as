import roo.DynamicLegendLayer;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.WFSConnectorDynamicLegendLayerAdapter {

	private var dynamicLegendLayer:DynamicLegendLayer = null;
    private var enabled:Boolean = true;
    
    function WFSConnectorDynamicLegendLayerAdapter(dynamicLegendLayer:DynamicLegendLayer) {
        this.dynamicLegendLayer = dynamicLegendLayer;
    }
    
    function setEnabled(enabled:Boolean):Void {
        this.enabled = enabled;
    }
    
    function onActionEvent(actionEvent:Object):Void {
        //_global.flamingo.tracer("onActionEvent, enabled = " + enabled + " dynamicLegendLayer = " + dynamicLegendLayer.getTitle());
        if (enabled) {
            var numFeatures:Number = Number(actionEvent["numFeatures"]);
            if (numFeatures > 0) {
                dynamicLegendLayer.doSetVisible(true);
            } else {
                dynamicLegendLayer.doSetVisible(false);
            }
        }
    }
    
}
