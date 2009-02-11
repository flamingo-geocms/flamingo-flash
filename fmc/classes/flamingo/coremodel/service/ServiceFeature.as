// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

class flamingo.coremodel.service.ServiceFeature {
    
    private var serviceLayer:ServiceLayer = null;
    private var id:String = null;
    private var values:Array = null;
    
    function getServiceLayer():ServiceLayer {
        return serviceLayer;
    }
    
    function setID(id:String):Void {
        this.id = id;
    }
    
    function getID():String {
        return id;
    }
    
    function setValue(name:String, value:Object):Void {
        var serviceProperties:Array = serviceLayer.getServiceProperties();
        for (var i:Number = 0; i < serviceProperties.length; i++) {
            if (ServiceProperty(serviceProperties[i]).getName() == name) {
                values[i] = value;
                return;
            }
        }
        
        _global.flamingo.tracer("Exception in flamingo.coremodel.service.ServiceFeature.setValue(" + name + ")");
    }
    
    function getValue(name:String):Object {
        var serviceProperties:Array = serviceLayer.getServiceProperties();
        for (var i:Number = 0; i < serviceProperties.length; i++) {
            if (ServiceProperty(serviceProperties[i]).getName() == name) {
                return values[i];
            }
        }
        
        _global.flamingo.tracer("Exception in flamingo.coremodel.service.ServiceFeature.getValue(" + name + ")");
        return null;
    }
    
}
