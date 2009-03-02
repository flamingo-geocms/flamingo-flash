/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

class flamingo.gui.LayerPrintTemplateAdapter {
    
    private var printTemplate:PrintTemplate = null;
    
    function LayerPrintTemplateAdapter(printTemplate:PrintTemplate) {
        this.printTemplate = printTemplate;
    }
    
    function onSetLayerProperty(layer:MovieClip, ids:String):Void {
        var visible:Boolean = layer.getLayerProperty(ids, "visible");
		if (ids.toUpperCase() == "#ALL#") {
			if(visible ==null){
				return;
			} else {
				for (var id in layer) {
					setVisible(layer, id, visible);
				}
			}
		} else {
			var a_ids = _global.flamingo.asArray(ids);
			for (var i = 0; i<a_ids.length; i++) {
				var id = a_ids[i];
				visible = layer.getLayerProperty(id, "visible");
				if (visible == null) {
					return;
				} 
				setVisible(layer, id, visible);
			}
		}
    }
	
	function setVisible(layer:MovieClip, id:String, visible:Boolean){
		var maps:Array = printTemplate.getMaps();
		if (maps.length > 0) {
			var mapID:String = _global.flamingo.getId(maps[0]);
			var layerID:String = _global.flamingo.getId(layer);
			layer = _global.flamingo.getComponent(mapID + "_" + layerID.split("_")[1]);
			layer.setLayerProperty(id, "visible", visible);
			maps[0].update(1000, true);
		}
	}
	
	function onHide(layer:MovieClip):Void {
		var maps:Array = printTemplate.getMaps();
        if (maps.length > 0) {
			var mapID:String = _global.flamingo.getId(maps[0]);
			var layerID:String = _global.flamingo.getId(layer);
			layer = _global.flamingo.getComponent(mapID + "_" + layerID.split("_")[1]);
			layer.hide();
		}
	}
	function onShow(layer:MovieClip):Void {
		var maps:Array = printTemplate.getMaps();
        if (maps.length > 0) {
			var mapID:String = _global.flamingo.getId(maps[0]);
			var layerID:String = _global.flamingo.getId(layer);
			layer = _global.flamingo.getComponent(mapID + "_" + layerID.split("_")[1]);
			layer.show();
		}
	}
    
}
