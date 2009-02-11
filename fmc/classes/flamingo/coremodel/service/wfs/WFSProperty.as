// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.wfs.*;

import flamingo.coremodel.service.ServiceProperty;

class flamingo.coremodel.service.wfs.WFSProperty extends ServiceProperty {
    
    function WFSProperty(rootNode:XMLNode, namespacePrefix:String) {
        name = namespacePrefix + ":" + rootNode.attributes["name"];
        if (name == null) {
            _global.flamingo.tracer("Exception in flamingo.coremodel.WFSProperty.<<init>>: The property has no name.\n" + rootNode);
        }
        type = rootNode.attributes["type"];
        if (type == null) {
            _global.flamingo.tracer("Exception in flamingo.coremodel.WFSProperty.<<init>>: The property has no type.\n" + rootNode);
        }
        if ((rootNode.attributes["minOccurs"] != null) && (rootNode.attributes["minOccurs"] == 0)) {
            optional = true;
        }
    }
    
    function toString():String {
        return "WFSProperty(" + name + ", " + type + ")";
    }
    
}
