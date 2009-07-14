// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.PatternPicker extends MovieClip implements ActionEventListener {
    
	private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	
	private var patternUrl:String = null;
	private var defaultvalue:String = null;
	
    function init():Void {
		tabEnabled = false;
		//trace("PatternPicker.as: init()");
		
		
		if (patternUrl == null || patternUrl == NaN || patternUrl == undefined){
			patternUrl = defaultvalue;
		}
		
		//set listener
		_parent._parent.setActionEventListener(this);
		
		drawGui();
    }
	
	function onActionEvent(actionEvent:ActionEvent):Void {
		var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "PropWindow_" + ActionEvent.OPEN) {
			trace("action event close popup window and/or store input value");
		}
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
	}
	
	function getValue():String {
		return patternUrl; 
    }
	
	function drawGui():Void{
		trace("PatternPicker.as: drawGui() this = "+this); 
	}
}
