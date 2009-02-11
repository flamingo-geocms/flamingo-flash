// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.event.*;

class flamingo.event.ActionEvent {
    
    static var CLICK:Number = 0;
    static var LOAD:Number = 1;
    
    private var source:Object = null;
    private var sourceClassName:String = null;
    private var actionType:Number = -1;
    
    function ActionEvent(source:Object, sourceClassName:String, actionType:Number) {
        if (source == null) {
            trace("Exception in flamingo.event.ActionEvent.<<init>>(" + sourceClassName + ")");
            return;
        }
        if (sourceClassName == null) {
            trace("Exception in flamingo.event.ActionEvent.<<init>>(" + sourceClassName + ")");
            return;
        }
        
        this.source = source;
        this.sourceClassName = sourceClassName;
        this.actionType = actionType;
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
    
    function toString():String {
        return "ActionEvent(" + sourceClassName + ", " + actionType + ")";
    }
    
}
