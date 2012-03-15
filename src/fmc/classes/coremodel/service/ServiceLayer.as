/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

/**
 * coremodel.service.ServiceLayer
 */
class coremodel.service.ServiceLayer {
    
    private var name:String = null;
    private var serviceProperties:Array = null;
    private var geometryProperties:Array = null;
    /**
     * getName
     * @return
     */
    function getName():String {
        return name;
    }
    /**
     * getServiceProperties
     * @return
     */
    function getServiceProperties():Array {
        return serviceProperties.concat();
    }
    /**
     * getServiceProperty
     * @param	name
     * @return
     */
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
    /**
     * getDefaultGeometryProperty
     * @return
     */
    function getDefaultGeometryProperty():ServiceProperty {
        return geometryProperties[0];
    }
    /**
     * getNamespace
     * @return always null
     */
    function getNamespace():String { return null; }
    /**
     * getServiceFeatureFactory
     * @return always null
     */
    function getServiceFeatureFactory():ServiceFeatureFactory { return null; }
    
}
