// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.event.*;

class flamingo.event.AddRemoveEvent extends StateEvent {
    
    private var addedObjects:Array = null;
    private var removedObjects:Array = null;
    
    function AddRemoveEvent(source:Object, sourceClassName:String, propertyName:String, addedObjects:Array, removedObjects:Array) {
        super(source, sourceClassName, ADD_REMOVE, propertyName);
        
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
        return "AddRemoveEvent(" + sourceClassName + ", ADD_REMOVE, " + propertyName + ")";
    }
    
}
