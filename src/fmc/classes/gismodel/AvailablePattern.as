/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
/**
 * gismodel.AvailablePattern
 */
class gismodel.AvailablePattern extends PropertyItem {
    
    private var pickPatternUrl:String = null;
    /**
     * constructor
     * @param	xmlNode
     */
	function AvailablePattern(xmlNode:XMLNode) {
        super(xmlNode);
    }
	/**
	 * setAttribute
	 * @param	name
	 * @param	value
	 */	
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
       if (name == "pickpatternurl") {
            pickPatternUrl = String(value);
        }
    }
	/**
	 * getPickPatternUrl
	 * @return
	 */
	function getPickPatternUrl():String {
        return pickPatternUrl;
    }
	/**
	 * toString
	 * @return
	 */    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickPatternUrl + ")";
    }
    
}
