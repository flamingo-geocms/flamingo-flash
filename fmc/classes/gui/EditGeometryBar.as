// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

import gui.*;
import core.AbstractComponent;

import event.*;
import coregui.BaseButton;
import coregui.ButtonBar;
import coregui.ButtonConfig;
import gismodel.GIS;
import gismodel.Layer;

class gui.EditGeometryBar extends AbstractComponent implements StateEventListener, ActionEventListener {
    
    private var gis:GIS = null;
	private var thisObj:Object;
    
    function init():Void {
        thisObj = this;
		gis = _global.flamingo.getComponent(listento[0]).getGIS();		//the second item is always the gis 
        drawButtonBar();
		this._visible=false;
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "buttonUpdate");
		var layers:Array = gis.getLayers();
        var layer:Layer = null;
        for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
        }
    }
    
    private function drawButtonBar():Void {
        var buttonConfigs:Array = new Array();
        buttonConfigs.push(new ButtonConfig("EditVertexGraphic", "Verwijder punt", this, null, null));
        var initObject:Object = new Object();
        initObject["buttonWidth"] = 20;
        initObject["buttonHeight"] = 20;
        initObject["orientation"] = ButtonBar.HORIZONTAL;
        initObject["spacing"] = 5;
		initObject["expandable"] = false;
        initObject["buttonConfigs"] = buttonConfigs;
        attachMovie("ButtonBar", "mButtonBar", 3, initObject);
    }
	
	function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
		if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            if (gis.getActiveFeature()==null){
				this._visible=false;
			}else{
				this._visible=true;
			}
        }
		else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_buttonUpdate") {
            //update button graphics
			thisObj.mButtonBar.mEditVertexGraphic0.setSelectedState(!gis.getEditRemoveVertex());			
        }
		else if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.CHANGE + "_visible") {
            var layer:Layer = Layer(stateEvent.getSource());
            if (layer.isVisible()) {
				if (gis.getActiveFeature() != null) {
					this._visible = true;
				}
			}
			else {
				this._visible = false;
			}
		}

		
    }

    function onActionEvent(actionEvent:ActionEvent):Void {
        var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "Button_" + ActionEvent.CLICK) {
            var buttonName:String = actionEvent.getSource()._name;
			if (buttonName.indexOf("EditVertexGraphic") > -1) {
				//toggle this button
				gis.setEditRemoveVertex(!gis.getEditRemoveVertex());
				//update button graphics
				actionEvent.getSource().setSelectedState(gis.getEditRemoveVertex());
            } 
        }
    }
    
}
