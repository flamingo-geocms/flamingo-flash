import roo.FilterLayer;

class roo.FilterLayerLayerOGWMSAdapter {

	private var layerOGWMS:MovieClip = null;
    private var filterLayer:FilterLayer = null;
    
    function FilterLayerLayerOGWMSAdapter(layerOGWMS:MovieClip) {
        //_global.flamingo.tracer("FilterLayerLayerOGWMSAdapter, layerOGWMS = " + layerOGWMS);
        this.layerOGWMS = layerOGWMS;
    }
    
    function onAddRemoveFilter(filterLayer:FilterLayer, update:Boolean):Void {
       this.filterLayer = filterLayer;
       if (update) {
            layerOGWMS.update();
        }
    }
    
    function getUrlFilter():String {
       var filterconditions:Object = this.filterLayer.getFilterconditions();
        
        var urlFilter:String = "";
        for (var filtername:String in filterconditions) {
            var filtercondition:String = filterLayer.getFiltercondition(filtername);
            //_global.flamingo.tracer("filtername = " + filtername + " filtercondition = " + filtercondition);

            urlFilter += "&" + filtercondition ;
		    }

		    return escape(urlFilter).split("%20").join("%2520");//spaces must be double encoded
		    
    }
    
    function getFiltersFingerprint():String {
        if (this.filterLayer == null) {
            return "";
        } else {
            return this.filterLayer.getFiltersFingerprint();
        }
    }
    
}
