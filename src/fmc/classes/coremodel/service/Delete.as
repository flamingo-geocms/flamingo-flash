/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

import coremodel.service.wfs.*;

/**
 * coremodel.service.Delete
 */
class coremodel.service.Delete extends Operation {
    /**
     * constructor
     * @param	serviceFeature
     */
    function Delete(serviceFeature:ServiceFeature) {
        super(serviceFeature);
    }
    /**
     * toXMLString
     * @return
     */
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
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Delete(" + serviceFeature.getID() + ")";
    }
    
}
