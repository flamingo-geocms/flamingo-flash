// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

/** @component BitmapClone
* A component that shows a visual copy of another component, but without the functionality of that component. 
* A bitmap clone is especially useful for showing components on a print template which are actually too complex or in need of heavy configuration, 
* such as  identify results or legends.
* @file flamingo/tpc/classes/flamingo/gui/BitmapClone.as  (sourcefile)
* @file flamingo/tpc/BitmapClone.fla (sourcefile)
* @file flamingo/tpc/BitmapClone.swf (compiled component, needed for publication on internet)
*/


/** @tag <tpc:BitmapClone> 
* This tag defines a bitmap clone. The bitmap clone must be registered as listener to the component of which a visual copy is desired. 
* The component to be cloned must not have any content that is loaded from another domain than the domain where Flamingo runs. 
* If it does, the bitmap clone will remain a white box. This behavior is due to the sandbox security model of the Flash player
* @class flamingo.gui.BitmapClone extends AbstractComponent
* @hierarchy child node of Flamingo or a container component.
* @example
    <tpc:PrintTemplate id="printTemplate1" name="verticaal A4" dpi="200" format="A4" orientation="portrait"
		listento="printMonitor1" maps="printMap1">
		...
		<tpc:BitmapClone name="legenda" width="30%" height="25%" listento="legend" refreshrate="2500"/>
		<tpc:BitmapClone name="identify resultaten" width="40%" height="30%" right="right" listento="identify" refreshrate="2500"/>
		...
	</tpc:PrintTemplate>
* @attr refreshrate	((default value: 7000) Time in milliseconds at which rate the visual copy be refreshed.
*/


import flamingo.gui.*;

import flash.display.BitmapData;

class flamingo.gui.BitmapClone extends AbstractComponent {
    
    var refreshRate:Number = 7000;
    var source:MovieClip = null;
	var mask:MovieClip = null;
    var bitmapData:BitmapData = null;
	var mc:MovieClip = null;
    
    function setAttribute(name:String, value:String):Void {
        if (name == "refreshrate") {
            refreshRate = Number(value);
        }
    }
    
    function init():Void {
        source = _global.flamingo.getComponent(listento[0]);

		if (source.mScrollPane != undefined){
			mask = source.mScrollPane.mask_mc;
			source = source.mScrollPane.spContentHolder;
		}	
        setInterval(this, "cloneBitmap", refreshRate);
    }
    
    function layout():Void {
        cloneBitmap();
    }
    
    function cloneBitmap():Void {
		var width:Number = __width;
        var height:Number = __height;
		 if (bitmapData != null) {
			 bitmapData.dispose();
        }
		if (width > source._width) {
			width = source._width;
		}
		if (height > source._height) {
			height = source._height;
		}
		
        bitmapData = new BitmapData(width,height);
		attachBitmap(bitmapData, 0, "auto", true);
		
		if (mask != undefined){
			source.setMask(null);
			bitmapData.draw(source);
			source.setMask(mask); 
		} else {
			bitmapData.draw(source);
		}
		
    }
    
}
