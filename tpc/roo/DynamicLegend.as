/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component DynamicLegend 
* 
* @file flamingo/tpc/roo/DynamicLegend.as  (sourcefile)
* @file flamingo/tpc/roo/DynamicLegend.fla (sourcefile)
* @file flamingo/tpc/roo/DynamicLegend.swf (compiled component, needed for publication on internet)

*/

/** @tag <roo:DynamicLegend>  
* This tag defines ..
* @class flamingo.gismodel.DynamicLegend extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component. 
* @example
	<Flamingo>
		
	</Flamingo>	
* @attr 
* @attr 
*/

/** @tag <tpc:Layer>
* This tag defines a layer instance.
* @class flamingo.gismodel.Layer extends AbstractComposite
* @hierarchy childnode of GIS.
* @example
	<tpc:GIS  id="gis" authentication="authentication" listento="authentication" >
		<tpc:Layer title="Redlining" visible="true" labelpropertyname="app:label" roles="XDF56YZ">
		...
		</tpc:Layer>
		<tpc:Layer title="Luchthavens" visible="true" wfsurl="wfs::http://localhost:8080/flamingo-edit-server/services" 
			featuretypename="app:Airport" geometrytypes="Point" labelpropertyname="app:numFlights" roles="XDF56YT">
		...
		</tpc:Layer>
	</tpc:GIS>
* @attr title Name by which the layer is presented to the user, for example in the edit legend.
* @attr visible	(true, false, defaultvalue = false) Whether or not the layer's features be visible in the edit map.
* @attr wfsurl	URL to the server that serves the layer's features. Standard url format is used, with the exception that it is preceded by “wfs::”. 
* Currently, only the OGC web feature service protocol is supported.
* @attr featuretypename	Name of the feature type that defines the layer's features on the server.
* @attr geometrytypes(“Point”, “LineString”, “Polygon”, “Circle”, or a combination of these, comma-separated, no default value) 
* Geometry types that the user be able to draw when a new feature is created. 
* Every possible geometry type will appear as a create button in the edit legend.
* NB the geometrytype Circle not supported when editing WFS Layers, is only applicable for red-lining 
* @attr labelpropertyname Name of the property which value be shown on a label in the edit map, near the feature's geometry.
* @attr roles Names of the roles that are authorized to access the layer and its features. 
* If the current user has none of these roles, the layer will not be loaded in the feature model, 
* which means that it will not be visible in the map legend and the layer's features will not be visible in the edit map. 
* If no roles at all are configured for the layer, the layer is considered unprotected by authorization and will be loaded in the feature model regardless of the user's roles.
*/

import mx.controls.CheckBox;
import mx.utils.Delegate;

import roo.AbstractComponent;
import roo.FeatureType;
import roo.WhereClause;
import roo.DynamicLegendItem;

class roo.DynamicLegend extends AbstractComponent {
    
    private var dynamik:Boolean = true;
    private var graphicWidth:Number = 25;
    private var graphicHeight:Number = 12;
    private var horiSpacing:Number = 100;
    private var vertiSpacing:Number = 3;
    private var fileURL:String = null;
    private var wmsURL:String = null;
    private var wfsURL:String = null;
    private var dynamicLegendItems:Array = null;
    private var layoutNeeded:Boolean = false;
    
    function onLoad():Void {
        super.onLoad();
        
        addCheckBox();
        var refreshId:Number = setInterval(this, "layout", 1000);        
    }
    
    function setAttribute(name:String, value:String):Void {
        //_global.flamingo.tracer("DynamicLegend.setAttribute, name = " + name + " value = " + value);
        if (name == "horispacing") {
            horiSpacing = Number(value);
        } else if (name == "vertispacing") {
            vertiSpacing = Number(value);
        } else if (name == "fileurl") {
            fileURL = value;
        } else if (name == "wmsurl") {
            wmsURL = value;
        } else if (name == "wfsurl") {
            wfsURL = value;
        }
    }
    
    function addComponent(name:String, value:XMLNode):Void {
        if (name == "tpc:DynamicLegendLayer") {
            addDynamicLegendLayer(value.attributes["listento"].split(","), value.attributes["graphicuri"], value.attributes["title"], value.attributes["featuretype"], value.attributes["whereclause"]);
        } else if (name == "tpc:DynamicLegendHeading") {
            addDynamicLegendHeading(value.attributes["listento"], value.attributes["title"]);
        }
    }
    
    function getMap():String {
        return listento[0];
    }
    
    function isDynamic():Boolean {
        return dynamik;
    }
    
    function getGraphicWidth():Number {
        return graphicWidth;
    }
    
    function getGraphicHeight():Number {
        return graphicHeight;
    }
    
    function getFileURL():String {
        return fileURL;
    }
    
    function getWMSURL():String {
        return wmsURL;
    }
    
    function getWFSURL():String {
        return wfsURL;
    }
    
    private function addCheckBox():Void {
        var initObject:Object = new Object();
        initObject["_x"] = graphicWidth / 2 - 8;
        initObject["_y"] = graphicHeight - 8;
        initObject["label"] = "toon alles";
        initObject["labelPlacement"] = "right";
        initObject["selected"] = false;
        var checkBox:CheckBox = CheckBox(attachMovie("CheckBox", "mCheckBox", getNextHighestDepth(), initObject));
        checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
        checkBox.setStyle("fontSize", 11);
    }
    
    function onClickCheckBox(eventObject:Object):Void {
        dynamik = !eventObject.target.selected;
        
        for (var i:Number = 0; i < dynamicLegendItems.length; i++) {
            DynamicLegendItem(dynamicLegendItems[i]).setVisible();
        }
        this.layoutNeeded = true;
    }
    
    private function addDynamicLegendLayer(layers:Array, graphicURI:String, title:String, featureTypeString:String, whereClauseString:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["filterLayer"] = listento[1];
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["graphicURI"] = graphicURI;
        initObject["title"] = title;
        var split:Array = featureTypeString.split(";");
        initObject["featureType"] = new FeatureType(split[0], split[1], split[2]);
        if (whereClauseString != null) {
            split = whereClauseString.split(";");
            initObject["whereClause"] = new WhereClause(split[0], split[1], WhereClause.EQUALS);
        }
        dynamicLegendItems.push(attachMovie("DynamicLegendLayer", "mDynamicLegendLayer" + depth, depth, initObject));
    }
    
    private function addDynamicLegendHeading(layers:String, title:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["title"] = title;
        dynamicLegendItems.push(attachMovie("DynamicLegendHeading", "mDynamicLegendHeading" + depth, depth, initObject));
    }
    
    //function onSetVisible() {
    //    _global.flamingo.tracer("onSetVisible, arguments = " + arguments);
    //}


    function refresh():Void {
        this.layoutNeeded = true;
    }
    
    private function layout():Void {

        if (!_parent._parent._parent._parent.visible) { //dynamicLegendWindow
            return;
        }

        //_global.flamingo.tracer("this.layoutNeeded = " + this.layoutNeeded);
        if (!this.layoutNeeded) {
            return;
        }

        var numPosPerColumn:Number = -1;
        if (__height < graphicHeight * 2 + vertiSpacing) {
            numPosPerColumn = 1;
        } else {
            numPosPerColumn = Math.floor((__height - graphicHeight) / (graphicHeight + vertiSpacing) + 1);
        }
        
        var dynamicLegendItem:DynamicLegendItem = null;
        var pos:Number = 2;
        for (var i:Number = 0; i < dynamicLegendItems.length; i++) {
            dynamicLegendItem = DynamicLegendItem(dynamicLegendItems[i]);
            //_global.flamingo.tracer("i = " + i + " dynamicLegendItem = " + dynamicLegendItem.getTitle() + " visible = " + dynamicLegendItem.isVisible() + " numPosPerColumn = " + numPosPerColumn);
            //_global.flamingo.tracer("graphicWidth = " + graphicWidth + " horiSpacing = " + horiSpacing + " pos = " + pos + " numPosPerColumn = " + numPosPerColumn);
            if (dynamicLegendItem.isVisible()) {
                dynamicLegendItem._x = (graphicWidth + horiSpacing) * Math.floor(pos / numPosPerColumn);
                dynamicLegendItem._y = (graphicHeight + vertiSpacing) * (pos % numPosPerColumn);
                pos++;
            } else {
                dynamicLegendItem._x = 0;
                dynamicLegendItem._y = 0;
            }
        }
        this.layoutNeeded = false;
    }
    
}
