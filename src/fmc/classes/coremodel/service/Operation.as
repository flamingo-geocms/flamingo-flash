/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

/**
 * coremodel.service.Operation
 */
class coremodel.service.Operation {
    
    private var serviceFeature:ServiceFeature = null;
    /**
     * constructor
     * @param	serviceFeature
     */
    function Operation(serviceFeature:ServiceFeature) {
        if (serviceFeature == null) {
            trace("Exception in coremodel.service.Operation.<<init>>()\nNo core feature given.");
            return;
        }
        
        this.serviceFeature = serviceFeature;
    }
    /**
     * getFeatureID
     * @return
     */
    function getFeatureID():String {
        return serviceFeature.getID();
    }
    /**
     * toXMLString stub
     * @return
     */
    function toXMLString():String { return null; }
    
}
