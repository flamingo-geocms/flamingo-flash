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
* This tag defines an url instance. When the url should also contain the map extent or the current theme as parameter
* the url should listen to the map component.
* @class gui.URL extends AbstractComponent 
* @hierarchy child node of URLSelector or Flamingo or a Container component
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
* @example
  <fmc:Window id="linkWindow" top="120" left="590" width="500" height="70" visible="false" skin="g"
    canresize="true" canclose="false">
    <string id="title" en="Copy/paste link" nl="Link kopiëren/plakken"/>
        <fmc:URL id="risurl"  width="95%" height="95%" showaslink="true" listento="map" visible="false">
          <style id="a" font-family="arial,verdana" font-size="12px" color="#0033cc" display="block" font-weight="normal" text-decoration="underline"/>
        </fmc:URL>
  </fmc:Window>  
* @attr url no default Defines the url to open in the browser when selecting an url instance from the combobox 
* in the URLSelector.
* @attr target default: _blank Defines the target paramater when opening the url (p.e. _blank or _self) 
* @attr group no default Defines a grouping for the urls in the URLSelector. When more than one group is defined within the same
* URLSelector first a combobox will appear for chosing a group. The url instances in the url combox will be limited 
* by the chosen group. When for one url a group is configured, all urls in the same URLSelector should have a group 
* configured. 
* @attr addExt default: true. When true the current extent of the map will be added as parameter to the resulting url.  
* @attr addTheme default: true. When true and applicable the current theme of the map will be added as parameter to the resulting url.  
* @attr showAsLink default: false. When true the URL will be shown in a textfield as a link, only when the URL is not
* in an URLSelector.
*/



import core.AbstractComponent;


class gui.URL extends AbstractComponent  {
    private var componentID:String = "URL";
    private var url:String;
	private var label:String;
	private var target:String = "_blank";
	private var group:String;
	private var addExt:Boolean = true;
	private var addTheme:Boolean = true;
	private var map:Object;
	private var showAsLink:Boolean = false;
	private var link_txt:TextField=null;
    
    
    function setAttribute(name:String, value:String):Void {     
        if(name.toLowerCase()=="url"){
        	url = value;
        } else if (name.toLowerCase()=="target"){
        	target = value;
        } else if (name.toLowerCase()=="group"){
        	group = value;
        }  else if (name.toLowerCase()=="addextent"){
        	if(value.toLowerCase()=="false"){
        		addExt = false;
        	} else {
        		addExt = true;
        	}
        } else if (name.toLowerCase()=="addtheme"){
        	if(value.toLowerCase()=="false"){
        		addTheme = false;
        	} else {
        		addTheme = true;
        	}
        } else if (name.toLowerCase()=="showaslink"){
        	if(value.toLowerCase()=="false"){
        		showAsLink = false;
        	} else {
        		showAsLink = true;
        	}
        }
    }
    
    
    function init(){
    	super.init();

		if(showAsLink){
			addLink();
		}
    }
    
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
    	if(showAsLink){
    		var parent:Object = _global.flamingo.getParent(this);
    		if(_global.flamingo.getUrl(parent).indexOf("Window") > 0){
    			link_txt._width = parent._width-20;
    			link_txt._height = parent._height-20;
    		}
    		
	    	var linkLabel:String = getLabel();
			if(linkLabel == null){
				linkLabel = this.getUrl();
			}
			link_txt.htmlText = '<span class="text"><a href="asfunction:openUrl">' + linkLabel + '</a></span>';	
    	}
    }
    
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
    	super.setBounds(x, y, width, height);
    	link_txt._width = width;
    	link_txt._height = height;	
    }
    
    function addLink():Void{
    	this.map = _global.flamingo.getComponent(listento[0]);
    	link_txt = this.createTextField("link_txt", this.getNextHighestDepth(), 0, 0, 100, 50);
    	link_txt.wordWrap = true;
		link_txt.autoSize = true;
		link_txt.html = true;
		link_txt.styleSheet = _global.flamingo.getStyleSheet(this);   
		var linkLabel:String = getLabel();
		if(linkLabel == null){
			linkLabel = this.getUrl();
		}
		link_txt.htmlText = '<span class="text"><a href="asfunction:openUrl">' + linkLabel + '</a></span>';

    }
    
    function openUrl():Void{
    	var my_xml:XML = new XML();
		my_xml.contentType = "text/xml";
		my_xml.send(this.getUrl(), this.getTarget());
    } 	

    function setUrl(url){
    	this.url = url;
    }
    	
    function setMap(map:Object):Void {
    	this.map = map;
    }
    
    function getLabel():String {
        return _global.flamingo.getString(this,"label");
    }  
    
    function getGroupLabel():String {
        return _global.flamingo.getString(this,"grouplabel");
    }  
    	
	function getUrl():String {
		if(url==null){
			var arg:String = _global.flamingo.getArgument(this, "url");
			if(arg!=null){
				setUrl(arg);
			}
		}
		var paramStr:String = "?";
		var params:Array = new Array();
		if (url.indexOf("?")!=-1){
			params = url.substr(url.indexOf("?")+1).split("&");
			url = url.substr(0,url.indexOf("?"));
		}	
		for(var i:Number=0;i<params.length;i++){			
			if(params[i].indexOf("ext")==-1&&params[i].indexOf("thema")==-1){
				paramStr += params[i] + "&";
			}
		} 			
		if(map!=null && addExt){
			var extent:Object = map.getCurrentExtent();
			if(extent!=null){
				paramStr += "ext=" + extent.minx + "," + extent.miny + "," + extent.maxx + "," + extent.maxy + "&" ;
			}		
		} 
		if(map!=null && addTheme){
			var themeSelector:Object = map.getThemeSelector();
			if(themeSelector!=null && themeSelector.getCurrentTheme()!=null){
				paramStr += "thema="+ themeSelector.getCurrentTheme().getName() + "&";
			}
		}
		return url + paramStr.substr(0,paramStr.length-1);	
	}
	
	function getTarget():String {
		return target;
	}
	
	function getGroup():String {
		return group;
	}
    
    
}
