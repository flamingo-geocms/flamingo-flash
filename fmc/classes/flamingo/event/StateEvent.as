// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.event.*;

class flamingo.event.StateEvent {
    
    static var CHANGE:Number = 0;
    static var ADD_REMOVE:Number = 1;
    static var LOAD:Number = 2;
    
    private var source:Object = null;
    private var sourceClassName:String = null;
    private var actionType:Number = -1;
    private var propertyName:String = null;
    
    function StateEvent(source:Object, sourceClassName:String, actionType:Number, propertyName:String) {
        if (source == null) {
            trace("Exception in flamingo.event.StateEvent.<<init>>(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        if (sourceClassName == null) {
            trace("Exception in flamingo.event.StateEvent.<<init>>(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        this.source = source;
        this.sourceClassName = sourceClassName;
        this.actionType = actionType;
        this.propertyName = propertyName;
    }
    
    function getSource():Object {
        return source;
    }
    
    function getSourceClassName():String {
        return sourceClassName;
    }
    
    function getActionType():Number {
        return actionType;
    }
    
    function getPropertyName():String {
        return propertyName;
    }
    
    function toString():String {
        return "StateEvent(" + sourceClassName + ", " + actionType + ", " + propertyName + ")";
    }
    
}
