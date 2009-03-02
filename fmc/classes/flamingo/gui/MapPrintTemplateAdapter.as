/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

class flamingo.gui.MapPrintTemplateAdapter {
    
    private var printTemplate:PrintTemplate = null;
    
    function MapPrintTemplateAdapter(printTemplate:PrintTemplate) {
        this.printTemplate = printTemplate;
    }
    
    function onAddLayer(map:MovieClip, layer:MovieClip):Void {
        _global.flamingo.addListener(new LayerPrintTemplateAdapter(printTemplate), layer, this);
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
