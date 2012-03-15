/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

/**
 * coremodel.service.ServiceProperty
 */
class coremodel.service.ServiceProperty {
    
    private var name:String = null;
    private var type:String = null;
    private var optional:Boolean = false;
    /**
     * getName
     * @return
     */
    function getName():String {
        return name;
    }
    /**
     * getType
     * @return
     */
    function getType():String {
        return type;
    }
    /**
     * isOptional
     * @return
     */
    function isOptional():Boolean {
        return optional;
    }
    
}
