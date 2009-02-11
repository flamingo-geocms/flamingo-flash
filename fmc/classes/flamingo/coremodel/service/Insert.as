// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

import flamingo.coremodel.service.wfs.*;
import flamingo.geometrymodel.Geometry;

class flamingo.coremodel.service.Insert extends Operation {
    
    function Insert(serviceFeature:ServiceFeature) {
        super(serviceFeature);
    }
    
    function toXMLString():String {
        var requestString:String = "";
        var serviceLayer:ServiceLayer = serviceFeature.getServiceLayer();
        var featureTypeName:String = serviceLayer.getName();
        var properties:Array = serviceLayer.getServiceProperties();
        var property:WFSProperty = null;
        var propertyName:String = null;
        var value:Object = null;
        
        requestString += "  <wfs:Insert handle=\"" + serviceFeature.getID() + "\" xmlns:" + serviceLayer.getNamespace() + ">\n";
        requestString += "    <wfs:FeatureCollection>\n";
        requestString += "      <gml:featureMember>\n";
        requestString += "        <" + featureTypeName + ">\n";
        
        for (var i:Number = 0; i < properties.length; i++) {
            property = WFSProperty(properties[i]);
            propertyName = property.getName();
            value = serviceFeature.getValue(propertyName);
            
            if (property == serviceLayer.getDefaultGeometryProperty()) {
                requestString += "          <" + propertyName + ">\n";
                requestString += Geometry(serviceFeature.getValue(serviceLayer.getDefaultGeometryProperty().getName())).toGMLString();
                requestString += "          </" + propertyName + ">\n";
            } else if (value != null) {
                requestString += "          <" + propertyName + ">" + value.toString() + "</" + propertyName + ">\n";
            }
        }
        requestString += "        </" + featureTypeName + ">\n";
        requestString += "      </gml:featureMember>\n";
        requestString += "    </wfs:FeatureCollection>\n";
        requestString += "  </wfs:Insert>\n";
        
        return requestString;
    }
    
    function toString():String {
        return "Insert(" + serviceFeature.getID() + ")";
    }
    
}
