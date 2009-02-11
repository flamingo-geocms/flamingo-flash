// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

class flamingo.coremodel.service.ServiceProperty {
    
    private var name:String = null;
    private var type:String = null;
    private var optional:Boolean = false;
    
    function getName():String {
        return name;
    }
    
    function getType():String {
        return type;
    }
    
    function isOptional():Boolean {
        return optional;
    }
    
}
