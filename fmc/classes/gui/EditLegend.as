/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/


/** @component EditLegend
* A component that lists the layers in the geometry model. And shows whether its feature geometries are visible in the edit map. 
* A user can control this visibility using a check box. Every layer in the edit legend may have one or more buttons to bring 
* the edit map in "drawing mode" for the user to draw a geometry and create a new feature. Please refer to the GIS component.
* @file flamingo/fmc/classes/flamingo/gui/EditLegend.as  (sourcefile)
* @file flamingo/fmc/EditLegend.fla (sourcefile)
* @file flamingo/fmc/EditLegend.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:EditLegend>
* This tag defines an edit legend instance. The edit legend must be registered as a listener to an edit map. 
* Actually, the edit legend listens to the feature model underneath the edit map.
* @class gui.EditLegend extends AbstractComponent implements StateEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example
  <flamingo>
  	 <fmc:EditLegend id="editLegend" left="right -210" right="right -5" top="40" height="180" listento="editMap" expandable="true" popwindow="true"/>
	...
  </fmc:Container>
  ...
  Example 1: fixed button bar below edit legend checkbox and label
  <fmc:EditLegend id="editLegend" left="75%" top="60%" listento="editMap" expandable="false" popwindow="false" dx="22" dy="25" spacing="0"/>
  ...
  Example 2: Pop up window style Button bar.
  <fmc:EditLegend id="editLegend" left="75%" top="60%" listento="editMap" expandable="true" popwindow="true"/>
  ...
  Example 3: expandable button bar over legend checkbox and label.
  <fmc:EditLegend id="editLegend" left="75%" top="60%" listento="editMap" expandable="true" popwindow="false" spacing="0"/>
  ...
* @attr listento the id of the EditMap element
* @attr expandable (true, false, default value: true) Expands the buttonbar. If set to true it wil expand. If set to false the buttonbar is fixed
* @attr popwindow (true, false, default value: false) The buttonbar as a window with a configurable background and border. 
* @attr orientation (horizontal, vertical, default value: horizontal) Orientation of the buttonbar. 
* @attr dx (number default value: 22) Horizontal offset of the buttonbar.
* @attr dy (number default value: 5) Vertical offset of the buttonbar.
* @attr popUpWindowHideDelay (number default value: 1000) Delay in ms before the expanded buttonbar window hides.
* @attr popUpWindowDX (number default value: 15) Vertical offset of the expanded buttonbar window.
* @attr popUpWindowDY (number default value: 22) Horizontal offset of the expanded buttonbar window.
* @attr buttonWidth (number default value: 15) Button width in pixels.
* @attr buttonHeight (number default value: 15) Button height in pixels.
* @attr spacing (number default value: 5) Spacing between buttons in pixels.
* @attr backgroundpadding (number default value: 6) Space between buttons and the edge of the expanded buttonbar window.
* @attr backgroundfillcolor (number default value: 0xcccccc) Backgroundfillcolor of the expanded buttonbar window.
* @attr backgroundfillopacity (number default value: 100) Backgroundfillopacity of the expanded buttonbar window.
* @attr backgroundborderwidth (number default value: 2) Width of border inside the expanded buttonbar window.
* @attr backgroundborderspacing (number default value: 2) Spacing between background edge and border of the expanded buttonbar window.
* @attr backgroundbordercolor (number default value: 0xaaaaaa Color of border inside the expanded buttonbar window.
* @attr backgroundborderopacity (number default value: 100) Opacity of border inside the expanded buttonbar window.
*/

import gui.*;

import event.*;
import gismodel.GIS;
import gismodel.Layer;
import core.AbstractComponent;
import tools.Logger;

class gui.EditLegend extends AbstractComponent implements StateEventListener {
    
    private var gis:GIS = null;
    private var editLegendLayers:Array = null;
    private var legendHeight:Number = 25;
    private var buttonBarProperties:Object = new Object(); //associative array
	
	function setAttribute(name:String, value:String):Void {
		if(name == "expandable"){
			buttonBarProperties["expandable"] = (value.toLowerCase() == "true" ? true : false);
		}
		if(name == "popwindow"){
		  	buttonBarProperties["popwindow"] = (value.toLowerCase() == "true" ? true : false);
        }
		if(name == "dx"){
		  	buttonBarProperties["_x"] = Number(value);
        }
		if(name == "dy"){
		  	buttonBarProperties["_y"] = Number(value);
        }
		if(name == "buttonWidth"){
		  	buttonBarProperties["buttonWidth"] = Number(value);
        }
		if(name == "buttonHeight"){
		  	buttonBarProperties["buttonHeight"] = Number(value);
        }
		if(name == "spacing"){
		  	buttonBarProperties["spacing"] = Number(value);
        }
		if(name == "orientation"){
		  	buttonBarProperties["orientation"] = (value.toLowerCase() == "vertical" ? 1 : 0);//HORIZONTAL = 0, VERTICAL = 1
        }
		if(name == "popUpWindowHideDelay"){
		  	buttonBarProperties["popUpWindowHideDelay"] = Number(value);
        }
		if(name == "popUpWindowDX"){
		  	buttonBarProperties["popUpWindowDX"] = Number(value);
        }
		if(name == "popUpWindowDY"){
		  	buttonBarProperties["popUpWindowDY"] = Number(value);
        }
		if(name == "backgroundpadding"){
		  	buttonBarProperties["backgroundpadding"] = Number(value);
        }
		if(name == "backgroundfillcolor"){
			buttonBarProperties["backgroundfillcolor"] = Number(value);
        }
		if(name == "backgroundfillopacity"){
		  	buttonBarProperties["backgroundfillopacity"] = Number(value);
        }
		if(name == "backgroundborderwidth"){
		  	buttonBarProperties["backgroundborderwidth"] = Number(value);
        }
		if(name == "backgroundbordercolor"){
			buttonBarProperties["backgroundbordercolor"] = Number(value);
        }
		if(name == "backgroundborderopacity"){
		  	buttonBarProperties["backgroundborderopacity"] = Number(value);
        }
	}
	
    function init():Void {
		if (!_global.flamingo.isLoaded(listento[0],true)) {
			_global.flamingo.loadCompQueue.executeAfterLoad(listento[0], this, init);
			return;
		}
		var editMap = _global.flamingo.getComponent(listento[0]);
		gis = editMap.getGIS();
		//if gis not loaded yet, get the id of gis and wait till it's loaded.
		if (gis == null) {
			var gisId = _global.flamingo.getComponent(listento[0]).listento[0];
			_global.flamingo.loadCompQueue.executeAfterLoad(gisId, this, init);
			return;
		}
		//if gis not loaded yet
		if (!_global.flamingo.isLoaded(gis, true)) {
			_global.flamingo.loadCompQueue.executeAfterLoad(gis, this, init);
			return;
		}		
		editLegendLayers = new Array();
        
        gis.addEventListener(this, "GIS", StateEvent.ADD_REMOVE, "layers");
        
		var layers:Array = gis.getLayers();
		var layer:Layer = null;
		for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            addEditLegendLayer(layer);
        }
    }
    
    function layout():Void {
        for (var i:String in editLegendLayers) {
            EditLegendLayer(editLegendLayers[i]).setSize(__width, legendHeight);
        }
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.ADD_REMOVE + "_layers") { // Removing is not supported at the moment, because we use this event only at init time.
			var layers:Array = AddRemoveEvent(stateEvent).getAddedObjects();
            for (var i:Number = 0; i < layers.length; i++) {
                addEditLegendLayer(Layer(layers[i]));
            }
        }
    }
    
    private function addEditLegendLayer(layer:Layer):Void {
        var depth:Number = gis.getLayerPosition(layer);
        var initObject:Object = new Object();
        initObject["_y"] = depth * legendHeight;
        initObject["width"] = __width;
        initObject["height"] = legendHeight;
        initObject["gis"] = gis;
        initObject["layer"] = layer;
		initObject["buttonBarProperties"] = buttonBarProperties;
        editLegendLayers.push(attachMovie("EditLegendLayer", "mEditLegendLayer" + depth, depth, initObject));
    }
    
}
