/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
/**
 * gismodel.AvailableIcon
 */
class gismodel.AvailableIcon extends PropertyItem {
    
    private var pickIconUrl:String = null;
    /**
     * constructor
     * @param	xmlNode
     */
	function AvailableIcon(xmlNode:XMLNode) {
        super(xmlNode);
    }
	/**
	 * setAttribute
	 * @param	name
	 * @param	value
	 */
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
		if (name == "pickiconurl") {
            pickIconUrl = String(value);
        }
    }
	/**
	 * getPickIconUrl
	 * @return
	 */
	function getPickIconUrl():String {
        return pickIconUrl;
    }
	/**
	 * toString
	 * @return
	 */
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickIconUrl + ")";
    }
    
}
