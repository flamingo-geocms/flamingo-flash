// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

class AbstractComposite {
    
    private var name:String = null;
    
    function parseConfig(xmlNode:XMLNode):Void {
        this.name = xmlNode.attributes["name"];
        
        // Parses the attributes from the config.
        for (var name:String in xmlNode.attributes) {
            var value:String = xmlNode.attributes[name];
            setAttribute(name, value);
        }
        
        // Parses the child nodes from the config.
        var childNode:XMLNode = null;
        var name:String = null;
        for (var i:Number = 0; i < xmlNode.childNodes.length; i++) {
            childNode = xmlNode.childNodes[i];
            name = childNode.nodeName;
            if (name.indexOf(":") > -1) {
                name = name.substr(name.indexOf(":") + 1);
            }
            addComposite(name, childNode);
        }
    }
    
    function getName():String {
        return name;
    }
    
    function setAttribute(name:String, value:String):Void { }
    
    function addComposite(name:String, xmlNode:XMLNode):Void { }
    
}
