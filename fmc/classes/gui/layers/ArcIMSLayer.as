/**
 * ...
 * @author Roy Braam
 */
import coremodel.service.arcims.ArcIMSConnector;
import core.AbstractPositionable;
import tools.Logger;
import gui.Map;
import gui.layers.AbstractLayer;
/** @component LayerArcIMS
* ESRI arcims layer.
* @version 2.0.4
* @file ArcIMSConnector.as (sourcefile)
* @file LayerArcIMS.fla (sourcefile)
* @file LayerArcIMS.swf (compiled layer, needed for publication on internet)
* @file LayerArcIMS.xml (configurationfile for layer, needed for publication on internet)
* @change 2007-10-25 version 2.0.1
* @change 2007-10-25 FIX - Maptips of layers from local shapefiles didn't show up correctly.
* @change 2007-11-12 version 2.0.2
* @change 2007-11-12 CHANGE - Attribute 'maptipfields' removed of <layer> tag. Maptipfields are determined from the maptip string.
* @change 2007-11-12 CHANGE - The fieldnames between the square brackets in the attribute 'maptip' are no longer case-senstive.
* @change 2007-11-12 CHANGE - onResponse, onRequest and onError events also trigged by the requests of maptips.
* @change 2007-11-12 NEW - Attribute 'maptipdistance' added to the <fmc:LayerArcIMS> tag to control the sensitivity of the maptip.
* @change 2007-11-12 NEW - Attribute 'maptipall' added to the <fmc:LayerArcIMS> tag to control the amount of maptips.
* @change 2007-11-12 NEW - Attributes 'maptipdistance' and 'identifydistance' added to <layer> tag. Each layer can be configured seperatly.
* @change 2007-11-12 NEW - Raster data (images) can now be identified and maptipped.
* @change 2007-11-12 NEW - <layerdefstring> tag added to the <layer> tag for incorporating custom AXL to a sublayer.
* @change 2007-11-12 NEW - <mydatastring> tag added to the <layer> tag for attaching custom data to a sublayer.
* @change 2007-11-12 NEW - 3 new functions to add, remove and get custom data to a layer > addMydata(...)  getMydata(...)  removeMydata(...)
* @change 2007-11-12 NEW - new function to make a ValueMapRender string, based on a layer, some custom data and a couple of classes > getValueMapRenderer(...)
* @change 2008-03-06 NEW - Visualisation selected: Selected can be colored
* @change 2008-11-27 NEW - Initservice parameter added
*/
/** @tag <fmc:LayerArcIMS>  
* This tag defines a ESRI arcims layer.
* @hierarchy childnode of <fmc:Map> 
* @example 
* <fmc:Map id="map"  left="5" top="5" bottom="bottom -5" right="right -5"  extent="13562,306839,278026,614073,Nederland" fullextent="13562,306839,278026,614073,Nederland">
*   <fmc:LayerArcIMS  id="layer1" identifyall="true" server="www.mymap.com"  mapservice="mymap" identifyids="1,39" maptipids="1">
*      <layer id="1" subfields="field1,field2"  maptip="name:[field3]" >
*         <string id="maptip" en="name:[field3]" nl="naam:[field3]"/>
*      </layer>
*   </fmc:LayerArcIMS>
* </fmc:Map>
* @attr server  servername of the ArcIMS mapservice
* @attr servlet (defaultvalue "servlet/com.esri.esrimap.Esrimap")
* @attr mapservice  mapservicename
* @attr outputtype  (defaultvalue = "png24") Image format of requested map.
* @attr transcolor  (defaultvalue = "#FBFBFB") Color which will be transparent.
* @attr backgroundcolor  (defaultvalue = "#FBFBFB") Color of the background.
* @attr legendcolor  (defaultvalue = "#FFFFFF") Color of the background of a legend.
* @attr timeout  (defaultvalue = "10") Time in seconds when the ArcIMSLayer will dispatch an onErrorUpdate event.
* @attr retryonerror (defaultvalue = "0") Number of retrys when encountering an error.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
* @attr identifydistance  (defaultvalue = "10") Distance in pixels for performing getFeatures request.
* @attr maptipdistance  (defaultvalue = "10") Distance in pixels for performing getFeatures request for a maptip.
* @attr featurelimit  (defaultvalue = "1") Number of features that will return after an identify.
* @attr fullextent  Extent of layer (comma seperated list of minx,miny,maxx,maxy). When the map is outside this extent, no update will performed.
* @attr identifyall (defaultvalue = "false") true or false;  true= all layerid's will be identified, false = identify stops after identify success
* @attr maptipall (defaultvalue = "true") true or false;  true= all maptips will show up, false = maptip stops after showing sucessfully the maptip of one layer.
* @attr legend  (defaultvalue = "false") true or false;   false = no legend image wil be generated with an update
* @attr hidelegendids Comma seperated list of layerid's (same as in axl) Id's in this list will not appear in a legend.
* @attr showlegendids Comma seperated list of layerid's (same as in axl) Id's in this list will appear in a legend.
* @attr visibleids Comma seperated list of layerid's (same as in axl) Id's in this list will be visible.
* @attr hiddenids Comma seperated list of layerid's (same as in axl) Id's in this list will be hidden.
* @attr identifyids Comma seperated list of layerid's (same as in axl) Id's in this list will be identified in the order of the list. Use keyword "#ALL#" to identify all layers.
* @attr forceidentifyids Comma seperated list of layerid's (same as in axl) Id's in this list will be identified regardless if they are visible in the order of the list. Use keyword "#ALL#" to identify all layers.
* @attr maptipids Comma seperated list of layerid's (same as in axl) Id's in this list will be queried during a maptip event. Use keyword "#ALL#" to query all layers.
* @attr visible  (defaultvalue "true") true or false
* @attr alpha (defaultvalue = "100") Transparency of the layer.
* @attr colorids Comma seperated list of the layers that need to be colored after a identify
* @attr colorIdsKey comma seperated list of the keys that colors the objects.
* @attr record if true the component let the clicked items colored (click 2 times to uncolor)
* @attr autorefreshdelay  (optional; no defaultvalue) Time in miliseconds (1000 = 1 second) at which rate the layer automatically refreshes. If not given, the layer will not refresh automatically, unless at map level an automatic refresh delay is given.
* @attr initService (default="true") if set to false the service won't do a getCap request to init the service. If set to false all parameters must be filled, and no #ALL# can be used.
*/
/** @tag <layer>  
* This defines a sublayer of an ArcIMS mapservice
* @hierarchy childnode of <fmc:LayerArcIMS> 
* @attr id  layerid, same as in the axl.
* @attr subfields  Comma seperated list of fields, which will be identified.
* @attr identifydistance  (defaultvalue = "10") Distance in pixels for performing getFeatures request.
* @attr maptipdistance (defaultvalue = "10") Distance in pixels for performing getFeatures request for a maptip. 
* @attr featurelimit  (defaultvalue = "1") Number of features that will return after an identify.
* @attr query  The 'where' clause in the getImage and getFeatures request.
* @attr maptip Configuration string for a maptip. Fieldnames between square brackets will be replaced  with their actual values. For multi-language support use a standard string tag with id='maptip'.
*/
/** @tag <layerdefstring>  
* This defines a part of AXL which is added to the request. Use the '<![CDATA[ ...her comes the AXL...  ]]>' tag, to incoperate the AXL.
* @example 
* <fmc:LayerArcIMS  server="myserver" mapservice="mymapservice">
*    <layer id="0">
*          <layerdefstring><!&#91;CDATA&#91;<GROUPRENDERER> <VALUEMAPRENDERER lookupfield='CODE'> 
*                               <EXACT value= '26;27;28;29;30;31 ' label='2600 - 3101'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,200,0'/> </EXACT> 
*                               <EXACT value= '21;22;23;24;25 ' label='2100 - 2600'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,211,40'/> </EXACT> 
*                               <EXACT value= '16;17;18;19;20 ' label='1600 - 2100'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,222,80'/> </EXACT> 
*                               <EXACT value= '11;12;13;14;15 ' label='1100 - 1600'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,233,120'/> </EXACT>
*                               <EXACT value= '6;7;8;9;10 ' label='600 - 1100'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,244,160'/> </EXACT> 
*                               <EXACT value= '1;2;3;4;5 ' label='100 - 600'> <SIMPLEPOLYGONSYMBOL boundarycolor='100,100,100'fillcolor='255,255,200'/> </EXACT> 
*                               <OTHER> <SIMPLEPOLYGONSYMBOL boundarycolor='175,175,175'fillcolor='204,204,204'/> </OTHER> 
*                           </VALUEMAPRENDERER> </GROUPRENDERER>&#93;&#93;></layerdefstring>
*    </layer> 
* </fmc:LayerArcIMS>
* @hierarchy childnode of <layer> 
*/
/** @tag <mydatastring>  
* This tag defines custom data which is joined to a layer with a joinfield. The tag itself contains the data string.
* The first line of the data string contains the fieldnames.
* @example 
* <fmc:LayerArcIMS  server="myserver" mapservice="mymapservice">
*    <layer id="0">
*        <mydatastring jointo="CODE" joinfield="mycode" fielddelimiter="," recorddelimiter="#">mycode,value#1,100#2,200#3,300#4,400#5,500#6,600#7,700#8,800#9,900#10,1000</mydatastring>
*    </layer> 
* </fmc:LayerArcIMS>
* 
* <fmc:LayerArcIMS  server="myserver" mapservice="mymapservice">
*    <layer id="0">
*        <mydatastring jointo="CODE" joinfield="mycode">
*          mycode,value
*				1,100
*				2,200
*				3,300
*				4,400
*				5,500
*				6,600
*		</mydatastring>
*    </layer> 
* </fmc:LayerArcIMS>
* @hierarchy childnode of <layer> 
* @attr jointo Fieldname to which the data will be joined. This field must exists in the layer.
* @attr joinfield  Fieldname of mydata which contains the comparable joinid's.
* @attr fielddelimiter (defaultvalue = ",") A token which acts as the field delimiter.
* @attr recorddelimiter (defaultvalue = "\n") A token which acts as the record delimiter.
*
/****
/** @ tag <visualisationselected>
* This tag defines the visualisation of selected features. The attributes are identical to the attributes of ArcIMS renderer attributes. 
* Default values are shown between square braquets.
* <layer id="110">
*     <visualisationselected id="110" fillcolor="255,0,0" other_fillcolor="255,255,255"/>
* </layer>
* @hierarchy childnode of <layer> 
* @attr antialiasing="true | false" [false]
* @attr boundary="true | false" [true]
* @attr boundarycaptype="butt | round | square" [butt]
* @attr boundarycolor="0,0,0 - 255,255,255" [0,0,0]
* @attr boundaryjointype="round | miter | bevel" [round]
* @attr boundarytransparency="0.0 - 1.0" [1]
* @attr boundarytype="solid | dash | dot | dash_dot | dash_dot_dot" [solid]
* @attr boundarywidth="1 - NNN" [1]
* @attr fillcolor="0,0,0 - 255,255,255" [0,200,0]
* @attr fillinterval="2 - NNN" [6]
* @attr filltransparency="0.0 - 1.0" [1]
* @attr filltype="solid | bdiagonal | fdiagonal | cross | diagcross | horizontal | vertical | gray | lightgray | darkgray" [solid]
* @attr overlap="true | false" [true]
* @attr transparency="0.0 - 1.0" [no default]
* @attr other_<see above> = the attributes for not selected objects
*
*/
class gui.layers.ArcIMSLayer extends AbstractLayer{
	
	//properties which can be set in ini
	var fullextent:Object;
	var server:String;
	var servlet:String;
	var mapservice:String;
	var featurelimit:Number = 1;
	var identifydistance:Number = 10;
	var maptipdistance:Number = 10;
	var legend:Boolean = false;
	var legendurl:String;
	var minscale:Number;
	var maxscale:Number;
	var identifyall:Boolean = false;
	var maptipall:Boolean = true;
	var retryonerror:Number = 0;
	var timeout:Number = 10;
	var backgroundcolor:Number = 0xFBFBFB;
	var transcolor:Number = 0xFBFBFB;
	var legendcolor:Number = 0xFFFFFF;
	var identifyids:String;
	var forceidentifyids:String;
	var maptipids:String;
	var hidelegendids:String;
	var showlegendids:String;
	var visibleids:String;
	var hiddenids:String;
	var outputtype:String = "png24";
	var alpha:Number = 100;
	//---------------------------------
	var layers:Object;
	var vislayers:String = null;
	var updating:Boolean = false;
	var nrcache:Number = 0;
	var map:Map;
	var caches:Object;
	//var thisObj:ArcIMSLayer = this;
	var _identifylayers:Array;
	var _hotlinklayers:Array;
	var _maptiplayers:Array;
	var identifyextent:Object;
	var selectextent:Object;
	var maptipcoordinate:Object;
	var showmaptip:Boolean;
	var canmaptip:Boolean = false;
	var timeoutid:Number;
	var initialized:Boolean = false;
	var serviceInfoRequestSent = false;
	var extent:Object;
	var nrlayersqueried:Number;
	var layerliststring:String;
	//***
	var initService:Boolean=true;
	//***
	//-------------------------------------------
	var DEBUG:Boolean = false;
	var colorIds:String;
	var colorIdsKey:String;
	var record:Boolean = false;
	var visualisationSelected:Object = new Object();
	//-------------------------------------------
	var addRecorded:Object = new Object();
	var newRecorded:Object = new Object();
		
	var starttime:Date;
	var maptipextent:Object;
	
	var subLayerCounter:Number = -1;
	
	public function ArcIMSLayer(id:String, container:MovieClip, map:Map) {
		super (id, container, map);
		caches = new Object();
		layers = new Object();
		init();			
	}
	
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object, dontGetCap:Boolean) {		
		//_global.flamingo.tracer(" LayerArcIMS setConfig server /n/n/n" + xml.toString());
		if (xml == undefined) {
			return;
		}
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml=xml.firstChild;
		}
		super.setConfig(XMLNode(xml));
		
		if (dontGetCap == undefined){
			if (visibleids != "#ALL#") {
				dontGetCap = true;
			}else{
				dontGetCap = false;
			}
		}
		//                                                                                                                                                                           
		//
		//_global.flamingo.tracer(" LayerArcIMS setConfig" + _global.flamingo.getId(this) +" server = " + server + " mapservice = " + mapservice);
		if (visible == undefined) {
			visible = true;
		}
		// deal with arguments                                                                                                                                                                             
		var val = flamingo.getArgument(this, "visible");
		if (val != undefined) {
			this.setLayerProperty(val, "visible", true);
		}
		flamingo.deleteArgument(this, "visible");
		//
		val = flamingo.getArgument(this, "hidden");
		if (val != undefined) {
			this.setLayerProperty(val, "visible", false);
		}
		flamingo.deleteArgument(this, "hidden");
		//thisObj.update();
		//get extra information about mapserver and the layers
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}
		var thisObj:ArcIMSLayer = this;
		var lConn = new Object();
		lConn.onResponse = function(connector:ArcIMSConnector) {
			//trace(connector.response)
			thisObj.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "init", connector);
		};
		lConn.onRequest = function(connector:ArcIMSConnector,requesttype:String) {
			thisObj.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "init", connector);
		};
		lConn.onError = function(error:String, objecttag:Object, requestid:String) {
			thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "init", error);
		};
		lConn.onStoreServiceInfo = function(){
			if(!thisObj.initialized){
				ArcIMSConnector.getServiceInfoFromStore(thisObj.server, thisObj.mapservice,this);
			}
		} 
		lConn.onGetServiceInfo = function(extent, servicelayers, objecttag, requestid) {
			//_global.flamingo.tracer(" LayerArcIMS onGetServiceInfo" + _global.flamingo.getId(thisObj));
			thisObj.initialized = true;
			for (var id in servicelayers) {
				if (thisObj.layers[id] == undefined) {
					thisObj.layers[id] = new Object();
				}
				for (var attr in servicelayers[id]) {
					if (thisObj.layers[id][attr] == undefined) {
						thisObj.layers[id][attr] = servicelayers[id][attr];
					}
				}
				if (thisObj.layers[id].type == "featureclass" || thisObj.layers[id].type == "image") {
					thisObj.layers[id].queryable = true;
				} else {
					thisObj.layers[id].queryable = false;
				}
			}
			for (var id in thisObj.layers) {
				if (thisObj.layers[id].name == undefined and thisObj.layers[id].id == undefined) {
					delete thisObj.layers[id];
				}
			}
			if (thisObj.forceidentifyids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "forceidentify", true);
			}
			if (thisObj.hidelegendids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "legend", false);
			}
			if (thisObj.showlegendids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "legend", true);
			}
			if (thisObj.visibleids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "visible", true);
			}
			if (thisObj.hiddenids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "visible", false);
			}
			if (thisObj.identifyids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "identify", true);
			}
			if (thisObj.maptipids.toUpperCase() == "#ALL#") {
				thisObj.setLayerProperty("#ALL#", "maptipable", true);
			}
			//update is done in lLayer.onGetServiceResponse of the Map
			//thisObj.update();
			thisObj.flamingo.raiseEvent(thisObj, "onGetServiceInfo", thisObj);
				
		};//***
		if(this.initService==true && !dontGetCap){
			var conn:ArcIMSConnector = new ArcIMSConnector(server);
			//_global.flamingo.tracer(" LayerArcIMS addInfoReponseListener" + _global.flamingo.getId(this));
			ArcIMSConnector.addInfoReponseListener(lConn,server,mapservice);
			if (servlet.length>0) {
				conn.servlet = servlet;
			}	
			//_global.flamingo.tracer(_global.flamingo.getId(this) + " naar getServiceInfo " + mapservice);
			if(!serviceInfoRequestSent){
				serviceInfoRequestSent = true;
				//_global.flamingo.tracer(_global.flamingo.getId(this) + " naar getServiceInfo " + mapservice);
				conn.getServiceInfo(mapservice,lConn);
			}
		}
		//***
		else{
			setLayersQueryAbleFeatureclass(this.maptipids,true);
			setLayersQueryAbleFeatureclass(this.identifyids,true);
			initialized = true;	
			if (visibleids.length > 0)
				update();		
		}
		//***
	}
	
	function setAttribute(name:String, val:String) {
		super.setAttribute(name, val);
		switch (name.toLowerCase()) {
		case "legendcolor" :
			if (val.charAt(0) == "#") {
				this.legendcolor = Number("0x"+val.substring(1, val.length));
			} else {
				this.legendcolor = Number(val);
			}
			break;
		case "transcolor" :
			if (val.charAt(0) == "#") {
				this.transcolor = Number("0x"+val.substring(1, val.length));
			} else {
				this.transcolor = Number(val);
			}
			break;
		case "backgroundcolor" :
			if (val.charAt(0) == "#") {
				this.backgroundcolor = Number("0x"+val.substring(1, val.length));
			} else {
				this.backgroundcolor = Number(val);
			}
			break;
		case "alpha" :
			this.container._alpha = Number(val);
			break;
		case "outputtype" :
			this.outputtype = val;
			break;
		case "timeout" :
			this.timeout = Number(val);
			break;
		case "retryonerror" :
			this.retryonerror = Number(val);
			break;
		case "minscale" :
			this.minscale = Number(val);
			break;
		case "maxscale" :
			this.maxscale = Number(val);
			break;
		case "identifydistance" :
			this.identifydistance = Number(val);
			break;
		case "featurelimit" :
			this.featurelimit = Number(val);
			break;
		case "fullextent" :
			this.fullextent = map.string2Extent(val);
			break;
		case "maptipall" :
			if (val.toLowerCase() == "true") {
				maptipall = true;
			} else {
				maptipall = false;
			}
			break;
		case "identifyall" :
			if (val.toLowerCase() == "true") {
				identifyall = true;
			} else {
				identifyall = false;
			}
			break;
		case "legend" :
			if (val.toLowerCase() == "true") {
				legend = true;
			} else {
				legend = false;
			}
			break;
		case "shadow" :
			this.container.dropShadow();
			break;
		case "server" :
		//_global.flamingo.tracer(" LayerArcIMS setConfig server " + val);
			server = val;
			break;
		case "servlet" :
			servlet = val;
			break;
		case "mapservice" :
			mapservice = val;
			break;
		case "showlegendids" :
			setLayerProperty(val, "legend", true);
			this.showlegendids = val;
			break;
		case "hidelegendids" :
			setLayerProperty(val, "legend", false);
			this.hidelegendids = val;
			break;
		case "visibleids" :
			setLayerProperty(val, "visible", true);
			setLayerProperty(val, "id", true);
			this.visibleids = val;
			break;
		case "hiddenids" :
			setLayerProperty(val, "visible", false);
			this.hiddenids = val;
			break;
		case "identifyids" :
			setLayerProperty(val, "identify", true);
			this.identifyids = val;
			break;
		case "forceidentifyids" :
			setLayerProperty(val, "forceidentify", true);
			this.forceidentifyids = val;
			break;
		//***
		case "initservice" :			
			if (val.toLowerCase() == "false") {
				this.initService  = false;
			}else {
				this.initService  = true;
			}
			break;
			//***
		case "maptipids" :
			this.canmaptip = true;
			setLayerProperty(val, "maptipable", true);
			this.maptipids = val;
			break;		
		case "colorids" :
			this.colorIds= val;						
			break;
		case "coloridskey" :
			this.colorIdsKey= val;
			break;				
		case "record" :
			if (val.toLowerCase()=="true"){
				this.record=true;
			}else{
				this.record=false;
			}
			break;
		case "autorefreshdelay" :
			setInterval(this, "autoRefresh", Number(val));
			break;
		}
	}
	
	/**
	 * Passes a name and child xml to the component.
	 * @param name the name of the tag
	 * @param config the xml child
	 */ 
	function addComposite(name:String, config:XMLNode):Void { 
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
				subLayerCounter++;
				layers[id].order = subLayerCounter;
				//get maptip
				flamingo.parseString(config, layers[id].language);
				for (var attr in config.attributes) {
					var val:String = config.attributes[attr];
					switch (attr.toLowerCase()) {
					case "identifydistance" :
					case "maptipdistance" :
					case "featurelimit" :
						layers[id][attr.toLowerCase()] = Number(val);
						break;
					case "subfields" :
					case "fields" :
						layers[id].subfields = val;
						break;
					default :
						layers[id][attr.toLowerCase()] = val;
						break;
					}
				}
			}
			//search for mydata                                                                                                                                      
			var xmydatas = config.childNodes;
			if (xmydatas.length>0) {
				for (var j:Number = xmydatas.length-1; j>=0; j--) {
					switch (xmydatas[j].nodeName.toLowerCase()) {
					case "mydatastring" :
						var mydata = xmydatas[j].firstChild.nodeValue;
						var fielddelimiter = ",";
						var recorddelimiter = "\n";
						var joinfield;
						var jointo;
						for (var attr in xmydatas[j].attributes) {
							var value = xmydatas[j].attributes[attr];
							switch (attr.toLowerCase()) {
							case "fielddelimiter" :
								fielddelimiter = value;
								break;
							case "recorddelimiter" :
								recorddelimiter = value;
								break;
							case "joinfield" :
								joinfield = value;
								break;
							case "jointo" :
								jointo = value;
								break;
							}
						}
						this.addMydata(id, jointo, mydata, joinfield, recorddelimiter, fielddelimiter);
						break;
					case "mydata" :
						break;
					case "layerdefstring" :
						layers[id].layerdefstring = xmydatas[j].firstChild.nodeValue;
						break;
					case "visualisationselected" :
						if (visualisationSelected[id]==undefined){
							this.visualisationSelected[id]=new Object();
						}
						for (var attr in xmydatas[j].attributes) {
							var val:String = xmydatas[j].attributes[attr];
							this.visualisationSelected[id][attr.toLowerCase()] = val;							
						}
					}
				}
			}
		}
	}
	/**
	* Remove custom data from a layer.
	* @param layerid:String Id of the sublayer.
	* @param jointo:String [optional] All data joined to this field will be removed.
	* @param id:String [optional] All data with this joinid will be removed
	* @param field:String [optional] All data in this custom field will be removed.
	*/
	function removeMydata(layerid:String, jointo:String, id:String, field:String):Array {
		if (layerid == undefined) {
			return null;
		}
		var b:Boolean;
		//
		if (field != undefined) {
			for (var joins in layers[layerid].mydatajoins) {
				for (var fld in layers[layerid].mydatajoins[joins]) {
					if (fld == field) {
						delete layers[layerid].mydatajoins[joins][fld];
					}
				}
				b = true;
				for (var fld in layers[layerid].mydatajoins[joins]) {
					b = false;
					break;
				}
				if (b) {
					delete layers[layerid].mydatajoins[joins];
				}
			}
		}
		//                                          
		for (var joindata in layers[layerid].mydata) {
			if (jointo == undefined || joindata.toLowerCase() == jointo.toLowerCase()) {
				for (var joinid in layers[layerid].mydata[joindata]) {
					if (id == undefined || joinid == id) {
						for (var joinfield in layers[layerid].mydata[joindata][joinid]) {
							if (field == undefined || joinfield.toLowerCase() == field.toLowerCase()) {
								delete layers[layerid].mydata[joindata][joinid][joinfield];
							}
						}
						b = true;
						for (var joinfield in layers[layerid].mydata[joindata][joinid]) {
							b = false;
							break;
						}
						if (b) {
							delete layers[layerid].mydata[joindata][joinid];
						}
					}
				}
				b = true;
				for (var joinid in layers[layerid].mydata[joindata]) {
					b = false;
					break;
				}
				if (b) {
					delete layers[layerid].mydata[joindata];
					delete layers[layerid].mydatajoins[joindata];
				}
			}
		}
		b = true;
		for (var joindata in layers[layerid].mydata) {
			b = false;
			break;
		}
		if (b) {
			delete layers[layerid].mydata;
			delete layers[layerid].mydatajoins;
		}
		return null;
	}
	function getMydataJoins(layerid:String):Array {
		if (layerid == undefined) {
			return null;
		}
		return layers[layerid].mydatajoins;
	}
	/**
	* Gets (not permanent) custom data which is joined to a layer.
	* @param layerid:String Id of the sublayer.
	* @param jointo:String [optional] All data joined to this field will be returned.
	* @param id:String [optional] All data with this joinid will be returned.
	* @param field:String [optional] All data in this custom field will be removed.
	* @return Array An array of records. A record is an object of fields. [{field1:value, field2:value},{field1:value, field2:value}] 
	*/
	function getMydata(layerid:String, jointo:String, id:String, field:String):Array {
		var b:Boolean;
		var data:Array = new Array();
		for (var joindata in layers[layerid].mydata) {
			if (jointo == undefined || joindata.toLowerCase() == jointo.toLowerCase()) {
				for (var joinid in layers[layerid].mydata[joindata]) {
					if (id == undefined || joinid == id) {
						var record = new Object();
						record[joindata] = joinid;
						b = false;
						for (var joinfield in layers[layerid].mydata[joindata][joinid]) {
							//if (field == undefined or joinfield.toLowerCase() == field.toLowerCase()) {
							record[joinfield] = layers[layerid].mydata[joindata][joinid][joinfield];
							b = true;
							//}
						}
						if (b) {
							data.push(record);
						}
					}
				}
			}
		}
		return data;
	}
	function _completeWithMydata(layerid:String, data:Array) {
		if (layerid == undefined) {
			return;
		}
		if (layers[layerid].mydata != undefined) {
			var joins = getMydataJoins(layerid);
			for (var jointo in joins) {
				for (var j = 0; j<data.length; j++) {
					var joinid = _getValue(data[j], jointo);
					if (joinid != undefined) {
						var mydata = getMydata(layerid, jointo, joinid);
						for (var k = 0; k<mydata.length; k++) {
							for (var field in mydata[k]) {
								if (field != jointo) {
									data[j]["MYDATA."+field] = mydata[k][field];
								}
							}
						}
					}
				}
			}
		}
	}
	/**
	* Gets a ValueMapRenderer string based on custom data and a layer.
	* @example
	*  //javascript:
	*  var app = getMovie("flamingo");
	*  var data="code,value#1,100#2,200#3,300#4,400#5,500#6,600#7,700#8,800#9,900#10,100";
	*  app.call("map_mylayer","addMydata", 0 , "CODE", data, "code", "#", ",");
	*  var classes = new Array();
	*  classes.push({min:0, max:50, label:'0-50', fillcolor:'204,0,204', boundarycolor:'175,175,175'});
	*  classes.push({min:50, max:100, label:'50-100',fillcolor:'0,204,204', boundarycolor:'175,175,175'});
	*  classes.push({fillcolor:'204,204,204', boundarycolor:'175,175,175'});
	*  var vmr = app.call("map_mylayer","getValueMapRenderer", 0,  "CODE", data, "code", "value", classes, "#", ",");
	*  app.call("map_mylayer","setLayerProperty", 0, "layerdefstring", vmr);
	*  app.call("map_mylayer","setLayerProperty", 0, "maptip", "[VALUE]");
	*  app.call("map_mylayer","setLayerProperty", 0, "visible", true);
	*  app.call("map_mylayer","update");
	* @param layerid:String Id of the sublayer.
	* @param lookupfield:String Fieldname which contains the id's of the sublayer.
	* @param data:Object An array or string containing the data. The array is an array of record objects. A record object contains fieldobjects. [{field1:value, field2:value},{field1:value, field2:value}] When table is a string, the first line must contain the fieldnames. 
	* @param lookupfieldtable:String Fieldname which contains the id's in the custom data.
	* @param classfield:String Fieldname which contains the class values in the custom data.
	* @param classes:String Array of class objects. A class object has the following attributes: min, max, label, fillcolor, boundarycolor, linecolor, color, width etc.
	* @param recorddelimiter:String [optional] Token by which records are seperated. Use only when table is a string.
	* @param fielddelimiter:String [optional] Token by which fields are seperated. Use only when table is a string.
	*/
	function getValueMapRenderer(layerid:String, lookupfield:String, data:Object, lookupfieldtable:String, classfield:String, classes:Object, recorddelimiter:String, fielddelimiter:String):String {
		if (layers[layerid] == undefined) {
			return null;
		}
		if (layers[layerid].type != "featureclass") {
			return null;
		}
		//
		if (typeof (data) == "string") {
			if (recorddelimiter == undefined) {
				return null;
			}
			if (fielddelimiter == undefined) {
				return null;
			}
			data = _string2Table(String(data), recorddelimiter, fielddelimiter);
		}
		var val:Number;
		var id:String;
		var min:Number;
		var max:Number;
		var vs:String;
		var other:String = "";
		var cls:Object;
		var record:Object;
		var tag:String;
		switch (layers[layerid].fclasstype.toLowerCase()) {
		case "polygon" :
			tag = "SIMPLEPOLYGONSYMBOL";
			break;
		case "line" :
			tag = "SIMPLELINESYMBOL";
			break;
		case "point" :
			tag = "SIMPLEMARKERSYMBOL";
			break;
		}
		var s = "<GROUPRENDERER>";
		s += newline+"<VALUEMAPRENDERER lookupfield='"+lookupfield+"'>";
		for (var cl in classes) {
			cls = classes[cl];
			if (cls.min != undefined and cls.max != undefined) {
				min = Number(cls.min);
				max = Number(cls.max);
				delete cls.min;
				delete cls.max;
				vs = "";
				for (var i = 0; i<data.length; i++) {
					record = data[i];
					val = Number(_getValue(record, classfield));
					if (val>=min and val<max) {
						id = _getValue(record, lookupfieldtable);
						if (vs.length == 0) {
							vs = String(id);
						} else {
							vs += ";"+String(id);
						}
					}
				}
				//
				s += newline+"<EXACT value= '"+vs+" ' label='"+cls.label+"'>";
				delete cls.label;
				s += newline+"<"+tag+" ";
				for (var attr in cls) {
					//transparency='0,6' 
					//filltransparency='1,0'
					//fillcolor='180,230,249'
					//boundarycaptype='round' 
					//boundarycolor='90,200,234'
					s += attr+"='"+cls[attr]+"'";
				}
				s += "/>";
				s += newline+"</EXACT>";
			} else {
				// no min and max > treat this class as 'other'
				other = "<OTHER>";
				other += newline+"<"+tag+" ";
				for (var attr in cls) {
					other += attr+"='"+cls[attr]+"'";
				}
				other += "/>";
				other += newline+"</OTHER>";
			}
		}
		s += newline+other;
		s += newline+"</VALUEMAPRENDERER>";
		s += newline+"</GROUPRENDERER>";
		//layers[layerid].layerdefstring = s;
		return s;
	}
	/**
	* Joins (not permanent) custom data to a layer.
	* @param layerid:String Id of the sublayer.
	* @param jointo:String Fieldname which contains joinid's of the sublayer.
	* @param table:Object An array or string containing the custom data. The array is an array of record objects. A record object contains fieldobjects. [{field1:value, field2:value},{field1:value, field2:value}] When table is a string, the first line must contain the fieldnames. 
	* @param joinfield:String Fieldname which contains the joinid's in the custom data.
	* @param recorddelimiter:String [optional] Token by which records are seperated. Use only when table is a string.
	* @param fielddelimiter:String [optional] Token by which fields are seperated. Use only when table is a string.
	*/
	function addMydata(layerid:String, jointo:String, table:Object, joinfield:String, recorddelimiter:String, fielddelimiter:String) {
		if (layers[layerid] == undefined and initialized) {
			return;
		}
		if (layers[layerid] == undefined) {
			layers[layerid] = new Object();
		}
		if (layers[layerid].mydata == undefined) {
			layers[layerid].mydata = new Object();
			layers[layerid].mydatajoins = new Object();
		}
		if (joinfield == undefined) {
			joinfield = jointo;
		}
		//if (layers[layerid].mydata[jointo] == undefined) {                                                                       
		//layers[layerid].mydata[jointo] = new Object();
		//}
		if (typeof (table) == "string") {
			if (recorddelimiter == undefined) {
				return;
			}
			if (fielddelimiter == undefined) {
				return;
			}
			table = _string2Table(String(table), recorddelimiter, fielddelimiter);
		}
		//                                                                    
		jointo = jointo.toLowerCase();
		if (layers[layerid].mydata[jointo] == undefined) {
			layers[layerid].mydata[jointo] = new Object();
		}
		if (layers[layerid].mydatajoins[jointo] == undefined) {
			layers[layerid].mydatajoins[jointo] = new Object();
		}
		for (var rec in table) {
			var joinid = _getValue(table[rec], joinfield);
			if (layers[layerid].mydata[jointo][joinid] == undefined) {
				layers[layerid].mydata[jointo][joinid] = new Object();
			}
			for (var fld in table[rec]) {
				//if (fld.toLowerCase() != joinfield.toLowerCase()) {
				if (layers[layerid].mydatajoins[jointo][fld] == undefined) {
					layers[layerid].mydatajoins[jointo][fld] = 1;
				} else {
					layers[layerid].mydatajoins[jointo][fld] = layers[layerid].mydatajoins[jointo][fld]+1;
				}
				layers[layerid].mydata[jointo][joinid][fld] = table[rec][fld];
				//}
			}
		}
	}
	
	/**
	* Hides a layer.
	*/
	function hide():Void {
		if(visible!=false){
		visible = false;
		update();
		flamingo.raiseEvent(this, "onHide", this);
	}
	}
	/**
	* Shows a layer.
	*/
	function show():Void {
		if (visible!=true){
			if (!initService){
				for (var l in layers){
					layers[l].visible=true;
				}
			}
			visible = true;
			updateCaches();
			update();
			flamingo.raiseEvent(this, "onShow", this);
		}
	}

	function autoRefresh():Void {
		if (!this.updating) {
			refresh();
		}
	}

	function refresh():Void {
		this.update();
	}

	/**
	* Updates a layer.
	*/
	function update():Void {
		if(initialized){
		_update(1);
	}
	}

	/*function noLayersVisible():Boolean {
		var lyrs:Object = this.getLayers();
		if(lyrs != null){
			for (var lyr in lyrs){
				if(getLayerProperty(lyr,"visible")){
					return false; 
				}
			}
			return true;
		} else {
			return false;		
		}
	}*/

	function _update(nrtry:Number):Void {
		if (! visible || ! map.visible) {
			_visible = false;
			return;
		}
		//check if any sublayer is visible 
		//if(noLayersVisible()){
			//_visible = false;
			//return;
		//}		
		if (updating) {
			return;
		}
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}
		if (! map.hasextent) {
			return;
		}
		extent = map.getMapExtent();
		var ms:Number = map.getMapScale();
		if (minscale != undefined) {
			if (ms<=minscale) {
				flamingo.raiseEvent(this, "onUpdate", this, nrtry);
				flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
				_visible = false;
				return;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				flamingo.raiseEvent(this, "onUpdate", this, nrtry);
				flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
				_visible = false;
				return;
			}
		}
		if (fullextent != undefined) {
			if (! map.isHit(fullextent)) {
				flamingo.raiseEvent(this, "onUpdate", this, nrtry);
				flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
				_visible = false;
				return;
			}
		}
		updating = true;
		_visible = true;
		nrcache++;
		var cache:MovieClip = this.container.createEmptyMovieClip("mCache"+nrcache, nrcache);
		cache._alpha = 0;
		caches[nrcache] = cache;
		//
		var thisObj:ArcIMSLayer = this;
		var lConn:Object = new Object();
		lConn.onResponse = function(connector:ArcIMSConnector) {
			thisObj._stoptimeout();
			//trace(connector.response)
			thisObj.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "update", connector);
		};
		lConn.onRequest = function(connector:ArcIMSConnector) {
			//trace(connector.request)
			thisObj.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "update", connector);
		};
		lConn.onError = function(error:String, objecttag:Object, requestid:String) {
			thisObj._stoptimeout();
			thisObj.updating = false;
			if (nrtry<thisObj.retryonerror) {
				nrtry++;
				thisObj._update(nrtry);
			} else {
				thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
			}
		};
		lConn.onGetImage = function(ext:Object, imageurl:String, legurl:String, objecttag:Object, requestid:String) {
			if (legurl.length>0) {
				thisObj.legendurl = legurl;
				thisObj.flamingo.raiseEvent(thisObj, "onGetLegend", thisObj, thisObj.legendurl);
			}
			thisObj._starttimeout();
			var newDate = new Date();
			var requesttime = (newDate.getTime()-thisObj.starttime.getTime())/1000;
			var listener:Object = new Object();
			listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
				thisObj._stoptimeout();
				thisObj.updating = false;
				thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
			};
			listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
				thisObj._stoptimeout();
				thisObj.flamingo.raiseEvent(thisObj, "onUpdateProgress", thisObj, bytesLoaded, bytesTotal);
			};
			listener.onLoadInit = function(mc:MovieClip) {
				var newDate2 = new Date();
				var loadtime = (newDate2.getTime()-thisObj.starttime.getTime())/1000;
				mc.extent = ext;
				//mc.requestedextent = objecttag;
				thisObj.updateCache(mc);
				if (thisObj.map.fadesteps>0) {
					mc.loadtime = loadtime;
					mc.requesttime = requesttime;
					mc.totalbytes = mc.getBytesTotal();
					var step = (100/thisObj.map.fadesteps)+1;
					thisObj.container.onEnterFrame = function() {
						cache = thisObj.caches[thisObj.nrcache];
						cache._alpha = cache._alpha+step;
						if (cache._alpha>=100) {
							delete this.onEnterFrame;
							thisObj.flamingo.raiseEvent(this, "onUpdateComplete", this, cache.requesttime, cache.loadtime, cache.totalbytes);
							delete cache.requesttime;
							delete cache.loadtime;
							delete cache.totalbytes;
							thisObj.updating = false;
							thisObj._clearCache();
							//_global.flamingo.tracer(_global.flamingo.getId(thisObj) + " vislayers " + vislayers);
							//_global.flamingo.tracer(_global.flamingo.getId(thisObj) + " _getVisLayers() " + _getVisLayers());
							//_global.flamingo.tracer(_global.flamingo.getId(thisObj) + " map.isEqualExtent(extent) " + map.isEqualExtent(extent));
							if (!thisObj.map.isEqualExtent(thisObj.extent) || thisObj._getVisLayers() != thisObj.vislayers) {
								thisObj.update();
							}
						}
					};
				} else {
					cache._alpha = 100;
					thisObj.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, requesttime, loadtime, mc.getBytesTotal());
					thisObj.updating = false;
					thisObj._clearCache();
					
					if (!thisObj.map.isEqualExtent(thisObj.extent) || thisObj._getVisLayers() != thisObj.vislayers) {
						thisObj.update();
					}
				}
			};
			var mcl:MovieClipLoader = new MovieClipLoader();
			mcl.addListener(listener);
			thisObj.starttime = new Date();
			mcl.loadClip(imageurl, cache);
		};
		var conn:ArcIMSConnector = new ArcIMSConnector(server);
		conn.addListener(lConn);
		conn.setIdentifyColorLayer(this.colorIds);
		conn.setIdentifyColorLayerKey(this.colorIdsKey);
		conn.setVisualisationSelected(this.visualisationSelected);
		conn.setRecord(this.record);
		for (var layerid in this.newRecorded){
			for (var key in this.newRecorded[layerid]){
				conn.setRecorded(layerid,key,this.newRecorded[layerid][key]);
			}
		}
		for (var layerid in this.addRecorded){
			for (var key in this.addRecorded[layerid]){
				conn.addRecorded(layerid,key,this.addRecorded[layerid][key]);
			}
		}
		this.addRecorded= new Object();
		this.newRecorded= new Object();
		
		
		if (servlet.length>0) {
			conn.servlet = servlet;
		}
		conn.layerliststring = this.layerliststring;
		conn.transcolor = this.transcolor;
		conn.backgroundcolor = this.backgroundcolor;
		conn.legendcolor = this.legendcolor;
		conn.outputtype = outputtype;
		conn.legend = legend;
		this.starttime = new Date();
		vislayers = _getVisLayers();
		flamingo.raiseEvent(this, "onUpdate", this, nrtry);
		conn.getImage(mapservice, extent, {width:Math.ceil(map.__width), height:Math.ceil(map.__height)}, layers);
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
		clearInterval(timeoutid);
		updating = false;
		flamingo.raiseEvent(this, "onError", this, "update", "timeout, connection failed...");
	}
	function _clearCache() {
		for (var nr in caches) {
			if (nr != nrcache) {
				caches[nr].removeMovieClip();
				delete caches[nr];
			}
		}
	}
	function _getLayerlist(list:String, field:String):Array {
		var layerlist:Array = new Array();
		var ms:Number = map.getScale();
		if (list.toUpperCase() == "#ALL#") {
			for (var id in layers) {
				if (layers[id].queryable) {
					if (layers[id][field] == false) {
						continue;
					}
					if (field == "identify" and layers[id].forceidentify == true) {
						layerlist.push(id);
					} else {
						if (layers[id].visible == false) {
							continue;
						}
						if (layers[id].minscale != undefined) {
							if (ms<layers[id].minscale) {
								continue;
							}
						}
						if (layers[id].maxscale != undefined) {
							if (ms>layers[id].maxscale) {
								continue;
							}
						}
						layerlist.push(id);
					}
				}
			}
		} else {
			var a:Array = list.split(",");
			for (var i = a.length-1; i>=0; i--) {
				var id = a[i];
				if (layers[id].queryable) {
					if (layers[id][field] == false) {
						continue;
					}
					if (field == "identify" and layers[id].forceidentify == true) {
						layerlist.push(id);
					} else {
						if (getVisible(id) != 1) {
							continue;
						}
						if (layers[id].minscale != undefined) {
							if (ms<layers[id].minscale) {
								continue;
							}
						}
						if (layers[id].maxscale != undefined) {
							if (ms>layers[id].maxscale) {
								continue;
							}
						}
						//all tests passed, this layer can be identified                                                                                                                                                                                                               
						layerlist.push(id);
					}
				}
			}
		}
		return layerlist;
	}
	function cancelIdentify() {
		_identifylayers = new Array();
		this.identifyextent = undefined;
	}
	/**
	* Identifies a layer.
	* @param identifyextent:Object extent of the identify
	*/
	function identify(_identifyextent:Object) {
		this.identifyextent = undefined;
		_identifylayers = new Array();
		if (!this.initialized) {
			return;
		}
		if (identifyids.length<=0) {
			return;
		}
		if (!visible || !_visible) {
			return;
		}
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}
		if (fullextent != undefined) {
			if (!map.isHit(_identifyextent, fullextent)) {
				return;
			}
		}
		_identifylayers = new Array();
		_identifylayers = _getLayerlist(identifyids, "identify");
		this.nrlayersqueried = _identifylayers.length;
		if (_identifylayers.length == 0) {
			return;
		}
		this.identifyextent = map.copyExtent(_identifyextent);
		flamingo.raiseEvent(this, "onIdentify", this, identifyextent);
		_identifylayer(this.identifyextent, new Date());
	}
	function _identifylayer(_identifyextent:Object, starttime:Date) {
		if (_identifylayers.length == 0) {
			var newDate = new Date();
			var t = (newDate.getTime()-starttime.getTime())/1000;
			flamingo.raiseEvent(this, "onIdentifyComplete", this, t);
			return;
		}
		var thisObj:ArcIMSLayer = this;
		var lConn = new Object();
		lConn.onResponse = function(connector:ArcIMSConnector) {
			//trace(connector.response);
			thisObj.flamingo.raiseEvent(this, "onResponse", this, "identify", connector);
		};
		lConn.onRequest = function(connector:ArcIMSConnector) {
			//trace(connector.request);
			thisObj.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "identify", connector);
		};
		lConn.onError = function(error:String, objecttag:Object, requestid:String) {
			thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "identify", error);
			if (thisObj._identifylayers.length>0) {
				thisObj._identifylayer(_identifyextent, starttime);
			} else {
				thisObj.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj);
			}
		};
		lConn.onGetRasterInfo = function(layerid:String, data:Array, objecttag:Object) {
			if (thisObj.map.isEqualExtent(thisObj.identifyextent, objecttag)) {
				// add data from mydata
				thisObj._completeWithMydata(layerid, data);
				//                                               
				var features = new Object();
				features[layerid] = data;
				thisObj.flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, features, thisObj.identifyextent, (thisObj.nrlayersqueried-thisObj._identifylayers.length), thisObj.nrlayersqueried);
				if (!thisObj.identifyall) {
					var b = false;
					for (var i = 0; i<data.length; i++) {
						for (var attr in data[i]) {
							if (data[i][attr] != undefined) {
								b = true;
								break;
							}
						}
					}
					if (b) {
						var newDate = new Date();
						var t = (newDate.getTime()-starttime.getTime())/1000;
						thisObj.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, t);
					} else {
						thisObj._identifylayer(_identifyextent, starttime);
					}
				} else {
					thisObj._identifylayer(_identifyextent, starttime);
				}
			}
		};
		lConn.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
			if (thisObj.map.isEqualExtent(thisObj.identifyextent, objecttag)) {
				// add data from mydata
				thisObj._completeWithMydata(layerid, data);
				//                                               
				var features = new Object();
				features[layerid] = data;
				thisObj.flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, features, thisObj.identifyextent, (thisObj.nrlayersqueried-thisObj._identifylayers.length), thisObj.nrlayersqueried);
				if (!thisObj.identifyall and count > 0) {
					var newDate:Date = new Date();
					var t = (newDate.getTime()-starttime.getTime())/1000;
					thisObj.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, t);
				} else {
					thisObj._identifylayer(_identifyextent, starttime);
				}
				if (data.length > 0 && thisObj.colorIds.length> 0){
					thisObj.update();
			}
			}
		};
		lConn.onRecord= function(layerid:String, recordedValues:Object){
			thisObj.flamingo.raiseEvent(thisObj, "onRecord", thisObj, layerid, recordedValues);			
			
		};
		var layerid:String = String(_identifylayers.pop());
		var conn:ArcIMSConnector = new ArcIMSConnector(server);
		conn.setIdentifyColorLayer(this.colorIds);
		conn.setIdentifyColorLayerKey(this.colorIdsKey);
		conn.setVisualisationSelected(this.visualisationSelected);
		conn.setRecord(this.record);
		if (servlet.length>0) {
			conn.servlet = servlet;
		}
		conn.addListener(lConn);
		var _featurelimit = layers[layerid].featurelimit;
		if (_featurelimit == undefined) {
			_featurelimit = this.featurelimit;
		}
		conn.featurelimit = _featurelimit;
		switch (layers[layerid].type) {
		case "featureclass" :
			//calculate the real identify extent based on the identify extent of the map
			//if the extent is actually a point 
			var _identifydistance = layers[layerid].identifydistance;
			if (_identifydistance == undefined) {
				_identifydistance = this.identifydistance;
			}
			var real_identifyextent = map.copyExtent(_identifyextent);
			if ((real_identifyextent.maxx-real_identifyextent.minx) == 0) {
				var w = map.getScale()*_identifydistance;
				real_identifyextent.minx = real_identifyextent.minx-(w/2);
				real_identifyextent.maxx = real_identifyextent.minx+w;
			}
			if ((real_identifyextent.maxy-real_identifyextent.miny) == 0) {
				var h = map.getScale()*_identifydistance;
				real_identifyextent.miny = real_identifyextent.miny-(h/2);
				real_identifyextent.maxy = real_identifyextent.miny+h;
			}
			var subfields:String = layers[layerid].subfields.split(",").join(" ");
			var query:String = layers[layerid].query;
			conn.getFeatures(mapservice, layerid, real_identifyextent, subfields, query, map.copyExtent(_identifyextent));
			break;
		case "image" :
			var point = new Object();
			point.x = (_identifyextent.maxx+_identifyextent.minx)/2;
			point.y = (_identifyextent.maxy+_identifyextent.miny)/2;
			conn.getRasterInfo(mapservice, layerid, point, layers[layerid].coordsys, map.copyExtent(_identifyextent));
			break;
		}
	}
	function cancelHotlink() {
		_hotlinklayers = new Array();
		this.identifyextent = undefined;
	}
	/**
	* Hotlink a layer.
	* @param identifyextent:Object extent of the identify
	*/
	function hotlink(_identifyextent:Object) {
		this.identifyextent = undefined;
		if (!this.initialized) {
			return;
		}
		if (identifyids.length<=0) {
			return;
		}
		if (!visible || !_visible) {
			return;
		}
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}
		if (fullextent != undefined) {
			if (!map.isHit(_identifyextent, fullextent)) {
				return;
			}
		}
		_hotlinklayers = new Array();
		_hotlinklayers = _getLayerlist(identifyids, "identify");
		this.nrlayersqueried = _hotlinklayers.length;
		if (_hotlinklayers.length == 0) {
			return;
		}
		this.identifyextent = map.copyExtent(_identifyextent);
		flamingo.raiseEvent(this, "onHotlink", this, identifyextent);
		_hotlinklayer(this.identifyextent, new Date());
	}
	function _hotlinklayer(_identifyextent:Object, starttime:Date) {
		if (_hotlinklayers.length == 0) {
			var newDate:Date = new Date();
			var t = (newDate.getTime() -starttime.getTime()) / 1000;
			flamingo.raiseEvent(this, "onHotlinkComplete", this, t);
			return;
		}
		var thisObj:ArcIMSLayer = this;
		var lConn = new Object();
		lConn.onResponse = function(connector:ArcIMSConnector) {
			//trace(connector.response);
			thisObj.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "hotlink", connector);
		};
		lConn.onRequest = function(connector:ArcIMSConnector) {
			//trace(connector.request);
			thisObj.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "hotlink", connector);
		};
		lConn.onError = function(error:String, objecttag:Object, requestid:String) {
			thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "hotlink", error);
			if (thisObj._hotlinklayers.length>0) {
				thisObj._hotlinklayer(_identifyextent, starttime);
			} else {
				thisObj.flamingo.raiseEvent(thisObj, "onHotlinkComplete", thisObj);
			}
		};
		lConn.onGetRasterInfo = function(layerid:String, data:Array, objecttag:Object) {
			if (thisObj.map.isEqualExtent(thisObj.identifyextent, objecttag)) {
				// add data from mydata
				thisObj._completeWithMydata(layerid, data);
				//                                               
				var features = new Object();
				features[layerid] = data;
				thisObj.flamingo.raiseEvent(thisObj, "onHotlinkData", thisObj, features, thisObj.identifyextent, (thisObj.nrlayersqueried-thisObj._hotlinklayers.length), thisObj.nrlayersqueried);
				if (!thisObj.identifyall) {
					var b = false;
					for (var i = 0; i<data.length; i++) {
						for (var attr in data[i]) {
							if (data[i][attr] != undefined) {
								b = true;
								break;
							}
						}
					}
					if (b) {
						var newDate:Date = new Date();
						var t = (newDate.getTime()-starttime.getTime())/1000;
						thisObj.flamingo.raiseEvent(thisObj, "onHotlinkComplete", thisObj, t);
					} else {
						thisObj._hotlinklayer(_identifyextent, starttime);
					}
				} else {
					thisObj._hotlinklayer(_identifyextent, starttime);
				}
			}
		};
		lConn.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
			if (thisObj.map.isEqualExtent(thisObj.identifyextent, objecttag)) {
				// add data from mydata
				thisObj._completeWithMydata(layerid, data);
				//                                               
				var features = new Object();
				features[layerid] = data;
				thisObj.flamingo.raiseEvent(thisObj, "onHotlinkData", thisObj, features, thisObj.identifyextent, (thisObj.nrlayersqueried-thisObj._hotlinklayers.length), thisObj.nrlayersqueried);
				if (!thisObj.identifyall and count > 0) {
					var newDate = new Date();
					var t = (newDate.getTime()-starttime.getTime())/1000;
					thisObj.flamingo.raiseEvent(thisObj, "onHotlinkComplete", thisObj, t);
				} else {
					thisObj._hotlinklayer(_identifyextent, starttime);
				}
				if (data.length > 0 && thisObj.colorIds.length> 0){
					thisObj.update();
				}
			}
		};
		lConn.onRecord= function(layerid:String, recordedValues:Object){
			thisObj.flamingo.raiseEvent(thisObj, "onRecord", thisObj, layerid, recordedValues);			

		};
		var layerid:String = String(_hotlinklayers.pop());
		var conn:ArcIMSConnector = new ArcIMSConnector(server);	
		conn.setIdentifyColorLayer(this.colorIds);
		conn.setIdentifyColorLayerKey(this.colorIdsKey);
		conn.setVisualisationSelected(this.visualisationSelected);
		conn.setRecord(this.record);
		if (servlet.length>0) {
			conn.servlet = servlet;
		}
		conn.addListener(lConn);
		var _featurelimit = layers[layerid].featurelimit;
		if (_featurelimit == undefined) {
			_featurelimit = this.featurelimit;
		}
		conn.featurelimit = _featurelimit;
		switch (layers[layerid].type) {
		case "featureclass" :
			//calculate the real identify extent based on the identify extent of the map
			//if the extent is actually a point 
			var _identifydistance = layers[layerid].identifydistance;
			if (_identifydistance == undefined) {
				_identifydistance = this.identifydistance;
			}
			var real_identifyextent = map.copyExtent(_identifyextent);
			if ((real_identifyextent.maxx-real_identifyextent.minx) == 0) {
				var w = map.getScale()*_identifydistance;
				real_identifyextent.minx = real_identifyextent.minx-(w/2);
				real_identifyextent.maxx = real_identifyextent.minx+w;
			}
			if ((real_identifyextent.maxy-real_identifyextent.miny) == 0) {
				var h = map.getScale()*_identifydistance;
				real_identifyextent.miny = real_identifyextent.miny-(h/2);
				real_identifyextent.maxy = real_identifyextent.miny+h;
			}
			var subfields:String = layers[layerid].subfields.split(",").join(" ");
			var query:String = layers[layerid].query;
			conn.getFeatures(mapservice, layerid, real_identifyextent, subfields, query, map.copyExtent(_identifyextent));
			break;
		case "image" :
			var point = new Object();
			point.x = (_identifyextent.maxx+_identifyextent.minx)/2;
			point.y = (_identifyextent.maxy+_identifyextent.miny)/2;
			conn.getRasterInfo(mapservice, layerid, point, layers[layerid].coordsys, map.copyExtent(_identifyextent));
			break;
		}
	}

	function setLayersQueryAbleFeatureclass(ids:String,val:Boolean){
		var a_ids = flamingo.asArray(ids);
		for (var i = 0; i<a_ids.length; i++) {
			var id = a_ids[i];
			if (layers[id] == undefined) {
				layers[id] = new Object();
			}
			layers[id].queryable=val;
			layers[id].type='featureclass';
		}
	}
	/** 
	* Selects from a layer.
	* @param selectExtent:Object extent of the selection
	* @param selectLayer:String Layerid
	*/
	function select(_selectExtent:Object, _selectLayer:Object) {
		this.selectextent = undefined;
		if (!this.initialized) {
			return;
		}
		if (!visible || !_visible) {
			return;
		}
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}

		this.selectextent = map.copyExtent(_selectExtent);
		flamingo.raiseEvent(this, "onSelect", this, _selectExtent, _selectLayer);
		_selectlayer(_selectExtent, _selectLayer, 1);
	}

	function _selectlayer(_selectExtent:Object, _selectLayer:Object, _beginrecord:Number) {
		var lConn = new Object();
		
		var layeridString:String = String(_selectLayer);
		var conn:ArcIMSConnector = new ArcIMSConnector(server);	

		if (servlet.length>0) {
			conn.servlet = servlet;
		}
		conn.addListener(lConn);
		var _featurelimit:Number = layers[layeridString].featurelimit;
		if (_featurelimit == undefined) {
			_featurelimit = this.featurelimit;
		}
		conn.envelope = true;
		conn.featurelimit = _featurelimit;
		conn.beginrecord = _beginrecord
		var thisObj:ArcIMSLayer = this;
		lConn.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
			if (thisObj.map.isEqualExtent(thisObj.selectextent, objecttag)) {
				var features = new Object();
				features[layerid] = data;
				thisObj.flamingo.raiseEvent(thisObj, "onSelectData", thisObj, features, thisObj.selectextent, _beginrecord);
				if(hasmore) {
					thisObj._selectlayer(_selectExtent, _selectLayer, _beginrecord + _featurelimit);
				}
			}
		};
		
		switch (layers[layeridString].type) {
		case "featureclass" :
			//calculate the real identify extent based on the identify extent of the map
			//if the extent is actually a point 
			var _identifydistance = layers[layeridString].identifydistance;
			if (_identifydistance == undefined) {
				_identifydistance = this.identifydistance;
			}
			var real_identifyextent = map.copyExtent(_selectExtent);
			if ((real_identifyextent.maxx-real_identifyextent.minx) == 0) {
				var w = map.getScale()*_identifydistance;
				real_identifyextent.minx = real_identifyextent.minx-(w/2);
				real_identifyextent.maxx = real_identifyextent.minx+w;
			}
			if ((real_identifyextent.maxy-real_identifyextent.miny) == 0) {
				var h = map.getScale()*_identifydistance;
				real_identifyextent.miny = real_identifyextent.miny-(h/2);
				real_identifyextent.maxy = real_identifyextent.miny+h;
			}
			var subfields:String = layers[layeridString].subfields.split(",").join(" ");
			var query:String = layers[layeridString].query;
			conn.getFeatures(mapservice, layeridString, _selectExtent, subfields, query, map.copyExtent(_selectExtent));

			break;
		}
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
			var a_ids = flamingo.asArray(ids);
			for (var i = 0; i<a_ids.length; i++) {
				var id = a_ids[i];
				if (layers[id] == undefined and !initialized) {
					layers[id] = new Object();
					layers[id][field] = value;
				} else {
					layers[id][field] = value;
				}
			}
		}
		flamingo.raiseEvent(this, "onSetLayerProperty", this, ids, field);
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
	* @return Object Collection of layers. A layer is an object with several properties, such as name, id, minscale, maxscale etc.
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
	function moveToLayer(ids:String, coord:Object, updatedelay:Number, movetime:Number) {
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
			map.moveToScale(zoomtoscale, coord, updatedelay, movetime);
		}
	}
	function getLegend():String {
		return legendurl;
	}
	/** 
	* Changes the visiblity of a layer or a sub-layer.
	* @param vis:Boolean True (visible) or false (not visible).
	* @param id:String [optional] A layerid. If omitted the entire maplayer will be effected.
	*/
	function setVisible(vis:Boolean, id:String) {
		if (id.length == 0 || id == undefined) {
			super.setVisible(vis);
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
		//returns 0 : not visible or 1:  visible or 2: visible but not in scalerange
		var ms:Number = map.getScale(extent);
		//var vis:Boolean = flamingo.getVisible(this)
		if (id.length == 0 || id == undefined) {
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
			if (sublayer == undefined) {
				return 0;
			} else {
				if (sublayer.visible) {
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
	function updateCaches() {
		for (var nr in caches) {
			updateCache(caches[nr]);
		}
	}
	function updateCache(layer:MovieClip) {
		if (layer == undefined) {
			return;
		}
		if (visible) {
			var ms = map.getScale();
			if (minscale != undefined) {
				if (ms<=minscale) {
					_visible = false;
					return;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					_visible = false;
					return;
				}
			}
			_visible = true;
			var r:Object = map.extent2Rect(layer.extent);
			layer._x = r.x;
			layer._y = r.y;
			layer._width = r.width;
			layer._height = r.height;
		}
	}
	/** Gets the scale of the layer
	* &return scale
	*/
	function getScale():Number {
		return map.getScale(extent);
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
	function _getString(item:Object, stringid:String):String {
		var lang = flamingo.getLanguage();
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
	function stopMaptip() {
		this.showmaptip = false;
		this.maptipcoordinate = new Object();
		this._maptiplayers = new Array();
	}
	function startMaptip(x:Number, y:Number) {
		this._maptiplayers = new Array();
		this.maptipcoordinate = new Object();
		if (!this.canmaptip) {
			return;
		}
		if (!this.initialized) {
			return;
		}
		if (maptipids.length<=0) {
			return;
		}
		if (!visible || !_visible) {
			return;
		}
		if (server == undefined) {
			return;
		}
		if (mapservice == undefined) {
			return;
		}
		if (this.fullextent != undefined) {
			if (!this.map.isHit({x:x, y:y}, this.fullextent)) {
				return;
			}
		}
		this.maptipcoordinate.x = x;
		this.maptipcoordinate.y = y;
		this.showmaptip = true;
		this._maptiplayers = _getLayerlist(maptipids, "maptipable");
		_maptip(x, y);
		var r = new Object();
		r.x = x-this.identifydistance/2;
		r.y = y-this.identifydistance/2;
		r.width = this.identifydistance;
		r.height = this.identifydistance;
		this.maptipextent = this.map.rect2Extent(r);
	}
	function _maptip(x:Number, y:Number) {
		if (!this.showmaptip) {
			return;
		}
		if (this._maptiplayers.length == 0) {
			return;
		}
		var thisObj:ArcIMSLayer = this;
		var lConn = new Object();
		lConn.onResponse = function(connector:ArcIMSConnector) {
			//trace(connector.response);
			thisObj.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "maptip", connector);
		};
		lConn.onRequest = function(connector:ArcIMSConnector) {
			//trace(connector.request);
			thisObj.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "maptip", connector);
		};
		lConn.onError = function(error:String, objecttag:Object, requestid:String) {
			thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "maptip", error);
			if (thisObj._maptiplayers.length>0) {
				thisObj._maptip(x, y);
			}
		};
		lConn.onGetRasterInfo = function(layerid:String, data:Array, objecttag:Object) {
			if (thisObj.showmaptip) {
				if (thisObj.maptipcoordinate.x == objecttag.x and thisObj.maptipcoordinate.y == objecttag.y) {
					thisObj._completeWithMydata(layerid, data);
					var maptip = thisObj._getString(thisObj.layers[layerid], "maptip");
					maptip = thisObj._makeMaptip(layerid, maptip, data[0]);
					if (maptip.length>=0) {
						thisObj.flamingo.raiseEvent(thisObj, "onMaptipData", thisObj, maptip);
						if (!thisObj.maptipall) {
							return;
						}
					}
				}
				if (thisObj._maptiplayers.length>0) {
					thisObj._maptip(x, y);
				}
			}
		};
		lConn.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
			if (thisObj.showmaptip) {
				if (count>0) {
					if (thisObj.maptipcoordinate.x == objecttag.x and thisObj.maptipcoordinate.y == objecttag.y) {
						thisObj._completeWithMydata(layerid, data);
						var maptip = thisObj._getString(thisObj.layers[layerid], "maptip");
						maptip = thisObj._makeMaptip(layerid, maptip, data[0]);
						if (maptip.length>=0) {
							thisObj.flamingo.raiseEvent(thisObj, "onMaptipData", thisObj, maptip);
							if (!thisObj.maptipall) {
								return;
							}
						}
					}
				}
				if (thisObj._maptiplayers.length>0) {
					thisObj._maptip(x, y);
				}
			}
		};
		//
		var layerid:String = String(_maptiplayers.pop());
		var conn:ArcIMSConnector = new ArcIMSConnector(server);
		if (servlet.length>0) {
			conn.servlet = servlet;
		}
		conn.addListener(lConn);
		conn.featurelimit = 1;
		
		var maptip = _getString(layers[layerid], "maptip");
		var maptipfields = _getMaptipFields(layerid, maptip);
		if (maptipfields == undefined || maptipfields.length == 0) {
			thisObj._maptip(x, y);
			return;
		}
		switch (layers[layerid].type) {
		case "featureclass" :
			var query:String = layers[layerid].query;
			var flds = maptipfields;
			var _maptipdistance = layers[layerid].maptipdistance;
			if (_maptipdistance == undefined) {
				_maptipdistance = this.maptipdistance;
			}
			var _maptipextent = new Object();
			var w = map.getScale()*_maptipdistance;
			var h = map.getScale()*_maptipdistance;
			_maptipextent.minx = x-(w/2);
			_maptipextent.miny = y-(h/2);
			_maptipextent.maxx = _maptipextent.minx+w;
			_maptipextent.maxy = _maptipextent.miny+h;
			conn.getFeatures(mapservice, layerid, _maptipextent, flds, query, {x:x, y:y});
			break;
		case "image" :
			conn.getRasterInfo(mapservice, layerid, {x:x, y:y}, layers[layerid].coordsys, {x:x, y:y});
			break;
		}
	}
	function _getValue(record:Object, field:String):String {
		var value;
		for (var fld in record) {
			if (fld.toLowerCase() == field.toLowerCase()) {
				value = record[fld];
				break;
			}
			if (fld.indexOf(".", 0)>=0 and field.indexOf(".", 0)<0) {
				field = "."+field;
			}
			if (fld.substr(fld.length-field.length).toLowerCase() == field.toLowerCase()) {
				value = record[fld];
				break;
			}
		}
		return value;
	}
	//
	function _string2Table(s:String, rdel:String, fdel:String):Array {
		var table:Array = new Array();
		var record:Object;
		var records:Array;
		var values:Array;
		var fields:Array;
		//
		s = flamingo.trim(s);
		records = flamingo.asArray(s, rdel);
		fields = flamingo.asArray(records[0], fdel);
		for (var i = 1; i<records.length; i++) {
			record = new Object();
			values = flamingo.asArray(records[i], fdel);
			for (var j = 0; j<fields.length; j++) {
				record[fields[j]] = values[j];
			}
			table.push(record);
		}
		return table;
	}
	//
	function _getMaptipFields(layerid:String, maptip:String):String {
		layers[layerid].maptipfields = new Object();
		var flds:Array = new Array();
		var fld:String;
		var temp:Object = new Object();
		var end:Number;
		var begin:Number = maptip.indexOf("[");
		while (begin>=0) {
			end = maptip.indexOf("]", begin);
			if (end>=0) {
				fld = maptip.substring(begin+1, end);
				layers[layerid].maptipfields[fld] = "";
				temp[fld] = "";
			} else {
				break;
			}
			begin = maptip.indexOf("[", begin+1);
		}
		//
		for (var jointo in layers[layerid].mydatajoins) {
			for (var joinfield in layers[layerid].mydatajoins[jointo]) {
				for (var maptipfield in temp) {
					if (joinfield.toLowerCase() == maptipfield.toLowerCase()) {
						delete temp[maptipfield];
						temp[jointo] = "";
					}
				}
			}
		}
		for (var maptipfield in temp) {
			flds.push(maptipfield);
		}
		//
		return flds.join(" ");
	}
	function _makeMaptip(layerid:String, maptip:String, record:Object):String {
		var val:String;
		var b:Boolean = false;
		for (var fld in layers[layerid].maptipfields) {
			val = _getValue(record, fld);
			if (val == undefined) {
				val = "";
			} else {
				b = true;
			}
			maptip = maptip.split("["+fld+"]").join(val);
		}
		if (b) {
			return maptip;
		} else {
			return "";
		}
	}
	/**
	* Sets (overwrites) the recorded (object that needs to be colored) of this layer
	* @param layerid:String the layer id of this object.
	* @param key:String the key on which the check is done?
	* @param values:String Comma seperated list. All objects with key = values[] are recorded (colored)
	*/
	function setRecordedValues(layerid:String, key:String, values:String){
		if (this.newRecorded[layerid] ==undefined){
			this.newRecorded[layerid]=new Object();
		}
		this.newRecorded[layerid][key]=values.split(",");
		update();
	}
	/**
	* Adds recorded (object that needs to be colored) condition of this layer
	* @param layerid:String the layer id of this object.
	* @param key:String the key on which the check is done?
	* @param values:String Comma seperated list. All objects with key = values[] are recorded (colored)
	*/
	function addRecordedValues(layerid:String, key:String, values:String){
		if (this.addRecorded[layerid] ==undefined){
			this.addRecorded[layerid]=new Object();
		}
		this.addRecorded[layerid][key]=values.split(",");
		update();
		
	}
	function log(stringtolog:Object){	
		if (DEBUG){
			var newDate:Date = new Date();
			trace(newDate +"LayerArcIms: " + stringtolog);
		}
	}
	
	public function getParent():Object {
		return this.map;
	}
	
	/***********************************************************
	 * map listeners
	 */
	public function onChangeExtent(map:MovieClip):Void  {
		updateCaches();
	}
	public function onHotlink(map:MovieClip, identifyextent:Object):Void  {
		hotlink(identifyextent);
	}
	public function onSelect(map:MovieClip, serviceId:Object, selectExtent:Object, selectLayer:Object, subfields:Array) {
		if(serviceId == this.name) {			
			select(selectExtent, selectLayer, subfields)
		}
	}
	public function onHotlinkCancel(map:MovieClip):Void  {
		cancelHotlink();
	}
	public function onHide(map:MovieClip):Void  {
		update();
	}
	public function onShow(map:MovieClip):Void  {
		update();
	}
	/**
	* Dispatched when the layer gets a request object from the connector.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" , "init" or "maptip"
	* @param requestobject:Object the object returned from the ArcIMSConnector, containing the raw requests and other properties.
	*/
	//public function onRequest(layer:MovieClip, type:String, requestobject:Object):Void {
	//
	/**
	* Dispatched when the layer gets a response object from the connector.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" , "init" or "maptip"
	* @param responseobject:Object the object returned from the ArcIMSConnector, containing the raw response and other properties.
	*/
	//public function onResponse(layer:MovieClip, type:String, responseobject:Object):Void {
	//
	/**
	* Dispatched when there is an error.
	* @param layer:MovieClip a reference to the layer.
	* @param type:String "update", "identify" , "init" or "maptip"
	* @param error:String error message
	*/
	//public function onError(layer:MovieClip, type:String, error:String):Void {
	//
	/**
	* Dispatched when the layer is identified.
	* @param layer:MovieClip a reference to the layer.
	* @param identifyextent:Object the extent that is identified
	*/
	//public function onIdentify(layer:MovieClip, identifyextent:Object):Void {
	//
	/**
	* Dispatched when the layer is identified and data is returned
	* @param layer:MovieClip a reference to the layer.
	* @param data:Object data object with the information 
	* @param identifyextent:Object the original extent that is identified 
	* @param nridentified:Number Number of sublayers thas has already been identified.
	* @param total:Number Total number of sublayers that has to be identified 
	*/
	//public function onIdentifyData(layer:MovieClip, data:Object, identifyextent:Object, nridentified:Number, total:Number):Void {
	//
	/**
	* Dispatched when the identify is completed.
	* @param layer:MovieClip a reference to the layer.
	* @param identifytime:Number total time of the identify 
	*/
	//public function onIdentifyComplete(layer:MovieClip, identifytime:Number):Void {
	//	
	/**
	* Dispatched when the starts an update sequence.
	* @param layer:MovieClip a reference to the layer.
	* @param nrtry:Number   number of retry after an error. 
	*/
	//public function onUpdate(layer:MovieClip, nrtry):Void {
	//
	/**
	* Dispatched when the layerimage is downloaded.
	* @param layer:MovieClip a reference to the layer.
	* @param bytesloaded:Number   Number of bytes already downloaded. 
	* @param bytestotal:Number   Total of bytes to be downloaded.
	*/
	//public function onUpdateProgress(layer:MovieClip, bytesloaded:Number, bytestotal:Number):Void {
	//
	/**
	* Dispatched when the layer is completely updated.
	* @param layer:MovieClip a reference to the layer.
	* @param updatetime:Object total time of the update sequence
	*/
	//public function onUpdateComplete(layer:MovieClip, updatetime:Number):Void {
	//
	/**
	* Dispatched when the layer is hidden.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onHide(layer:MovieClip):Void {
	//
	/**
	* Dispatched when the layer is shown.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onShow(layer:MovieClip):Void {
	//
	/**
	* Dispatched when a legend is returned during an update sequence.
	* @param layer:MovieClip a reference to the layer.
	* @param legendurl:String the url of the legend.
	*/
	//public function onGetLegend(layer:MovieClip, legendurl:String):Void {
	//
	/**
	* Dispatched when a the layer is up and running and ready to update for the first time.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onInit(layer:MovieClip):Void {
	//
	/**
	* Dispatched when a the layer gets its initial information from the server.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onGetServiceInfo(layer:MovieClip):Void {
	//	
	/**
	* Dispatched when a the layers collection is changed by setLayerProperty().
	* @param layer:MovieClip A reference to the layer.
	* @param ids:String  The affected layers.
	*/
	//public function onSetLayerProperty(layer:MovieClip, ids:String, prop:String):Void {
	//
	/**
	* Dispatched when a layer has data for a maptip.
	* @param layer:MovieClip A reference to the layer.
	* @param maptip:String  the maptip
	*/
	//public function onMaptipData(layer:MovieClip, maptip:String):Void {
	//
}