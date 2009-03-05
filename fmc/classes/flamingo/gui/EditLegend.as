/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/


/** @component EditLegend
* A component that lists the layers in the geometry model. And shows whether its feature geometries are visible in the edit map. 
* A user can control this visibility using a check box. Every layer in the edit legend may have one or more buttons to bring 
* the edit map in “drawing mode” for the user to draw a geometry and create a new feature. Please refer to the GIS component.
* @file flamingo/fmc/classes/flamingo/gui/EditLegend.as  (sourcefile)
* @file flamingo/fmc/EditLegend.fla (sourcefile)
* @file flamingo/fmc/EditLegend.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:EditLegend>
* This tag defines an edit legend instance. The edit legend must be registered as a listener to an edit map. 
* Actually, the edit legend listens to the feature model underneath the edit map.
* @class flamingo.gui.EditLegend extends AbstractComponent implements StateEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example
  <flamingo>
  	 <fmc:EditLegend id="editLegend" left="right -210" right="right -5" top="40" height="180" listento="editMap"/>
	...
  </fmc:Container>	
*/



import flamingo.gui.*;

import flamingo.event.*;
import flamingo.gismodel.GIS;
import flamingo.gismodel.Layer;
import flamingo.core.AbstractComponent;

class flamingo.gui.EditLegend extends AbstractComponent implements StateEventListener {
    
    private var gis:GIS = null;
    private var editLegendLayers:Array = null;
    private var legendHeight:Number = 25;
    
    function init():Void {
        gis = _global.flamingo.getComponent(listento[0]).getGIS();
		
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
        editLegendLayers.push(attachMovie("EditLegendLayer", "mEditLegendLayer" + depth, depth, initObject));
    }
    
}
