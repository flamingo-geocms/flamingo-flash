/**
 * ...
 * @author Roy Braam
 */
import coremodel.service.wms.OGWMSConnector;
import core.AbstractPositionable;
import tools.Logger;
import gui.Map;
import gui.layers.AbstractLayer;

/** @component LayerOGWMS
* Open Gis WMS layer. (Tested with Demis, Geoserver, Degree, Esri and Mapserver)
* @file OGWMSConnector.as (sourcefile)
* @file LayerOGWMS.fla (sourcefile)
* @file LayerOGWMS.swf (compiled layer, needed for publication on internet)
* @file LayerOGWMS.xml (configurationfile for layer, needed for publication on internet)
* @change 2010-01-28 Added attribute InitService
*/
/** @tag <fmc:LayerOGWMS>  
* This tag defines a Open Gis WMS layer.
* @hierarchy childnode of <fmc:Map> 
* @example 
* <fmc:Map id="map"  left="5" top="5" bottom="bottom -5" right="right -5"  extent="13562,306839,278026,614073,Nederland" fullextent="13562,306839,278026,614073,Nederland">
*    <fmc:LayerOGWMS id="mylayer" url="myserver.com" WMS="mymap" MAPTIP_LAYERS="Countries" QUERY_LAYERS="#ALL#" LAYERS="#ALL#">
*        <layer id="Countries" maptip="[Name]"/>
*   </fmc:LayerOGWMS>
* </fmc:Map>
* @attr url  Base url of the mapserver, without! these arguments: BBOX, TRANSPARENT, FORMAT, INFO_FORMAT, LAYERS, QUERY_LAYERS, WIDTH, HEIGTH, FEATURE_COUNT, STYLES, EXCEPTIONS, X and Y etc.
* @attr getfeatureinfourl  This url is used when the getFeatureinfo request requires a different url as the getMap request. When omitted the 'url' is used
* @attr getcapabilitiesurl  This url is used when the getCapabilities request requires a different url as the getMap request. When omitted the 'url' is used
* @attr format (defaultvalue = "image/png") Format of returned image.
* @attr info_format  (defaultvalue = "application/vnd.ogc.gml") Format of identify information.
* @attr exceptions  (defaultvalue = "application/vnd.ogc.se_xml") EXCEPTIONS argument.
* @attr srs (defaultvalue = "EPSG:4326") SRS argument.
* @attr version (defaultvalue = "1.1.1") VERSION argument.
* @attr transparent  (defaultvalue = "true") True or false.
* @attr layers  A comma seperated list of layers that have to be displayed. Use keyword "#ALL#" for displaying all available layers.
* @attr styles  STYLES argument. A comma seperated list of the styles used to display the layers. Be aware: Number of styles have to mach the number of layers!
* @attr query_layers  A comma seperated list of layers that will be identified. Use keyword "#ALL#" for querying all available layers.
* @attr maptip_layers  A comma seperated list of layers that will be queried during a maptip event. Use keyword "#ALL#" for querying all available layers.
* @attr feature_count (defaultvalue = "10")  Number of features that will be returned after an identify.
* @attr maptip_feature_count (defaultvalue= "1") Number of features that wil be shown when a maptip is done on this flamingo layer.
* @attr limitedtofullextent  (defaultvalue = "false") True or false.
* @attr timeout  (defaultvalue = "10") Time in seconds when the layer will dispatch an onErrorUpdate event.
* @attr retryonerror (defaultvalue = "0") Number of retrys when encountering an error.
* @attr showerrors  (defaultvalue = "false") True or false. If true errors will be displayed in a standard flamingo error window.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
* @attr fullextent  Extent of layer (comma seperated list of minx,miny,maxx,maxy). When the map is outside this extent, no update will performed.
* @attr alpha (defaultvalue = "100") Transparency of the layer.
* @attr maxHttpGetUrlLength default: 0 If a url is longer then the maxHttpGetUrlLength the layer tries to do a HTTP POST request. If set to 0 (default)the layer wil alwalys do a HTTP GET.
* @attr nocache default:false if set to true the getMap requests are done with a extra parameter to force a no cache
* @attr visible default:true if set to false this component will be set to invisible but also all the layers will be set to visible=false;
* @attr visible_layers Comma seperated list of layers that must be visible. If omitted all layers are visible.
* @attr updateWhenEmpty deafult:true If set to false the layer will not get updated when the layerstring is empty(no sublayers), although the sld parameter may be set. The layer will be set invisible instead. 
* @attr identPerLayer When true, an identify request will be sent for each sublayer seperately when sending the identify request per sublayer you know the sublayer name when handling the response. The FeatureInfo response of ArcGisServer WMS often doesn't contain the 
* faeturetype (or sublayer) name.  
* @attr initService (default="true") if set to false the service won't do a getCap request to init the service. If set to false all parameters must be filled, and no #ALL# can be used.
*/
/** @tag <layer>  
* This defines a sublayer of an OG-WMS service.
* @hierarchy childnode of <fmc:LayerOGWMS> 
* @attr id  layerid, same as in the getcapabilities listing.
* @attr aka  The layerid of a layer in the getfeatureinfo response.
* @attr maptip Configuration string for a maptip. Fieldnames between square brackets will be replaced  with their actual values. For multi-language support use a standard string tag with id='maptip'.
*/
class gui.layers.OGCWMSLayer extends AbstractLayer{
	var version:String = "2.0";
	//---------------------------------
	var query_layers:String;
	//same as query_layers, needed for IdentifyResultsHTML, to make interface for LayerArcIMS, LayerArcServer vs LayerOGWMS equal 
	var identifyids:String; 
	var feature_count:Number = 10;
	var info_format:String = "application/vnd.ogc.gml";
	var exceptions:String = "application/vnd.ogc.se_xml";
	var format:String = "image/png";
	var srs:String = "EPSG:4326";
	var wmsversion:String = "1.1.1";
	var transparent:Boolean = true;
	var styles:String;
	var url:String;
	var slayers:String;
	var getcapabilitiesurl:String;
	var getfeatureinfourl:String;
	var fullextent:Object;
	var minscale:Number;
	var maxscale:Number;
	var retryonerror:Number = 1;
	var timeout:Number = 10;
	var attributes:Object;
	var limitedtofullextent:Boolean = false;
	var showerrors:Boolean = false;
	var showmaptip:Boolean;
	var canmaptip:Boolean = false;
	var maptipFeatureCount:Number=1;
	//-------------------------------------
	var _updating:Boolean = false;
	var updateWhenEmpty:Boolean = true;
	var layers:Object = new Object();
	var timeoutid:Number;
	var nrcache:Number = 0;
	var map:Map;
	var caches:Object = new Object();
	var extent:Object;
	var maptipextent:Object;
	var identifyextent:Object;
	var aka:Object = new Object();
	var lastFiltersFingerprint:String = null;
	var sldParam:String = "";
	var maxHttpGetUrlLength:Number=0;
	var noCache:Boolean = false;
	var visible_layers=null;
	var initialized:Boolean = false;
	var initService:Boolean= true;

	//When true, an identify request will be sent for each sublayer seperately
	//when sending the identify request per sublayer you know the sublayer name when handling 
	//the response. The FeatureInfo response of ArcGisServer WMS often doesn't contain the 
	//faeturetype (or sublayer) name.  
	var identPerLayer:Boolean = false;
	var identsSent:Number = 0;
	//listenerobject for map
	var lMap:Object = new Object();
		
	var maptip_layers:String;
	var vislayers:String;
	var starttime:Date;
	
	public function OGCWMSLayer(id:String, container:MovieClip, map:Map) {
		super (id, container,map);		
		init();		
	}
	
	
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	* @attr dontGetCap:Boolean default=false. If you dont want to let flamingo do a getCap request.
	* Be carefull with this, because flamingo adds listeners etc. and replaces #ALL# with all layers while doing a getCap request.
	*/
	function setConfig(xml:Object, dontGetCap:Boolean) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml= xml.firstChild;
		}
		super.setConfig(XMLNode(xml));
		
		if (dontGetCap == undefined){
			dontGetCap=false;
		}				
		//after loading all parameters set the layer properties.
		if (nullIfEmpty(slayers) != null) {
			if (visible_layers==null){
				//_global.flamingo.tracer("LayerOGWMS setLayerProperty " + this.visible + " slayers " + slayers);
				setLayerProperty(slayers, "visible", true);
			}else{
				setLayerProperty(slayers,"visible",false);
				if (nullIfEmpty(visible_layers)!=null){
					setLayerProperty(visible_layers,"visible",true);
				}
			}	
		}
		if (nullIfEmpty(slayers)!=null){
			if(maxscale!=null){
				setLayerProperty(slayers, "maxscale", maxscale);
			}
			if(minscale!=null){
				setLayerProperty(slayers, "minscale", minscale);
			}	
		}	
		if (nullIfEmpty(styles)!=null){
			if (styles.length>0) {
				var a_styles = _global.flamingo.asArray(styles);
				var a_layers = _global.flamingo.asArray(slayers);
				if (a_styles.length == a_layers.length) {
					for (var i = 0; i<a_styles.length; i++) {
						this.setLayerProperty(a_layers[i], "style", a_styles[i]);
					}
				}
			}
		}
		if (nullIfEmpty(maptip_layers)!=null){
			setLayerProperty(maptip_layers, "maptip", true);
			setLayerProperty(maptip_layers, "queryable", true);
		}
		if (nullIfEmpty(query_layers)!=null){
			setLayerProperty(query_layers, "identify", true);
			setLayerProperty(query_layers, "queryable", true);
		}	
		
		//get extra information about mapserver and the layers                                                                 
		if (url == undefined and getcapabilitiesurl == undefined) {
			return;
		}
		var thisObj:OGCWMSLayer = this;
		var lConn = new Object();
		lConn.onError = function(error:String, objecttag:Object) {
			if (thisObj.showerrors) {
				_global.flamingo.showError("LayerOGWMS error", error);
			}
			_global.flamingo.raiseEvent(thisObj, "onError", thisObj, "init", error);
		};
		lConn.onRequest = function(connector:OGWMSConnector) {
			//_global.flamingo.tracer(requestobject.url);
			_global.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "init", connector);
		};
		lConn.onResponse = function(connector:OGWMSConnector) {
			//trace(responseobject.response);
			_global.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "init", connector);
		};
		lConn.onGetCapabilities = function(service, servicelayers, obj, reqid) {
			//_global.flamingo.tracer("lConn.onGetCapabilities, layer = " + _global.flamingo.getId(thisObj));
			if (thisObj.name == undefined) {
				thisObj.name = service.title;
			}
			thisObj._parseLayers(servicelayers);
			thisObj.flamingo.raiseEvent(thisObj, "onGetCapabilities", thisObj);
			//set initialized in analogy with LayerArcIMS and LayerArcServer.
			thisObj.initialized = true;
			//The update is done in the Map in lLayer.onGetCapabilities 
			//if (thisObj.slayers == "#ALL#") {
			//thisObj.update();
			//}
		};
		var c_url = this.getcapabilitiesurl;
		if (c_url == undefined) {
			this.getcapabilitiesurl = this.url;
		}
		var cogwms:OGWMSConnector = OGWMSConnector.getInstance(this.getcapabilitiesurl);
		cogwms.addListener(lConn);
		var args:Object = new Object();
		args.VERSION = wmsversion;
		for (var attr in this.attributes) {
		  //remove sld and sld_body parameter from request
		  if ((attr.toUpperCase()) != "SLD" && (attr.toUpperCase() != "SLD_BODY")) {
				args[attr.toUpperCase()] = this.attributes[attr];
			}
		}
		//set the service param if not set.
		if (args.SERVICE==undefined){
			args.SERVICE="WMS";
		}
		if(this.initService==true && !dontGetCap){
			cogwms.getCapabilities(this.getcapabilitiesurl, args, lConn);
		}else {
			update();
		}
	}
	
	/**
	 * @see AbstractLayer#setAttribute
	 */
	function setAttribute(name:String, val:String):Void {
		super.setAttribute(name, val);
        switch (name.toLowerCase()) {
			case "retryonerror" :
				this.retryonerror = Number(val);
				break;
			case "minscale" :
				this.minscale = Number(val);
				break;
			case "maxscale" :
				this.maxscale = Number(val);
				break;
			case "fullextent" :
				this.fullextent = map.string2Extent(val);
				break;
			case "layers" :
				if (val.toUpperCase() == "#ALL#") {
					val = "#ALL#";
				}
				//remove spaces in layers val		
				var lyrs:Array = new Array();
				lyrs = val.split(",");
				this.slayers = "";
				for (var n:Number=0;n<lyrs.length;n++){
					this.slayers += trim(lyrs[n]) + ",";
				}
				this.slayers = this.slayers.substr(0,slayers.length - 1);	
				break;
			case "styles" :
				styles = val;			
				break;
			case "maptip_layers" :
				this.canmaptip = true;
				if (val.toUpperCase() == "#ALL#") {
					val = "#ALL#";
				}
				var lyrs:Array = new Array();
				lyrs = val.split(",");
				this.maptip_layers  = "";
				for (var n:Number=0;n<lyrs.length;n++){
					this.maptip_layers  += trim(lyrs[n]) + ",";
				}
				this.maptip_layers  = this.maptip_layers.substr(0,maptip_layers.length - 1);			
				break;
			case "query_layers" :
				if (val.toUpperCase() == "#ALL#") {
					val = "#ALL#";
				}
				var lyrs:Array = new Array();
				lyrs = val.split(",");
				this.query_layers  = "";
				for (var n:Number=0;n<lyrs.length;n++){
					this.query_layers  += trim(lyrs[n]) + ",";
				}
				this.query_layers  = this.identifyids = this.query_layers.substr(0,query_layers.length - 1);				
				break;
			case "alpha" :
				this.container._alpha = Number(val);
				break;
			case "showerrors" :
				if (val.toLowerCase() == "true") {
					showerrors = true;
				} else {
					showerrors = false;
				}
				break;
			case "transparent" :
				if (val.toLowerCase() == "true") {
					transparent = true;
				} else {
					transparent = false;
				}
				break;
			case "limitedtofullextent" :
				if (val.toLowerCase() == "true") {
					this.limitedtofullextent = true;
				} else {
					this.limitedtofullextent = false;
				}
				break;
			case "srs" :
				srs = val;
				break;
			case "version" :
				wmsversion = val;
				break;
			case "info_format" :
				info_format = val;
				break;
			case "format" :
				format = val;
				break;
			case "exceptions" :
				exceptions = val;
				break;
			case "feature_count" :
				feature_count = Number(val);
				break;
			case "maptip_feature_count" :
				maptipFeatureCount= Number(val);
				break;
			case "getcapabilitiesurl" :
				this.getcapabilitiesurl = val;
				break;
			case "getfeatureinfourl" :
				this.getfeatureinfourl = val;
				break;
			case "url" :
				this.url = val;
				break;
			case "maxhttpgeturllength" :
				this.maxHttpGetUrlLength= Number(val);
				break;
			case "visible_layers" :
				this.visible_layers=val;
				break;
			case "nocache" :
				if (val.toLowerCase() == "true") {
					this.noCache = true;
				} else {
					this.noCache = false;
				}
				break;
			case "updatewhenempty" :
				if(val.toLowerCase() == "true"){
					this.updateWhenEmpty = true;
				} else {	
					this.updateWhenEmpty = false;
				}
				break;
			case "identifyperlayer" :
				if(val.toLowerCase() == "true"){
					this.identPerLayer = true;
				} else {	
					this.identPerLayer = false;
				}
				break;
			case "initservice" :			
				if (val.toLowerCase() == "false") {
					this.initService  = false;
				}else {
					this.initService  = true;
				}
				break;			
			default :
				if (name.toLowerCase().indexOf("xmlns:", 0) == -1) {
					this.attributes[name] = val;
				}
				break;
			}
    }
	/**
	 * Passes a name and child xml to the component.
	 * @param name the name of the tag
	 * @param config the xml child
	 */ 
	function addComposite(name:String, config:XMLNode):Void { 
		super.addComposite(name, config);
		if (name.toLowerCase() == "layer") {
			var id;
			for (var attr in config.attributes) {
				if (attr.toLowerCase() == "id") {
					id = config.attributes[attr];
					break;
				}
			}
			if (id != undefined) {
				if (layers[id] == undefined) {
					layers[id] = new Object();
				}
				if (layers[id].language == undefined) {
					layers[id].language = new Object();
				}
				_global.flamingo.parseString(config, layers[id].language);
				for (var attr in config.attributes) {
					var val:String = config.attributes[attr];
					switch (attr.toLowerCase()) {
					case "aka" :
						this.aka[val] = id;
						break;
					case "fields" :
						layers[id].fields = val;
						break;
					default :
						layers[id][attr.toLowerCase()] = val;
						break;
					}
				}
			}
		}
	}
	function trim(str:String):String {
		var i = 0;
		var j = str.length-1;
		for(; str.charCodeAt(i) < 33; i++);
		for(; str.charCodeAt(j) < 33; j--);
		return str.substring(i, j+1);
	}
	/**
	* Sets a url parameter to be used with sld attribute
	* @param sldParamNew: String value to be appended to the sld attribute, must be url encoded
	*/
	function setSLDparam(sldParamNew:String) {
	  this.sldParam = tools.Utils.trim(sldParamNew);
	  update();
	}

	/**
	* gets the sld parameter 
	* @return sldParam: String value which is appended to the sld attribute, is url encoded
	*/
	function getSLDparam():String {
	  return this.sldParam;
	}
	/**
	* Gets the url of a service
	* @return the url
	*/
	function getUrl(){
		return this.url;
	}

	function _parseLayers(tlayers:Array) {
		var thisObj:OGCWMSLayer = this;
		for(var i:Number=0;i<tlayers.length;i++){
			if (tlayers[i].name != null) {
				var layerid:String = tlayers[i].name;
				var old = thisObj.layers[layerid];
				delete thisObj.layers[layerid];
				if (thisObj.layers[layerid] == undefined) {
					thisObj.layers[layerid] = new Object();
					if (thisObj.slayers == "#ALL#") {
						thisObj.layers[layerid].visible = true;
					}
					if (thisObj.query_layers == "#ALL#") {
						thisObj.layers[layerid].identify = true;
					}
				}
				for (var attr in old) {
					thisObj.layers[layerid][attr] = old[attr];
				}
				delete old;
			}
			for (var attr in tlayers[i]) {
				if(tlayers[i].name!=null){
					var layerid:String = tlayers[i].name;
					if (thisObj.layers[layerid][attr] == undefined) {
						thisObj.layers[layerid][attr] = tlayers[i][attr];
					}
					if (attr == "styles") {
						var s_style = tlayers[i].style;
						var s_url = tlayers[i].styles[s_style].legendurl;
						_global.flamingo.raiseEvent(thisObj, "onGetLegend", thisObj, s_url, layerid);
					}
				}
				if (attr == "layers") {
					_parseLayers(tlayers[i][attr]);
				}
			} 		
		}
	}
	/**
	* Updates a layer. Only one request will be fired at a time.
	* After the image is loaded the function checks if the mapextent is changed meanwhile.
	* If so, the function fires another request.
	* @forceupdate forces a  update. A timestamp is added in seconds.
	*/
	public function update(forceupdate:Boolean) {
		_update(1,forceupdate);
	}
	
	function _update(nrtry:Number, forceupdate:Boolean) {
		var thisObj:OGCWMSLayer = this;
		//_global.flamingo.tracer("LayerOGWMS _update " + _global.flamingo.getId(this) + " visible " + visible);
		if (! this.visible|| ! map.visible) {
			this.container._visible = false;
			return;
		}
		//only one request will be fired at once                                                                                    
		if (this.updating) {
			return;
		}
		if (this.url == undefined) {
			return;
		}
		if (!map.hasextent) {
			return;
		}
		extent = map.getMapExtent();
		
		lastFiltersFingerprint = "";
		
		var ms:Number = map.getScaleHint(extent);
		if (minscale != undefined) {
			if (ms<=minscale) {
				_global.flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
				_global.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
				this.container._visible = false;
				return;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				_global.flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
				_global.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
				this.container._visible = false;
				return;
			}
		}
		var layerstring = getLayersString();
		//_global.flamingo.tracer("_Update " + _global.flamingo.getId(this) + " layerstring==" + layerstring + "!updateWhenEmpty" + !updateWhenEmpty);
		if (layerstring.length<=0 && ((this.attributes["sld"] == undefined)||!updateWhenEmpty)) {
			_global.flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
			_global.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
			this.container._visible = false;
			return;
		}
		//var requestedextent = map.getMapExtent();                                                                                    
		if (fullextent != undefined) {
			if (!map.isHit(fullextent)) {
				_global.flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
				_global.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
				_visible = false;
				return;
			}
		}
		updating = true;
		_visible = true;
		nrcache++;
		var cachemovie:MovieClip = this.container.createEmptyMovieClip("mCache" + nrcache, nrcache);
		cachemovie.createEmptyMovieClip("mHolder", 0);
		cachemovie._alpha = 0;
		var w = map.__width;
		var h = map.__height;
		cachemovie.extent = new Object();
		if (this.fullextent != undefined and this.limitedtofullextent) {
			cachemovie.extent.minx = Math.max(extent.minx, this.fullextent.minx);
			cachemovie.extent.miny = Math.max(extent.miny, this.fullextent.miny);
			cachemovie.extent.maxx = Math.min(extent.maxx, this.fullextent.maxx);
			cachemovie.extent.maxy = Math.min(extent.maxy, this.fullextent.maxy);
			var r = map.extent2Rect(cachemovie.extent, extent);
			w = r.width;
			h = r.height;
		} else {
			cachemovie.extent.minx = extent.minx;
			cachemovie.extent.miny = extent.miny;
			cachemovie.extent.maxx = extent.maxx;
			cachemovie.extent.maxy = extent.maxy;
		}
		caches[nrcache] = cachemovie;
		//extent;
		//listener for OGWMSConnector	
		var lConn:Object = new Object();
		lConn.onRequest = function(connector:OGWMSConnector) {
			//_global.flamingo.tracer(requestobject.url);
			_global.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "update", connector);
		};
		lConn.onResponse = function(connector:OGWMSConnector) {
			//trace(responsobject.response);
			_global.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "update", connector);
		};
		lConn.onError = function(error:String, objecttag:Object) {
			thisObj._stoptimeout();
			if (thisObj.showerrors) {
				_global.flamingo.showError("LayerOGWMS error", error);
			}
			thisObj.updating = false;
			if (nrtry<thisObj.retryonerror) {
				nrtry++;
				thisObj._update(nrtry);
			} else {
				_global.flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
			}
		};
		lConn.onGetMap = function(imageurl:String, objecttag:Object) {
			var newDate:Date = new Date();
			var requesttime = (newDate.getTime()-thisObj.starttime.getTime())/1000;
			//listener for MovieClipLoader
			var listener:Object = new Object();
			listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
				thisObj._stoptimeout();
				thisObj.updating = false;
				_global.flamingo.raiseEvent(thisObj, "onUpdateError", thisObj, error);
			};
			cachemovie.mHolder.onData=listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
				thisObj._stoptimeout();
				_global.flamingo.raiseEvent(thisObj, "onUpdateProgress", thisObj, bytesLoaded, bytesTotal);
			};
			cachemovie.mHolder.onLoad=listener.onLoadInit = function(mc:MovieClip) {
				var correctedExtent=thisObj.map.copyExtent(thisObj.extent);
				thisObj.map.correctExtent(correctedExtent);
				thisObj._stoptimeout();
				var newTime:Date = new Date();
				var loadtime = (newTime.getTime()-thisObj.starttime.getTime())/1000;
				thisObj.updateCache(cachemovie);
				var currentFiltersFingerprint:String = "";
				if (thisObj.map.fadesteps>0) {
					var step = (100/thisObj.map.fadesteps)+1;
					thisObj.container.onEnterFrame = function() {
						cachemovie._alpha = cachemovie._alpha+step;
						if (cachemovie._alpha>=100) {
							delete thisObj.container.onEnterFrame;
							thisObj.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, requesttime, loadtime, mc.getBytesTotal());
							thisObj.updating = false;
							thisObj._clearCache();
							if ((!thisObj.map.isEqualExtent(correctedExtent) and !thisObj.map.isEqualExtent(thisObj.extent)) || thisObj._getVisLayers() != thisObj.vislayers ||
								("|" + currentFiltersFingerprint + "|") !=  ("|" + thisObj.lastFiltersFingerprint + "|")) {
								//_global.flamingo.tracer("re-update, fadesteps>0");
								this.update();
							}
						}
					};
				} else {
					cachemovie._alpha = 100;
					_global.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, requesttime, loadtime, mc.getBytesTotal());
					thisObj.updating = false;
					thisObj._clearCache();
					if (((!thisObj.map.isEqualExtent(correctedExtent)) and (!thisObj.map.isEqualExtent(thisObj.extent))) || thisObj._getVisLayers() != thisObj.vislayers ||
						("|" + currentFiltersFingerprint + "|") !=  ("|" + thisObj.lastFiltersFingerprint + "|")) {
						//_global.flamingo.tracer("re-update, fadesteps<=0");
						thisObj.update();
					}
				}
			};
			if (thisObj.maxHttpGetUrlLength > 0 && imageurl.length >thisObj.maxHttpGetUrlLength){
				if (imageurl.split("?").length > 1){
					var parameters:Array = imageurl.split("?")[1].split("&");
					for (var p=0; p < parameters.length; p++){
						if(parameters[p].split("=").length>1){
							cachemovie.mHolder[parameters[p].split("=")[0]]=unescape(parameters[p].split("=")[1]);						
						}
					}						
					cachemovie.mHolder.oldLoadMovie = cachemovie.mHolder.loadMovie;				
					cachemovie.mHolder.loadMovie =function(url,vars){
						if(this.onData != undefined && this.onData != null){
							this._parent.createEmptyMovieClip("__fixEvents",7777);
							this._parent.__fixEvents.theTarget=this;
							this._parent.__fixEvents.onData=this.onData;
							if(this.onLoad != undefined && this.onLoad != null){
								this._parent.__fixEvents.onLoad=this.onLoad;
							}
							this._parent.__fixEvents.onEnterFrame=function(){							
								this.oldv=this.v;
								this.v=this.theTarget.getBytesLoaded();							
								if(this.v!=0 && (this.v != this.oldv)){
									this.onData.call(this.theTarget);
								}
								if(this.theTarget._framesLoaded>0 && this.v >0){
									this.theTarget.onData=this.onData;
									if(this.onLoad != undefined){
										this.theTarget.onLoad=this.onLoad;
									}
									this.onLoad.call(this.theTarget);
									this.removeMovieClip();
								}
							}
						}
						this.oldLoadMovie(url,vars)
					};				
					var urlWithoutParams:String;
					//remove all params. The params are already loaded in the body.
					if (thisObj.url.indexOf("?")>-1){
						urlWithoutParams=thisObj.url.split("?")[0];
					}else{
						urlWithoutParams=thisObj.url;
					}
					cachemovie.mHolder.loadMovie(urlWithoutParams,"POST");				
					thisObj.starttime = new Date();
					thisObj._starttimeout();
				}			
			}else{			
				//listener for MovieClipLoader
				var mcl:MovieClipLoader = new MovieClipLoader();
				mcl.addListener(listener);
				mcl.loadClip(imageurl, cachemovie.mHolder);
				this.starttime = new Date();
				thisObj._starttimeout();			
			
			}
		};
		var cogwms:OGWMSConnector = new OGWMSConnector();
		cogwms.addListener(lConn);
		//
		var args:Object = new Object();
		args.BBOX = this.extent2String(cachemovie.extent);
		args.WIDTH = Math.ceil(w);
		args.HEIGHT = Math.ceil(h);
		args.FORMAT = this.format;
		args.LAYERS = layerstring;
		args.EXCEPTIONS = this.exceptions;
		args.VERSION = this.wmsversion;
		args.SRS = this.srs;
		if (forceupdate == true) {
			var date = new Date();
			args.TIMESTAMP= date.getMilliseconds()/1000;
		}
		if (this.transparent != undefined) {
			args.TRANSPARENT = this.transparent.toString().toUpperCase();
		}
		var s_styles = this.getStylesString();
		if (s_styles.length>=0) {
			args.STYLES = s_styles;
		}

		args = handleSLDarg(args);
	  
		// 
		this.starttime = new Date();
		//
		vislayers = _getVisLayers();
		_global.flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
		//if the args.width or args.height are lower or equal to 0 then don't do a update.
		if (Number(args.WIDTH) <=0 || Number(args.HEIGHT) <=0){
			trace("update=false");
			updating = false;
			_visible = false;
			return;
		}
		if (this.noCache==true){			
			var newurl=_global.flamingo.getNocacheName(url,'second');
			cogwms.getMap(newurl, args);
		}else{
			cogwms.getMap(url, args);
		}
		thisObj._starttimeout();
	}
	function _starttimeout() {
		clearInterval(timeoutid);
		timeoutid = setInterval(this, "_timeout", (timeout*1000));
	}
	function _stoptimeout() {
		clearInterval(timeoutid);
	}
	function _timeout() {
		var thisObj:OGCWMSLayer = this;
		clearInterval(timeoutid);
		updating = false;
		_global.flamingo.raiseEvent(thisObj, "onUpdateError", thisObj, "timeout, connection failed...");
	}
	function cancelIdentify() {
		this.identifyextent = undefined;
	}
	/**
	* Identifies a layer.
	* @param identifyextent:Object extent of the identify
	* @param map:MovieClip [optional]
	*/
	function identify(extent:Object) {
		var thisObj:OGCWMSLayer = this;
		if (url == undefined and getfeatureinfourl == undefined) {
			return;
		}
		if (!_visible || !visible) {
			return;
		}
		if (fullextent != undefined) {
			if (!map.isHit(fullextent, identifyextent)) {
				return;
			}
		}
		var querylayerstring = _getLayerlist(query_layers, "identify");
		var nrlayersqueried = querylayerstring.split(",").length;
		if (querylayerstring.length<=0) {
			return;
		}
		this.identifyextent = extent;
		var lConn:Object = new Object();
		lConn.onResponse = function(connector:OGWMSConnector) {
			thisObj.identsSent--; 
			_global.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "identify", connector);
		};
		lConn.onRequest = function(connector:OGWMSConnector) {
			thisObj.identsSent++; 
			_global.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "identify", connector);
		};
		lConn.onError = function(error:String, obj:Object, requestid:String) {
			if (thisObj.showerrors) {
				_global.flamingo.showError("LayerOGWMS error", error);
			}
			_global.flamingo.raiseEvent(thisObj, "onError", thisObj, "identify", error);
		};
		lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
			if (thisObj.map.isEqualExtent(thisObj.identifyextent, obj)) {
				var date = new Date();
				var identifytime = (date.getTime()-thisObj.starttime.getTime())/1000;
				for (var layer in features) {
					var realname = thisObj.aka[layer];
					if (realname != undefined) {
						features[realname] = features[layer];
						delete features[layer];
					}
				}
				_global.flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, features, obj, nrlayersqueried, nrlayersqueried);
				if(thisObj.identPerLayer){
					if(thisObj.identsSent == 0){
						_global.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, identifytime);
					}
				} else {
					_global.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, identifytime);
				}
			}
		};
			
		var args:Object = new Object();
		args.BBOX = this.extent2String(map.getMapExtent());
		args.WIDTH = Math.ceil(map.__width);
		args.HEIGHT = Math.ceil(map.__height);
		args.INFO_FORMAT = this.info_format;
		args.FORMAT = this.format;
		args.EXCEPTIONS = this.exceptions;
		args.VERSION = this.wmsversion;
		args.SRS = this.srs;
		args.STYLES = getStylesString();
		var rect = map.extent2Rect(this.identifyextent);
		args.X = String(Math.round(rect.x+(rect.width/2)));
		args.Y = String(Math.round(rect.y+(rect.height/2)));
		args.FEATURE_COUNT = String(feature_count);
		args = handleSLDarg(args);
		if(identPerLayer){
			identifyPerLayer(args,lConn);
		} else {
			args.LAYERS = getLayersString();
			args.QUERY_LAYERS = querylayerstring;
			sendIdentifyRequest(args,lConn);
		}	
	}

	function identifyPerLayer(args:Object,lConn:Object) {
			var querylayerstring = _getLayerlist(query_layers, "identify");
			var qlayers:Array = querylayerstring.split(",");
			for (var i:Number=0; i<qlayers.length;i++){
				args.LAYERS = qlayers[i];
				args.QUERY_LAYERS = qlayers[i];
				
				sendIdentifyRequest(args,lConn);
			}
	}


	function sendIdentifyRequest(args:Object, lConn:Object) {
		var thisObj:OGCWMSLayer = this;
		var cogwms:OGWMSConnector = new OGWMSConnector();
		cogwms.addListener(lConn);
		_global.flamingo.raiseEvent(thisObj, "onIdentify", thisObj, thisObj.identifyextent);
		if (getfeatureinfourl != undefined) {
			var reqid = cogwms.getFeatureInfo(getfeatureinfourl, args, this.map.copyExtent(this.identifyextent));
		} else {
			var reqid = cogwms.getFeatureInfo(url, args, this.map.copyExtent(this.identifyextent));
		}
		this.starttime = new Date();
	}

	/*
	* private function to handle filter params in sld argument
	*/

	function handleSLDarg(argsLocal:Object):Object {
		for (var attr in this.attributes) {
		  argsLocal[attr.toUpperCase()] = this.attributes[attr];
		}
		if ((argsLocal["SLD"] != null) && (argsLocal["SLD"] != "")) {
			argsLocal["SLD"] = tools.Utils.trim(argsLocal["SLD"]);
			argsLocal["SLD"] += escape(sldParam.split(" ").join("+")); //replace spaces with "+" and url encode (spaces must be 'double encoded')
			/*if (this.filterLayerLayerOGWMSAdapter != undefined) {
				 argsLocal["SLD"] += this.filterLayerLayerOGWMSAdapter.getUrlFilter();
			}*/
		}
		return argsLocal;
	}

	function stopMaptip() {
		this.showmaptip = false;
		this.maptipextent = undefined;
	}
	function startMaptip(x:Number, y:Number) {
		var thisObj:OGCWMSLayer = this;
		if (!this.canmaptip) {
			return;
		}
		if (url == undefined and getfeatureinfourl == undefined) {
			return;
		}
		if (!_visible || !visible) {
			return;
		}
		var maptiplayerstring = _getLayerlist(maptip_layers, "maptip");
		if (maptiplayerstring.length<=0) {
			return;
		}
		var r = new Object();
		r.x = x;
		r.y = y;
		r.width = 0;
		r.height = 0;
		this.maptipextent = this.map.rect2Extent(r);
		if (this.fullextent != undefined) {
			if (!this.map.isHit(this.fullextent, this.maptipextent)) {
				return;
			}
		}
		this.showmaptip = true;
		var lConn:Object = new Object();
		lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
			if (thisObj.showmaptip) {
				if (thisObj.map.isEqualExtent(thisObj.maptipextent, obj)) {
					var combinedMaptip="";
					for (var layer in features) {
						var id = thisObj.aka[layer];
						if (id == undefined) {
							id = layer;
						}
						var maptip = thisObj._getString(thisObj.layers[id], "maptip");
						if (maptip.length>0) {
							var record = features[layer][0];
							for (var field in record) {
								if (maptip.indexOf("["+field+"]", 0)>=0) {
									maptip = maptip.split("["+field+"]").join(record[field]);
								}
							}
							if (combinedMaptip.length >0){
								combinedMaptip+="\n";
							}
							combinedMaptip+=maptip;
						}
					}
					_global.flamingo.raiseEvent(thisObj, "onMaptipData", thisObj, combinedMaptip);				
				}
			}
		};
		var args:Object = new Object();
		args.BBOX = this.extent2String(map.getMapExtent());
		args.WIDTH = Math.ceil(map.__width);
		args.HEIGHT = Math.ceil(map.__height);
		args.LAYERS = maptiplayerstring;
		args.QUERY_LAYERS = maptiplayerstring;
		args.INFO_FORMAT = this.info_format;
		args.FORMAT = this.format;
		args.EXCEPTIONS = this.exceptions;
		args.VERSION = this.wmsversion;
		args.SRS = this.srs;
		args.X = x;
		args.Y = y;	
		args.FEATURE_COUNT = maptipFeatureCount;
		for (var attr in this.attributes) {
			args[attr.toUpperCase()] = this.attributes[attr];
		}
		var cogwms:OGWMSConnector = new OGWMSConnector();
		cogwms.addListener(lConn);
		if (getfeatureinfourl != undefined) {
			var reqid = cogwms.getFeatureInfo(getfeatureinfourl, args, this.map.copyExtent(this.maptipextent));
		} else {
			var reqid = cogwms.getFeatureInfo(url, args, this.map.copyExtent(this.maptipextent));
		}
	}
	
	function extent2String(ext:Object):String {
		return (ext.minx+","+ext.miny+","+ext.maxx+","+ext.maxy);
	}
	function string2Extent(str:Object):Object {
		var extent:Object = new Object();
		var a:Array = str.split(",");
		extent.minx = Number(a[0]);
		extent.maxx = Number(a[2]);
		extent.miny = Number(a[1]);
		extent.maxy = Number(a[3]);
		if (extent.minx>extent.maxx) {
			var maxx = extent.maxx;
			extent.maxx = extent.minx;
			extent.minx = maxx;
		}
		if (extent.miny>extent.maxy) {
			var maxy = extent.maxy;
			extent.maxy = extent.miny;
			extent.miny = maxy;
		}
		return (extent);
	}
	function _getLayerlist(list:String, field:String):String {
		//function getQueryLayersString():String {
		var s:String;
		if (list.length == 0) {
			return s;
		}
		if (list.toUpperCase() == "#ALL#") {
			var a = new Object();
			for (var id in layers) {
				if (layers[id].visible and layers[id].queryable) {
					a[id] = "";
				}
			}
			for (var id in a) {
				if (s == undefined) {
					s = id;
				} else {
					s += ","+id;
				}
			}
			return s;
		}
		var a:Array = _global.flamingo.asArray(list);
		for (var i = 0; i<a.length; i++) {
			var id = a[i];
			//if (layers[id].visible == false) {
				//continue;
			//}
			if (getVisible(id) !=1) {
				continue;
			}
			if (layers[id].queryable == false) {
				continue;
			}
			if (layers[id][field] == false) {
				continue;
			}
			if (s == undefined) {
				s = id;
			} else {
				s += ","+id;
			}
		}
		return s;
	}
	function getStylesString():String {
		var s = "";
		if (slayers.length == 0) {
			return s;
		}
		if (slayers == "#ALL#") {
			for (var id in layers) {
				if (layers[id].styles == undefined) {
					return s;
				}
			}
			var a = new Object();
			for (var id in layers) {
				if (layers[id].visible) {
					a[id] = layers[id].style;
				}
			}
			for (var id in a) {
				if (s == "") {
					s = a[id];
				} else {
					s += ","+a[id];
				}
			}
			return s;
		}
		var a:Array = slayers.split(",");
		for (var i = 0; i<a.length; i++) {
			var id = a[i];
			if (layers[id].visible == false) {
				continue;
			}
			if (layers[id].style==undefined){
				return "";
			}
			if (s == "") {
				s = layers[id].style;
			} else {
				s += ","+layers[id].style;
			}
		}
		return s;
	}
	function getLayersString():String {
		var s = "";
		if (slayers.length == 0) {
			return s;
		}
		if (slayers == "#ALL#") {
			var a = new Object();
			for (var id in layers) {
				if (layers[id].visible) {
					a[id] = "";
				}
			}
			for (var id in a) {
				if (s == "") {
					s = id;
				} else {
					s += ","+id;
				}
			}
			return s;
		}
		var a:Array = slayers.split(",");
		for (var i = 0; i<a.length; i++) {
			var id = a[i];
			if (layers[id].visible == false) {
				continue;
			}
			if (s == "") {
				s = id;
			} else {
				s += ","+id;
			}
		}
		return s;
		//turns the layers object into a string, regarding visible and order 
		/*
		var a:Array = new Array();
		var s:String;
		for (var id in layers) {
		if (layers[id].visible) {
		a.push({id:id, order:layers[id].order});
		}
		}
		a.sortOn("order", Array.NUMERIC);
		for (var i = 0; i<a.length; i++) {
		if (s == undefined) {
		s = a[i].id;
		} else {
		s += ","+a[i].id;
		}
		}
		return s;
		*/
	}
	function _clearCache() {
		for (var nr in caches) {
			if (nr != nrcache) {
				this.caches[nr].removeMovieClip();
				delete caches[nr];
			}
		}
	}
	function updateCaches() {
		for (var nr in caches) {
			this.updateCache(caches[nr]);
		}
	}
	function getLegend(id):String {
		return layers[id].legendurl;
	}
	/** 
	* Gets the scale of the layer
	* @return Number Scale.
	*/
	function getScale():Number {
		return map.getScaleHint(extent);
	}
	function updateCache(cache:MovieClip) {		
		if (cache == undefined) {
			return;
		}
		if (visible) {
			var ms = map.getScaleHint();
			if (minscale != undefined) {
				if (ms<=minscale) {
					_visible = false;
					return;
				}else{
					/*If in a previous updateCache the movie could be set to _visible=false
					then also set the _visible = true if this movie must be visible (according the scale)
					*/
					_visible =true;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					_visible = false;
					return;
				}else{
					/*If in a previous updateCache the movie could be set to _visible=false
					then also set the _visible = true if this movie must be visible (according the scale)
					*/
					_visible =true;
				}
			}
			/*Why do a _visible=true????? 
			*Don't set the visibility if the cache is updated!
			*It causes some unpredictable stuff....
			*If all layers are not visible and the map is updated the cache will be visible for a short time! 
			*/
			//_visible = true;
			
			var r:Object = map.extent2Rect(cache.extent);
			//cache.scrollRect = new flash.geom.Rectangle(0, 0, map.__width, map.__height);
			cache._x = r.x;
			cache._y = r.y;
			cache._width = r.width;
			cache._height = r.height;
		}
	}
	/**
	* Hides a layer.
	* @param map:MovieClip [optional]
	*/
	function hide() {
		_visible = false;
		update();
		_global.flamingo.raiseEvent(this, "onHide", this);
	}
	/**
	* Shows a layer.
	* @param map:MovieClip [optional]
	*/
	function show() {
		_visible = true;
		updateCaches();
		update();
		_global.flamingo.raiseEvent(this, "onShow", this);
	}
	function _getVisLayers():String {
		var s = "";
		for (var layer in layers) {
			if (layers[layer].visible) {
				s += "1";
			} else {
				s += "0";
			}
		}
		return s;
	}
	/** 
	* Changes the layers collection.
	* @param ids:String Comma seperated string of affected layerids. If keyword "#ALL#" is used, all layers will be affected.
	* @param field:String Property that has to be changed. e.g. "visible", "legend", "identify"
	* @param value:Object Value to be set.
	* @example mylayer.setLayerProperty("39,BRZO","visible",true)
	* mylayer.setLayerProperty("#ALL#","identify",false)
	*/
	function setLayerProperty(ids:String, field:String, value:Object) {
		if (ids.toUpperCase() == "#ALL#") {
			for (var id in layers) {
				layers[id][field] = value;
			}
		} else {
			var a_ids = _global.flamingo.asArray(ids);
			for (var i = 0; i<a_ids.length; i++) {	
				var id = a_ids[i];
				if (layers[id] == undefined) {
					layers[id] = new Object();
					layers[id][field] = value;
				} else {
					layers[id][field] = value;
				}
				//_global.flamingo.tracer("voor " + layers[id] + " field " + field + " issetto " + value); 
			}
		}
		_global.flamingo.raiseEvent(this, "onSetLayerProperty", this, ids, field);
	}
	/** 
	* Gets a property of a layer in the layers collection.
	* @param id:String Layerid.
	* @param field:String Property. e.g. "visible", "legend", "identify"
	* @return Object Value of property.
	*/
	function getLayerProperty(id:String, field:String):Object {
		if (layers[id] == undefined) {
			return null;
		}
		return layers[id][field.toLowerCase()];
	}

	/** 
	* Returns a reference to the layers collection.
	* Be carefull for making changes.
	* @return Object Collection of layers. A layer is an object with several properties, such as name, id, maxscale etc.
	*/
	function getLayers():Object {
		return layers;
	}
	/** 
	* Gets an array of layerids.
	* @return Array List of layerids.
	*/
	function getLayerIds():Array {
		var a = new Array();
		for (var id in layers) {
			a.push(id);
		}
		return a;
	}
	/** 
	* Moves the map to a scale where the (map)layer is visible.
	* @param ids:String Comma seperated string of layers. If omitted the scale of the maplayer will be used.
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	function moveToLayer(ids:String, coord:Object, updatedelay:Number, movetime:Number):Void {
		var zoomtoscale;
		if (ids == undefined || ids == "") {
			if (maxscale != undefined) {
				zoomtoscale = maxscale*0.9;
			}
			if (minscale != undefined) {
				zoomtoscale = minscale*1.1;
			}
		} else {
			var a_ids = ids.split(",");
			for (var i = 0; i<a_ids.length; i++) {
				var layer = layers[a_ids[i]];
				if (layer != undefined) {
					//first examine maxscale
					if (layer.maxscale != undefined) {
						if (zoomtoscale == undefined) {
							zoomtoscale = layer.maxscale*0.9;
						} else {
							zoomtoscale = Math.min(zoomtoscale, layer.maxscale*0.9);
						}
					} else if (layer.minscale != undefined) {
						if (zoomtoscale == undefined) {
							zoomtoscale = layer.minscale*1.1;
						} else {
							zoomtoscale = Math.max(zoomtoscale, layer.minscale*1.1);
						}
					}
				}
			}
		}
		if (zoomtoscale != undefined) {
			map.moveToScaleHint(zoomtoscale, coord, updatedelay, movetime);
		}
	}
	/** 
	* Changes the visiblity of a layer or a sub-layer.
	* @param vis:Boolean True (visible) or false (not visible).
	* @param id:String [optional] A layerid. If omitted the entire maplayer will be effected.
	*/
	function setVisible(vis:Boolean, id:String) {
		if (id.length == 0 || id == undefined) {
			if (vis) {			
				this.show();
			} else {
				this.hide();
			}
		} else {
			this.setLayerProperty(id, "visible", vis);
		}
	}
	/** 
	* Checks if a maplayer or a layer of a maplayer is visible.
	* @param id:String [optional] A layerid. If omitted the entire maplayer will be checked.
	* @return Number -3, -2, -1, 0, 1, 2, or 3
	* -3 = layer is not visible and maplayer is not visible
	* -2 = (map)layer is not visible and (map)layer is out of scale
	* -1 = (map)layer is not visible;
	*  0 = layer does not exist
	*  1 = (map)layer is visible;
	*  2 = (map)layer is visible and (map)layer is out of scale
	*  3 = layer is visible and maplayer is not visible
	*/
	function getVisible(id:String):Number {
		var ms:Number = map.getScaleHint(map.getMapExtent());	
		if (id == undefined || id.length == 0) {
			//examine whole layer
			if (visible) {
				if (minscale != undefined) {
					if (ms<minscale) {
						return 2;
					}
				}
				if (maxscale != undefined) {
					if (ms>maxscale) {
						return 2;
					}
				}
				return 1;
			} else {
				if (minscale != undefined) {
					if (ms<minscale) {
						return -2;
					}
				}
				if (maxscale != undefined) {
					if (ms>maxscale) {
						return -2;
					}
				}
				return -1;
			}
		} else {
			var sublayer = layers[id];
			//_global.flamingo.tracer("LayerOGWMS sublayer.visible "+ sublayer.visible + " sublayer.maxscale " + sublayer.maxscale + " ms " + ms);
			if (sublayer == undefined) {
				return 0;
			} else {
				if (sublayer.visible==true||sublayer.visible==undefined) {
					if (visible) {
						if (sublayer.minscale != undefined) {
							if (ms<sublayer.minscale) {
								return 2;
							}
						}
						if (sublayer.maxscale != undefined) {
							if (ms>sublayer.maxscale) {
								return 2;
							}
						}
						return 1;
					} else {
						return 3;
					}
				} else {
					if (visible) {
						if (sublayer.minscale != undefined) {
							if (ms<sublayer.minscale) {
								return -2;
							}
						}
						if (sublayer.maxscale != undefined) {
							if (ms>sublayer.maxscale) {
								return -2;
							}
						}
						return -1;
					} else {
						return -3;
					}
				}
			}
		}
	}
	function _getString(item:Object, stringid:String):String {
		var lang = _global.flamingo.getLanguage();
		var s = item.language[stringid][lang];
		if (s.length>0) {
			//option A
			return s;
		}
		s = item[stringid];
		if (s.length>0) {
			//option B
			return s;
		}
		for (var attr in item.language[stringid]) {
			//option C
			return item.language[stringid][attr];
		}
		//option D
		return "";
	}
	/**
	* Returns null if the string is empty
	* attr s the string to check
	*/
	function nullIfEmpty(s:String):Object{
		if (s==undefined){
			return null;
		}
		if (s==""){
			return null;
		}
		if (s.length <= 0){
			return null;
		}
		return s;		
	}
	
	/*************************************************************
	 * Overwrites of map listener functions in AbstractLayer
	 **/
	public function onChangeExtent(map:MovieClip):Void {
		this.updateCaches();
	}
	public function onHide(map:MovieClip):Void  {
		this.update();
	}
	public function onShow(map:MovieClip):Void  {
		this.update();
	}

	/**
	* Dispatched when the layer gets a request object from the connector.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" or "init"
	* @param requestobject:Object the object returned from the OGWMSConnector, containing the raw requests and other properties.
	*/
	//public function onRequest(layer:MovieClip, type:String, requestobject:Object):Void {
	//
	/**
	* Dispatched when the layer gets a response object from the connector.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" or "init"
	* @param responseobject:Object the object returned from the OGWMSConnector, containing the raw response and other properties.
	*/
	//public function onResponse(layer:MovieClip, type:String, responseobject:Object):Void {
	//
	/**
	* Dispatched when there is an error.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" or "init"
	* @param error:String error message
	*/
	//public function onError(layer:MovieClip, type:String, error:String):Void {
	/**
	* Dispatched when the layer is identified.
	* @param layer:MovieClip a reference to the layer.
	* @param identifyextent:Object the extent that is identified
	*/
	//public function onIdentify(layer:MovieClip, identifyextent:Object):Void {
	/**
	* Dispatched when the layer is identified and data is returned
	* @param layer:MovieClip a reference to the layer.
	* @param data:Object data object with the information 
	* @param identifyextent:Object the original extent that is identified 
	* @param nridentified:Number Number of sublayers thas has already been identified.
	* @param total:Number Total number of sublayers that has to be identified 
	*/
	//public function onIdentifyData(layer:MovieClip, data:Object, identifyextent:Object,nridentified:Number,total:Number):Void {
	/**
	* Dispatched when the identify is completed.
	* @param layer:MovieClip a reference to the layer.
	* @param identifytime:Number total time of the identify 
	*/
	//public function onIdentifyComplete(layer:MovieClip, identifytime:Number):Void {
	/**
	* Dispatched when the starts an update sequence.
	* @param layer:MovieClip a reference to the layer.
	* @param nrtry:Number   number of retry after an error. 
	*/
	//public function onUpdate(layer:MovieClip, nrtry):Void {
	/**
	* Dispatched when the layerimage is downloaded.
	* @param layer:MovieClip a reference to the layer.
	* @param bytesloaded:Number   Number of bytes already downloaded. 
	* @param bytestotal:Number   Total of bytes to be downloaded.
	*/
	//public function onUpdateProgress(layer:MovieClip, bytesloaded:Number, bytestotal:Number):Void {
	/**
	* Dispatched when the layer is completely updated.
	* @param layer:MovieClip a reference to the layer.
	* @param updatetime:Object total time of the update sequence
	*/
	//public function onUpdateComplete(layer:MovieClip, updatetime:Number):Void {
	/**
	* Dispatched when the layer is hidden.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onHide(layer:MovieClip):Void {
	/**
	* Dispatched when the layer is shown.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onShow(layer:MovieClip):Void {
	/**
	* Dispatched when a legend is returned during an update sequence.
	* @param layer:MovieClip a reference to the layer.
	* @param legendurl:String the url of the legend.
	*/
	//public function onGetLegend(layer:MovieClip, legendurl:String):Void {
	/**
	* Dispatched when a the layer is up and running and ready to update for the first time.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onInit(layer:MovieClip):Void {
	/**
	* Dispatched when a the layer gets its initial information from the server.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onGetCapabilities(layer:MovieClip):Void {
	//
	/**
	* Dispatched when a the layers collection is changed by setLayerProperty().
	* @param layer:MovieClip A reference to the layer.
	* @param ids:String  The affected layers.
	*/
	//public function onSetLayerProperty(layer:MovieClip, ids:String, prop:String):Void {
	/**
	* Dispatched when a layer has data for a maptip.
	* @param layer:MovieClip A reference to the layer.
	* @param maptip:String  the maptip
	*/
	//public function onMaptipData(layer:MovieClip, maptip:String):Void {
	//
		
	/*Getters and setters*/	
	public function get updating():Boolean {
		return _updating;
	}
	
	public function set updating(value:Boolean):Void {
		_updating = value;
	}
}