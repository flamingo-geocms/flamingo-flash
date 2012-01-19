/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

class coremodel.service.Operation {
    
    private var serviceFeature:ServiceFeature = null;
    
    function Operation(serviceFeature:ServiceFeature) {
        if (serviceFeature == null) {
            trace("Exception in coremodel.service.Operation.<<init>>()\nNo core feature given.");
            return;
        }
        
        this.serviceFeature = serviceFeature;
    }
    
    function getFeatureID():String {
        return serviceFeature.getID();
    }
    
    function toXMLString():String { return null; }
    
}
