/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component URL
* An URL defines a url that can be opened from within flamingo. 
* A URL can be set by selecting an url from the URLSelector Component. 
* @file flamingo/tpc/classes/flamingo/gui/URL.as  (sourcefile)
* @file flamingo/fmc/URL.fla (sourcefile)
* @file flamingo/fmc/URL.swf (compiled component, needed for publication on internet)
* @configstring label Label text for the choices in the URLSelector combobox.
* @configstring grouplabel Label text for the choices in the groupcombobox.
*/

/** @tag <fmc:URL> 
* This tag defines an url instance. When the url should also contain the map extent as parameter
* the url should listen to the map component.
* @class gui.URL extends AbstractComponent 
* @hierarchy child node of URLSelector 
* @example
* <fmc:UrlSelector left="10" top="20" right="right -10" height="50"  borderalpha="0">
     <string id="groupsellabel" nl="Selecteer een thema..."/>
     <string id="urlsellabel" nl="Kies een atlas..."/>
     <fmc:URL   url="http://..." group="algemeen" listento="map" target="_blank">
      	<string id="grouplabel" nl="Algemeen"/>	
      	<string id="label" nl="Kaart en luchtfoto"/>	
     </fmc:URL>
     <fmc:URL   url="http://...." group="economie_werk" listento="map" target="_blank">
      	<string id="grouplabel" nl="Economie en werk"/>	
      	<string id="label" nl="Bedrijventerreinen"/>	
     </fmc:URL>
     .....
   </fmc:URLSelector> 
* @attr url no default Defines the url to open in the browser when selecting an url instance from the combobox 
* in the URLSelector.
* @attr target default: _blank Defines the target paramater when opening the url (p.e. _blank or _self) 
* @attr group no default Defines a grouping for the urls. When more than one group is defined within the same
* URLSelector first a combobox will appear for chosing a group. The url instances in the url combox will be limited 
* by the chosen group. When for one url a group is configured, all urls in the same URLSelector should have a group 
* configured. 
*/



import core.AbstractComponent;

class gui.URL extends AbstractComponent  {
    private var componentID:String = "URL";
    private var url:String;
	private var label:String;
	private var target:String = "_blank";
	private var group:String;
	private var map:Map;
    
    
    function setAttribute(name:String, value:String):Void {     
        if(name.toLowerCase()=="url"){
        	url = value;
        } else if (name.toLowerCase()=="target"){
        	target = value;
        } else if (name.toLowerCase()=="group"){
        	group = value;
        }  
    }
    
    function setMap(map:Map):Void {
    	this.map = map;
    }
    
    function getLabel():String {
    	_global.flamingo.tracer("URL getLabel" + _global.flamingo.getString(this,"label"))
        return _global.flamingo.getString(this,"label");
    }  
    
    function getGroupLabel():String {
        return _global.flamingo.getString(this,"grouplabel");
    }  
    	
	function getUrl():String {
		var paramStr:String = "";
		if(url.valueOf("?") == -1){
			paramStr = "?";
		} else {
			paramStr = "&";
		}	
		
		if(map!=null){
			var extent:Object = map.getCurrentExtent();
			paramStr += "ext=" + extent.minx + "," + extent.miny + "," + extent.maxx + "," + extent.maxy ;	
		} 
		if(paramStr.length > 1) {
			return url + paramStr.substr(0, paramStr.length-1);
		} else {
			return url;
		}
	}
	
	function getTarget():String {
		return target;
	}
	
	function getGroup():String {
		return group;
	}
    
    
}
