/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.wfs.*;

import coremodel.service.ServiceFeature;
import coremodel.service.ServiceFeatureFactory;
import coremodel.service.ServiceLayer;
import tools.Randomizer;

class coremodel.service.wfs.WFSFeatureFactory extends ServiceFeatureFactory {
    
    function createServiceFeature(serviceLayer:ServiceLayer):ServiceFeature {
        var id:String = "WFSFF_" + Randomizer.getNumber();
        var serviceProperties:Array = serviceLayer.getServiceProperties();
        var serviceFeature:ServiceFeature = new WFSFeature(null, id, new Array(serviceProperties.length), serviceLayer);
        
        return serviceFeature;
    }
    
}
