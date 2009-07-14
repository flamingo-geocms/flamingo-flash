/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;

class gismodel.AvailableIcon extends PropertyItem {
    
    private var pickIconUrl:String = null;
    
	function AvailableIcon(xmlNode:XMLNode) {
        super(xmlNode);
    }
	
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
		if (name == "pickiconurl") {
            pickIconUrl = String(value);
        }
    }
	
	function getPickIconUrl():String {
        return pickIconUrl;
    }
  
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickIconUrl + ")";
    }
    
}
