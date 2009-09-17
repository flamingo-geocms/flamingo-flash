/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/


/** @component BaseButton
* A base class for a button with default behaviour
* @file flamingo/fmc/classes/flamingo/coregui/BaseButton.as  (sourcefile)
* @file flamingo/fmc/CommitButton.fla  (sourcefile)
* @file flamingo/fmc/CommitButton.swf (compiled component, needed for publication on internet)
*/


/** @tag <fmc:CommitButton>
* This tag defines a commit button instance. A click on it makes the edit bar commit the changes on the feature model to the server.
* @class coregui.BaseButton extends AbstractComponent
* @hierarchy childnode of EditBar.
* @configstring tooltip toolti shown with button
* @example
	<fmc:EditBar id="editBar" left="523" top="4" listento="editMap" backgroundalpha="0" borderalpha="0">
		<fmc:CommitButton>
            <string id="tooltip" en="save edits" nl="bewerkingen opslaan"/>
        </fmc:CommitButton>
	</fmc:EditBar>
*/


import coregui.*;
import event.ActionEvent;
import event.ActionEventListener;
import core.AbstractComponent;

class coregui.BaseButton extends AbstractComponent {
    
	private var id:Number = -1; // Set by init object.
    //private var tooltipText:String = "";
	private var tooltipText:String = null; // Set by init object.
    private var actionEventListener:ActionEventListener = null;
	private var actionEventListeners:Array = null;
    private var url:String = null;
    private var windowName:String = "_blank";
	private var thisObj:Object;
	private var selected:Boolean = false;
    
	//*** graphical buttonstates
	//frame 1: up
	//frame 2: over
	//frame 3: down
	//Optional:
	//frame 4: selected_up
	//frame 5: selected_over
	//frame 6: selected_down
	
	function BaseButton(){
		actionEventListeners = new Array();
		setActionEventListener(this.actionEventListener);
	}
	
    function init():Void {
        useHandCursor = false;
		
		//if value not set by init object overrule it
		if (tooltipText == null) {
			tooltipText = _global.flamingo.getString(this, "tooltip");
		}
    }
	
	function getID():Number {
        return id;
    }
    
    function setActionEventListener(actionEventListener:ActionEventListener):Void {
		actionEventListeners = new Array();	//delete former listeners!
		if (actionEventListener != null) { 
			actionEventListeners.push(actionEventListener);
		}
    }
	
	function addActionEventListener(actionEventListener:ActionEventListener):Void {
		if (actionEventListener != null) { 
			actionEventListeners.push(actionEventListener);
		}
    }
	
	function setSelectedState(selected:Boolean):Void {
		this.selected = selected;
		
		//update graphic
		if (selected) {
			if (_totalframes > 3) {
				gotoAndStop(4);		//selected_up
			}
		}
		else {
			gotoAndStop(1);			//up
		}
	}
    
	function getSelectedState():Boolean {
		return selected;
	}
	
    function onPress():Void {
        if (selected) {
			if (_totalframes > 5) {
				gotoAndStop(6);		//selected_down
			}
		}
		else {
			gotoAndStop(3);			//down
		}
		for (var i:Number=0; i<actionEventListeners.length; i++) {
			if (actionEventListeners[i] != null) {
				var actionEvent:ActionEvent = new ActionEvent(this, "Button", ActionEvent.CLICK);
				actionEventListeners[i].onActionEvent(actionEvent);
				var id:String =  _global.flamingo.getId(this);
				if(id != null){
					_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
				} 
			} else if (url != null) {
				getURL("javascript:openNewWindow('" + url + "', '" + windowName + "', 'width=500, height=400, top=50, left=50, toolbar=no, resizable=yes, scrollbars=yes')");
			}
		}
    }
    
    function onRollOver():Void {
        if (selected) {
			if (_totalframes > 4) {
				gotoAndStop(5);		//selected_over
			}
		}
		else {
			gotoAndStop(2);			//over
		}
	
		_global.flamingo.showTooltip(tooltipText, this);
    }
    
    function onRollOut():Void {
        if (selected) {
			if (_totalframes > 3) {
				gotoAndStop(4);		//selected_up
			}
		}
		else {
			gotoAndStop(1);			//up
		}
    }
    
    function onRelease():Void {
        if (selected) {
			if (_totalframes > 3) {
				gotoAndStop(4);		//selected_up
			}
		}
		else {
			gotoAndStop(1);			//up
		}
    }
    
    function onReleaseOutside():Void {
        if (selected) {
			if (_totalframes > 3) {
				gotoAndStop(4);		//selected_up
			}
		}
		else {
			gotoAndStop(1);			//up
		}
    }
}
