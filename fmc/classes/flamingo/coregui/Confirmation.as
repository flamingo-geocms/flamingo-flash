﻿// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

/** @component Confirmation
* A component that pops-up to ask the user for confirmation. It gives the user two options: confirm or deny.
* @file flamingo/tpc/classes/flamingo/coregui/Confirmation.as  (sourcefile)
* @file flamingo/tpc/Confirmation.fla (sourcefile)
* @file flamingo/tpc/Confirmation.swf (compiled component, needed for publication on internet)
* @file flamingo/tpc/Confirmation.xml (configurationfile, needed for publication on internet)
* @configstring question Question to ask the user for confirmation. For example: “Are you sure?”
* @configstring yes Text to appear on the “confirm” button.
* @configstring no Text to appear on the “deny” button.
*/

/** @tag <tpc:Confirmation>
* This tag defines a confirmation component instance. 
* A confirmation component listens to two other components: one is a veil and the other can be any component that is interested in a confirmation event. 
* The veil's visibility is automatically linked to the visibility of the confirmation component. 
* An example of a component interested in confirmation events is the edit bar. 
* When a “confirm” event reaches the edit bar, the edit bar continues to delete the active feature in the feature model. 
* A confirmation component should be placed in a window so that a component visible button can make it pop-up.
* @class flamingo.coregui.Confirmation extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component.
* @example
	<fmc:Window skin="g" top="300" left="500" width="290" height="180" canresize="false" canclose="true" visible="false">
        <string id="title" en="Confirm" nl="Bevestigen"/>
        <tpc:Confirmation id="confirmation" visible="false" listento="veil,editBar">
            <string id="question" en="Are you sure you want to remove the object?" nl="Weet u zeker dat u het object wilt verwijderen?"/>
            <string id="no" en="Cancel" nl="Annuleren"/>
        </tpc:Confirmation>
    </fmc:Window>
*/


import flamingo.coregui.*;

import flamingo.event.ActionEvent;
import flamingo.event.ActionEventListener;

import mx.controls.Button;
import mx.controls.Label;
import mx.utils.Delegate;

class flamingo.coregui.Confirmation extends AbstractComponent {
    
    private var veil:MovieClip = null;
    private var actionEventListener:ActionEventListener = null;
    
    function init():Void {
        veil = _global.flamingo.getComponent(listento[0]);
        actionEventListener = _global.flamingo.getComponent(listento[1]);
        		
        var initObject:Object = null;
        
        initObject = new Object();
        initObject["_x"] = 85;
        initObject["_y"] = 35;
        initObject["autoSize"] = "center";
        initObject["text"] = _global.flamingo.getString(this, "question");
        var label:Label = Label(attachMovie("Label", "mLabel", 0, initObject));
     //   label._x = 130 - (label._width / 2);
        
        initObject = new Object();
        initObject["_x"] = 20;
        initObject["_y"] = 90;
        initObject["label"] = _global.flamingo.getString(this, "yes");
        var yesButton:Button = Button(attachMovie("Button", "mYesButton", 1, initObject));
        yesButton.addEventListener("click", Delegate.create(this, onClickYesButton));
        
        initObject = new Object();
        initObject["_x"] = 150;
        initObject["_y"] = 90;
        initObject["label"] = _global.flamingo.getString(this, "no");
        var noButton:Button = Button(attachMovie("Button", "mNoButton", 2, initObject));
        noButton.addEventListener("click", Delegate.create(this, onClickNoButton));
	    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
        
        veil.setVisible(this.visible);
    }
    
    function onClickYesButton(eventObject:Object):Void {
        setVisible(false);
        
        actionEventListener.onActionEvent(new ActionEvent(this, "Confirmation", ActionEvent.CLICK));
    }
    
    function onClickNoButton(eventObject:Object):Void {
        setVisible(false);
    }
    
}