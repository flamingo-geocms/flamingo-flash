/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import event.*;
import core.AbstractComponent;
/**
 * event.AddRemoveEvent
 */
class event.AddRemoveEvent extends StateEvent {
    
    private var addedObjects:Array = null;
    private var removedObjects:Array = null;
    /**
     * AddRemoveEvent
     * @param	source
     * @param	sourceClassName
     * @param	propertyName
     * @param	addedObjects
     * @param	removedObjects
     * @param	eventComp
     */
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
    /**
     * getAddedObjects
     * @return
     */
    function getAddedObjects():Array {
        return addedObjects;
    }
    /**
     * getRemovedObjects
     * @return
     */
    function getRemovedObjects():Array {
        return removedObjects;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "AddRemoveEvent(" + sourceClassName + ", " + source + ", ADD_REMOVE, " + propertyName + ", " + _global.flamingo.getId(eventComp)+ ")";
    }
    
}
