/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import event.*;

/**
 * event.ActionEvent
 */
class event.ActionEvent {
    
    static var CLICK:Number = 0;
    static var LOAD:Number = 1;
	static var OPEN:Number = 2;
    
    private var source:Object = null;
    private var sourceClassName:String = null;
    private var actionType:Number = -1;
    
	/**
	 * constructor
	 * @param	source
	 * @param	sourceClassName
	 * @param	actionType
	 */
    function ActionEvent(source:Object, sourceClassName:String, actionType:Number) {
        if (source == null) {
            trace("Exception in event.ActionEvent.<<init>>(" + sourceClassName + ")");
            return;
        }
        if (sourceClassName == null) {
            trace("Exception in event.ActionEvent.<<init>>(" + sourceClassName + ")");
            return;
        }
        
        this.source = source;
        this.sourceClassName = sourceClassName;
        this.actionType = actionType;
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
     * toString
     * @return
     */
    function toString():String {
        return "ActionEvent(" + sourceClassName + ", " + actionType + ")";
    }
    
}
