// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

import flamingo.coremodel.service.wfs.*;

class flamingo.coremodel.service.Delete extends Operation {
    
    function Delete(serviceFeature:ServiceFeature) {
        super(serviceFeature);
    }
    
    function toXMLString():String {
        var requestString:String = "";
        var serviceLayer:ServiceLayer = serviceFeature.getServiceLayer();
        
        requestString += "  <wfs:Delete typeName=\"" + serviceLayer.getName() + "\" xmlns:" + serviceLayer.getNamespace() + ">\n";
        requestString += "    <ogc:Filter>\n";
        requestString += "      <ogc:GmlObjectId gml:id=\"" + serviceFeature.getID() + "\"/>\n";
        requestString += "    </ogc:Filter>\n";
        requestString += "  </wfs:Delete>\n";
        
        return requestString;
    }
    
    function toString():String {
        return "Delete(" + serviceFeature.getID() + ")";
    }
    
}
