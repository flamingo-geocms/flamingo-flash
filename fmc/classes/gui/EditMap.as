/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component EditMap
* A component that draws feature geometries within a certain zoom extent and at a certain scale. 
* The edit map is also the component where the user draws a geometry when a new feature is created. 
* Features and their geometries exist within the feature model. Please refer to the GIS component.
* @file flamingo/fmc/classes/flamingo/gui/EditMap.as  (sourcefile)
* @file flamingo/fmc/EditMap.fla (sourcefile)
* @file flamingo/fmc/EditMap.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/classes/flamingo/gui/EditMapCircle.as (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapCreateGeometry.as  (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapFeature.as  (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapGeometry.as  (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapLayer.as  (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapLineString.as  (sourcefile)
* @file flamingo/fmc/classes/flamingo/gui/EditMapPolygon.as  (sourcefile)
*/

/** @tag <fmc:EditMap>
* This tag defines an edit map instance. An edit map must be registered as a listener to two components. 
* One is the feature model that keeps the feature geometries(GIS). The other is a map to inform the edit map about its current zoom extent. 
* The Map and EditMap components should be positioned exactly the same. 
* This can be accomplished by making them both child nodes of the same container.
* @class gui.EditMap extends AbstractComponent implements StateEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example
	<FLAMINGO>
		...
		<fmc:EditMap id="editMap"  left="210" top="40" bottom="bottom -30" right="right -218" listento="gis,map"/>
		...
		<fmc:PrintTemplate id="printTemplate1" ...>
         	...
			<fmc:Map id="printMap1" name="kaartbeeld" width="100%" height="100%" movequality="HIGH" configobject="map"/>
         	<fmc:EditMap id="editMap2" name="redlining"  width="100%" height="100%"  listento="gis,printMap1" editable="false"/>
		</fmc:PrintTemplate>	
	</FLAMINGO>
* @attr editable (true, false, default value: true) Whether or not map is editable, f.i. an EditMap in a PrintTemplate is mostly 
* not editable
*/

import gui.*;
import event.*;
import gismodel.GIS;
import gismodel.Layer;
import gismodel.CreateGeometry;
import core.AbstractComponent;

class gui.EditMap extends AbstractComponent implements StateEventListener {
    
    private var mask:MovieClip = null;
    private var gis:GIS = null;
	private var map:Object = null;
    private var tools:Object = null;
	private var editble:Boolean = true;
    private var editMapLayers:Array = null;
    private var editMapCreateGeometry:EditMapCreateGeometry = null;
    private var editMapCreateGeometryDepth:Number = 1001; // Assumes that there will never be more than 1000 layers at the same time.

	function setAttribute(name:String, value:String):Void {
		  if (name == "editable") {
			if(value=="false"){
            	editble = false;
			}
		 } 
	}
	
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
	   if (mask == null) {
            mask = createEmptyMovieClip("mMask", editMapCreateGeometryDepth + 1);
        } else {
            mask.clear();
        }
        mask.lineStyle(1, 0x000000, 100);
        mask.beginFill(0xFF0000);
        mask.moveTo(0, 0);
        mask.lineTo(width, 0);
        mask.lineTo(width, height);
        mask.lineTo(0, height);
        mask.endFill();
        setMask(mask);
        
        super.setBounds(x, y, width, height);
    }
    
    function init():Void {
        editMapLayers = new Array();
		gis=_global.flamingo.getComponent(listento[0]);
        map=_global.flamingo.getComponent(listento[1]);
		tools=_global.flamingo.getComponent(listento[2]);
        gis.addEventListener(this, "GIS", StateEvent.ADD_REMOVE, "layers");
        gis.addEventListener(this, "GIS", StateEvent.CHANGE, "createGeometry");
		_global.flamingo.addListener(this,tools,this);
		_global.flamingo.addListener(this,map,this);
        var layers:Array = gis.getLayers();
		
        var layer:Layer = null;
        for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
            if (layer.isVisible() && map.visible) {
                addEditMapLayer(layer);
            }
        }
    }
    
    function layout():Void {
        for (var i:String in editMapLayers) {
            EditMapLayer(editMapLayers[i]).setSize(__width, __height);
        }
        if (editMapCreateGeometry != null) {
            editMapCreateGeometry.setSize(__width, __height);
        }
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
		var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.ADD_REMOVE + "_layers") { // Removing is not supported at the moment, because we use this event only at init time.
            var layers:Array = AddRemoveEvent(stateEvent).getAddedObjects();
            var layer:Layer = null;
            for (var i:Number = 0; i < layers.length; i++) {
                layer = Layer(layers[i]);
                layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
                if (layer.isVisible() && map.visible) {
                    addEditMapLayer(layer);
                }
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_createGeometry") {
            if(editble){
				var createGeometry:CreateGeometry = gis.getCreateGeometry();
				
				if (createGeometry == null) {
					removeEditMapCreateGeometry();
				} else {
					addEditMapCreateGeometry(createGeometry);
				}
			}
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.CHANGE + "_visible") {
            var layer:Layer = Layer(stateEvent.getSource());
            if (layer.isVisible()) {
                addEditMapLayer(layer);
            } else {
                removeEditMapLayer(layer);
            }
        }
    }
    
    function getGIS():GIS {
        return gis;
    }
    
    private function addEditMapLayer(layer:Layer):Void {
        removeEditMapLayer(layer);
        var depth:Number = editMapCreateGeometryDepth - 1 - gis.getLayerPosition(layer);
        var initObject:Object = new Object();
        initObject["gis"] = gis;
		initObject["map"] = map;
        initObject["layer"] = layer;
        initObject["width"] = __width;
        initObject["height"] = __height;
		initObject["editble"] = editble;
        editMapLayers.push(attachMovie("EditMapLayer", "mEditMapLayer" + depth, depth, initObject));
    }
    
    private function removeEditMapLayer(layer:Layer):Void {
        var editMapLayer:EditMapLayer = null;
        for (var i:Number = 0; i < editMapLayers.length; i++) {
            editMapLayer = EditMapLayer(editMapLayers[i]);
            if (editMapLayer.getLayer() == layer) {
                editMapLayer.remove();
                editMapLayers.splice(i, 1);
                break;
            }
        }
    }
    
    private function addEditMapCreateGeometry(createGeometry:CreateGeometry):Void {
        removeEditMapCreateGeometry();
        var initObject:Object = new Object();
        initObject["map"] = map;
		initObject["gis"] = gis;
        initObject["createGeometry"] = createGeometry;
        initObject["width"] = __width;
        initObject["height"] = __height;
        editMapCreateGeometry = EditMapCreateGeometry(attachMovie("EditMapCreateGeometry", "mEditMapCreateGeometry", editMapCreateGeometryDepth, initObject));
    }
    
    private function removeEditMapCreateGeometry():Void {
        if (editMapCreateGeometry != null) {
            editMapCreateGeometry.remove();
            editMapCreateGeometry = null; // MovieClip.removeMovieClip does not nullify the reference.
        }
    }
	
	public function onSetTool(toolgroup:Object,tool:Object){
		var feature:gismodel.Feature = gis.getActiveFeature();
		if (feature != null && editMapCreateGeometry != null) {
			feature.getLayer().removeFeature(feature, true);
		}
		removeEditMapCreateGeometry();
	}
	
	public function onShow(map:Object){
		setVisibility(true);
	}
	
	public function onHide(map:Object){
		setVisibility(false);	
	}
	
	private function setVisibility(visible:Boolean):Void{
		var layers:Array = gis.getLayers();
		var layer:Layer = null;
		for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            if (layer.isVisible()) {
            	if(visible){
                	addEditMapLayer(layer);
            	} else {
            		removeEditMapLayer(layer);
            	}	
            }
         }
	}
}
