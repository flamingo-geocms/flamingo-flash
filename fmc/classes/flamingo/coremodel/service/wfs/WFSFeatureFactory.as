// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.wfs.*;

import flamingo.coremodel.service.ServiceFeature;
import flamingo.coremodel.service.ServiceFeatureFactory;
import flamingo.coremodel.service.ServiceLayer;
import flamingo.tools.Randomizer;

class flamingo.coremodel.service.wfs.WFSFeatureFactory extends ServiceFeatureFactory {
    
    function createServiceFeature(serviceLayer:ServiceLayer):ServiceFeature {
        var id:String = "WFSFF_" + Randomizer.getNumber();
        var serviceProperties:Array = serviceLayer.getServiceProperties();
        var serviceFeature:ServiceFeature = new WFSFeature(null, id, new Array(serviceProperties.length), serviceLayer);
        
        return serviceFeature;
    }
    
}
