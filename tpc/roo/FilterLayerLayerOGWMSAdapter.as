import roo.FilterLayer;
import roo.XMLTools;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.FilterLayerLayerOGWMSAdapter {

	private var layerOGWMS:MovieClip = null;
    private var initialSLD:String = null;
    private var filterLayer:FilterLayer = null;
    
    function FilterLayerLayerOGWMSAdapter(layerOGWMS:MovieClip) {
        //_global.flamingo.tracer("FilterLayerLayerOGWMSAdapter, layerOGWMS = " + layerOGWMS);
        this.layerOGWMS = layerOGWMS;
        this.initialSLD = this.layerOGWMS.attributes["sld"];
        //_global.flamingo.tracer("this.initialSLD = " + this.initialSLD);
    }
    
    function onAddRemoveFilter(filterLayer:FilterLayer, update:Boolean):Void {
        this.filterLayer = filterLayer;
        var filterconditions:Object = filterLayer.getFilterconditions();
        //_global.flamingo.tracer(" arguments = " + arguments);
        //_global.flamingo.tracer(" filterconditions = " + filterconditions);

    		if (this.initialSLD != undefined) {
            layerOGWMS.attributes["sld"] = this.initialSLD;
        } else {
            delete layerOGWMS.attributes["sld"];
        }

        for (var filtername:String in filterconditions) {
            var filtercondition:String = filterLayer.getFiltercondition(filtername);
            //_global.flamingo.tracer("filtername = " + filtername + " filtercondition = " + filtercondition);

            layerOGWMS.attributes["sld"] += filtercondition + "&";
		    }
		    var sld:String = String(layerOGWMS.attributes["sld"]);
        //_global.flamingo.tracer("sld = " + sld);

		    if (sld != undefined) {
		        layerOGWMS.attributes["sld"] = XMLTools.urlEncode(sld);
		    }
        //_global.flamingo.tracer("layerOGWMS.attributes[sld] = " + layerOGWMS.attributes["sld"]);

        //_global.flamingo.tracer("update = " + update);
        if (update) {
            layerOGWMS.update();
        }
    }
    
    function getFiltersFingerprint():String {
        if (this.filterLayer == null) {
            return "";
        } else {
            return this.filterLayer.getFiltersFingerprint();
        }
    }
    
}
