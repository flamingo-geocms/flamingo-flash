/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

class gui.MapPrintTemplateAdapter {
    
    private var printTemplate:PrintTemplate = null;
    var lFlamingo:Object;
    
    function MapPrintTemplateAdapter(printTemplate:PrintTemplate) {
        this.printTemplate = printTemplate;
    }
    
    function onAddLayer(map:MovieClip, layer:MovieClip):Void {
        _global.flamingo.addListener(new LayerPrintTemplateAdapter(printTemplate), layer, this);
    	var thisObj:Object = this; 
    	lFlamingo = new Object;
		lFlamingo.onConfigComplete = function() { 
			_global.flamingo.removeListener(thisObj.lFlamingo, "flamingo", thisObj);
			thisObj.printTemplate.showMap();
		};
		 //parse map xml
		_global.flamingo.addListener(lFlamingo, "flamingo", this);
        var maps:Array = printTemplate.getMaps();
        printTemplate.removeLayerListeners()
       	//reload the mapconfig after adding a layer
       	var mapConfigObj:Object = _global.flamingo.getComponent(maps[0].configObjId);
				var allXML:Array = _global.flamingo.getXMLs(mapConfigObj);
				for(var i:Number=0;i<allXML.length;i++){
					maps[0].parseCustomAttr(allXML[i]);
				}
    }
    
    function onRemoveLayer(map:MovieClip, layer:MovieClip):Void {
    	 var maps:Array = printTemplate.getMaps();
        if (maps.length > 0) {
            maps[0].removeLayer(layer);
        }
    }
    
    function onChangeExtent(map:MovieClip):Void {
        var maps:Array = printTemplate.getMaps();
        if (maps.length > 0) {
            maps[0].moveToExtent(map.getCurrentExtent(), 0, 0);
        }
    }
    

    function onIdentify(map:MovieClip, extent:Object):Void {
		var maps:Array = printTemplate.getMaps();
		if (maps.length > 0) {
				maps[0].correctIdentifyIcon(extent)
		}
    }
	
	function onHideIdentifyIcon(map:MovieClip):Void {
		var maps:Array = printTemplate.getMaps();
		if (maps.length > 0) {
			_global.flamingo.raiseEvent(maps[0], "onHideIdentifyIcon", maps[0]);
		}
	}
	
	
	
}
