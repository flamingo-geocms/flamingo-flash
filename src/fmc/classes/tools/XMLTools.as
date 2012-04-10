/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/


/**
 * tools.XMLTools
 */
class tools.XMLTools {
    /**
     * getChild
     * @param	name
     * @param	_xmlNode
     * @return
     */ 
    static function getChild(name:String, _xmlNode:XMLNode):XMLNode {
        for (var i:Number = 0; _xmlNode.childNodes[i] != null; i++) {
            if (_xmlNode.childNodes[i].nodeName.toUpperCase() == name.toUpperCase()) {
                return _xmlNode.childNodes[i];
            }
        }
        return null;
    }
    /**
     * getChildNodes
     * @param	name
     * @param	_xmlNode
     * @return
     */
    static function getChildNodes(name:String, _xmlNode:XMLNode):Array {
        var _array:Array = new Array();
        for (var i:Number = 0; _xmlNode.childNodes[i] != null; i++) {
            if (_xmlNode.childNodes[i].nodeName == name) {
                _array.push(_xmlNode.childNodes[i]);
            }
        }
        return _array;
    }
    /**
     * getElementsByTagName
     * @param	tagName
     * @param	_xmlNode
     * @return
     */
  static function getElementsByTagName(tagName:String, _xmlNode:XMLNode):Array	{
		var fringe: Array = [ _xmlNode ];
		var results: Array = [ ];
		while (fringe.length > 0) {
			var currentNode: XMLNode = XMLNode(fringe.shift ());
			if (currentNode.nodeName == tagName) {
				results.push (currentNode);
			}	
			var nodeCount:Number = currentNode.childNodes.length;
			for (var nodeIndex:Number = 0; nodeIndex < nodeCount; nodeIndex++) {
				fringe.push (currentNode.childNodes[nodeIndex]);				
			}
		}
	return results;	
}
     
    /**
     * getStringValue
     * @param	name
     * @param	_xmlNode
     * @return
     */
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
    /**
     * getStringValues
     * @param	name
     * @param	_xmlNode
     * @return
     */
    static function getStringValues(name:String, _xmlNode:XMLNode):Array {
        var subNodes:Array = getChildNodes(name, _xmlNode);
        var stringValues:Array = new Array();
        for (var i:Number = 0; i < subNodes.length; i++) {
            stringValues.push(subNodes[i].firstChild.nodeValue);
        }
        return stringValues;
    }
    /**
     * getNumberValue
     * @param	name
     * @param	_xmlNode
     * @return
     */
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
    /**
     * getNumberValues
     * @param	name
     * @param	_xmlNode
     * @return
     */
    static function getNumberValues(name:String, _xmlNode:XMLNode):Array {
        var subNodes:Array = getChildNodes(name, _xmlNode);
        var numberValues:Array = new Array();
        for (var i:Number = 0; i < subNodes.length; i++) {
            numberValues.push(Number(subNodes[i].firstChild.nodeValue));
        }
        return numberValues;
    }
    /**
     * getBooleanValue
     * @param	name
     * @param	_xmlNode
     * @return
     */
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
    /**
     * xmlDecode
     * @param	str
     * @return
     */
     static function xmlDecode(str:String):String {
        return str.split("&amp;").join("&").split("&lt;").join("<").split("&gt;").join(">").split("&quot;").join("\"").split("&apos;").join("\'");
    }
    
}
