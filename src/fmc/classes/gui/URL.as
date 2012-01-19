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
* the url (or the urlselector in which this url is used) should listen to the map component.
* @class gui.URL extends AbstractComponent 
* @hierarchy child node of URLSelector or Flamingo or a Container component
* @example (use of URL in an URLSelector Component)
* <fmc:UrlSelector left="10" top="20" right="right -10" height="50"  borderalpha="0" listento="map">
     <string id="groupsellabel" nl="Selecteer een thema..."/>
     <string id="urlsellabel" nl="Kies een atlas..."/>
     <fmc:URL url="http://..." group="algemeen"  target="_blank">
      	<string id="grouplabel" nl="Algemeen"/>	
      	<string id="label" nl="Kaart en luchtfoto"/>	
     </fmc:URL>
     <fmc:URL   url="http://...." group="economie_werk" listento="map" target="_blank">
      	<string id="grouplabel" nl="Economie en werk"/>	
      	<string id="label" nl="Bedrijventerreinen"/>	
     </fmc:URL>
     .....
   </fmc:URLSelector> 
* @example (use of URL in an Window Component)
  ...
  <fmc:LinkButton left="560" bottom="bottom +5" listento="linkWindow">
    <string id="tooltip" en="open/ close the link window" nl="open/sluit link"/>
  </fmc:LinkButton> 
  ....
   <fmc:Window id="linkWindow" top="120" left="590" width="500" height="70" visible="false" skin="g"
    canresize="true" canclose="false">
    <string id="title" en="Copy/paste link" nl="Link kopiëren/plakken"/>
        <fmc:URL id="risurl"  width="95%" height="95%" showaslink="true" listento="map" visible="false">
          <style id="a" font-family="arial,verdana" font-size="12px" color="#0033cc" display="block" font-weight="normal" text-decoration="underline"/>
        </fmc:URL>
  </fmc:Window>
* @example (use of URL with a persistency service)
  <fmc:URL id="url"  width="95%" height="95%" showaslink="false" listento="map" persistencyservice="http://.../persistency-service/" appid="apo">\
	<string id="buttonlabel" nl="Genereer link"/>
	<string id="linkidentifierlabel" nl="Code"/>
	<string id="linkidentifierhelp" nl="Vul optioneel een code in, toegestane karakters zijn A-Z, a-z, 0-9, - en _"/>
	<string id="linkidentifiererror" nl="De gegeven code bestaat al"/>
  </fmc:URL>
   
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
* @attr persistencyService no default. URL of a persistency service to use for serializing viewer state
* @attr persistComponents no default. List of component ids whose states must be persisted, use in combination with the persistencyService parameter.
* @attr appid default: flamingo. Passed to the persistency service as application identifier.
*/



import core.AbstractComponent;

import mx.controls.Button;
import mx.controls.TextInput;
import mx.controls.Label;
import mx.utils.Delegate;

import coremodel.service.persistency.PersistencyServiceConnector;

class gui.URL extends AbstractComponent  {
    private var componentID:String = "URL";
    private var url:String;
	private var label:String;
	private var target:String = "_blank";
	private var group:String;
	private var addExt:Boolean = true;
	private var addTheme:Boolean = true;
	private var addLayerVisibility = false;
	private var addLegendState = false;
	private var addBufferState: Boolean = false;
	private var mapId:String;
	private var map:Object;
	private var legendId:String;
	private var bufferId:String;
	private var legend:Object;
	private var buffer:Object;
	private var showAsLink:Boolean = false;
	private var warningLength:String=null;
	private var link_txt:TextField=null;
	private var persistencyService: String;
	private var applicationIdentifier: String = "flamingo";
	private var persistComponents: Array;
	private var linkIdentifierLabel: Label;
	private var linkIdentifierInput: TextInput;
	private var linkIdentifierHelp: Label;
	private var linkError: Label;
	private var linkButton: Button;
	private var currentURL: String;
	private var lastDocument: XML;
    
    
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
        }
        else if (name.toLowerCase()=="addlayervisibility"){
        	if(value.toLowerCase()=="false"){
        		addLayerVisibility = false;
        	} else {
        		addLayerVisibility = true;
        	}	
        } else if (name.toLowerCase()=="addlegendstate"){
        	if(value.toLowerCase()=="false"){
        		addLegendState = false;
        	} else {
        		addLegendState = true;
        	}
        }	
        else if (name.toLowerCase()=="legendid"){
	        legendId = value;
        }
        else if (name.toLowerCase()=="addbufferstate") {
			addBufferState = value.toLowerCase () != "false";
		}
		else if (name.toLowerCase()=="bufferid") {
			bufferId = value;
		}
        else if (name.toLowerCase()=="showaslink"){
        	if(value.toLowerCase()=="false" || persistencyService){
        		showAsLink = false;
        	} else {
        		showAsLink = true;
        	}
        }
        else if (name.toLowerCase()=="persistencyservice") {
        	persistencyService = value;
        	showAsLink = false;
        }
        else if (name.toLowerCase()=="persistcomponents") {
        	persistComponents = _global.flamingo.asArray (value);
        }
        else if (name.toLowerCase()=="appid") {
			applicationIdentifier = value;
		}
    }
    
    
    function init(){
    	super.init();
    	if(listento[0]!=undefined){
    		mapId = listento[0];
    		map = _global.flamingo.getComponent(listento[0]);
    	}
		if(showAsLink || persistencyService){
			addLink();
			if (persistencyService) {
				addLinkIdentifierControls ();
			} else {
				updateLink ();				
			}
		}
		
		var viewerStateCode: String = _global.flamingo.getArgument (this, 'viewerStateCode');
		if (viewerStateCode && viewerStateCode.length > 0 && persistencyService) {
			retrieveViewerState (viewerStateCode);
		}
    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
		var parent:Object = _global.flamingo.getParent(this);
		if(_global.flamingo.getUrl(parent).indexOf("Window") > 0){
			link_txt._width = parent._width-20;
			link_txt._height = parent._height-20;
		}
    	if(showAsLink){
			updateLink();
    	}
    }
    
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
    	super.setBounds(x, y, width, height);
    	link_txt._width = width;
    	link_txt._height = height;	
    }
    
    function addLink():Void{
    	link_txt = this.createTextField("link_txt", this.getNextHighestDepth(), 0, 0, 100, 50);
    	link_txt.wordWrap = true;
		link_txt.autoSize = true;
		link_txt.html = true;
		link_txt.styleSheet = _global.flamingo.getStyleSheet(this);   
		warningLength = _global.flamingo.getString(this,"label");
		if(warningLength == null){
			warningLength = "Letop: een url van deze lengte kan niet zonder problemen worden geopend in Internet Explorer";
		}
    }
    
    public function addLinkIdentifierControls (): Void {
		linkIdentifierLabel = Label (attachMovie ('Label', 'linkIdentifierLabel', getNextHighestDepth (), {
			text: _global.flamingo.getString (this, "linkidentifierlabel"),
			autoSize: 'left'
		}));
		linkIdentifierInput = TextInput (attachMovie ('TextInput', 'linkIdentifierInput', getNextHighestDepth (), {
			width: 60,
			maxChars: 64,
			restrict: "A-Za-z0-9_\\-"
		}));
		linkButton = Button (attachMovie ('Button', 'linkButton', getNextHighestDepth(), {
    		label: _global.flamingo.getString (this, "buttonlabel")
    	}));
		linkIdentifierHelp = Label (attachMovie ('Label', 'linkIdentifierHelp', getNextHighestDepth (), {
			text: _global.flamingo.getString (this, 'linkidentifierhelp'),
			autoSize: 'left'
		}));
		linkError = Label (attachMovie ('Label', 'linkError', getNextHighestDepth (), {
			text: '',
			autoSize: 'left'
		}));
		
		linkButton.addEventListener ('click', Delegate.create (this, onClickLinkButton));
    }
    
    private function onClickLinkButton (): Void {
    	persistViewerState ();
    }
    
    public function layout (): Void {
    	super.layout ();
    	
    	if (persistencyService) {
    		var width: Number = __width,
    			height: Number = __height,
    			x: Number = 4,
    			y: Number = 4;
    			
    		linkIdentifierLabel.move (x, y);
    		x += linkIdentifierLabel.width + 10; 
    		linkIdentifierInput.move (x, y);
    		x += linkIdentifierInput.width + 10;
    		linkButton.move (x, y);
    		y += Math.max (Math.max (linkIdentifierInput.height, linkIdentifierLabel.height), linkButton.height) + 4;
    		x = 4;
    		
			linkIdentifierHelp.move (x, y);
			y += linkIdentifierHelp.height + 4;
			linkError.move (x, y);
			y += linkError.height + 10;
			
			link_txt._x = x;
			link_txt._y = y;
			link_txt._width = __width - 20;
		}
    }
    
    private function updateLink(){
    	var linkLabel:String = getLabel();
		if(linkLabel == null){
			linkLabel = this.getUrl();
		}
    	if(linkLabel.length < 2048){
				link_txt.htmlText = '<span class="text"><a href="asfunction:openUrl">' + linkLabel + '</a></span>';	
			} else {
				link_txt.htmlText = '<span><warn>' + warningLength +  '</warn><br>' + 
										'<span class="text"><a href="asfunction:openUrl">' + linkLabel + '</a></span>';	
			}	
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
    	mapId = _global.flamingo.getId(map);
    	this.map = map;
    }
    
    function getLabel():String {
        return _global.flamingo.getString(this,"label");
    }  
    
    function getGroupLabel():String {
        return _global.flamingo.getString(this,"grouplabel");
    }  
    	
	function getUrl():String {
		
		if (persistencyService) {
			return currentURL;
		}
		
		var resultUrl:String = "";
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
			resultUrl = url.substr(0,url.indexOf("?"));
		} else {
			resultUrl = url;
		}	
		for(var i:Number=0;i<params.length;i++){			
			if(params[i].indexOf("ext")==-1&&params[i].indexOf("thema")==-1&&
				params[i].indexOf("groupsopen")==-1&&params[i].indexOf("groupsclosed")==-1&&
				params[i].indexOf("layersVisible")==-1&&params[i].indexOf("layersInvisible")==-1){
				paramStr += params[i] + "&";
			}
		} 		
		if(map!=null && addExt){
			var extent:Object = map.getCurrentExtent();
			if(extent!=null){
				paramStr += "ext=" + Math.round(extent.minx) + "," +  Math.round(extent.miny) + "," +  Math.round(extent.maxx) + "," +  Math.round(extent.maxy) + "&" ;
			}		
		} 
		if(map!=null && addTheme){
			var themeSelector:Object = map.getThemeSelector();
			if(themeSelector!=null && themeSelector.getCurrentTheme()!=null){
				paramStr += "thema="+ themeSelector.getCurrentTheme().getName() + "&";
			}
		}
		if(map!=null && addLayerVisibility){
			paramStr += buildVisibilityParam() + "&";
		}
		if(legend==undefined){
			legend = _global.flamingo.getComponent(legendId);	
		} 
		if(legend!=null && addLegendState){
			paramStr += buildLegendGroupParams() + "&";
		}
		
		if (!buffer && bufferId) {
			buffer = _global.flamingo.getComponent (bufferId);
		}
		if (buffer && addBufferState) {
			paramStr += buildBufferParams() + "&";
		}
		
		return resultUrl + paramStr.substr(0,paramStr.length-1);
	}
	
	function getTarget():String {
		return target;
	}
	
	function getGroup():String {
		return group;
	}
    
    private function buildVisibilityParam():String {
    	var params:String = "";
    	var lyrs:Array = map.getLayers();
    	var lyrsinvis:String = ""; 
    	var lyrsvis:String = ""; 
    	//do not list all invisible layers in url, otherwise the url will become too long
    	//so first make all layers and sublayers invisible (in js) 
    	//and than make the visible layers visible again
    	for(var i:Number = 0; i< lyrs.length; i++){
    		var lyrId:String =  lyrs[i].substring(mapId.length + 1);
    		var lyr:Object = _global.flamingo.getComponent(lyrs[i]);
    		var slyrs:Object = lyr.getLayers();
    		var slyrsVis:String = "{"; 
    		//add the visibility of the layer ("f" = false and "t" = true)
    		if(lyr.getVisible() <= 0){
    			slyrsVis += "f,";
    		} else {
    			slyrsVis += "t,";
    		}
    		for(var a in slyrs){
    			if(slyrs[a].visible){
    				slyrsVis += a + ","; 
    			}	
    		}
   			lyrsvis +=  lyrId + slyrsVis.substring(0,slyrsVis.length -1) + "},";
    	}	
    	params += "layersVisible=" + lyrsvis.substr(0, lyrsvis.length -1);
    	return params;
    }
    
    private function buildLegendGroupParams():String {
    	var params:String = "";
    	//do not list all groupclosed in url, otherwise the url will become too long
    	//so first close allgroups and than open the opengroups
    	params+="groupsclosed=all&";
    	var groupsOpen:Array = legend.getGroups(false);
    	//var groupsClosed:Array = legend.getGroups(true);
    	if(groupsOpen.length > 0){
    		params+="groupsopen=" + groupsOpen.toString();
    	}
    	return params;
    }
    
    private function buildBufferParams(): String {
    	var buffers: Object = buffer.getBuffers (),
    		params: String = '';
    		
    	for (var layerId: String in buffers) {
    		var bufferSize: Number = buffers[layerId];

			if (params != '') {
				params += ',';
			}
			
			params += layerId + '-' + bufferSize;    		
    	}
    	
    	return 'buffers=' + params;
    }
    
    private function getPersistComponentIDs (): Array {
    	var componentIDs: Array = persistComponents ? persistComponents.concat () : [ ];
    	
    	if (mapId) {
    		componentIDs.push (mapId);
    	}
    	if (legendId) {
    		componentIDs.push (legendId);
    	}
    	if (bufferId) {
    		componentIDs.push (bufferId);
    	}
    	
    	return componentIDs;
    }
    private function persistViewerState (): Void {
    	var components: Array =  [ ],
    		i: Number,
    		component: MovieClip;
    	
    	// Collect all components whose viewer state must be persisted:
    	var componentIDs: Array = getPersistComponentIDs ();
    	for (i = 0; i < componentIDs.length; ++ i) {
    		if ((component = _global.flamingo.getComponent (componentIDs[i])) && component.persistState) {
    			components.push (component);
    		}
    	}
    	
    	// Create a viewer state document:
    	var document: XML = new XML ('<ViewerState></ViewerState>'),
    		documentElement: XMLNode = document.firstChild;
    		
    	for (i = 0; i < components.length; ++ i) {
    		var componentNode: XMLNode = document.createElement ('Component');
    		
    		component = components[i];
    		componentNode.attributes['id'] = _global.flamingo.getId (component);
    		component.persistState (document, componentNode);
    		
    		documentElement.appendChild (componentNode);
    	}

		// If the viewer state does not differ from the last viewer state there is no need to re-submit the state again to the service:    	
    	if (linkIdentifierInput.text == "" && lastDocument && document.toString () == lastDocument.toString ()) {
    		return;
    	}
    	lastDocument = document;
    	
    	// Submit the viewer state to the service:
    	linkButton.enabled = false;
    	var connector:PersistencyServiceConnector = new PersistencyServiceConnector(persistencyService, applicationIdentifier);
    	connector.persistDocument (document, linkIdentifierInput.text, Delegate.create (this, onPersistComplete));
    }
    
    private function onPersistComplete (status: Number, code: String): Void {
    	
    	linkButton.enabled = true;
    	
    	if (status == PersistencyServiceConnector.STATUS_INVALID_CODE) {
    		linkError.text = _global.flamingo.getString (this, "linkidentifiererror");
			link_txt.htmlText = "";
			currentURL = "";
			return;
		} else {
    		linkError.text = "";
    	}
    	
    	// Build the URL:
    	var url: String = this.url || _global.flamingo.getArgument (this, 'url'),
    		offset: Number;
    	if ((offset = url.indexOf ('?')) >= 0) {
    		url = url.substr (0, offset);
    	}
    	url += '?s=' + code;

		currentURL = url;
		updateLink ();    	
    }
    
    private function retrieveViewerState (viewerStateCode: String): Void {
		// Createa a connector and request the viewer state from the service:
		_global.setTimeout (Delegate.create (this, function (): Void {    	
    		var connector: PersistencyServiceConnector = new PersistencyServiceConnector(this.persistencyService, this.applicationIdentifier);
    		connector.getDocument (viewerStateCode, Delegate.create (this, this.onRetrieveViewerStateComplete));
		}), 10);
    	
    }
    
    private function onRetrieveViewerStateComplete (status: Number, document: XML): Void {
    	
    	// Ignore invalid codes or failures in the service:
    	if (status != PersistencyServiceConnector.STATUS_SUCCESS) {
    		return;
    	}
    	
    	var documentNode: XMLNode = document.firstChild;
    	for (var i: Number = 0; i < documentNode.childNodes.length; ++ i) {
    		var componentNode: XMLNode = documentNode.childNodes[i];
    		
    		if (componentNode.localName != "Component" || !componentNode.attributes["id"]) {
    			continue;
    		}
    		
    		setComponentState (componentNode.attributes["id"], componentNode);
    	}
    }
    
    private function setComponentState (componentId: String, node: XMLNode): Void {

		var callback: Function = function (component: MovieClip): Void {
			if (!component.restoreState) {
				return;
			}
			
			component.restoreState (node);
		};
		
		var component: MovieClip = _global.flamingo.getComponent (componentId);
		if (component && (!(component instanceof AbstractComponent) || component.inited)) {
			callback (component);
		}
		
		_global.flamingo.addListener ({
			onInit: callback
		}, componentId, this);
    }
}
