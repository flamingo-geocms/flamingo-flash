/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.event.*;
import flamingo.core.AbstractComponent;

class flamingo.event.ChangeEvent extends StateEvent {
    
    private var previousState:Object = null;
    
    function ChangeEvent(source:Object, sourceClassName:String, propertyName:String, previousState:Object, eventComp:AbstractComponent) {
        super(source, sourceClassName, CHANGE, propertyName, eventComp);
        
        this.previousState = previousState;
    }
    
    function getPreviousState():Object {
        return previousState;
    }
    
    function toString():String {
        return "ChangeEvent(" + sourceClassName + ", " + source + ", CHANGE, " + propertyName + ", " + _global.flamingo.getId(eventComp)+ ")";
    }
    
}
