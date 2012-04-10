/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
import core.AbstractComposite;
/**
 * gismodel.PropertyItem
 */
class gismodel.PropertyItem extends AbstractComposite {
    
    private var title:String = null;
	private var name:String = null;
    private var type:String = null;
    private var defaultValue:String = null;
    private var value:String = null;
    /**
     * constructor
     * @param	xmlNode
     */
    function PropertyItem(xmlNode:XMLNode) {
        parseConfig(xmlNode);
    }
    /**
     * setAttribute
     * @param	name
     * @param	value
     */
    function setAttribute(name:String, value:String):Void {
		if (name == "title") {
            title = value;
        } else if (name == "type") {
            type = value;
        } else if (name == "defaultvalue") {
            defaultValue = value;
        } else if (name == "name") {
            name = value;
        } else if (name == "value") {
            this.value = value;
        }
    }
	/**
	 * getTitle
	 * @return
	 */
	function getTitle():String {
        return title;
    }
    /**
     * getType
     * @return
     */
    function getType():String {
        return type;
    }
    /**
     * getDefaultValue
     * @return
     */
    function getDefaultValue():String {
        return defaultValue;
    }
	/**
	 * getName
	 * @return
	 */
	function getName():String {
        return name;
    }
	/**
	 * getValue
	 * @return
	 */
	function getValue():String {
        return value;
    }
	/**
	 * toString
	 * @return
	 */    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ")";
    }
    
}
