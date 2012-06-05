/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

/** @component EditMap
* A component that draws feature geometries within a certain zoom extent and at a certain scale. 
* The edit map is also the component where the user draws a geometry when a new feature is created. 
* Features and their geometries exist within the feature model. Please refer to the GIS component.
* @file flamingo/fmc/classes/gui/EditMap.as  (sourcefile)
* @file flamingo/fmc/EditMap.fla (sourcefile)
* @file flamingo/fmc/EditMap.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/classes/gui/EditMapCircle.as (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapCreateGeometry.as  (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapFeature.as  (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapGeometry.as  (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapLayer.as  (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapLineString.as  (sourcefile)
* @file flamingo/fmc/classes/gui/EditMapPolygon.as  (sourcefile)
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

/** @tag <fmc:Style>
* This tag defines a Style for the overlay when drawing a geometry
* @class gismodel.Style extends AbstractComposite
* @hierarchy childnode of EditMap.
* @example
	<fmc:EditMap .... >
	 	...
		<fmc:Style fillcolor="0xFFCC00" fillopacity="30" strokecolor="0xFFCC00" strokeopacity="100"/>
	</fmc:Layer>
* @attr fillcolor (0x000000 – 0xFFFFFF, Default: 0xFF0000) Fill color. Not applicable to point or line string geometries.
* @attr fillopacity	(0 – 100, Default: 30) Fill opacity. A value of 0 means completely transparent. Not applicable to point or line string geometries. If a feature's geometry is not completely transparent, a click on its fill will make the feature the active feature. If the geometry is completely transparent the user's mouse will click right through it.
* @attr strokecolor	(0x000000 – 0xFFFFFF, Default: 0x000000) Stroke color.
* @attr strokeopacity (0 – 100, Default: 100) Stroke opacity. A value of 0 means completely transparent.
*/

import gui.*;
import event.*;
import gismodel.GIS;
import gismodel.Layer;
import gismodel.CreateGeometry;
import gismodel.Style;
import geometrymodel.*;
import gismodel.Feature;
import coremodel.service.js.JsFeature;
import tools.Logger;

import core.AbstractComponent;

/**
 * EditMap
 */
class gui.EditMap extends AbstractComponent implements StateEventListener, core.PersistableComponent {
    
    private var mask:MovieClip = null;
    private var gis:GIS = null;
	private var map:Object = null;
    private var tools:Object = null;
	private var editable:Boolean = true;
    private var editMapLayers:Array = null;
    private var editMapCreateGeometry:EditMapCreateGeometry = null;
    private var editMapCreateGeometryDepth:Number = 1001; // Assumes that there will never be more than 1000 layers at the same time.
	private var editMapSelectFeature:EditMapSelectFeature=null;
	private var ctrlKeyDown:Boolean = false;
	private var log:Logger=null;
	private var style:Style=null;
	/**
	 * set Attribute
	 * @param	name
	 * @param	value
	 */
	function setAttribute(name:String, value:String):Void {
		 if (name == "editable") {
			if(value=="false"){
            	editable = false;
			}
		 } 
	}
	/**
	 * add Composite
	 * @param	name
	 * @param	xmlNode
	 */
	function addComposite(name:String, xmlNode:XMLNode):Void { 
        if (name == "Style") {
            style = new Style(xmlNode);
        }
    }
	/**
	 * set Bounds
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 */
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
    /**
     * init edit map
     */
    function init():Void {
		this.log = new Logger("gui.EditMap",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
		editMapLayers = new Array();
		if (!_global.flamingo.isLoaded(listento[0])){
			_global.flamingo.loadCompQueue.executeAfterLoad(listento[0], this, init);
			return;
		}
		
		gis = _global.flamingo.getComponent(listento[0]);
		map = _global.flamingo.getComponent(listento[1]);
		tools = _global.flamingo.getComponent(listento[2]);
		
        gis.addEventListener(this, "GIS", StateEvent.ADD_REMOVE, "layers");
        gis.addEventListener(this, "GIS", StateEvent.CHANGE, "createGeometry");		
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "editTool");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "geometryUpdate");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "geometryDragUpdate");
		_global.flamingo.addListener(this,tools,this);
		_global.flamingo.addListener(this,map,this);
        var layers:Array = gis.getLayers();
		
        var layer:Layer = null;
        for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
			layer.addEventListener(this, "Layer", StateEvent.ADD_REMOVE, "featuresFound");
			if (layer.isVisible() && map.visible) {
                addEditMapLayer(layer);
            }
        }
		
		if (gis.getEditMapEditable()) {
			//setup keyboard listener
			var thisObj:Object = this;
			var keyListener:Object = new Object();
			keyListener.onKeyDown = function() {
				if (Key.isDown(Key.CONTROL)){
					if (ctrlKeyDown == false) {
						ctrlKeyDown = true;
					}
					ctrlKeyDown = true;
					thisObj.gis.setCtrlKeyDown(true);
					thisObj.gis.setEditRemoveVertex(true);
				}
				else {
					ctrlKeyDown = false;
					thisObj.gis.setCtrlKeyDown(false);
					thisObj.gis.setEditRemoveVertex(false);
				}   
			};
			keyListener.onKeyUp = function() {
				if (Key.isDown(Key.CONTROL)){
					ctrlKeyDown = true;
					thisObj.gis.setCtrlKeyDown(true);
					thisObj.gis.setEditRemoveVertex(true);
				}
				else {
					if (ctrlKeyDown == true) {
						ctrlKeyDown = false;
					}
					ctrlKeyDown = false;
					thisObj.gis.setCtrlKeyDown(false);
					thisObj.gis.setEditRemoveVertex(false);
				}   
			};
			Key.addListener(keyListener);
		}
    }
    /**
     * layout
     */
    function layout():Void {
        for (var i:String in editMapLayers) {
            EditMapLayer(editMapLayers[i]).setSize(__width, __height);
        }
        if (editMapCreateGeometry != null) {
            editMapCreateGeometry.setSize(__width, __height);
        }
    }
    /**
     * event handler state
     * @param	stateEvent
     */
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
				layer.addEventListener(this, "Layer", StateEvent.ADD_REMOVE, "featuresFound");
                if (layer.isVisible() && map.visible) {
                    addEditMapLayer(layer);
                }
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_createGeometry") {
            if(editable){
				var createGeometry:CreateGeometry = gis.getCreateGeometry();
				
				if (createGeometry == null) {
					removeEditMapCreateGeometry();
				} else {
					addEditMapCreateGeometry(createGeometry);
				}
			}
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_editTool") {
			var editToolSelected:String = gis.getSelectedEditTool();
			if (editToolSelected == "selectFeature") {	
                addEditMapSelectFeature();
				gis.removeAllFeatures();
            } else if (editToolSelected==null){
				removeEditMapSelectFeature();
            }
		} else if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.CHANGE + "_visible") {
            var layer:Layer = Layer(stateEvent.getSource());
            if (layer.isVisible()) {
                addEditMapLayer(layer);
            } else {
                removeEditMapLayer(layer);
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.ADD_REMOVE + "_featuresFound") {
			var nrFeaturesFound:Number = null;
			if (AddRemoveEvent(stateEvent).getAddedObjects() != null) {
				nrFeaturesFound = Number(AddRemoveEvent(stateEvent).getAddedObjects().length);
			}
			//API event onFeatureFound();
			_global.flamingo.raiseEvent(this,"onFeatureFound",this,nrFeaturesFound);
		} else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            if (gis.getActiveFeature()!=null){
				//API event onActiveFeatureChange();
                _global.flamingo.raiseEvent(this,"onActiveFeatureChange",this,gis.getActiveFeature().toObject());
            }
		} else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_geometryUpdate") {
			if (gis.getActiveFeature()!=null){
				//API event onGeometryDrawUpdate();
				if (!(gis.getActiveFeature().getGeometry() instanceof Circle)){
					_global.flamingo.raiseEvent(this,"onGeometryDrawUpdate",this,gis.getActiveFeature().getGeometry().toWKT());
				}
			}
		}
		else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_geometryDragUpdate") {
			if (gis.getActiveFeature()!=null){
				//API event onGeometryDrawDragUpdate();
				if (!(gis.getActiveFeature().getGeometry() instanceof Circle)){
					_global.flamingo.raiseEvent(this,"onGeometryDrawDragUpdate",this,gis.getActiveFeature().getGeometry().toWKT());
				}
			}
		}
    }
    /**
     * get GIS
     * @return
     */	
    function getGIS():GIS {
        return gis;
    }
	
	/**
	 * Let the user draw the specified geometryType on the layer with specified layerName. 
	 * @param layerName The name of the layer
	 * @param geometryType The geometry type: Point, PointAtDistance, LineString, Polygon. Note: geometryType must correspond with the available types set in <fmc:Layer>
	 */
	function editMapDrawNewGeometry(layerName:String, geometryType:String):Void {
		var editMapLayer:EditMapLayer = null;
		var layer:Layer = null;
        for (var i:Number = 0; i < editMapLayers.length; i++) {
            editMapLayer = EditMapLayer(editMapLayers[i]);
            if (editMapLayer.getLayer().getName() == layerName) {
				layer = editMapLayer.getLayer();
                break;
            }
        }
		
		if (layer == null) {
			_global.flamingo.tracer("Exception in EditMap.editMapDrawNewGeometry()\nNo corresponding layer with layerName = "+layerName);
			return;
		}
		
		if (geometryType == "Point") {
			gis.setCreateGeometry(new CreateGeometry(layer, new PointFactory()));
		}
		else if (geometryType == "PointAtDistance") {
			gis.setCreateGeometry(new CreateGeometry(layer, new LineStringFactory()));
			gis.setCreatePointAtDistance(true);
		}
		else if (geometryType == "LineString") {
			gis.setCreateGeometry(new CreateGeometry(layer, new LineStringFactory()));
		}
		else if (geometryType == "Polygon") {
			gis.setCreateGeometry(new CreateGeometry(layer, new PolygonFactory()));
		}
		else if (geometryType == "Circle") {
			gis.setCreateGeometry(new CreateGeometry(layer, new CircleFactory()));
		}
		else {
			_global.flamingo.tracer("Exception in EditMap.editMapDrawNewGeometry()\nRequested geometryType not implemented.\ngeometryType = "+geometryType);
		}
	
	}
	
	/**
	 * Adds the specified featureObject to the layer with specified layerName and makes it the active feature. 
	 * @param layerName The name of the layer
	 * @param featureObject Javascript object with wkt describing the feature.
	 */
	function addFeature(layerName:String, featureObject:Object):Void {
		//haal layer op met layerName
		var editMapLayer:EditMapLayer = null;
		var layer:Layer = null;
        for (var i:Number = 0; i < editMapLayers.length; i++) {
            editMapLayer = EditMapLayer(editMapLayers[i]);
            if (editMapLayer.getLayer().getName() == layerName) {
				layer = editMapLayer.getLayer();
                break;
            }
        }
		
		if (layer == null) {
			_global.flamingo.tracer("Exception in EditMap.addFeature()\nNo corresponding layer with layerName = "+layerName);
			return;
		}
		
		//check if serviceFeature exists
		var idInObj:String;
		for (var i in featureObject){
			if (i=="id"){
				idInObj=featureObject[i];
				break;
			}
		}
		var featureFound:Feature = layer.getFeature(idInObj);
		if (featureFound != null){
			//update existing feature
			//_global.flamingo.tracer("TRACE in EditMap.addFeature()\nFeature with id = "+idInObj+" exist and will be updated.");
			layer.removeFeature(featureFound, false);
		} 
		
		//create new JsFeature with featureObject and add it to the layer
		var jsFeature:JsFeature= new JsFeature(featureObject,layer.getServiceLayer());
		if (jsFeature != null) {
			layer.addFeature(jsFeature);	//the feature is made active by the postAction in Layer.as addFeature().
		} else {
			_global.flamingo.tracer("Exception in EditMap.addFeature()\n JsFeature is <<null>>. Can not add it to layer with layerName = "+layerName);
		}
	}
	
	/**
	 * Draws the specified geometryType on the layer with specified layerName. 
	 * @param layerName The name of the layer
	 * @param geometryType The geometry type: Point, PointAtDistance, LineString, Polygon. Note: geometryType must correspond with the available types set in <fmc:Layer>
	 * @param coordinatePairs Array with the coordinate pairs
	 */
	function editMapCreateNewGeometry(layerName:String, geometryType:String, coordinatePairs:Array):Void {
		var editMapLayer:EditMapLayer = null;
		var layer:Layer = null;
        for (var i:Number = 0; i < editMapLayers.length; i++) {
            editMapLayer = EditMapLayer(editMapLayers[i]);
            if (editMapLayer.getLayer().getName() == layerName) {
				layer = editMapLayer.getLayer();
                break;
            }
        }
		
		if (layer == null) {
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nNo corresponding layer with layerName = "+layerName);
			return;
		}
		
		if (coordinatePairs == null) {
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nNo point coordinatepairs specified = "+coordinatePairs);
			return;
		}
				
        if (geometryType == "Point" || geometryType == "PointAtDistance") {
			//create point geometry & add it as a feature to the layer
			var geometry:Geometry = new Point(coordinatePairs[0], coordinatePairs[1]);
			layer.addFeature(geometry, true);
			
			_global.flamingo.raiseEvent(this,"onGeometryDrawFinished",this,gis.getActiveFeature().getGeometry().toWKT());			
			gis.setCreateGeometry(null);
		} else if (geometryType == "LineString") {
			/*
			NOTE the code below does not work yet!
			
			//create linestring geometry & add it as a feature to the layer
			var points:Array = null;
			var x:Number = 0;
			var y:Number = 0;
			for (var j:Number = 0; j < coordinatePairs.length; j=j+2) {
                x = Number(coordinatePairs[j]);
                y = Number(coordinatePairs[j+1]);
                points.push(new geometrymodel.Point(x, y));
				//_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nCreate LineString with x = "+x+"  y = "+y+"   j = "+j);
				//_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nCreate LineString with points = "+points.toString());
            }
			//trace("EditMap.as: editMapCreateNewGeometry(): points = "+points);
			//_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nCreate LineString with coordinatePairs = "+coordinatePairs);
			//_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nCreate LineString with points = "+points.toString());
			if (points!=null){
				var geometry:Geometry = new LineString(points);
				layer.addFeature(geometry, true);
				_global.flamingo.raiseEvent(this,"onGeometryDrawFinished",this,gis.getActiveFeature().getGeometry().toWKT());			
				gis.setCreateGeometry(null);
			} else{
				_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nNo points for the creation of LineString geometry. \npoints = "+points.toString());
			}
		
			*/
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nRequested geometryType not implemented.\ngeometryType = "+geometryType);
		} else if (geometryType == "Polygon") {
			/*
			NOTE the code below does not work yet!
			
			//create polygon geometry & add it as a feature to the layer
			var points:Array = null;
			var x:Number = 0;
			var y:Number = 0;
			for (var j:Number = 0; j < coordinatePairs.length; j=j+2) {
                x = Number(coordinatePairs[j]);
                y = Number(coordinatePairs[j+1]);
                points.push(new geometrymodel.Point(x, y));
            }
			var geometry:Geometry = new Polygon(new LinearRing(points));
			layer.addFeature(geometry, true);
			trace("onGeometryDrawFinished");
			_global.flamingo.raiseEvent(this,"onGeometryDrawFinished",this,gis.getActiveFeature().getGeometry().toWKT());			
			gis.setCreateGeometry(null);
			*/
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nRequested geometryType not implemented.\ngeometryType = "+geometryType);
		} else if (geometryType == "Circle") {
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nRequested geometryType not implemented.\ngeometryType = "+geometryType);
		} else {
			_global.flamingo.tracer("Exception in EditMap.editMapCreateNewGeometry()\nRequested geometryType not implemented.\ngeometryType = "+geometryType);
		}
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
		initObject["editable"] = (editable && layer.getEditable());		
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
		if (style!=null){
			initObject["style"]= style;
		}
        editMapCreateGeometry = EditMapCreateGeometry(attachMovie("EditMapCreateGeometry", "mEditMapCreateGeometry", editMapCreateGeometryDepth, initObject));
    }
	/**
	 * Add the editMapSelectFeature component to select a geometry.
	 */
	private function addEditMapSelectFeature():Void {
		var initObject:Object = new Object();
        initObject["map"] = map;
		initObject["gis"] = gis;
		initObject["width"] = __width;
        initObject["height"] = __height;
        editMapSelectFeature = EditMapSelectFeature(attachMovie("EditMapSelectFeature", "mEditMapSelectFeature", 2000, initObject));
	}
	/**
	 * Remove the editMapSelectFeature component to select a geometry.
	 */
    private function removeEditMapSelectFeature():Void {
        if (editMapSelectFeature != null) {
            editMapSelectFeature.remove();
            editMapSelectFeature = null; // MovieClip.removeMovieClip does not nullify the reference.
        }
    }
    /**
	 * Removes all features from all the layers for this editmap
	 */
	public function removeAllFeatures():Void{
		var layers:Array=gis.getLayers();
		for (var i=0; i < layers.length; i++){
			var layer=Layer(layers[i]);
			layer.removeFeatures(layer.getFeatures(),false);
		}
	}
	/**
	 * Removes the editmapCreateGeometry, edit stops.
	 */
    private function removeEditMapCreateGeometry():Void {
        if (editMapCreateGeometry != null) {
            editMapCreateGeometry.remove();
            editMapCreateGeometry = null; // MovieClip.removeMovieClip does not nullify the reference.
        }
    }
	/**
	* Get all features of all the layers in this EditMap as objects(usable objects for javascript, see Feature.toObject() for details of the object)
	* @deprecated use GIS.getAllFeaturesAsObject(
	*/
	public function getAllFeaturesAsObject(includePrefix: Boolean):Array{
		return gis.getAllFeaturesAsObject(includePrefix);
	}
	/**
	 * When a new tool is set.
	 * @param	toolgroup
	 * @param	tool
	 */
	public function onSetTool(toolgroup:Object,tool:Object){
		var feature:gismodel.Feature = gis.getActiveFeature();
		if (feature != null && editMapCreateGeometry != null) {
			feature.getLayer().removeFeature(feature, true);
		}
		removeEditMapCreateGeometry();
	}
	/**
	 * on Show
	 * @param	map
	 */
	public function onShow(map:Object){
		setVisibility(true);
	}
	/**
	 * on Hide
	 * @param	map
	 */
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
	/**
	 * Gets the active feature as a object (see Feature.toObject() for details of the object)
	 */
	public function getActiveFeature():Object{
		var returnValue:Object = new Object();
		if (gis!=undefined || gis!=null){
			if (gis.getActiveFeature()!=null){
				var returnObject= gis.getActiveFeature().toObject();
				return returnObject;
			}
		}
		return null;
	}
	/**
	 * get Map
	 * @return
	 */
	public function getMap():Object{
		return map;
	}
	/**
	 * get CFullExtent
	 * @return
	 */
	public function getCFullExtent():Object{
		return _global.flamingo.getComponent(listento[0]).getCFullExtent();

	}
	/**
	 * get CurrentExtent
	 * @return
	 */
	public function getCurrentExtent():Object{
		return _global.flamingo.getComponent(listento[0]).getCurrentExtent();

	}
	/**
	 * move To Extent
	 * @param	extendedExtent
	 */
	public function moveToExtent(extendedExtent:Object):Void{
		_global.flamingo.getComponent(listento[0]).moveToExtent(extendedExtent);
	}
	
	/**
	 * Provide the state of EditMap to the component responsible for storing the viewer state
	 * @param document:XML object to execute createElement calls, do not change it
	 * @param node:XMLNode node to be filled with the state of EditMap
	 */
	public function persistState (document: XML, rootnode: XMLNode): Void {
		var features:Array;
		features = getAllFeaturesAsObject(true);
		for (var i:Number=0; i < features.length; i++){
			var fNode:XMLNode = document.createElement("feature_" + i.toString());
			var feature:Object = features[i];
			for (var prop:String in feature) {
				var propNode:XMLNode = document.createElement("Property");
				propNode.attributes.name = prop;
				propNode.attributes.isnull = "false";
				if (feature[prop] == undefined) {
					propNode.attributes.isnull = "true";
				}
				var propText:XMLNode = document.createTextNode(feature[prop]);				
				propNode.appendChild(propText);
				fNode.appendChild(propNode);
			}
			rootnode.appendChild(fNode);
		}
	}
	
	/**
	 * Restore the state of EditMap as saved with persistState()
	 * @param node:XMLNode node containing the saved state
	 */
	public function restoreState (node: XMLNode): Void {
		var features:Array = node.childNodes;
		for (var i:Number=0; i < features.length; i++) {
			var feature:Object = new Object();
			var props:Array = features[i].childNodes;
			for (var j:Number=0; j < props.length; j++) {
				var propNode:XMLNode = props[j],
					propName:String = propNode.attributes.name;
				if (propNode.attributes.isnull == "true") {
					feature[propName] = undefined;
				} else {
					feature[propName] = propNode.firstChild.nodeValue;
				}
			}
			this.addFeature(feature["flamingoLayerName"], feature);
		}
	}
	
	/**
	* Dispatched when the layer receives features from the connector.
	* @param editMap:MovieClip a reference to the editMap.
	* @param nrFeaturesFound:Number number of features found.
	*/
	public function onFeatureFound(editMap:MovieClip, nrFeaturesFound:Number):Void {}
	//
	/**
	* Dispatched when the active feature is changed.
	* @param editMap:MovieClip a reference to the editMap.
	* @param activeFeature:Object the active feature as object.
	*/
	public function onActiveFeatureChange(editMap:MovieClip, activeFeature:Object):Void {}
	//
	/**
	* Dispatched when drawing or editing of the geometry is finished.
	* @param editMap:MovieClip a reference to the editMap.
	* @param activeFeatureWKT:String WKT of the active feature.
	*/
	public function onGeometryDrawUpdate(editMap:MovieClip, activeFeatureWKT:String):Void {}
	//
	/**
	* Dispatched when dragging is finished during drawing or editing of the geometry.
	* @param editMap:MovieClip a reference to the editMap.
	* @param activeFeatureWKT:String WKT of the active feature.
	*/
	public function onGeometryDrawDragUpdate(editMap:MovieClip, activeFeatureWKT:String):Void {}	
}
