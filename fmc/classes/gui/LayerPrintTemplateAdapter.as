/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

class gui.LayerPrintTemplateAdapter {
    
    private var printTemplate:PrintTemplate = null;
    private var updatelayers:Object;
    
    function LayerPrintTemplateAdapter(printTemplate:PrintTemplate) {
        this.printTemplate = printTemplate;
        updatelayers=new Object();
    }
    
    function onSetLayerProperty(layer:MovieClip, ids:String, property:String):Void {
    	if(property == "visible"){
			var update:Boolean = false;
			var printLayer:Object = getPrintLayer(layer); 
			if (printLayer.initialized){
	        	var visible:Boolean; 
				if (ids.toUpperCase() == "#ALL#") {
					var lyrs:Array = layer.layers;
					for (var id in lyrs) {
						visible = layer.getLayerProperty(lyrs[id], "visible");
						//_global.flamingo.tracer("LayerPrintTemplateAdapter id == " + id + visible);
						if(printLayer.getLayerProperty(lyrs[id], "visible") != visible){
							//_global.flamingo.tracer(id + " update1 ");
							update = true;
							printLayer.setLayerProperty(lyrs[id], "visible", visible);
						}
					}
				} else {
					var a_ids = _global.flamingo.asArray(ids);
					for (var i = 0; i<a_ids.length; i++) {
						var id = a_ids[i];
						visible = layer.getLayerProperty(id, "visible");
						//_global.flamingo.tracer(printLayer.getLayerProperty(id, "visible") + " != " + visible);
						if(printLayer.getLayerProperty(id, "visible") != visible){
							//_global.flamingo.tracer(printLayerId + " " + id + " update2 " + visible);
							update = true;
							printLayer.setLayerProperty(id, "visible", visible);
						}	
					}	
				}
				
				if(update){
					updatelayers[_global.flamingo.getId(printLayer)] = 1;
					_global.setTimeout(this,'update',1000);
				}
			}
	    }
    }
	
	function onHide(layer:MovieClip):Void {
		//_global.flamingo.tracer("LayerPrintTemplateAdapter onHide == " +_global.flamingo.getId(layer));
		var printLayer:Object =  getPrintLayer(layer);
		printLayer.visible = false;
		_global.flamingo.raiseEvent(printLayer, "onHide", printLayer);
	}
	
	function onShow(layer:MovieClip):Void {
		//_global.flamingo.tracer("LayerPrintTemplateAdapter onShow == " +_global.flamingo.getId(layer));
		var printLayer:Object =  getPrintLayer(layer);
		//_global.flamingo.tracer("LayerPrintTemplateAdapter show == " +_global.flamingo.getId(layer));
		printLayer.visible = true;
		printLayer.updateCaches();
		_global.flamingo.raiseEvent(printLayer, "onShow", printLayer);
	}
	
	function onSetValue(setter:String, val:Number, layer:MovieClip){
		if(setter=="setAlpha"){
			getPrintLayer(layer).setAlpha(val);	
		}
	}
		
	private function getPrintLayer(layer:MovieClip):Object{
		var maps:Array = printTemplate.getMaps();
        if (maps.length > 0) {
			var mapID:String = _global.flamingo.getId(maps[0]);
			var layerID:String = _global.flamingo.getId(layer);
			var masterMapId:String=_global.flamingo.getId(layer.map)
			var printLayerId:String = mapID + layerID.substr(masterMapId.length);
			var printLayer:Object =  _global.flamingo.getComponent(mapID + layerID.substr(masterMapId.length));
			return printLayer;
        } else {
        	return null;
        }
		
	}	
	
	private function update() {
		for (var layername in updatelayers) {
			//_global.flamingo.tracer("Adapt update " + layername); 
			_global.flamingo.getComponent(layername).update();
		}
		updatelayers = new Object();
	}
    
}
