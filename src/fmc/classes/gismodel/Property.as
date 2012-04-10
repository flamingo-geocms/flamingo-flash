/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import gismodel.*;
import core.AbstractComposite;
/**
 * gismodel.Property
 */
class gismodel.Property extends AbstractComposite {
    
    private var title:String = null;
    private var type:String = null;
    private var defaultValue:String = null;
    private var immutable:Boolean = false;
    /**
     * constructor
     * @param	xmlNode
     */
    function Property(xmlNode:XMLNode) {
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
        } else if (name == "immutable") {
            immutable = (value.toLowerCase() == "true" ? true : false);
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
     * isImmutable
     * @return
     */
    function isImmutable():Boolean {
        return immutable;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ")";
    }
    
}
