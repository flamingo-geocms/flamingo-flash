import core.AbstractComponent;

class roo.HighlightLayer extends AbstractComponent {
    
    private var map:Object = null;
    
    private var srs:String = "EPSG:4326";
    private var alpha:String = "100";
    
    function onLoad():Void {
        super.onLoad();
        
    }
    
    function setAttribute(name:String, value:String):Void {
        switch (name) {
            case "srs":
                srs = value;
                break;
            case "alpha":
                alpha = value;
        }
    }
    
    function highlightFeature(wmsUrl:String, sldServletUrl:String, featureTypeName:String, propertyName:String, value:String, objectAlpha:Number, name:String):Void {
        map = _global.flamingo.getComponent(listento[0]);

        //_global.flamingo.tracer("map = " + map + " wmsUrl = " + wmsUrl + " sldServletUrl = " + sldServletUrl + " featureTypeName = " + featureTypeName + " propertyName = " + propertyName + " value = " + value + " name = " + name);
        if ((name == null) || (name == "")) {
            name = "highlight";
        }
        
        var nameSpacePrefix:String = null;
        if (propertyName.indexOf(":") > -1) {
            nameSpacePrefix = propertyName.split(":")[0];
        } else {
            nameSpacePrefix = "app";
        }
        
        var layerXML:String = "";
        layerXML += "<fmc:LayerOGWMS xmlns:fmc=\"fmc\" id=\"" + name + "\" ";
        layerXML += "url=\"" + wmsUrl + "\" ";
        layerXML += "srs=\"" + srs + "\" ";
        layerXML += "layers=\"dummy\" showerrors=\"true\" ";
        if (objectAlpha == undefined || objectAlpha == 0) {
        	layerXML += "alpha=\"" + alpha + "\" ";
        }
        else {
        	layerXML += "alpha=\"" + objectAlpha.toString() + "\" ";
        }
        layerXML += "sld=\"" + sldServletUrl + "/highlight.jsp%3FfeatureTypeName%3D" + featureTypeName + "%26propertyName%3D" + propertyName + "%26value%3D" + value + "\"/>";
        //_global.flamingo.tracer("layerXML = " + layerXML);
        map.addLayer(layerXML);
    }
    
    function resetFeature(name:String):Void {
        if ((name == null) || (name == "")) {
            name = "highlight";
        }
        name = _global.flamingo.getId(map) + "_" + name;
        
        map.removeLayer(name);
    }
    
}
