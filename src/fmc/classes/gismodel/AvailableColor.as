/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
/**
 * gismodel.AvailableColor
 */
class gismodel.AvailableColor extends PropertyItem {
    
    private var pickColor:Number = null;
    /**
     * AvailableColor
     * @param	xmlNode
     */
	function AvailableColor(xmlNode:XMLNode) {
        super(xmlNode);
    }
	/**
	 * setAttribute
	 * @param	name
	 * @param	value
	 */
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
		if (name == "pickcolor") {
            pickColor = Number(value);
        }
    }
	/**
	 * getPickColor
	 * @return
	 */
	function getPickColor():Number {
        return pickColor;
    }
	/**
	 * toString
	 * @return
	 */    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickColor + ")";
    }
    
}
