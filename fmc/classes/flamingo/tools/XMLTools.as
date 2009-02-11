// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.tools.*;

class flamingo.tools.XMLTools {
    
    static function getChild(name:String, _xmlNode:XMLNode):XMLNode {
        for (var i:Number = 0; _xmlNode.childNodes[i] != null; i++) {
            if (_xmlNode.childNodes[i].nodeName.toUpperCase() == name.toUpperCase()) {
                return _xmlNode.childNodes[i];
            }
        }
        return null;
    }
    
    static function getChildNodes(name:String, _xmlNode:XMLNode):Array {
        var _array:Array = new Array();
        for (var i:Number = 0; _xmlNode.childNodes[i] != null; i++) {
            if (_xmlNode.childNodes[i].nodeName == name) {
                _array.push(_xmlNode.childNodes[i]);
            }
        }
        return _array;
    }
    
    static function getStringValue(name:String, _xmlNode:XMLNode):String {
        var valueNode:XMLNode = getChild(name, _xmlNode);
        var _string:String = null;
    
        if (valueNode.firstChild == null) {
                if (_xmlNode.attributes[name] != null) {
                _string = _xmlNode.attributes[name];
            } else {
                _string = null;
            }
        } else {
            _string = valueNode.firstChild.nodeValue;
        }
        return _string;
    }
    
    static function getStringValues(name:String, _xmlNode:XMLNode):Array {
        var subNodes:Array = getChildNodes(name, _xmlNode);
        var stringValues:Array = new Array();
        for (var i:Number = 0; i < subNodes.length; i++) {
            stringValues.push(subNodes[i].firstChild.nodeValue);
        }
        return stringValues;
    }
    
    static function getNumberValue(name:String, _xmlNode:XMLNode):Number {
        var valueNode:XMLNode = getChild(name, _xmlNode);
        var number:Number = -1;
    
        if (valueNode.firstChild == null) {
            if (_xmlNode.attributes[name] != null) {
                number = Number(_xmlNode.attributes[name]);
            }
        } else {
            number = Number(valueNode.firstChild.nodeValue);
        }
        return number;
    }
    
    static function getNumberValues(name:String, _xmlNode:XMLNode):Array {
        var subNodes:Array = getChildNodes(name, _xmlNode);
        var numberValues:Array = new Array();
        for (var i:Number = 0; i < subNodes.length; i++) {
            numberValues.push(Number(subNodes[i].firstChild.nodeValue));
        }
        return numberValues;
    }
    
    static function getBooleanValue(name:String, _xmlNode:XMLNode):Boolean {
        var valueNode:XMLNode = getChild(name, _xmlNode);
        var _string:String = null;
    
        if (valueNode.firstChild == null) {
            _string = _xmlNode.attributes[name];
        } else {
            _string = valueNode.firstChild.nodeValue;
        }
        if ((_string != null) && (_string.toUpperCase() == "TRUE")) {
            return true;
        } else {
            return false;
        }
        return null;
    }
    
}
