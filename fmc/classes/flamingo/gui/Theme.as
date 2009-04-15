/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.gismodel.*;



import flamingo.core.AbstractComponent;

class flamingo.gui.Theme extends AbstractComponent  {
    private var componentID:String = "Theme";
    private var layerIds:String = null;
	private var themeLayers:Array;
	private var map:Object; 
    
    function setAttribute(name:String, value:String):Void {     
        if(name="layerids"){
        	layerIds = value;
        }    
    }
    
    function getLabel():String {
        return _global.flamingo.getString(this,"label");
    }  
    
    function go():Void {
		map = getParent("ThemePicker").getMap();
		var mapStr:String = _global.flamingo.getId(map); 	
        var sublayer:String = '';
    	themeLayers = new Array();
    	if(layerIds==undefined){
  			return;		 
    	}
    	var a:Array = _global.flamingo.asArray(this.layerIds);//this.layerIds.split(",");
		for (var j:Number = 0; j<a.length; j++) {
			var layername:String = null;
			if (a[j].indexOf(".", 0) == -1) {
				layername = mapStr+"_"+a[j];
				sublayer = "";
			} else {	
				layername  = mapStr+"_"+a[j].split(".")[0];
				sublayer = a[j].split(".")[1];
			}
			var item:Object = new Object();
			item["layername"] = layername;
			item["sublayer"] = sublayer;
			themeLayers[layername + "." + sublayer] = item;
		}
		getParent().themeReady();
    }
    
    function getThemelayers():Array {
        return themeLayers;
    }
    	
    
    
}
