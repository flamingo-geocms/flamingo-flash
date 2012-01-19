/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;

class gismodel.AvailablePattern extends PropertyItem {
    
    private var pickPatternUrl:String = null;
    
	function AvailablePattern(xmlNode:XMLNode) {
        super(xmlNode);
    }
		
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
       if (name == "pickpatternurl") {
            pickPatternUrl = String(value);
        }
    }
	
	function getPickPatternUrl():String {
        return pickPatternUrl;
    }
	    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickPatternUrl + ")";
    }
    
}
