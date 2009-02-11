// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gismodel.*;

class flamingo.gismodel.Property extends AbstractComposite {
    
    private var title:String = null;
    private var type:String = null;
    private var defaultValue:String = null;
    private var immutable:Boolean = false;
    
    function Property(xmlNode:XMLNode) {
        parseConfig(xmlNode);
    }
    
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
    
    function getTitle():String {
        return title;
    }
    
    function getType():String {
        return type;
    }
    
    function getDefaultValue():String {
        return defaultValue;
    }
    
    function isImmutable():Boolean {
        return immutable;
    }
    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ")";
    }
    
}
