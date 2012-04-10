/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import event.*;
import core.AbstractComponent;
/**
 * event.ChangeEvent
 */
class event.ChangeEvent extends StateEvent {
    
    private var previousState:Object = null;
    /**
     * constrcutor
     * @param	source
     * @param	sourceClassName
     * @param	propertyName
     * @param	previousState
     * @param	eventComp
     */
    function ChangeEvent(source:Object, sourceClassName:String, propertyName:String, previousState:Object, eventComp:AbstractComponent) {
        super(source, sourceClassName, CHANGE, propertyName, eventComp);
        
        this.previousState = previousState;
    }
    /**
     * getPreviousState
     * @return
     */
    function getPreviousState():Object {
        return previousState;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "ChangeEvent(" + sourceClassName + ", " + source + ", CHANGE, " + propertyName + ", " + _global.flamingo.getId(eventComp)+ ")";
    }
    
}
