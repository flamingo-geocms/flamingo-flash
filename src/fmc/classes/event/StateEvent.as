/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import event.*;
import core.AbstractComponent;
/**
 * event.StateEvent
 */
class event.StateEvent {
    
    static var CHANGE:Number = 0;
    static var ADD_REMOVE:Number = 1;
    static var LOAD:Number = 2;
    
    private var source:Object = null;
    private var sourceClassName:String = null;
    private var actionType:Number = -1;
    private var propertyName:String = null;
    private var eventComp:AbstractComponent = null;
    /**
     * constructor
     * @param	source
     * @param	sourceClassName
     * @param	actionType
     * @param	propertyName
     * @param	eventComp
     */
    function StateEvent(source:Object, sourceClassName:String, actionType:Number, propertyName:String, eventComp:AbstractComponent) {
        if (source == null) {
            trace("Exception in event.StateEvent.<<init>>(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        if (sourceClassName == null) {
            trace("Exception in event.StateEvent.<<init>>(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        this.source = source;
        this.sourceClassName = sourceClassName;
        this.actionType = actionType;
        this.propertyName = propertyName;
        this.eventComp = eventComp;
    }
    /**
     * getSource
     * @return
     */
    function getSource():Object {
        return source;
    }
    /**
     * getSourceClassName
     * @return
     */
    function getSourceClassName():String {
        return sourceClassName;
    }
    /**
     * getActionType
     * @return
     */
    function getActionType():Number {
        return actionType;
    }
    /**
     * getPropertyName
     * @return
     */
    function getPropertyName():String {
        return propertyName;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
    	var actionTypeStr:String = "";
    	if(actionType==0){
    		actionTypeStr = "CHANGE";
    	} else if(actionType==1) {
    		actionTypeStr = "ADD_REMOVE";
    	} else if(actionType==2){
    		actionTypeStr = "LOAD";
    	}
    	if(actionTypeStr == ""){
    		actionTypeStr = actionType.toString();
    	}		
    		
        return "StateEvent(" + sourceClassName + ", " + source + ", " + actionTypeStr + ", " + propertyName + ", " + _global.flamingo.getId(eventComp)+ ")";
	}
	/**
	 * getEventComp
	 * @return
	 */
	public function getEventComp() : AbstractComponent {
		return eventComp;
	}
}
