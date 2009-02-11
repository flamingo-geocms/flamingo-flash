// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.event.*;

class flamingo.event.ChangeEvent extends StateEvent {
    
    private var previousState:Object = null;
    
    function ChangeEvent(source:Object, sourceClassName:String, propertyName:String, previousState:Object) {
        super(source, sourceClassName, CHANGE, propertyName);
        
        this.previousState = previousState;
    }
    
    function getPreviousState():Object {
        return previousState;
    }
    
    function toString():String {
        return "ChangeEvent(" + sourceClassName + ", CHANGE, " + propertyName + ")";
    }
    
}
