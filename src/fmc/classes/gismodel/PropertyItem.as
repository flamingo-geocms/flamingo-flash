/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
import core.AbstractComposite;

class gismodel.PropertyItem extends AbstractComposite {
    
    private var title:String = null;
	private var name:String = null;
    private var type:String = null;
    private var defaultValue:String = null;
    private var value:String = null;
    
    function PropertyItem(xmlNode:XMLNode) {
        parseConfig(xmlNode);
    }
    
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
	
	function getTitle():String {
        return title;
    }
    
    function getType():String {
        return type;
    }
    
    function getDefaultValue():String {
        return defaultValue;
    }
	
	function getName():String {
        return name;
    }
	
	function getValue():String {
        return value;
    }
	    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ")";
    }
    
}
