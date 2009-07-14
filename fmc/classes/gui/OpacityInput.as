// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import geometrymodel.*;


class gui.OpacityInput extends MovieClip implements ActionEventListener {
    
	private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = true;
	private var propertyName:String = null;
	
	private var opacity:Number = null;
	private var defaultvalue:String = null;
	private var minvalue:Number = 0;
	private var maxvalue:Number = 100;
	
	private var mComponentTI:Object = null;
	
    
    function init():Void {
		tabEnabled = false;
		
		var feature:Feature = gis.getActiveFeature();
		opacity = Number(feature.getValue(propertyName));
			
		if (opacity == null || opacity == NaN || opacity == undefined){
			opacity = Number(defaultvalue);
		}
		
		//set listener
		_parent._parent.setActionEventListener(this);
		
		drawGui();
    }
	
	function onActionEvent(actionEvent:ActionEvent):Void {
		var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "PropWindow_" + ActionEvent.OPEN) {
			processInputValue(this.mComponentTI.text);
		}
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
	}
	
	function getValue():String {
		processInputValue(this.mComponentTI.text);
		return String(opacity); 
    }
	
	function drawGui():Void{
		if(mComponentTI != null) {
			mComponentTI.removeMovieClip();
		}
		//draw number input box
		var initObject = new Object();
		initObject["enabled"] = this.enabled;
		initObject["tabIndex"] = this.tabIndex;
		initObject["tabEnabled"] = this.tabEnabled;
	
		mComponentTI = this.attachMovie("TextInput", "mComponentTI", 10, initObject);
				
		mComponentTI.text = String(opacity);
		mComponentTI.setSize(30,22);
		mComponentTI.maxChars = 3;
		mComponentTI.editable = true;

		
		var thisObj:Object = this;
		
		var tiListener:Object = new Object();
		tiListener.handleEvent = function (evt_obj:Object){
			trace("evt_obj.type = "+evt_obj.type);
			if (evt_obj.type == "enter"){
				processInputValue(thisObj.mComponentTF.text);
			}
			if (evt_obj.type == "focusIn"){
				//close popupwindows from other properties
				thisObj._parent._parent.closeOtherComponentWindows(this);
			}
		}
		
		mComponentTI.addEventListener("enter", tiListener);
		mComponentTI.addEventListener("focusIn", tiListener);
	}
	
	private function processInputValue(textValueInput:String):Void{
		if (textValueInput != null || textValueInput != "") {
			var opacityInput:Number = Number(textValueInput);
				if (opacityInput <= maxvalue && opacityInput >=minvalue) {
					opacity = opacityInput;
				} else {
					this.mComponentTI.text = String(this.opacity);
				}
		} else {
			this.mComponentTI.text = String(this.opacity);
		}
	}
}
