// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

/** @tag <fmc:EditMapGetFeature>
* This tag defines an editMap get feature instance. An editMap and GIS must be registered
* as a listener to this component. This FMC draws a button. If pressed a WFS request to the server is made 
* for features within the boundary set by the geometry of the active feature. This boundary can be drawn by the user.
* @class gui.EditMapGetFeature extends AbstractComponent implements ActionEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example
	<FLAMINGO>
		...
		<fmc:EditMapGetFeature id="EditMapGetFeature"  left="2" top="2" bottom="bottom" listento="gis,editMap"/>
		...
	</FLAMINGO>
*/

import gui.*;
import core.AbstractComponent;

import event.*;
import coregui.BaseButton;
import coregui.ButtonBar;
import coregui.ButtonConfig;
import gismodel.GIS;
import geometrymodel.Geometry;

class gui.EditMapGetFeature extends AbstractComponent implements ActionEventListener {
    
    private var gis:GIS = null;
	private var editMap:Object = null;
	private var thisObj:Object;
    
    function init():Void {
        thisObj = this;
		gis = _global.flamingo.getComponent(listento[0]);
        editMap = _global.flamingo.getComponent(listento[1]);
		
		drawButtonBar();
		this._visible=true;
    }
	
    private function drawButtonBar():Void {
        var buttonConfigs:Array = new Array();
        buttonConfigs.push(new ButtonConfig("EditMapSelectFeatureButton", "Selecteer features in geometrie", this, null, null));
        var initObject:Object = new Object();
        initObject["buttonWidth"] = 20;
        initObject["buttonHeight"] = 20;
        initObject["orientation"] = ButtonBar.HORIZONTAL;
        initObject["spacing"] = 5;
		initObject["expandable"] = false;
        initObject["buttonConfigs"] = buttonConfigs;
        attachMovie("ButtonBar", "mButtonBar", 3, initObject);
    }
	
    function onActionEvent(actionEvent:ActionEvent):Void {
        var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "Button_" + ActionEvent.CLICK) {
            var buttonName:String = actionEvent.getSource()._name;
			if (buttonName.indexOf("EditMapSelectFeatureButton") > -1) {
				var geometry:Geometry = gis.getActiveFeature().getGeometry();
				
				//API event onEditMapGetFeature();
				_global.flamingo.raiseEvent(this,"onEditMapGetFeature",editMap,geometry.toWKT());
				
				if (geometry !=null){
					//perform getFeature WFS request with the geometry of the active feature
					gis.doGetFeatures(geometry);
				}
            } 
        }
    }

	/**
	* Dispatched when the layer receives features from the connector.
	* @param editMap:MovieClip a reference to the editMap.
	* @param activeFeatureWKT:String WKT of the active feature.
	*/
	public function onEditMapGetFeature(editMap:MovieClip, activeFeatureWKT:String):Void {}
}
