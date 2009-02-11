// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

class flamingo.coremodel.service.ServiceLayer {
    
    private var name:String = null;
    private var serviceProperties:Array = null;
    private var geometryProperties:Array = null;
    
    function getName():String {
        return name;
    }
    
    function getServiceProperties():Array {
        return serviceProperties.concat();
    }
    
    function getServiceProperty(name:String):ServiceProperty {
        var serviceProperty:ServiceProperty = null;
        for (var i:String in serviceProperties) {
            serviceProperty = ServiceProperty(serviceProperties[i]);
            if (serviceProperty.getName() == name) {
                return serviceProperty;
            }
        }
        return null;
    }
    
    function getDefaultGeometryProperty():ServiceProperty {
        return geometryProperties[0];
    }
    
    function getNamespace():String { return null; }
    
    function getServiceFeatureFactory():ServiceFeatureFactory { return null; }
    
}
