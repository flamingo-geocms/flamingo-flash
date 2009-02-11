// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

/** @component PrintTemplate 
* A container that holds and positions a number of components, with the intension to send them to a printer. 
* As a container it can hold any type of Flamingo component.
* With the print component a user can change the make-up of a template and preview it. Please refer to the Print component.
* Zoom and pan events in Flamingo's “main map” reflect on the first map in the template. 
* Identify events also reflect on the first map in the template, provided that the map is configured to handle identifies, 
* for example with an identify icon or with an identify results component that listens to the template's map.
* @file flamingo/tpc/classes/flamingo/gui/PrintTemplate.as  (sourcefile)
* @file flamingo/tpc/PrintTemplate.fla (sourcefile)
* @file flamingo/tpc/PrintTemplate.swf (compiled component, needed for publication on internet)
*/


/** @tag <tpc:PrintTemplate> 
* This tag defines a print template. A print template is a container and as such can hold child components, for example a map. 
* Configuration of the child components is as usual in Flamingo. 
* The legend component and the map component can both be configured in two ways now: direct and indirect. 
* Direct is the usual way with their own Flamingo attributes. 
* Indirect is by referring to another legend or map and using the configuration settings of that other component (attribute configobject in Map and Legend). 
* If ids are used for the child components, make sure the ids are unique within the whole Flamingo configuration. 
* Names do not have to be unique. The names of child components are used as labels in the “container inspector” of the print component. 
* The “container inspector” lets the user set the visibility of components within the template. 
* A print template should be registered as a listener to the legend component  that controls its map, 
* and that exists in the “legend container” of the print component. 
* If registered the legend will become visible when the corresponding template is chosen and invisible when another template is chosen by the user.
* @class flamingo.gui.PrintTemplate extends flamingo.gui.ScalableContainer
* @hierarchy child node of Print. 
* @example
	<tpc:Print id="print" width="100%" height="100%" visible="false"  borderwidth="0" listento="map">
		...
		<tpc:PrintTemplate id="printTemplate1" name="verticaal A4" dpi="144" format="A4" orientation="portrait"
			listento="printMonitor1" maps="printMap1">
			<fmc:Map id="printMap1" name="kaartbeeld" width="100%" height="100%" movequality="HIGH" configobject="map"/>
			<tpc:EditMap id="editMap2" name="redlining"  width="100%" height="100%"  listento="gis,printMap1" editable="false"/>
			<tpc:BitmapClone name="legenda" width="30%" height="25%" listento="legend" refreshrate="2500"/>
			<tpc:BitmapClone name="identify resultaten" width="40%" height="30%" right="right" listento="identify" refreshrate="2500"/>
			<tpc:PrintLabel name="identifylabel" top="0" width="40%" right="right"  text="Identify resultaten" fontfamily="arial" fontsize="18"/>
		</tpc:PrintTemplate>
	</tpc:Print>	
* @attr dpi (default value = “72”, max value = "144") Resolution in which the template is intended to be sent to the printer. In dots per inch. 
* Raising the resolution will improve the print quality but it may also show more a more detailed map than one might expect.
* @attr format (“A3”, “A4”, no default value) Paper format to which the template is intended to be printed.
* @attr orientation (“landscape”, “portrait”, no default value) Paper orientation to which the template is intended to be printed.
* @attr maps (optional, default value: “”) Comma separated string with ids of a the map components within the template. 
* The first one of these maps responds to zooms and pans and identifies in the “main map”. 
* If a template contains a second map, for example as an overview map, make sure that the second map is not first in the list of maps.
*/

import flamingo.gui.*;

class flamingo.gui.PrintTemplate extends ScalableContainer {
    
    private var componentID:String = "PrintTemplate 1.0";
    
    var top:String = "220";
    
    private var dpi:Number = 144;
    private var format:String = null;
    private var orientation:String = null;
	private var mapStrings:Array = null;
    private var maps:Array = null;
	private var layerIDs:Array;
	private var map:MovieClip;
    
    function PrintTemplate() {
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "dpi") {
            dpi = Number(value);
			if (dpi > 144){
				dpi = 144;
			}
        } else if (name == "format") {
            format = value;
        } else if (name == "orientation") {
            orientation = value;
            
            if ((format == "A4") && (orientation == "landscape")) {
                width = "" + Math.floor(813 * getDPIFactor());
                height = "" + Math.floor(561 * getDPIFactor());
            } else if ((format == "A4") && (orientation == "portrait")) {
                width = "" + Math.floor(561 * getDPIFactor());
                height = "" + Math.floor(813 * getDPIFactor());
            } else if ((format == "A3") && (orientation == "landscape")) {
                width = "" + Math.floor(1122 * getDPIFactor());
                height = "" + Math.floor(813 * getDPIFactor());
            } else if ((format == "A3") && (orientation == "portrait")) {
                width = "" + Math.floor(813 * getDPIFactor());
                height = "" + Math.floor(1122 * getDPIFactor());
            }
        } else if (name == "maps") {
           mapStrings = value.split(",");
        }
    }
    
    function go():Void {
       	map = getParent("Print").getMap();
       	layerIDs = map.getLayers();
		_global.flamingo.addListener(new MapPrintTemplateAdapter(this), map, this);
       	for (var i:String in layerIDs) {
          	_global.flamingo.addListener(new LayerPrintTemplateAdapter(this), layerIDs[i], this);
       	}
	   	maps = new Array()
		for (var i:Number = 0; i < mapStrings.length; i++) {
                maps.push(_global.flamingo.getComponent(mapStrings[i]));
        }
    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
        
        var component:MovieClip = null;
        for (var i:String in listento) {
            component = _global.flamingo.getComponent(listento[i]);
            if ((component.legenditems != undefined) || (component.monitorobjects != undefined))  { // Instance of Legend or MonitorLayer.
                component._visible = visible;
            }
        }
		for(var i:Number=0;i<maps.length;i++){
			if(visible){
				maps[i].show();
			} else {
				maps[i].hide();
			}
		}
		
    }
    
    function getOrientation():String {
        return orientation;
    }
    
    function getDPIFactor():Number {
        return dpi / 72;
    }
    
    function getMaps():Array {
        return maps.concat();
    }
    
}
