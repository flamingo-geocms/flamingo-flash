// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

import flamingo.coremodel.service.wfs.*;

class flamingo.coremodel.service.Update extends Operation {
    
    function Update(serviceFeature:ServiceFeature) {
        super(serviceFeature);
    }
    
    function toXMLString():String {
        var requestString:String = "";
        var featureType:FeatureType = FeatureType(serviceFeature.getServiceLayer());
        var wfsProperties:Array = featureType.getServiceProperties();
        var wfsProperty:WFSProperty = null;
        var propertyName:String = null;
        var value:Object = null;
        
        requestString += "  <wfs:Update typeName=\"" + featureType.getName() + "\" xmlns:" + featureType.getNamespace() + ">\n";
        
        for (var i:Number = 0; i < wfsProperties.length; i++) {
            wfsProperty = WFSProperty(wfsProperties[i]);
            propertyName = wfsProperty.getName();
            value = serviceFeature.getValue(propertyName);
            
            if (wfsProperty != featureType.getDefaultGeometryProperty()) {
                requestString += "    <wfs:Property>\n";
                requestString += "      <wfs:Name>" + propertyName + "</wfs:Name>\n";
                
                if (value != null) {
                    requestString += "      <wfs:Value>" + value.toString() + "</wfs:Value>\n";
                }
                requestString += "    </wfs:Property>\n";
            }
        }
        requestString += "    <ogc:Filter>\n";
        requestString += "      <ogc:GmlObjectId gml:id=\"" + serviceFeature.getID() + "\"/>\n";
        requestString += "    </ogc:Filter>\n";
        requestString += "  </wfs:Update>\n";
        
        return requestString;
    }
    
    function toString():String {
        return "Update(" + serviceFeature.getID() + ")";
    }
    
}
