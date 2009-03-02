/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.event.*;
import flamingo.core.AbstractComponent;

class flamingo.event.AddRemoveEvent extends StateEvent {
    
    private var addedObjects:Array = null;
    private var removedObjects:Array = null;
    
    function AddRemoveEvent(source:Object, sourceClassName:String, propertyName:String, addedObjects:Array, removedObjects:Array, eventComp:AbstractComponent) {
        super(source, sourceClassName, ADD_REMOVE, propertyName, eventComp);
        
        if (addedObjects == null) {
            this.addedObjects = new Array();
        } else {
            this.addedObjects = addedObjects;
        }
        if (removedObjects == null) {
            this.removedObjects = new Array();
        } else {
            this.removedObjects = removedObjects;
        }
    }
    
    function getAddedObjects():Array {
        return addedObjects;
    }
    
    function getRemovedObjects():Array {
        return removedObjects;
    }
    
    function toString():String {
        return "AddRemoveEvent(" + sourceClassName + ", " + source + ", ADD_REMOVE, " + propertyName + ", " + _global.flamingo.getId(eventComp)+ ")";
    }
    
}
