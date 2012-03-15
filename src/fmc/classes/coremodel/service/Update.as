/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

import coremodel.service.wfs.*;

/**
 * coremodel.service.Update
 */
class coremodel.service.Update extends Operation {
    /**
     * constructor
     * @param	serviceFeature
     */
    function Update(serviceFeature:ServiceFeature) {
        super(serviceFeature);
    }
    /**
     * toXMLString
     * @return
     */
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
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Update(" + serviceFeature.getID() + ")";
    }
    
}
