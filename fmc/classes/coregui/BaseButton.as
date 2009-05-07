/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
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
    
    private var tooltipText:String = "";
    private var actionEventListener:ActionEventListener = null;
    private var url:String = null;
    private var windowName:String = "_blank";
    
    function init():Void {
        useHandCursor = false;
        
        tooltipText = _global.flamingo.getString(this, "tooltip");
    }
    
    function setActionEventListener(actionEventListener:ActionEventListener):Void {
        this.actionEventListener = actionEventListener;
    }
    
    function onPress():Void {
        gotoAndStop(3);
        
        if (actionEventListener != null) {
        	var actionEvent:ActionEvent = new ActionEvent(this, "Button", ActionEvent.CLICK);
            actionEventListener.onActionEvent(actionEvent);
            var id:String =  _global.flamingo.getComponentID(this);
            if(id != null){
            	_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
            } 
        } else if (url != null) {
            getURL("javascript:openNewWindow('" + url + "', '" + windowName + "', 'width=500, height=400, top=50, left=50, toolbar=no, resizable=yes, scrollbars=yes')");
        }
    }
    
    function onRollOver():Void {
        gotoAndStop(2);
        
        _global.flamingo.showTooltip(tooltipText, this);
    }
    
    function onRollOut():Void {
        gotoAndStop(1);
    }
    
    function onRelease():Void {
        gotoAndStop(2);
    }
    
    function onReleaseOutside():Void {
        gotoAndStop(1);
    }
    
}
