/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;

class gismodel.AvailableColor extends PropertyItem {
    
    private var pickColor:Number = null;
    
	function AvailableColor(xmlNode:XMLNode) {
        super(xmlNode);
    }
	
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
		if (name == "pickcolor") {
            pickColor = Number(value);
        }
    }
	
	function getPickColor():Number {
        return pickColor;
    }
	    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickColor + ")";
    }
    
}
