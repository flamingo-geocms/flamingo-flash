/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
import mx.controls.Label;

import roo.DynamicLegendItem;
import roo.FeatureType;
import roo.WhereClause;
import roo.FilterLayerDynamicLegendLayerAdapter;
import roo.WFSConnector;
import roo.WFSConnectorDynamicLegendLayerAdapter;
import roo.LayerOGWMSDynamicLegendItemAdapter;
import roo.Envelope;
import roo.FilterLayer;

class roo.DynamicLegendLayer extends DynamicLegendItem {
    
    private var filterLayer:String = null; // Set by init object.
    private var layers:Array = null; // Set by init object.
    private var graphicURI:String = null; // Set by init object.
    private var featureType:FeatureType = null; // Set by init object.
    private var whereClause:WhereClause = null; // Set by init object.
    
    private var filterLayerDynamicLegendLayerAdapter:FilterLayerDynamicLegendLayerAdapter = null;
    private var graphic:MovieClip = null;
    private var wfsConnector:WFSConnector = null;
    private var wfsConnectorDynamicLegendLayerAdapter:WFSConnectorDynamicLegendLayerAdapter = null;
    
    function onLoad():Void {
        super.onLoad();
        
        wfsConnector = WFSConnector.getInstance(title, dynamicLegend.getWFSURL());
        wfsConnectorDynamicLegendLayerAdapter = new WFSConnectorDynamicLegendLayerAdapter(this);

        var map:String = dynamicLegend.getMap();
        filterLayerDynamicLegendLayerAdapter = new FilterLayerDynamicLegendLayerAdapter(this);
        _global.flamingo.addListener(filterLayerDynamicLegendLayerAdapter, filterLayer, this);
        layerOGWMSDynamicLegendItemAdapter = new LayerOGWMSDynamicLegendItemAdapter(this);
        for (var i:String in layers) {
            //_global.flamingo.tracer("DynamicLegendLayer / addListener / layer = " + layers[i]);
            _global.flamingo.addListener(layerOGWMSDynamicLegendItemAdapter, map + "_" + layers[i], this);
        }
        
        _global.flamingo.addListener(this, _parent._parent._parent._parent._parent, this);
        
        addGraphic();
        addLabel();
    }
    
    function onSetVisible(s:Object):Void {
        if (_parent._parent._parent._parent._parent._visible) {
            setVisible();
        }
    }
    
    private function addGraphic():Void {
        var split:Array = graphicURI.split("://");
        var protocol:String = split[0];
        var resource:String = split[1];
        var url:String = "";
        if (protocol == "file") {
            url += dynamicLegend.getFileURL();
            url = _global.flamingo.correctUrl(url);
            if ((url.length > 0) && (url.charAt(url.length - 1) != "/")) {
                url += "/";
            }
            url += resource;
        } else { // protocol == "wms"
            url += dynamicLegend.getWMSURL();
            url += "&VERSION=1.1.1&REQUEST=GetLegendGraphic&FORMAT=image/gif";
            url += "&WIDTH=" + dynamicLegend.getGraphicWidth();
            url += "&HEIGHT=" + dynamicLegend.getGraphicHeight();
            url += "&LAYER=" + resource;
        }
        //_global.flamingo.tracer("addGraphic.url = " + url);
        graphic = createEmptyMovieClip("mGraphic", 0);
        graphic.loadMovie(url);
    }
    
    private function addLabel():Void {
        var initObject:Object = new Object();
        initObject["_x"] = dynamicLegend.getGraphicWidth() + 1;
        initObject["_y"] = -3;
        initObject["text"] = title;
        var label:Label = Label(attachMovie("Label", "mLabel", 1, initObject));
        label.setStyle("fontSize", 11);
    }
    
    function setVisible():Void {
        //if (wfsConnectorDynamicLegendLayerAdapter != null) {
        //    wfsConnectorDynamicLegendLayerAdapter.setEnabled(false); // For thread safety.
        //}
        
        //_global.flamingo.tracer("dynamicLegendWindow.visible = " + _parent._parent._parent._parent._parent.visible);
        if (!_parent._parent._parent._parent._parent._visible) {
            return;
        }
        
        var atLeast1LayerVisible:Boolean = false;
        var map:String = dynamicLegend.getMap();
        var layer:MovieClip = null;
        for (var i:String in layers) {
            layer = _global.flamingo.getComponent(map + "_" + layers[i]);
            //_global.flamingo.tracer("DynamicLegendLayer.setVisible(), layers[" + i + "] = " + layer + " visible = " + layer.getVisible());
            if (layer.getVisible() == 1) {
                atLeast1LayerVisible = true;
            }
        }
        //_global.flamingo.tracer("atLeast1LayerVisible = " + atLeast1LayerVisible + " dynamicLegend.isDynamic() = " + dynamicLegend.isDynamic());
        if (!atLeast1LayerVisible) {
            doSetVisible(false);
        } else if (!dynamicLegend.isDynamic()) {
            doSetVisible(true);
        } else {
            var extent:Object = _global.flamingo.getComponent(map).getMapExtent();
            var envelope:Envelope = new Envelope(extent.minx, extent.miny, extent.maxx, extent.maxy);
            
            _alpha = 40;
            
            var filterLayerComp:FilterLayer = FilterLayer(_global.flamingo.getComponent(filterLayer));
		        //_global.flamingo.tracer("setVisible, filterLayer = " + filterLayer + " filterLayerComp = " + filterLayerComp);
            var filterconditions:Object = filterLayerComp.getFilterconditions();
            var additionalFilter:String = new String("");
            var nrConditions:Number = 0;
        		for (var filtername:String in filterconditions) {
            		var filtercondition:String = filterLayerComp.getFiltercondition(filtername);

		            var template:String = filterLayerComp.getFilterTemplate(filtername);
		        		//_global.flamingo.tracer("setVisible, template = " + template);

								var namevaluepairs:Array = filtercondition.split("&");
								for (var i = 0; i<namevaluepairs.length; i++) {
										var namevaluepair:Array = filtercondition.split("=");
										var name:String = "[" + namevaluepair[0] + "]";
										var value:String = namevaluepair[1];
										template = template.split(name).join(value);
		                //_global.flamingo.tracer("name = " + name + " value = " + value + " filtercondition = " + filtercondition);
								}
								additionalFilter += template;
								nrConditions += 1;
						}
						if (nrConditions > 1) {
						    additionalFilter = "<ogc:And>" + additionalFilter + "</ogc:And>";
						}

            //_global.flamingo.tracer("whereClause = " + whereClause + " additionalFilter = " + additionalFilter);
						var clauses:Array = null;
						if (whereClause != null) {
						    clauses = new Array(whereClause);
						}
            wfsConnector.performGetFeature(featureType, envelope, clauses, additionalFilter, true, wfsConnectorDynamicLegendLayerAdapter);
        }
    }
    
    function doSetVisible(visible:Boolean):Void {
        _alpha = 100;
        _visible = visible;
        
        //_global.flamingo.tracer("doSetVisible, DynamicLegendLayer = " + this);
        dynamicLegend.refresh();
    }
    
}
