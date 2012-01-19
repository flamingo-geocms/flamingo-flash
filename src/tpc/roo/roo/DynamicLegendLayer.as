import mx.controls.Label;

import roo.DynamicLegendItem;
import roo.FilterLayerDynamicLegendLayerAdapter;
import roo.LayerOGWMSDynamicLegendItemAdapter;

class roo.DynamicLegendLayer extends DynamicLegendItem {
    
    private var filterLayer:String = null; // Set by init object.
    private var graphicURI:String = null; // Set by init object.
    private var serverids:String = null; // Set by init object.
    private var legendCriteria:String = null; // Set by init object.
	
    private var filterLayerDynamicLegendLayerAdapter:FilterLayerDynamicLegendLayerAdapter = null;
	private var resource:String = null;
    private var graphic:MovieClip = null;
    
    function onLoad():Void {
        super.onLoad();
        
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
        resource = split[1];
        var url:String = "";
		switch (protocol) { 
 		case "file" : 
			graphic = createEmptyMovieClip("mGraphic", 0);
		    url += dynamicLegend.getFileURL();
            url = _global.flamingo.correctUrl(url);
            if ((url.length > 0) && (url.charAt(url.length - 1) != "/")) {
                url += "/";
            }
            url += resource;
			graphic.loadMovie(url)
 		break;
		case "wms" :
			graphic = createEmptyMovieClip("mGraphic", 0);
		    url += dynamicLegend.getWMSURL();
            url += "&VERSION=1.1.1&REQUEST=GetLegendGraphic&FORMAT=image/gif";
            url += "&WIDTH=" + dynamicLegend.getGraphicWidth();
            url += "&HEIGHT=" + dynamicLegend.getGraphicHeight();
            url += "&LAYER=" + resource;
			graphic.loadMovie(url)
		break;
		case "symbol" :
			graphic = createEmptyMovieClip("mGraphic", 0);
			var mcLoader:MovieClipLoader = new MovieClipLoader();
			mcLoader.addListener(this);
			mcLoader.loadClip(dynamicLegend.getSwfLibURL(), graphic);
			break;
		}
    }
	
	function onLoadInit(mc:MovieClip) {
		graphic.attachSymbol(resource);
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
        
        //_global.flamingo.tracer("dynamicLegendWindow.visible = " + _parent._parent._parent._parent._parent.visible);
        if (!_parent._parent._parent._parent._parent._visible) {
            return;
        }
        
        if (!dynamicLegend.isDynamic()) {
            doSetVisible(true);
        }
        else {
        		dynamicLegend.refresh();
        }
    }
    
    function doSetVisible(visible:Boolean):Void {

        _visible = visible;
        if (visible) {
        	_alpha = 100;
        }
        else {
        	_alpha = 40;
        }
    }
    
    function getServerIds():String {
        return serverids;
    }
    
    function getLegendCriteria():String {
        return legendCriteria;
    }
    
}
