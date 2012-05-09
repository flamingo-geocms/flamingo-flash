/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
/** @component GIS 
* A component without a graphical user interface, that serves as a model for the editing components, such as the edit map and the edit legend. 
* The feature model keeps the layer and feature data for all editing components that listen to this model.
* A feature model is organized hierarchically. It consists of zero of more layers, which in turn consist of zero of more features per layer. 
* Every level in the hierarchy broadcasts its own events. 
* For example: the feature model about adding and removing of layers, a layer about changing its visibility, and a feature about a change in its property values.
* @file flamingo/fmc/classes/flamingo/gismodel/GIS.as  (sourcefile)
* @file flamingo/fmc/GIS.fla (sourcefile)
* @file flamingo/fmc/GIS.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/classes/flamingo/gismodel/Layer.as 
* @file flamingo/fmc/classes/flamingo/gismodel/Property.as 
* @file flamingo/fmc/classes/flamingo/gismodel/Feature.as
* @file flamingo/fmc/classes/flamingo/gismodel/Style.as
* @file flamingo/fmc/classes/flamingo/gismodel/CreateGeometry.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/GeometryTools.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/Geometry.as (hierachical classes for the geometry model -> used for digitizing polygons, boxes and circles)
* @file flamingo/fmc/classes/flamingo/geometrymodel/GeometryFactory.as 
* @file flamingo/fmc/classes/flamingo/geometrymodel/GeometryParser.as 
* @file flamingo/fmc/classes/flamingo/geometrymodel/LinearRing.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/LineSegment.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/LineString.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/LineStringFactory.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/Point.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/PointFactory.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/Polygon.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/PolygonFactory.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/Envelope.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/Circle.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/CircleFactory.as
*/

/** @tag <fmc:GIS>  
* This tag defines a feature model instance. A feature model can be registered as a listener of an authentication component. 
* If one or more layers within the feature model are protected with authorization, 
* the feature model must listen to the authentication component, which tells the feature model the roles of the current user.
* @class gismodel.GIS extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component. 
* @example
	<Flamingo>
		<fmc:GIS  id="gis" authentication="authentication" listento="authentication" updatemaps="map,printMap0">
		...
		</fmc:GIS>
	</Flamingo>	
* @attr authentication Reference to the authentication component. This value must be equal to the "listento".
* @attr updateMaps Comma seperate list of maps that should be updated after a commit to the server. Set this attribute when
* the Layers in your map(s) (LayerOGWMS, LayerArcIMS) are based on the same data as the (WFS)Layers in the GIS (EditMap)
* @attr geometryeditable Switch, value = "yes" or "no". If yes the editMap geometries for the layer corresponding to this gis
* are editable, i.e. the user can drag, add and remove vertices of the geometries.
* @attr alwaysdrawpoints always draw points at the end of the lines.
* @attr featuresDraggable True if polygons can be dragged, false if not. Defaults to false;
*/

/** @tag <fmc:Layer>
* This tag defines a layer instance.
* @class gismodel.Layer extends AbstractComposite
* @hierarchy childnode of GIS.
* @example
	<fmc:GIS  id="gis" authentication="authentication" listento="authentication" >
		<fmc:Layer title="Redlining" visible="true" labelpropertyname="app:label" roles="XDF56YZ">
		...
		</fmc:Layer>
		<fmc:Layer title="Luchthavens" visible="true" wfsurl="wfs::http://localhost:8080/flamingo-edit-server/services" 
			featuretypename="app:Airport" geometrytypes="Point" labelpropertyname="app:numFlights" roles="XDF56YT">
		...
		</fmc:Layer>
	</fmc:GIS>
* @attr title Name by which the layer is presented to the user, for example in the edit legend.
* @attr visible	(true, false, defaultvalue = false) Whether or not the layer's features be visible in the edit map.
* @attr wfsurl	URL to the server that serves the layer's features. Standard url format is used, with the exception that it is preceded by "wfs::". 
* Currently, only the OGC web feature service protocol is supported.
* @attr featuretypename	Name of the feature type that defines the layer's features on the server.
* @attr geometrytypes("Point", "LineString", "Polygon", "Circle", or a combination of these, comma-separated, no default value) 
* Geometry types that the user be able to draw when a new feature is created. 
* Every possible geometry type will appear as a create button in the edit legend.
* NB the geometrytype Circle not supported when editing WFS Layers, is only applicable for red-lining 
* @attr labelpropertyname Name of the property which value be shown on a label in the edit map, near the feature's geometry.
* @attr roles Names of the roles that are authorized to access the layer and its features. 
* If the current user has none of these roles, the layer will not be loaded in the feature model, 
* which means that it will not be visible in the map legend and the layer's features will not be visible in the edit map. 
* If no roles at all are configured for the layer, the layer is considered unprotected by authorization and will be loaded in the feature model regardless of the user's roles.
* @attr showmeasures default=false If showmeasures=true the length of a line, the area of a polygon and the radius of a circle will be shown for the active feature
* @attr version the version of the wfs service
* @attr srsname the name of the srs (EPSG:28992)
* @attr editable true if this layer is editable
*/

/** @tag <fmc:Property>
* This tag defines a layer's feature property instance.
* @class gismodel.Property extends AbstractComposite
* @hierarchy childnode of Layer.
* @example
	<fmc:Layer name="redlining" title="Redlining" visible="true" labelpropertyname="app:label" roles="XDF56YZ">
	 	<fmc:Property name="app:label" title="Label" type="MultiLine"/>
		...
	</fmc:Layer>
	<fmc:Layer title="Luchthavens" visible="true" wfsurl="wfs::http://localhost:8080/flamingo-edit-server/services" 
		featuretypename="app:Airport" geometrytypes="Point" labelpropertyname="app:numFlights" roles="XDF56YT">
            <fmc:Property name="app:numFlights" title="Aantal vluchten" type="DropDown:50,100,120,250,450,900,2000"/>
            <fmc:Property name="app:name" title="Naam" type="SingleLine" defaultvalue="YAYA"/>
            <fmc:Property name="app:description" title="Omschrijving" type="MultiLine" immutable="true"/>
* @attr name (no default value) Name of the property, this should correspond with the feature type property name on the server (incl. namespace).			
* @attr title (default value: "") Name by which the property is presented to the user, for example on a label in the edit properties component.
* @attr type ("SingleLine", "MultiLine", "DropDown", default value = "SingleLine") Presentation type of the property. 
* This type defines how the property will appear in the edit properties component. As a single line or multi line text input, 
* or a drop down list with fixed values.
* @attr defaultvalue Value that the property gets when a new feature is created.
* @attr immutable (true, false, default value: false) Whether or not the property value can be changed.
*/

/** @tag <fmc:Style>
* This tag defines a layer's feature style instance. All the layer's features will use this style to present themselves in the edit map.
* @class gismodel.Style extends AbstractComposite
* @hierarchy childnode of Layer.
* @example
	<fmc:Layer name="redlining" title="Redlining" visible="true" labelpropertyname="app:label" roles="XDF56YZ">
	 	...
		<fmc:Style fillcolor="0xFFCC00" fillopacity="30" strokecolor="0xFFCC00" strokeopacity="100"/>
	</fmc:Layer>
* @attr fillcolor (0x000000 – 0xFFFFFF, no default value) Fill color. Not applicable to point or line string geometries.
* @attr fillopacity	(0 – 100, no default value) Fill opacity. A value of 0 means completely transparent. Not applicable to point or line string geometries. If a feature's geometry is not completely transparent, a click on its fill will make the feature the active feature. If the geometry is completely transparent the user's mouse will click right through it.
* @attr strokecolor	(0x000000 – 0xFFFFFF, no default value) Stroke color.
* @attr strokeopacity (0 – 100, no default value) Stroke opacity. A value of 0 means completely transparent.
*/

/** @tag <fmc:GeometryProperty>
* This tag defines a layer's geometry feature property instance. 
* @class gismodel.GeometryProperty extends gismodel.Property
* @hierarchy childnode of Layer.
* @example
	<fmc:Layer name="redlining" title="Redlining" visible="true" labelpropertyname="app:numFlights" roles="XDF56YZ">
	 	<fmc:GeometryProperty name="app:puntkleur" propertytype="pointcolor" title="Puntkleur" type="ColorPalettePicker" defaultvalue="#AE1219" nrtileshor="2" nrtilesver="4" ingeometrytypes="Point">
		...
	</fmc:Layer>
	<fmc:Layer title="Luchthavens" visible="true" wfsurl="wfs::http://localhost:8080/flamingo-edit-server/services" 
		featuretypename="app:Airport" geometrytypes="Point" labelpropertyname="app:numFlights" roles="XDF56YT">
            <fmc:Property name="app:numFlights" title="Aantal vluchten" type="DropDown:50,100,120,250,450,900,2000"/>
            <fmc:Property name="app:name" title="Naam" type="SingleLine" defaultvalue="YAYA"/>
            <fmc:Property name="app:description" title="Omschrijving" type="MultiLine" immutable="true"/>
* @attr name (no default value) Name of the property this should correspond with the feature type property name on the server (incl. namespace).
* @attr propertytype (possible values: "pointcolor", "pointopacity", "pointicon", "pointtext", "strokecolor", "strokeopacity", "linestyle", "linedashstyle", "fillcolor", "fillopacity")
* Propertytype of the property, indicates the styling of the editMap geometry drawn by flash.
* @attr title (default value: "") Name by which the property is presented to the user, for example on a label in the edit properties component.
* @attr type (no default value, implemented are: "ColorPalettePicker", "OpacityInput", "OpacityPicker", "IconPicker", "PointTextEditor", "LineTypePicker", "DashStylePicker") Defines the user interface presentation type of input.
* This type defines how the property will appear in the edit properties component. As a popup picker 
* window, a line input editor, etc. 
* @attr defaultvalue Value that the property gets when a new feature is created. In case of the ColorPalettePicker and the IconPicker this should match the value attribute of an availableColor, resp. availableIcon.
* @attr immutable (true, false, default value: false) Whether or not the property value can be changed.
* @attr ingeometrytypes (Point,LineString,Polygon,Circle, default value: none) Specifies for which geometry types this property will be available.
* @attr nrtileshor The number of horizontal tiles in a pickwindow. Available in the pickers types.
* @attr nrtilesver The number of vertical tiles in a pickwindow.  Available in the pickers types.
* @attr minvalue (0,100) The minimum value. Available in "OpacityPicker" and "OpacityInput".
* @attr maxvalue (0,100) The maximum value. Available in "OpacityPicker" and "OpacityInput".
*/

/** @tag <fmc:availableColor>
* This tag defines the available colors of the geometry property "ColorPalettePicker" instance. 
* @class gismodel.AvailableColor extends PropertyItem
* @hierarchy childnode of GeometryProperty.
* @example
	<fmc:GeometryProperty name="app:puntkleur" propertytype="pointcolor" title="Puntkleur" type="ColorPalettePicker" defaultvalue="#AE1219" nrtileshor="2" nrtilesver="4" ingeometrytypes="Point">
		<fmc:availableColor title="kleur 1" name="color1" pickcolor="0x000000" value="#000000"/>
		<fmc:availableColor title="kleur 2" name="color2" pickcolor="0xAE1219" value="#AE1219"/>
		...
	</fmc:GeometryProperty>

* @attr title (default value: "") Name by which the property is presented to the user, for example on a label in the edit properties component.
* @attr name (no default value) Friendly name presented to the user.
* @attr pickcolor Color value used by flamingo in 0xffffff format.
* @attr value (String) Color value send to server.
*/

/** @tag <fmc:availableIcon>
* This tag defines the available icons of the geometry property "IconPicker" instance. 
* @class gismodel.AvailableIcon extends PropertyItem
* @hierarchy childnode of GeometryProperty.
* @example
	<fmc:GeometryProperty name="app:puntikoonurl" propertytype="pointicon" title="Puntikoon" type="IconPicker" defaultvalue="null" nrtileshor="4" nrtilesver="2" ingeometrytypes="Point">
		<fmc:availableIcon title="ovaal" name="icon2" pickiconurl="assets/icons/icon2.png" value="assets/icons/icon2.png"/>
		<fmc:availableIcon title="driehoek" name="icon3" pickiconurl="assets/icons/icon3.png" value="assets/icons/icon3.png"/>
		...
	</fmc:GeometryProperty>

* @attr title (default value: "") Name by which the property is presented to the user, for example on a label in the edit properties component.
* @attr name (no default value) Friendly name presented to the user.
* @attr pickiconurl Url of the icon used by flamingo to load the icon.
* @attr value (String) Url of the icon send to server.
*/

/** @tag <fmc:availableDashStyle>
* This tag defines the available styles of the geometry property "DashStylePicker" instance. 
* @class gismodel.AvailableDashStyle extends PropertyItem
* @hierarchy childnode of GeometryProperty.
* @example
	<fmc:GeometryProperty name="app:linedashstyle" title="Stippelstijl " propertytype="linedashstyle" type="DashStylePicker" defaultvalue="1.0" nrtileshor="1" nrtilesver="4" ingeometrytypes="LineString">
		<fmc:availableDashStyle title="Getrokken" name="solid" pickdashstyle="1.0" value="1.0"/>
		<fmc:availableDashStyle title="Stippel 1" name="dash2" pickdashstyle="5.0 5.0" value="5.0 5.0"/>
		<fmc:availableDashStyle title="Stippel 2" name="dash3" pickdashstyle="20.0 5.0 5.0 5.0" value="20.0 5.0 5.0 5.0"/>
		<fmc:availableDashStyle title="Stippel 3" name="dash4" pickdashstyle="20.0 5.0 5.0 5.0 14.0" value="20.0 5.0 5.0 5.0 14.0"/>
		...
	</fmc:GeometryProperty>

* @attr title (default value: "") Name by which the property is presented to the user, for example on a label in the edit properties component.
* @attr name (no default value) Friendly name presented to the user.
* @attr pickdashstyle String with the alternating pen on / pen off lengths. Values are of float type describing the length in pixels. Values are space delimmited.
* @attr value (String)  send to server.
*/

import gismodel.*;

import event.*;
import geometrymodel.Envelope;
import geometrymodel.Geometry;
import core.AbstractComponent;
import tools.Logger;
/**
* A component without a graphical user interface, that serves as a model for the editing components, such as the edit map and the edit legend. 
* The feature model keeps the layer and feature data for all editing components that listen to this model.
* A feature model is organized hierarchically. It consists of zero of more layers, which in turn consist of zero of more features per layer. 
* Every level in the hierarchy broadcasts its own events. 
 */
class gismodel.GIS extends AbstractComponent {
    
    private var authentication:MovieClip = null;
    private var layers:Array = null;
    private var updateMaps:Array = null;
    private var activeFeature:Feature = null;
    private var createGeometry:CreateGeometry = null;
    private var serversBusy:Number = 0;
	private var selectedGeometries:Array=null;
	
	private var extent:Envelope = null;
	private var ctrlKeyDown:Boolean = false;	//listener setting this value in editMap.as
	private var editRemoveVertexFlag:Boolean = false;
	private var createPointAtDistance:Boolean = false;
    
    private var stateEventDispatcher:StateEventDispatcher = null;
	
	private var editMapEditable:Boolean = false;
	private var alwaysDrawPoints:Boolean = true;
	private var selectedEditTool:String = null;
	
	private var featuresDraggable:Boolean = false;
    
	private var log:Logger=null;
	/**
	 * onLoad
	 */
	function onLoad(){	
		//execute the rest when the movieclip is realy loaded and in the timeline
		if (!_global.flamingo.isLoaded(this)) {
			_global.flamingo.loadCompQueue.executeAfterLoad(id, this, onLoad);
			return;
		}
		_global.flamingo.correctTarget(_parent, this);
		layers = new Array();
		super.onLoad();
		this.log = new Logger("gismodel.GIS",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
	}
	/**
	 * init
	 */
	function init():Void{
		stateEventDispatcher = new StateEventDispatcher();
    }
    /**
     * setAttribute
     * @param	name
     * @param	value
     */
    function setAttribute(name:String, value:String):Void {
		if (name == "updatemaps") {
			updateMaps = value.split(",");
        }
		if (name == "authentication") {
			authentication = _global.flamingo.getComponent(value);
        }
		if (name == "geometryeditable") {
			if (value.toLowerCase() == "yes" || value.toLowerCase() == "true") {
				editMapEditable = true;
			}
			else {
				editMapEditable = false;
			}
		}
		if (name == "alwaysdrawpoints") {
			if (value.toLowerCase() == "no" || value.toLowerCase() == "false") {
				alwaysDrawPoints = false;
			}
			else {
				alwaysDrawPoints = true;
			}
		}
		
		if (name == "featuresDraggable") {
			if (value.toLowerCase() == "no" || value.toLowerCase() == "false") {
				featuresDraggable = false;
			}
			else {
				featuresDraggable = true;
			}
		}
        super.setAttribute(name, value);
    }
	/**
	 * addLayerAsString
	 * @param	xmlString
	 */
    function addLayerAsString(xmlString:String) {
		var xml:XML = new XML(xmlString);		
		var xmlNode:XMLNode = xml.firstChild;
		var name:String = xmlNode.localName;		
		addComposite(name, xmlNode);
	}
	/**
	 * addComposite
	 * @param	name
	 * @param	xmlNode
	 */
    function addComposite(name:String, xmlNode:XMLNode):Void {
        if (name == "Layer") {
			var layer:Layer = new Layer(this,xmlNode);
            addLayer(layer);
        }
    }
    
    /**
     * addLayer
     * @param	layer
     */
    function addLayer(layer:Layer):Void {
        if (layer == null) {
            _global.flamingo.tracer("Exception in gismodel.GIS.addLayer()\nNo layer given.");
            return;
        }
        if (getLayer(layer.getName()) != null) {
            _global.flamingo.tracer("Exception in gismodel.GIS.addLayer(" + layer.getName() + ")\nGiven layer already exists.");
            return;
        }
        var roles:Array = layer.getRoles();
        var authorized:Boolean = false;
        //_global.flamingo.tracer("GIS addLayer roles = " + roles + " authentication = " + authentication);
        if (roles.length == 0) {
            authorized = true;
        }
        for (var i:String in roles) {
            if ((authentication != null) && (authentication.hasRole(roles[i]))) {
                authorized = true;
            }
        }
        //_global.flamingo.tracer("GIS addLayer authorized = " + authorized);
        if (!authorized) {
            return;
        }
        layers.push(layer);
        stateEventDispatcher.dispatchEvent(new AddRemoveEvent(this, "GIS", "layers", new Array(layer), null));
    }
	
	/**
	 * Sets the composite at the given layer
	 * @param	xmlString The string containing the xml to be setted at the layer
	 * @param	compositeName The string denoting the name of the composite to be setted
	 * @param	layerName the name of the layer. 
	*/
	public function setCompositeInLayer(xmlString: String, compositeName: String, layerName:String):Void {
		if (layerName == undefined){
			return;
		}
		var returnValue:Array=new Array();
		var layers:Array=this.getLayers();
		for (var i=0; i < layers.length; i++){
			var layer = Layer(layers[i]);
			if (layerName != null && layer.getName() == layerName) {
				var xml:XML = new XML(xmlString);		
				var xmlNode:XMLNode = xml.firstChild;
				layer.addComposite(compositeName, xmlNode);
			}
		}
	}
    /**
     * getLayers
     * @return
     */
    function getLayers():Array {
        return layers.concat();
    }
    /**
     * getLayer
     * @param	name
     * @return
     */
    function getLayer(name:String):Layer {
        var layer:Layer = null;
        for (var i:String in layers) {
            layer = Layer(layers[i]);
            if (layer.getName() == name) {
                return layer;
            }
        }
        return null;
    }
    /**
     * getLayerPosition
     * @param	layer
     * @return
     */
    function getLayerPosition(layer:Layer):Number {
		for (var i:Number = 0; i < layers.length; i++) {
            if (layers[i] == layer) {
                return i;
            }
        }
        return -1;
    }
	/**
	 * getEditMapEditable
	 * @return
	 */
	function getEditMapEditable():Boolean {
		return editMapEditable;
	}
	/**
	 * getAlwaysDrawPoints
	 * @return
	 */
	function getAlwaysDrawPoints():Boolean {
		return alwaysDrawPoints;
	}
	
	function getFeaturesDraggable():Boolean {
		return featuresDraggable;
	}
	/**
	 * getEnvelope
	 * @return
	 */
    function getEnvelope():Envelope {
    	var layer:Layer = layers[0];
    	 var minx:Number = layer.getEnvelope().getMinX();  
    	 var maxx:Number = layer.getEnvelope().getMaxX();
    	 var miny:Number = layer.getEnvelope().getMinY(); 
    	 var maxy:Number = layer.getEnvelope().getMaxY();
    	  
    	 for (var i:Number = 1; i < layers.length; i++) {
    	 	layer = layers[i];
    	 	if (layer.getEnvelope().getMinX() < minx) {
    	 		minx = layer.getEnvelope().getMinX();
    	 	}
    	 	if (layer.getEnvelope().getMaxX() > maxx) {
    	 		maxx = layer.getEnvelope().getMaxX();
    	 	}
    	 	if (layer.getEnvelope().getMinY() < miny) {
    	 		miny = layer.getEnvelope().getMinY();
    	 	}
    	 	if (layer.getEnvelope().getMaxY() > maxy) {
    	 		maxy = layer.getEnvelope().getMaxY();
    	 	}
    	 }	   	 
    	 return new Envelope(minx,miny,maxx,maxy);
    }
    /**
     * setActiveFeature
     * @param	activeFeature
     */
    function setActiveFeature(activeFeature:Feature):Void {
        if (this.activeFeature == activeFeature) {
            return;
        }
        
        var previousActiveFeature:Feature = this.activeFeature;
        this.activeFeature = activeFeature;
        
        stateEventDispatcher.dispatchEvent(new ChangeEvent(this, "GIS", "activeFeature", previousActiveFeature, this));
    }
    /**
     * getActiveFeature
     * @return
     */
    function getActiveFeature():Feature {
        return activeFeature;
    }
	/**
	 * Gets the active feature as a object (see Feature.toObject() for details of the object)
	 * @return
	 */
	public function getActiveFeatureAsObject():Object{
		if (this.getActiveFeature()!=null){
			return this.getActiveFeature().toObject();							
		}
		return null;
	}
	
	/**
	 * Get the features of layers  as objects(usable objects for javascript, see Feature#toObject for details of the object)
	 * @param	includePrefix include prefix in features (@see Feature#toObject)
	 * @param	layerName the name of the layer. If ommitted all features of all the layers will return. 
	 * Otherwise only the features from the layer with name== layername are returned.
	*/
	public function getFeaturesAsObject(includePrefix: Boolean, layerName:String):Array {
		if (layerName == undefined){
			layerName = null;
		}
		var returnValue:Array=new Array();
		var layers:Array=this.getLayers();
		for (var i=0; i < layers.length; i++){
			var layer = Layer(layers[i]);
			if (layerName==null || layer.getName() == layerName) {
				var lFeatures:Array=layer.getFeatures();
				for (var l=0; l < lFeatures.length; l++){
					var oFeature:Object=Feature(lFeatures[l]).toObject(includePrefix);
					if (oFeature!=undefined && oFeature!=null){					
						oFeature["flamingoLayerName"]=layer.getName();
						returnValue.push(oFeature);
					}
				}	
			}
		}
		return returnValue;
	}
	
	/**
	 * Get all features of all the layers in this EditMap as objects(usable objects for javascript, see Feature.toObject() for details of the object)
	 * @param	includePrefix include prefix in features (@see Feature#toObject)
	 * @deprecated use GIS#getFeaturesAsObject
	 */
	public function getAllFeaturesAsObject(includePrefix:Boolean) {
		return getFeaturesAsObject(includePrefix,null);
		
	}
	
	/**
	 * Set the value of a feature in a given layer
	 * @param	layerName the name of the layer.
	 * @param	featureId The id of the property
	 * @param	propertyName the name of the property
	 * @param	value Value of the property
	*/
	public function setFeatureValue(layerName:String, featureId: Number, propertyName:String, value:String):Void {
		if (layerName == undefined){
			return;
		}
		var layers:Array=this.getLayers();
		for (var i=0; i < layers.length; i++){
			var layer = Layer(layers[i]);
			if (layer.getName() == layerName) {
				var feature:Feature = layer.getFeature(featureId);
				if (value == "null") {
					value = "";
				}
				feature.setValue(propertyName, value);
			}
		}
	}
	
	/**
	 * Set the value of a feature in a given layer
	 * @param	layerName the name of the layer.
	 * @param	featureId The id of the property
	 * @param	propertyName the name of the property
	 * @param	value Value of the property
	*/
	public function getFeature(layerName:String, featureId: Number) : Object {
		if (layerName == undefined){
			return null;
		}
		var layers:Array=this.getLayers();
		for (var i=0; i < layers.length; i++){
			var layer = Layer(layers[i]);
			if (layer.getName() == layerName) {
				var feature:Feature = layer.getFeature(featureId);
				if (feature != null) {
					return feature.toObject();
				}
			}
		}
	}
	/**
	 * setCreateGeometry
	 * @param	createGeometry
	 */
    function setCreateGeometry(createGeometry:CreateGeometry):Void {
        this.createGeometry = createGeometry;
            
        stateEventDispatcher.dispatchEvent(new StateEvent(this, "GIS", StateEvent.CHANGE, "createGeometry", this));
    }
	/**
	 * getCreateGeometry
	 * @return
	 */    
    function getCreateGeometry():CreateGeometry {
        return createGeometry;
    }
	/**
	 * setSelectedEditTool
	 * @param	editToolSelected
	 */
	function setSelectedEditTool(editToolSelected:String):Void {
		this.selectedEditTool=editToolSelected;
		stateEventDispatcher.dispatchEvent(new StateEvent(this, "GIS", StateEvent.CHANGE, "editTool"));
	}
	/**
	 * getSelectedEditTool
	 * @return
	 */
	function getSelectedEditTool():String{
		return this.selectedEditTool;
	}
	/**
	 * addSelectedGeometry
	 * @param	selectedGeometry
	 */
	function addSelectedGeometry(selectedGeometry:SelectedGeometry){
		for (var i=0 ;i < selectedGeometries.length; i++){
			var s:SelectedGeometry=SelectedGeometry(selectedGeometries[i]);
			if (s.getId() == selectedGeometry.getId()){
				return;
			}
		}
		selectedGeometries.push(selectedGeometry);
		stateEventDispatcher.dispatchEvent(new ChangeEvent(this,"GIS","selectedGeometry",new Array(selectedGeometry),null));    
	}
	/**
	 * getSelectedGeometries
	 * @return
	 */
	function getSelectedGeometries():Array{
		return selectedGeometries;
	}
	/**
	 * clearSelectedGeometries
	 */
	function clearSelectedGeometries(){
		selectedGeometries= new Array();
		stateEventDispatcher.dispatchEvent(new ChangeEvent(this,"GIS","selectedGeometry",selectedGeometries,null));    
	}
	/**
	 * commit
	 */
    function commit():Void {
        for (var i:String in layers) {
            if (Layer(layers[i]).isTransactionProblematic4Server()) {
                _global.flamingo.tracer("Exception in gismodel.GIS.commit()\nAt least one of the layers, \"" + Layer(layers[i]).getName() +  "\", has problems to send its transaction to the server. Sending transactions is cancelled for all layers.");
                return;
            }
        }
        
        serversBusy += layers.length;
        for (var i:String in layers) {
            Layer(layers[i]).commit();
        }
    }
    /**
     * onServerReady
     */
    function onServerReady():Void {
        serversBusy--;
        if ((serversBusy == 0) && (updateMaps!=null)) {
        	for (var i:String in updateMaps) {
        		var map:Object = _global.flamingo.getComponent(updateMaps[i]); 
        		map.update(0, true);
        	}
            
        }
    }
    /**
     * addEventListener
     * @param	stateEventListener
     * @param	sourceClassName
     * @param	actionType
     * @param	propertyName
     */
    function addEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_extent")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.ADD_REMOVE + "_layers")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_activeFeature")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_createGeometry")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_editTool")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_buttonUpdate")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_geometryUpdate")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_geometryDragUpdate")
           ) {
            _global.flamingo.tracer("Exception in gismodel.GIS.addEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        stateEventDispatcher.addEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    /**
     * removeEventListener
     * @param	stateEventListener
     * @param	sourceClassName
     * @param	actionType
     * @param	propertyName
     */
    function removeEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_extent")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.ADD_REMOVE + "_layers")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_activeFeature")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_createGeometry")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_editTool")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_buttonUpdate")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_geometryUpdate")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "GIS_" + StateEvent.CHANGE + "_geometryDragUpdate")
           ) {
            _global.flamingo.tracer("Exception in gismodel.GIS.removeEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        stateEventDispatcher.removeEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
	/**
	 * getCreatePointAtDistance
	 * @return
	 */
	function getCreatePointAtDistance():Boolean {
        return createPointAtDistance;
    }
	/**
	 * setCreatePointAtDistance
	 * @param	createPointAtDistance
	 */
	function setCreatePointAtDistance(createPointAtDistance:Boolean):Void {
		this.createPointAtDistance = createPointAtDistance;
	}
	/**
	 * setCtrlKeyDown
	 * @param	_ctrlKeyDown
	 */
    function setCtrlKeyDown(_ctrlKeyDown:Boolean):Void {
		ctrlKeyDown = _ctrlKeyDown;
	}
	/**
	 * getCtrlKeyDown
	 * @return
	 */
	function getCtrlKeyDown():Boolean {
		return ctrlKeyDown;
	}
	/**
	 * setEditRemoveVertex
	 * @param	_editRemoveVertexFlag
	 */
	function setEditRemoveVertex(_editRemoveVertexFlag:Boolean):Void {
		if (editRemoveVertexFlag != _editRemoveVertexFlag) {
			stateEventDispatcher.dispatchEvent(new StateEvent(this, "GIS", StateEvent.CHANGE, "buttonUpdate",this));
		}
		editRemoveVertexFlag = _editRemoveVertexFlag;
	}
	/**
	 * getEditRemoveVertex
	 * @return
	 */
	function getEditRemoveVertex():Boolean {
		return editRemoveVertexFlag;
	}
	/**
	 * geometryUpdate
	 */
	function geometryUpdate():Void {
		stateEventDispatcher.dispatchEvent(new StateEvent(this, "GIS", StateEvent.CHANGE, "geometryUpdate",this));
	}
	/**
	 * geometryDragUpdate
	 */
	function geometryDragUpdate():Void {
		stateEventDispatcher.dispatchEvent(new StateEvent(this, "GIS", StateEvent.CHANGE, "geometryDragUpdate",this));
	}
	/**
	 * doGetFeatures
	 * @param	extent
	 */
	function doGetFeatures(extent:geometrymodel.Geometry){		
		var geomObject=extent;
		if (extent instanceof geometrymodel.Envelope){
			geomObject=Envelope(extent).toObject();
		}
		_global.flamingo.raiseEvent(this,"onGetFeatures",geomObject);
        var layer:Layer = null;
        for (var i:String in layers) {
            layer = Layer(layers[i]);
			layer.getFeatureWithGeometry(extent);			
		}		
	}
	/**
	 * Remove all features from all layers
	 */
	function removeAllFeatures(){
		var layer:Layer = null;
        for (var i:String in layers) {
            layer = Layer(layers[i]);
			layer.removeFeatures(layer.getFeatures(),false);			
		}		 
	}
	
	/**
	 * Remove all features for layer with name: 'name'
	 * @param	name the name of the layer
	 * @param	addOperation if set to true, a operation is created to remove features from service (if supported)
	 */
	function removeAllLayerFeatures(name:String, addOperation:Boolean) {
		var layer:Layer = null;
		for (var i:String in layers) {
			layer = Layer(layers[i]);
			if (layer.getName() == name) {
				layer.removeFeatures(layer.getFeatures(),addOperation);
			}
		}
	}
	
	/**
	 * Remove all features for layer with name: 'name'
	 * @param	layerName the name of the layer
	 * @param	featureId The id of the feature
	 * @param	addOperation if set to true, a operation is created to remove features from service (if supported)
	 */
	function removeLayerFeatureById(layerName:String, featureId:String, addOperation:Boolean) {
		var layer:Layer = null;
		for (var i:String in layers) {
			layer = Layer(layers[i]);
			if (layer.getName() == layerName) {
				var feat = layer.getFeature(featureId);
				if (feat != null) {
					layer.removeFeature(feat, addOperation);
				}
			}
		}
	}
	/**
	 * raiseFeatureRemoved
	 * @param	removedFeature
	 */
	function raiseFeatureRemoved(removedFeature:Feature){
		_global.flamingo.raiseEvent(this,"onFeatureRemoved",removedFeature.toObject());
	}
	/**
	 * raiseLayerVisibility
	 * @param	layername
	 * @param	visibility
	 */
	function raiseLayerVisibility(layername,visibility){
		_global.flamingo.raiseEvent(this,"onLayerSetVisibility",layername,visibility);
	}
	/**
	 * toString
	 * @return
	 */
    function toString():String {
        return "GIS()";
    }
    
	/*Events*/
    /**
	*onFeatureRemoved is raised when a feature is removed
    *removedFeature: the removed feature as a object so it can be accessed in js
	*/
	function onFeatureRemoved(removedFeature:Feature){}
	
	/**
	*onLayerSetVisibility is raised when one of the layers visibility is changed.
	*layername: the layername of the layer that is changed
	*visibility: true or false
	*/
	function onLayerSetVisibility(layername,visibility){}
	/**
	*onGetFeatures is raised when a getFeatures click is done with the getFeature button.
	*envelopeObject: the extent of the click.
	*/
	function onGetFeatures(envelopeObject){}
}
