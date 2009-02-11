// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.


/** @component BaseButton
* A base class for a button with default behaviour
* @file flamingo/tpc/classes/flamingo/coregui/BaseButton.as  (sourcefile)
* @file flamingo/tpc/CommitButton.fla  (sourcefile)
* @file flamingo/tpc/CommitButton.swf (compiled component, needed for publication on internet)
*/


/** @tag <tpc:CommitButton>
* This tag defines a commit button instance. A click on it makes the edit bar commit the changes on the feature model to the server.
* @class flamingo.coregui.BaseButton extends AbstractComponent
* @hierarchy childnode of EditBar.
* @configstring tooltip toolti shown with button
* @example
	<tpc:EditBar id="editBar" left="523" top="4" listento="editMap" backgroundalpha="0" borderalpha="0">
		<tpc:CommitButton>
            <string id="tooltip" en="save edits" nl="bewerkingen opslaan"/>
        </tpc:CommitButton>
	</tpc:EditBar>
*/


import flamingo.coregui.*;

import flamingo.event.ActionEvent;
import flamingo.event.ActionEventListener;

class flamingo.coregui.BaseButton extends AbstractComponent {
    
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
            actionEventListener.onActionEvent(new ActionEvent(this, "Button", ActionEvent.CLICK));
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
