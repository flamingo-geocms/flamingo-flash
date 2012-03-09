// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import geometrymodel.*;


class gui.PointTextEditor extends MovieClip implements ActionEventListener {
    
	private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	
	private var mComponentTF:Object = null;
	private var htmlTextValue:String = null;
	private var defaultvalue:String = null;
    
    function init():Void {
		tabEnabled = false;
		
		var feature:Feature = gis.getActiveFeature();
		htmlTextValue = String(feature.getValue(propertyName));
		if (htmlTextValue == null || htmlTextValue == NaN || htmlTextValue == undefined){
			htmlTextValue = defaultvalue;
		}
		
		//set listener
		_parent._parent.setActionEventListener(this);
		
		drawGui();
    }
	
	function onActionEvent(actionEvent:ActionEvent):Void {
		var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "PropWindow_" + ActionEvent.OPEN) {
			processInputValue(this.mComponentTF.text);
		}
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
	}
	
	function getValue():String {
		processInputValue(mComponentTF.text);
		return String(htmlTextValue); 
    }
		
	function drawGui():Void{
		if(mComponentTF != null) {
			mComponentTF.removeMovieClip();
		}
		
		//draw number input box
		var initObject = new Object();
		initObject["enabled"] = this.enabled;
		initObject["tabIndex"] = this.tabIndex;
		initObject["tabEnabled"] = this.tabEnabled;
	
		mComponentTF = this.attachMovie("TextInput", "mComponentTF", 10, initObject);

		if (htmlTextValue == null || htmlTextValue == "null") {
			mComponentTF.text = "";
		} else {
			mComponentTF.text = htmlTextValue;
		}

		mComponentTF.setSize(100,22);
		mComponentTF.maxChars = 100;
		mComponentTF.editable = true;

		
		var thisObj:Object = this;
		
		var tiListener:Object = new Object();
		tiListener.handleEvent = function (evt_obj:Object){
			if (evt_obj.type == "enter"){
				processInputValue(thisObj.mComponentTF.text);
			} else if (evt_obj.type == "focusIn"){
				//close popupwindows from other properties
				thisObj._parent._parent.closeOtherComponentWindows(this);
			}
		}
		
		mComponentTF.addEventListener("enter", tiListener);
		mComponentTF.addEventListener("focusIn", tiListener);
	}

	
	private function processInputValue(htmlTextValueInput:String):Void{
		if (htmlTextValueInput != null || htmlTextValueInput != "") {
			//test if all characters in input string are spaces:
			var sum:Number = 0;
			for (var i:Number = 0; i < htmlTextValueInput.length; i++) {
				sum += htmlTextValueInput.charCodeAt(i);
			}
			if (sum == htmlTextValueInput.length * 32 && htmlTextValueInput.length > 0) {
				mComponentTF.text = "";
				htmlTextValueInput = "";
			}
			htmlTextValue = htmlTextValueInput;
			if (htmlTextValue == "null"){
				htmlTextValue = null;
			}
		}
	}
	
	
}
