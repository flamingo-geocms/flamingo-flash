/**
 * ...
 * @author Roy Braam
 */

import tools.Logger;
import gui.marker.DefaultMarker;
import gui.marker.FOVMarker;
import core.PersistableComponent;
import core.AbstractPositionable;
import tools.XMLTools;

/** @component Map
* The Map is a container for layers.
* Supported arguments: extent (comma seperated list of minx,miny,maxx,maxy)  eg. flamingo.swf?config=mymap.xml&amp;map.extent=100,123,124,156
* @file Map.as  (sourcefile)
* @file Map.fla (sourcefile)
* @file Map.swf (compiled Map, needed for publication on internet)
* @file Map.xml (configurationfile for Map, needed for publication on internet)
*/
/** @tag <fmc:Map>  
* This tag defines a map. A Map can contain different layer tags
* @hierarchy childnode of <flamingo> or <fmc:Window>
* @example
* @attr extent  Comma seperated list of minx,miny,maxx,maxy,{extentname} defining the current view of the map. 
* @attr fullextent  Comma seperated list of minx,miny,maxx,maxy,{extentname}. When defined, a map cannot zoom further out than this extent.
* @attr extenthistory (defaultvalue "0") Number of extents that are remembered.
* @attr mapunits (defaultvalue "") Values are "" or "DECIMALDEGREES". It affects the way distances are calculated.
* @attr conformal (defaultvalue "false") True or false. True: the map corrects the mapextent to ensure (in the center of the map) equal values for horizontal and vertical distances.
* @attr minscale  A map cannot zoom further in than this scale (defined in mapunits per pixel).
* @attr maxscale  A map cannot zoom further out than this scale (defined in mapunits per pixel).
* @attr zoomscalefactor  The map zooms in steps with this factor starting with the minScale (minscale is required) and ending with the initialextent (when configured);
* @attr resolutions A comma seperated list of resolutions this map must use. From big to small. Can't be used in combination with 'zoomscalefactor'
* @attr initextenttoscale (defaultvalue "true") if set to false the init extent will not respect the zoomscale levels set with zoomscalefactor.
* @attr holdonupdate  (defaultvalue "false") True or false. True: the map cannot update until the previous update is completed.
* @attr holdonidentify (defaultvalue "false") True or false. True: the map cannot perform an identify until the previous identify is completed.
* @attr fadesteps  (defaultvalue "3")  Number of steps of the fade-effect, which layers use to appear.
* @attr movetime  (defaultvalue "200") The time in miliseconds (1000 = 1 second) the map needs for moving to a new extent.
* @attr movesteps  (defaultvalue "5") The number of steps (resolution) of a move from the one extent to the other. More steps = smoother animation = more computer stress.
* @attr movequality  (defaultvalue "MEDIUM") The quality of the map during zooming. Values are "LOW", "MEDIUM", "HIGH" or "BEST".
* @attr maptipdelay (defaultvalue "") Time in miliseconds (1000 = 1 second) the mouse have to hover on one spot to raise a maptip event.
* @attr maptipresolution (defaultvalue "3") Number of pixels the mouse have to move to raise a new maptip event.
* @attr clear  (defaultvalue "true") True or false. True: all existing layers will be removed from the map.
* @attr autorefreshdelay  (optional; no defaultvalue) Time in miliseconds (1000 = 1 second) at which rate the map automatically refreshes. If not given, the map will not refresh automatically.
*/
class gui.Map extends AbstractPositionable implements PersistableComponent{
	public var version:String = "2.0.1";
	var defaultXML:String = "";
	public var conformal:Boolean;
	public var mapunits:String;
	public var __width:Number;
	public var __height:Number;
	public var holdonidentify:Boolean;
	public var holdonupdate:Boolean;
	public var updating:Boolean;
	public var identifying:Boolean;
	public var moving:Boolean;
	public var maxscale:Number;
	public var minscale:Number;
	public var zoomScaleFactor:Number;
	private var resolutions:Array;
	public var movetime:Number;
	public var movesteps:Number;
	public var movequality:String;
	public var fadesteps:Number;
	public var hit:Boolean;
	public var prevextents:Array;
	public var nextextents:Array;
	//
	private var maptipdelay:Number;
	//
	private var angle:Number;
	private var _mapextent:Object;
	private var _currentextent:Object;
	private var _fullextent:Object;
	private var _cfullextent:Object;
	private var _extent:Object;
	private var _initialextent:Object;
	private var _updatedextent:Object;
	private var _identifyextent:Object;
	private var rememberextent:Boolean;
	private var nrprevextents:Number;
	private var cursor:Object;
	//
	private var layersupdating:Object;
	private var layersidentifying:Object;
	//
	private var xresolution:Number;
	private var yresolution:Number;
	//
	private var moveid:Number;
	private var updateid:Number;
	private var maptipid:Number;
	private var maptipresolution:Number;
	private var maptipcalled:Boolean;
	private var maptipcoord:Object;
	private var saveextent:Boolean;
	private var clearlayers:Boolean; 
	private var initExtentToScale:Boolean;
	//
	private var configObjId:String;
	public var hasextent:Boolean;
	//
	private var nextDepth:Number=0
	private var markers:Array=null;
	private var markerIDnr:Number = 0;
	private var fovMarker:FOVMarker=null;
	public var nrOfServiceLayers:Number = 0;
	public var log = null;
	//Background movieclip
	private var _mBG:MovieClip;
	private var _mLayers:MovieClip;
	private var mAcetate:MovieClip;
	//update time
	private var startupdatetime:Date;
	
	/**
	 * Constructor for creating a Map component
	 * @param id the id of this component
	 * @param container the MovieClip that contains this Component
	 * @see AbstractPositionable#Constructor(id:String,container:MovieClip);
	 */
	public function Map(id:String, container:MovieClip) {
		super(id, container);
		this.log = new Logger("Map",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Map "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
		//defaults                                                                                     
		mapunits = "";
		conformal = false;
		hit = false;
		angle = 0;
		rememberextent = true;
		nrprevextents = 0;
		holdonidentify = false;
		holdonupdate = false;
		updating = false;
		identifying = false;
		moving = false;
		fadesteps = 3;
		movequality = "MEDIUM";
		movetime = 200;
		movesteps = 5;
		saveextent = false;
		maptipcalled = false;
		maptipresolution = 3;
		maptipcoord = new Object();
		maptipcoord.x = 0;
		maptipcoord.y = 0;
		maptipdelay = undefined;
		minscale = undefined;
		maxscale = undefined;
		zoomScaleFactor = undefined;
		initExtentToScale=true;
		hasextent = false;
		layersupdating = new Object();
		layersidentifying = new Object();
		this.prevextents = new Array();
		//because this is a superclass we have to correct the target information
		flamingo.correctTarget(this._parent, this.container);
		//
		var thisObj:Map = this;		
		//flamingo
		var lFlamingo:Object = new Object();
		lFlamingo.onLoadComponent = function(mc:Object) {	
			var objectid = mc._name;
			var movieClip= MovieClip(mc);
			if (mc instanceof AbstractPositionable){
				objectid = AbstractPositionable(mc).id;
				movieClip = AbstractPositionable(mc).container;
			}
			if (thisObj.mLayers[objectid] == movieClip) {
				thisObj.flamingo.raiseEvent(thisObj, "onAddLayer", thisObj, mc);
				thisObj.checkUpdate()
				//deal with argument extent, wait untill at least one layer is loaded 
				var val = thisObj.flamingo.getArgument(thisObj, "extent");
				if (val != undefined && thisObj.configObjId == null) {
					var e = null;
					if (val.toLowerCase() == "cookie") {
						e = thisObj.flamingo.getCookie(thisObj.flamingo.getId(thisObj)+".mapextent");
					} else {
						e = thisObj.string2Extent(val);
					}
					//trace("cookie"+e.minx)
					thisObj.correctExtent(e);
					thisObj.moveToExtent(e, 0);
				}
				thisObj.flamingo.deleteArgument(this, "extent");
			}
		};
		lFlamingo.onConfigComplete = function() {
			//If you do it just in onConfigComplete the map gets loaded twice 
			//once with initial extent and once with the extent in the argument
			//moved this code to onLoadComponent 
			//deal with arguments
			/*var val = flamingo.getArgument(thisObj, "extent");
			if (val != undefined && configObjId==null) {
				if (val.toLowerCase() == "cookie") {
					var e = flamingo.getCookie(flamingo.getId(thisObj)+".mapextent");
				} else {
					var e = thisObj.string2Extent(val);
				}
				//trace("cookie"+e.minx)
				thisObj.correctExtent(e);
				thisObj.moveToExtent(e, 0);
			}
			flamingo.deleteArgument(this, "extent");*/
		};
		flamingo.addListener(lFlamingo, "flamingo", this);
		//
		//special listener for mousewheel
		//TODO Still needed? Expensive....
		var lMouse:Object = new Object();
		lMouse.onMouseWheel = function(delta, target) {
			if (thisObj.hit) {
				var coord = thisObj.point2Coordinate({x:thisObj.container._xmouse, y:thisObj.container._ymouse});
				thisObj.flamingo.raiseEvent(thisObj, "onMouseWheel", thisObj, delta, thisObj.container._xmouse, thisObj.container._ymouse, coord);
			}
		};
		Mouse.addListener(lMouse);
		//
		//------------------------------------------
		// step2: Movies
		//------------------------------------------
		//var mc:MovieClip = this.attachMovie("bg", "mBG", 0);
		mBG = this.container.createEmptyMovieClip("mBG", 0);
		mBG.beginFill(0x0000FF, 0);
		mBG.moveTo(0, 0);
		mBG.lineTo(300, 0);
		mBG.lineTo(300, 300);
		mBG.lineTo(0, 300);
		mBG.lineTo(0, 0);
		mBG.endFill();
		//
		mBG.useHandCursor = false;
		mBG.onRollOver = function() {
			thisObj.flamingo.raiseEvent(thisObj, "onRollOver", thisObj);
			thisObj.flamingo.showCursor(thisObj.cursor);
			thisObj.hit = true;
			this.onMouseMove = function() {
				if (thisObj.hit) {
					var x = thisObj.container._xmouse;
					var y = thisObj.container._ymouse;
					var coord = thisObj.point2Coordinate( { x:x, y:y } );
					thisObj.flamingo.raiseEvent(thisObj, "onMouseMove", thisObj, x, y, coord);
					// the following is for maptips
					if (thisObj.maptipdelay>0) {
						if (!this.md) {
							if (!thisObj.moving) {
								if (Math.abs(thisObj.maptipcoord.x-x)>thisObj.maptipresolution || Math.abs(thisObj.maptipcoord.y-y)>thisObj.maptipresolution) {
									if (thisObj.maptipcalled) {
										thisObj.flamingo.raiseEvent(thisObj, "onMaptipCancel", thisObj);
										thisObj.maptipcalled = false;
									}
									clearInterval(thisObj.maptipid);
									thisObj.maptipid = setInterval(thisObj, "maptip", thisObj.maptipdelay, x, y, coord);
								}
							}
						}
					}
				}
				updateAfterEvent();
			};
			this.onMouseDown = function() {
				if (thisObj.hit) {
					clearInterval(thisObj.maptipid);
					this.md = true;
					var coord = thisObj.point2Coordinate({x:thisObj.container._xmouse, y:thisObj.container._ymouse});
					thisObj.flamingo.raiseEvent(thisObj, "onMouseDown", thisObj, thisObj.container._xmouse, thisObj.container._ymouse, coord);
				}
			};
			this.onDragOver = function() {
				thisObj.flamingo.showCursor(thisObj.cursor);
				thisObj.flamingo.raiseEvent(thisObj, "onMaptipCancel", thisObj);
				thisObj.flamingo.raiseEvent(thisObj, "onDragOver", thisObj);
				thisObj.hit = true;
			};
			this.onDragOut = function() {
				clearInterval(thisObj.maptipid);
				thisObj.flamingo.hideCursor();
				thisObj.flamingo.raiseEvent(thisObj, "onMaptipCancel", thisObj);
				thisObj.flamingo.raiseEvent(thisObj, "onDragOut", thisObj);
				thisObj.hit = false;
			};
			this.onMouseUp = function() {
				if (this.md) {
					delete this.md;
					var coord = thisObj.point2Coordinate({x:thisObj.container._xmouse, y:thisObj.container._ymouse});
					thisObj.flamingo.raiseEvent(thisObj, "onMouseUp", thisObj, thisObj.container._xmouse, thisObj.container._ymouse, coord);
				}
				if (!thisObj.hit) {
					delete this.onMouseMove;
					delete this.onMouseUp;
					delete this.onMouseDown;
					delete this.onDragOver;
					delete this.onDragOut;
				}
			};
		};
		mBG.onRollOut = function() {
			clearInterval(thisObj.maptipid);
			thisObj.hit = false;
			thisObj.flamingo.hideCursor();
			thisObj.flamingo.raiseEvent(thisObj, "onMaptipCancel", thisObj);
			thisObj.flamingo.raiseEvent(thisObj, "onRollOut", thisObj);
			delete this.coord;
			delete this.onMouseMove;
			delete this.onMouseUp;
			delete this.onMouseDown;
			delete this.onDragOver;
			delete this.onDragOut;
		};
		this.mLayers=this.container.createEmptyMovieClip("mLayers", 1);
	
		//--------------------------
		//defaults
		//custom
		var xmls:Array = this.flamingo.getXMLs(this);
		for (var i = 0; i<xmls.length; i++) {		
			this.setConfig(xmls[i]);
		}

		//LV:Do not remove the xmls because of re-use by the map(s) in the printtemplate(s)
		//delete xmls;
		//remove xml from repository
		//flamingo.deleteXML(this);
		this._visible = this.visible;
		flamingo.raiseEvent(this, "onInit", this);
	}
	
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	public function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml= xml.firstChild;
		}
		if (this.type!=undefined && this.type.toLowerCase() != xml.localName.toLowerCase()) {
			return;
		}
		clearlayers = false;
		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		this.parseCustomAttr(xml);
		
	}
		
	private function parseCustomAttr(xml:Object) {
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "configobject" :
				configObjId = val;
				//_global.flamingo.tracer(_global.flamingo.getId(this) + " Legend set configObj " + _global.flamingo.getId(configObj) + flamingo.getXMLs(configObj).length);
				//parsing of xml is done when printTemplate becomes visible
				break;
			case "clear" :
				if (val.toLowerCase() == "true") {
					clearlayers = true;
				}
				if(configObjId!=null){
					clearlayers = false;
				}
				break;
			case "extenthistory" :
				this.nrprevextents = Number(val);
				break;
			case "saveextent" :
				if (val.toLowerCase() == "true") {
					this.saveextent = true;
				} else {
					this.saveextent = false;
				}
				break;
			case "holdonupdate" :
				if (val.toLowerCase() == "true") {
					this.holdonupdate = true;
				} else {
					this.holdonupdate = false;
				}
				break;
			case "holdonidentify" :
				if (val.toLowerCase() == "true") {
					this.holdonidentify = true;
				} else {
					this.holdonidentify = false;
				}
				break;
			case "fadesteps" :
				this.fadesteps = Number(val);
				break;
			case "maptipdelay" :
				this.maptipdelay = Number(val);
				break;
			case "maptipresolution" :
				this.maptipresolution = Number(val);
				break;
			case "extent" :
				this._extent = this.string2Extent(val);
				this._initialextent = this.string2Extent(val);
				break;
			case "fullextent" :
				this._fullextent = this.string2Extent(val);
				break;
			case "minscale" :
				this.minscale = Number(val);
				break;
			case "maxscale" :
				this.maxscale = Number(val);
				break;
			case "zoomscalefactor" :
				if (this.resolutions!=undefined){
					log.error("Resolutions and ZoomScaleFactor can't be used at the same time");
				}
				this.zoomScaleFactor = Number(val);
				break;				
			case "resolutions" :
				if (this.zoomScaleFactor!=undefined){
					log.error("Resolutions and ZoomScaleFactor can't be used at the same time");
				}
				var stringRes:Array = val.split(",");
				this.resolutions= new Array();
				for (var i=0; i < stringRes.length; i++){
					this.resolutions[i]=Number(stringRes[i]);
				}
				break;				
			case "initextenttoscale" :
				if (val.toLowerCase() == "true") {
					this.initExtentToScale = true;
				} else {
					this.initExtentToScale = false;
				}
				break;
			case "movetime" :
				this.movetime = Number(val);
				break;
			case "movequality" :
				this.movequality = val.toUpperCase();
				break;
			case "movesteps" :
				this.movesteps = Number(val);
				break;
			case "mapunits" :
				this.mapunits = val.toUpperCase();
				break;
			case "conformal" :
				if (val.toLowerCase() == "true") {
					this.conformal = true;
				} else {
					this.conformal = false;
				}
				break;
			case "autorefreshdelay" :
				setInterval(this, "autoRefresh", Number(val));
				break;
			default :
				break;
			}
		}
		if (this.resolutions!=undefined && this.resolutions.length>1){
			log.debug("set minscale and maxscale");
			this.minscale=Number(resolutions[resolutions.length-1]);
			this.maxscale=Number(resolutions[0]);
			log.debug("new minscale: "+this.minscale);
			log.debug("new maxscale: "+this.maxscale);
		}
		//
		if (clearlayers) {
			this.clear();
		}
		resize();
		//component resized further with adding layers
		//go on with adding layers
		this.addLayers(xml);
	}
	private function maptip(x:Number, y:Number, coord:Object) {
		clearInterval(this.maptipid);
		this.maptipcoord.x = x;
		this.maptipcoord.y = y;
		flamingo.raiseEvent(this, "onMaptip", this, x, y, coord);
		this.maptipcalled = true;
	}
	//private function cacheMap() {
	//trace("cache");
	//this.bmpcache = new flash.display.BitmapData(__width, __height, true);
	//this.mCache.attachBitmap(this.bmpcache, 0, "auto", true);
	//this.bmpcache.draw(this.mLayers);
	//}
	//function releaseCache() {
	//trace("release");
	//this.bmpcache.dispose();
	//}
	/**
	* Forces a resize of the map
	* This will raise the onResize event.
	*/
	public function resize():Void {		
		this.container._xscale = this.container._yscale=100;
		var r:Object = flamingo.getPosition(this);
		this.container._x = r.x;
		this.container._y = r.y;
		this.__width = r.width;
		this.__height = r.height;
		this.mBG._width = __width;
		this.mBG._height = this.__height;
		this.mBorder._width = __width;
		this.mBorder._height = this.__height;
		this.container.scrollRect = new flash.geom.Rectangle(0, 0, (this.__width), (this.__height));
		if (this._fullextent != undefined) {
			this._cfullextent = this.copyExtent(this._fullextent);
			this.correctExtent(this._cfullextent);
		}
		this.rememberextent = false;
		var c = this.copyExtent(this._extent);
		this.correctExtent(c);
		this.moveToExtent(c, undefined, 0,false);
		flamingo.raiseEvent(this, "onResize", this);
		this.update();
	}
	/**
	* Adds one or more layers to the map.
	* If a layer is added the onAddLayer event will dispatch.
	* @example
	* var s = "<flamingo xmlns:fmc='fmc'>"
	* s += "<fmc:LayerImage  id='NL'  imageurl='assets/nl.png' extent='13562,306839,278026,614073' />"
	* s += "<fmc:LayerImage  id='NL2'  imageurl='assets/nl.png' extent='13562,306839,278026,614073' />"
	* s += "</flamingo>"
	* mymap.addLayers(s)
	* @param xml:Object xml(or string representing an xml) with layer definition
	*/
	public function addLayers(xml:Object):Void {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;
		}
		var xlayers:Array = xml.childNodes;
		if (xlayers.length>0) {
			for (var i:Number = xlayers.length-1; i>=0; i--) {
				this.addLayer(xlayers[i]);
			}
		}
	}
	/**
	* Adds one layer to the map
	* If a layer is added the onAddLayer event will dispatch.
	* @example
	* var s = "<fmc:LayerImage xmlns:fmc='fmc'  id='NL'  imageurl='assets/nl.png' extent='13562,306839,278026,614073' />"
	* mymap.addLayer(s)
	* @param xml:Object xml(or string representing an xml) with layer definition
	* @return String Id of the added layer.
	*/
	public function addLayer(xml):String {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml = xml.firstChild;			
		}
			
		//determine id                         
		var mapid:String = flamingo.getId(this);
		var id:String;
		for (var attr in xml.attributes) {
			if (attr.toLowerCase() == "id") {
				id = xml.attributes[attr];
				break;
			}
		}
		if (id == undefined) {
			id = flamingo.getUniqueId();
			xml.attributes.id = id;
		}
		var layerid = mapid+"_"+id;
		var depth = this.getNextDepth();
		if(xml.localName == "LayerIdentifyIcon"){
			depth=10000;
		}
		if (flamingo.exists(layerid)) {
			// let flamingo deal with double ids
			flamingo.addComponent(xml, layerid);
			//if (this.mLayers[layerid] != undefined) {
			//flamingo.loadComponent(xml, this.mLayers[layerid], layerid);
			//}
			//layer already exists, use original depth to add new layer 
			//if (this.mLayers[layerid] != undefined) {
			//depth = this.mLayers[layerid].getDepth();
			//}
			//this.removeLayer(layerid);
		} else {
			// add new movie 
			var mc:MovieClip = this.mLayers.createEmptyMovieClip(layerid, depth);			
			var thisObj:Map = this;
			var lLayer:Object = new Object();
			lLayer.onUpdate = function(layer:MovieClip, nrtry:Number) {
				thisObj.layersupdating[layer._name] = new Object();
				thisObj.layersupdating[layer._name].updatecomplete = false;
				thisObj.checkUpdate();
			};
			lLayer.onUpdateComplete = function(layer:MovieClip) {
				thisObj.layersupdating[layer._name].updatecomplete = true;
				thisObj.checkUpdate();
			};
			lLayer.onIdentify = function(layer:MovieClip, extent:Object) {
				//thisObj.identifying = true;
				//trace("Onidentify:"+thisObj.extent2String(extent));
				thisObj.layersidentifying[layer._name] = new Object();
				thisObj.layersidentifying[layer._name].nridentified = 0;
				thisObj.layersidentifying[layer._name].totalidentify = 0;
				thisObj.layersidentifying[layer._name].identifycomplete = false;
				thisObj.checkIdentify();
			};
			lLayer.onIdentifyData = function(layer:MovieClip, data:Object, identifyextent:Object, nridentified:Number, total:Number) {
				thisObj.layersidentifying[layer._name].nridentified = nridentified;
				thisObj.layersidentifying[layer._name].totalidentify = total;
				thisObj.flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, layer, data, identifyextent, nridentified, total);
				thisObj.checkIdentify();
			};
			lLayer.onHotlinkData = function(layer:MovieClip, data:Object, identifyextent:Object, nridentified:Number, total:Number) {
				thisObj.layersidentifying[layer._name].nridentified = nridentified;
				thisObj.layersidentifying[layer._name].totalidentify = total;
				thisObj.flamingo.raiseEvent(thisObj, "onHotlinkData", thisObj, layer, data, identifyextent, nridentified, total);
				thisObj.checkHotlink();
			};
			lLayer.onSelectData = function(layer:MovieClip, data:Object, selectextent:Object, beginrecord:Number) {
				thisObj.flamingo.raiseEvent(thisObj, "onSelectData", thisObj, layer, data, selectextent, beginrecord);
			};
			lLayer.onIdentifyComplete = function(layer:MovieClip) {
				thisObj.layersidentifying[layer._name].totalidentify = thisObj.layersidentifying[layer._name].nridentified;
				thisObj.layersidentifying[layer._name].identifycomplete = true;
				thisObj.checkIdentify();
			};
			lLayer.onError = function(layer:MovieClip, type:String, error:String) {		
				type = type.toLowerCase();
				if (type == "identify") {
					thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "identify", error, layer);
					thisObj.layersidentifying[layer._name].totalidentify = thisObj.layersidentifying[layer._name].nridentified;
					thisObj.layersidentifying[layer._name].identifycomplete = true;
					thisObj.layersidentifying[layer._name].error = error;
					thisObj.checkIdentify();
				} else if (type == "update") {
					thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error, layer);
					thisObj.layersupdating[layer._name].updatecomplete = true;
					thisObj.layersupdating[layer._name].error = error;
					thisObj.checkUpdate();
				}
			};
			lLayer.onGetServiceInfo = function(layer:MovieClip) {
				thisObj.nrOfServiceLayers--;
				var themeSelector:Object = thisObj.getThemeSelector();
				if(thisObj.configObjId!=null){
					return;
				}
				if(themeSelector==null){
					layer.update();
				//if all service layers have serviceinfo/capabilities set currentTheme
				} else if (thisObj.nrOfServiceLayers==0){
					themeSelector.setCurrentTheme();
				} 	
			};
			lLayer.onGetCapabilities =  function(layer:MovieClip) {
				thisObj.nrOfServiceLayers--;
				var themeSelector:Object = thisObj.getThemeSelector();
				if(thisObj.configObjId!=null){
					return;
				}
				if(themeSelector==null){
					layer.update();
				} else if (thisObj.nrOfServiceLayers==0){
					themeSelector.setCurrentTheme();
				} 				
			};			
			flamingo.addListener(lLayer, layerid, this);
			
			flamingo.loadComponent(xml, mc, layerid);
			
			//_global.flamingo.tracer("Map " + _global.flamingo.getId(this)+ " addLayer "  + layerid + " url " + _global.flamingo.getUrl(layerid) + _global.flamingo.getUrl(layerid).indexOf("LayerArcIMS"));
			//count the number of serviceLayers
			if(_global.flamingo.getUrl(layerid).indexOf("LayerArcIMS")>0 || 
				_global.flamingo.getUrl(layerid).indexOf("LayerArcServer")>0 ||
					_global.flamingo.getUrl(layerid).indexOf("LayerOGWMS")>0){
				nrOfServiceLayers++;
			} 
			return id;
		}
	}
	
	function getThemeSelector():Object {
		var comps:Array = _global.flamingo.getComponents();
		var themeSelector:Object = null;
		for(var i:Number=0;i<comps.length;i++){
			if(flamingo.getType(comps[i])=="ThemeSelector"){
				var mapId:String =  _global.flamingo.getComponent(comps[i]).getMapId();
				if(mapId == _global.flamingo.getId(this) || mapId == configObjId){
					themeSelector=_global.flamingo.getComponent(comps[i]);
				}
			}	
		}	
		return themeSelector;	
	}
	
	private function checkUpdate() {
		var updatetotal:Number = 0;
		var layersupdated:Number = 0;
		this.updating = true;
		for (var attr in this.layersupdating) {
			updatetotal++;
			if (this.layersupdating[attr].updatecomplete) {
				layersupdated++;
			}
		}
		flamingo.raiseEvent(this, "onUpdateProgress", this, layersupdated, updatetotal);
		if (updatetotal == layersupdated) {
			this.updating = false;
			flamingo.raiseEvent(this, "onUpdateComplete", this);
		}
	}
	private function checkIdentify() {
		var identifytotal:Number = 0;
		var totalsublayers:Number = 0;
		var nrsublayers:Number = 0;
		var numberlayersidentifying:Number = 0;
		this.identifying = true;
		for (var attr in this.layersidentifying) {
			identifytotal++;
			nrsublayers += this.layersidentifying[attr].nridentified;
			totalsublayers += this.layersidentifying[attr].totalidentify;
			if (this.layersidentifying[attr].identifycomplete) {
				numberlayersidentifying++;
			}
		}
		flamingo.raiseEvent(this, "onIdentifyProgress", this, numberlayersidentifying, identifytotal, nrsublayers, totalsublayers);
		if (identifytotal == numberlayersidentifying) {
			this.identifying = false;
			flamingo.raiseEvent(this, "onIdentifyComplete", this);
		}
	}
	/**TODO: Remove? Hotlink tool not needed*/
	private function checkHotlink() {
		var identifytotal:Number = 0;
		var totalsublayers:Number = 0;
		var nrsublayers:Number = 0;
		var layersidentifying:Number = 0;
		this.identifying = true;
		for (var attr in this.layersidentifying) {
			identifytotal++;
			nrsublayers += this.layersidentifying[attr].nridentified;
			totalsublayers += this.layersidentifying[attr].totalidentify;
			if (this.layersidentifying[attr].identifycomplete) {
				layersidentifying++;
			}
		}
		flamingo.raiseEvent(this, "onHotlinkProgress", this, layersidentifying, identifytotal, nrsublayers, totalsublayers);
		if (identifytotal == layersidentifying) {
			this.identifying = false;
			flamingo.raiseEvent(this, "onHotlinkComplete", this);
		}
	}
	/**
	* Removes all layers from the map.
	* This will raise the onRemoveLayer event.
	*/
	public function clear() {
		for (var id in this.mLayers) {
			this.removeLayer(id);
		}
	}
	/**
	* Gets a list of layerids.
	* @return List of layerids.
	*/
	public function getLayers():Array {
		var layers:Array = new Array();
		for (var id in this.mLayers) {
			layers.push(id);
		}
		return layers;
	}
	/**
	* Removes a layer from the map.
	* This will raise the onRemoveLayer event.
	* @param id:String Layerid.
	*/
	public function removeLayer(id:String):Void {
		delete layersupdating[id];
		flamingo.killComponent(id);
		flamingo.raiseEvent(this, "onRemoveLayer", this, id);
	}
	/**
	* Change layer order.
	* This will raise the onSwapLayer event.
	* @param id:String Layerid.
	* @param index:Number {optional] New layer position. If ommited the layer is swapped to the top.
	*/
	public function swapLayer(id:String, index:Number):Void {
		if (index == undefined) {
			index = this.getNextDepth();
		}
		this.mLayers[id].swapDepths(index);
		flamingo.raiseEvent(this, "onSwapLayer", this);
	}
	/**
	* Sets the visibility of a layer to false.
	* This will raise the onHideLayer event.
	* @param id:String Layerid.
	*/
	public function hideLayer(id:String):Void {
		this.mLayers[id].hide();
		flamingo.raiseEvent(this, "onHideLayer", this, this.mLayers[id]);
	}
	/**
	* Sets the visibility of a layer to true.
	* This will raise the onShowLayer event.
	* @param id:String Layerid.
	*/
	public function showLayer(id:String):Void {	
		this.mLayers[id].show();
		flamingo.raiseEvent(this, "onShowLayer", this, this.mLayers[id]);
	}
	/**
	* Hides the map.
	* This will raise the onHide event.
	*/
	public function hide():Void {
		this._visible = false;
		//LV: make also the visible attribute false
		this.visible = false;
		flamingo.raiseEvent(this, "onHide", this);
	}
	/**
	* Shows the map.
	* This will raise the onShow event.
	*/
	public function show():Void {	
		this._visible = true;
		//LV: make also the visible attribute true
		this.visible = true;
		flamingo.raiseEvent(this, "onShow", this);
	}
	/**
	* Cancels an identify on a map.
	* This will raise the onIdentifyCancel event.
	*/
	public function cancelIdentify():Void {
		flamingo.raiseEvent(this, "onIdentifyCancel", this);
		identifying = false;
		//this.checkIdentify();
	}
	/**
	* Performs an identify on a map.
	* This will raise the onIdentify event.
	* @param identifyextent:Object Extent defining identify area.
	*/
	
	public function identify(identifyextent:Object):Void {
		if (this.holdonidentify && this.identifying) {
			return;
		}
		this._identifyextent = this.copyExtent(identifyextent);
		flamingo.raiseEvent(this, "onIdentify", this, this._identifyextent);
		this.checkIdentify();
	}
	/**
	* Performs an hotlink request on a map.
	* This will raise the onHotlink event.
	* @param identifyextent:Object Extent defining identify area.
	*/
	public function hotlink(identifyextent:Object):Void {
		if (this.holdonidentify && this.identifying) {
			return;
		}
		this._identifyextent = this.copyExtent(identifyextent);
		flamingo.raiseEvent(this, "onHotlink", this, this._identifyextent);
		this.checkHotlink();
	}
	/** 
	* Performs a select on a map
	* This will raise the onSelect event
	* @param serviceId:String LayerComponent id
	* @param selectExtent:Object Extent defining the select area
	* @param selectLayer:String Layerid
	*/
	
	public function select(serviceId:Object, selectExtent:Object, selectLayer:Object):Void {
		flamingo.raiseEvent(this, "onSelect", this, serviceId, selectExtent, selectLayer);
	}
	
	/**
	* This will raise the onCorrectIdentifyIcon event.
	* @param identifyextent:Object Extent defining identify area.
	*/
	
	public function correctIdentifyIcon(identifyextent:Object):Void {
		flamingo.raiseEvent(this, "onCorrectIdentifyIcon", this, identifyextent);
	}
	
	/**
	* Returns the scale based on the fullextent.
	* @return  Number Scale.
	*/
	public function getFullScale():Number {
		return getScale(this._fullextent);
	}
	/**
	* Returns the scale based on the currentextent.
	* @return  Number Scale. 
	*/
	public function getCurrentScale():Number {
		return getScale(this._currentextent);
	}
	/**
	* Returns the scale based on a the mapextent
	* @return  Number Scale. 	
	*/
	public function getMapScale():Number {
		return getScale(this._mapextent);
	}
	/**
	* Returns the scale based on a extent
	* @param extent:Object [optional] Extent on which the scale is based. If undefined the map's currentextent will be used.
	* @return  Number Scale. 	
	*/
	public function getScale(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		if (mapunits == "DECIMALDEGREES") {
			var angle = (extent.maxx-extent.minx)/this.__width;
			var y = (extent.miny+extent.maxy)/2;
			var scale = degrees2Meters(angle)*Math.cos(rad(y));
			return scale;
		} else {
			var scale = (extent.maxx-extent.minx)/this.__width;
			return scale;
		}
	}
	public function getScale2(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		if (mapunits == "DECIMALDEGREES") {
			var x = (extent.minx+extent.maxx)/2;
			var y = (extent.miny+extent.maxy)/2;
			var x2 = x+((extent.maxx-extent.minx)/this.__width);
			var d = this.getDistance({x:x, y:y}, {x:x2, y:y});
			return d;
		} else {
			var scale = (extent.maxx-extent.minx)/this.__width;
			return scale;
		}
	}
	public function getScaleHint2(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		var x = (extent.minx+extent.maxx)/2;
		var y = (extent.miny+extent.maxy)/2;
		var x2 = x+((extent.maxx-extent.minx)/this.__width);
		var y2 = y+((extent.maxy-extent.miny)/this.__height);
		var d = this.getDistance({x:x, y:y}, {x:x2, y:y2});
		return (d);
	}
	/**
	* Returns the scalehint based on a extent.
	* @param extent:Object [optional] Extent on which the scalehint is based. If undefined the map's currentextent will be used.
	* @return  Number Scalehint. 	
	*/
	public function getScaleHint(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		var xs = (extent.maxx-extent.minx)/this.__width;
		var ys = (extent.maxy-extent.miny)/this.__height;
		var hint = Math.sqrt((ys*ys)+(xs*xs));
		if (mapunits == "DECIMALDEGREES") {
			hint = this.degrees2Meters(hint);
		}
		return (hint);
	}
	/**
	* Returns the height of an extent.
	* @param extent:Object [optional] Extent on which the height is based. If undefined the map's currentextent will be used.
	* @return Number height.
	*/
	public function getHeight(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		return extent.maxy-extent.miny;
	}
	/**
	* Returns the width of an extent.
	* @param extent:Object [optional] Extent on which the width is based. If undefined the map's currentextent will be used.
	* @return Number width.
	*/
	public function getWidth(extent:Object):Number {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		return extent.maxx-extent.minx;
	}
	/**
	* Returns the height of the Movieclip.
	* @return Number _height.
	*/
	public function getMovieClipHeight():Number {
		return this.container._height;
	}
	/**
	* Returns the width of of the Movieclip.
	* @return Number _width.
	*/
	public function getMovieClipWidth():Number {
		return this.container._width;
	}
	/**
	* Returns the coordinate of the center of the map.
	* @param extent:Object [optional] Extent on which the center is based. If undefined the map's currentextent will be used.
	* @return Object Center. Center is a coordinate and has 2 properties: x and y. center.x and center.y
	*/
	public function getCenter(extent:Object):Object {
		if (extent == undefined) {
			extent = this._currentextent;
		}
		var center:Object = new Object();
		center.x = (extent.maxx+extent.minx)/2;
		center.y = (extent.maxy+extent.miny)/2;
		return (center);
	}
	/**
	* Returns the mapextent.
	* extent = the uncorrected extent of a map set by 'moveToExtent'.
	* mapextent = the corrected (to aspectratio, to max- and minscale) extent of a map.
	* fullextent = the maximum extent of a map, you can not further zoom out.
	* currentextent = the actually corrected extent during animation. When animation is finished then mapextent = currentextent.
	* @return Object Mapextent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getMapExtent():Object {
		return this.copyExtent(this._mapextent);
	}
	/**
	* Returns the corrected fullextent
	* @return Object Fullextent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getCFullExtent():Object {
		return this.copyExtent(this._cfullextent);
	}
	/**
	* Returns the fullextent
	    * @return Object Fullextent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getFullExtent():Object {
		return this.copyExtent(this._fullextent);
	}
	
	/**
	* Returns the initialextent
	    * @return Object initialextent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getInitialExtent():Object {
		return this.copyExtent(this._initialextent);
	}
	
	/**
	* Returns the currentextent.
	* @return Object Currentextent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getCurrentExtent():Object {
		return this.copyExtent(this._currentextent);
	}
	/**
	* Return the extent
	* @return Object Extent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function getExtent():Object {
		return this.copyExtent(this._extent);
	}
	/**
	* Sets the full extent.
	* @param extent:Object An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	*/
	public function setFullExtent(extent:Object):Void {
		if (this.isValidExtent(extent)) {
			this._fullextent = this.copyExtent(extent);
			this._cfullextent = this.copyExtent(this._fullextent);
			this.correctAspectRatio(this._cfullextent);
		}
	}
	/** 
	* Converts meters to decimaldegrees.
	* @param meter:Number Meters.
	* @return Number Degrees.
	*/
	public function meters2Degrees(meter:Number):Number {
		var r = 6377000;
		return meter/r*180/Math.PI;
	}
	/** 
	* Converts decimaldegrees to meters.
	* @param angle:Number Degrees.
	* @return Number Meters.
	*/
	public function degrees2Meters(angle:Number):Number {
		var r = 6377000;
		return r*rad(angle);
	}
	/**
	* Moves or zooms the map to a given scale. With or without animation.
	* @param scale:Number Mapscale. (mapunits per pixel)
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToScale(scale:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		if (scale == undefined) {
			return;
		}
		var x;
		var y;
		if (coord == undefined) {
			x = (this._currentextent.maxx+this._currentextent.minx)/2;
			y = (this._currentextent.maxy+this._currentextent.miny)/2;
		} else {
			x = coord.x;
			y = coord.y;
		}
		var ratio = 1;
		if (mapunits == "DECIMALDEGREES") {
			if (this.conformal) {
				var rx = this.getDistance({x:x-0.5, y:y}, {x:x+0.5, y:y});
				var ry = this.getDistance({x:x, y:y-0.5}, {x:x, y:y+0.5});
				ratio = rx/ry;
			}
			scale = this.meters2Degrees(scale*ratio)/Math.cos(rad(y));
		}
		var ext:Object = new Object();
		var nw = this.__width*scale/ratio;
		var nh = this.__height*scale;
		ext.minx = x-nw/2;
		ext.miny = y-nh/2;
		ext.maxx = ext.minx+nw;
		ext.maxy = ext.miny+nh;

		this.moveToExtent(ext, updatedelay, movetime);
	}
	/**
	* Moves or zooms the map to a given scalehint. With or without animation.
	* @param scale:Number Scalehint. 
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToScaleHint(scalehint:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		if (mapunits == "DECIMALDEGREES") {
			scalehint = this.meters2Degrees(scalehint);
		}
		var x;
		var y;
		if (coord == undefined) {
			x = (this._currentextent.maxx+this._currentextent.minx)/2;
			y = (this._currentextent.maxy+this._currentextent.miny)/2;
		} else {
			x = coord.x;
			y = coord.y;
		}
		var ratio = 1;
		if (this.conformal) {
			var rx = this.getDistance({x:x-0.5, y:y}, {x:x+0.5, y:y});
			var ry = this.getDistance({x:x, y:y-0.5}, {x:x, y:y+0.5});
			ratio = rx/ry;
		}
		//var xs = (this._mapextent.maxx-this._mapextent.minx)/this.__width;                                                             
		//var ys = (this._mapextent.maxy-this._mapextent.miny)/this.__height;
		//trace(xs/ys + "=" + this.__width/this.__height)
		var angle = Math.atan(ratio);
		var nh = Math.sin(angle)*scalehint*this.__height;
		var nw = Math.cos(angle)*scalehint*this.__width;
		var ext:Object = new Object();
		ext.minx = x-nw/2;
		ext.miny = y-nh/2;
		ext.maxx = ext.minx+nw;
		ext.maxy = ext.miny+nh;
		this.moveToExtent(ext, updatedelay, movetime);
	}
	/**
	* Moves or zooms the map to a given percentage. With or without animation.
	* @param percentage:Number [optional] Percentage, 100 means 100% of the current mapextent, Number smaller than 100 means zooming out. Number greater than 100 means zooming in.
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToPercentage(percentage:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		if (percentage == undefined) {
			return;
		}
		var x, y;
		if (coord == undefined) {
			x = (this._currentextent.maxx+this._currentextent.minx)/2;
			y = (this._currentextent.maxy+this._currentextent.miny)/2;
		} else {
			x = coord.x;
			y = coord.y;
		}
		

		if(zoomScaleFactor!=undefined){
			var curScale:Number = (this._currentextent.maxx-this._currentextent.minx)/this.__width;
			var newScale:Number = curScale;
			if(percentage>100){
				newScale=curScale/zoomScaleFactor;	
			} 
			if(percentage<100){
				newScale=curScale*zoomScaleFactor;
			}	
			var intExtent:Object = copyExtent(_initialextent);
			correctExtent(intExtent);
			var initialScale:Number = ((intExtent.maxx-intExtent.minx)/this.__width);
			if(newScale<initialScale){
				moveToScale(newScale,coord,updatedelay,movetime);
				return;
			}
		}else if (this.resolutions!=undefined){
			var currentResolutionIndex=0;
			var curScale:Number = (this._currentextent.maxx-this._currentextent.minx)/this.__width;
			//while the curScale is smaller then the resolutions in the list.
			while (this.resolutions[currentResolutionIndex] > curScale+0.00000000001){
				currentResolutionIndex++;
			}
			var newScale=curScale;
			if(percentage>100){
				newScale=this.resolutions[currentResolutionIndex+1];
			} 
			if(percentage<100){
				newScale=this.resolutions[currentResolutionIndex-1];
			}	
			var intExtent:Object = copyExtent(_initialextent);
			correctExtent(intExtent);
			var initialScale:Number = ((intExtent.maxx-intExtent.minx)/this.__width);
			//if(newScale<initialScale){
				moveToScale(newScale,coord,updatedelay,movetime);
				return;
			//}
		}
		
		//var ratio = 1
		//if (this.conformal) {
		//var rx = this.getDistance({x:x-0.5, y:y}, {x:x+0.5, y:y});
		//var ry = this.getDistance({x:x, y:y-0.5}, {x:x, y:y+0.5});
		//var ratio = rx/ry;
		//}
		
		var ext:Object = new Object();
		
		var nw = (this._currentextent.maxx-this._currentextent.minx)/percentage*100;
		var nh = (this._currentextent.maxy-this._currentextent.miny)/percentage*100;
		ext.minx = x-nw/2;
		ext.miny = y-nh/2;
		ext.maxx = ext.minx+nw;
		ext.maxy = ext.miny+nh;

		this.moveToExtent(ext, updatedelay, movetime);
	}
	/**
	* Moves or zooms the map to a given coordinate. With or without animation.
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param percentage:Number [optional] Percentage, 100 means 100% of the current mapextent, Number smaller than 100 means zooming out. Number greater than 100 means zooming in.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToCoordinate(coord:Object, updatedelay:Number, movetime:Number):Void {
		if (coord == undefined) {
			return;
		}
		var ext:Object = new Object();
		var nw = this._currentextent.maxx-this._currentextent.minx;
		var nh = this._currentextent.maxy-this._currentextent.miny;
		var x = coord.x;
		var y = coord.y;
		ext.minx = x-nw/2;
		ext.miny = y-nh/2;
		ext.maxx = ext.minx+nw;
		ext.maxy = ext.miny+nh;

		this.moveToExtent(ext, updatedelay, movetime);
	}
	
	/**
	* returns the map's nextextents which is filled by 'moveToPrevExtent'
	* The map's 'extenthistory' must be greater than 0.
	* @return Array nextextents.
	*/
	public function getNextExtents():Array{
		return this.nextextents;
	}
	/**
	* Moves the map to the next extent. The array with next extents is filled by 'moveToPrevExtent'
	* The map's 'extenthistory' must be greater than 0.
	* @param  movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToNextExtent(movetime:Number):Void {
		if (this.nextextents.length<=0) {
			return;
		}
		var ext = this.nextextents.pop();
		this.prevextents.push(this.copyExtent(this._updatedextent));
		this.rememberextent = false;
		this.moveToExtent(ext, 0, movetime);
	}
	/**
	* returns the map's prevextents
	* The map's 'extenthistory' must be greater than 0.
	* @return Array prevtextents.
	*/
	public function getPrevExtents():Array{
		return this.prevextents;
	}
	/**
	* Moves the map to the previous extent. 
	* The map's 'extenthistory' must be greater than 0.
	* @param  movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	public function moveToPrevExtent(movetime:Number):Void {
		if (this.prevextents.length<=0) {
			return;
		}
		this.nextextents.push(this.copyExtent(this._updatedextent));
		var ext = this.prevextents.pop();
		this.rememberextent = false;
		this.moveToExtent(ext, 0, movetime);
	}
	/**
	* Sets the extent of the map with or without move-animation. 
	* @param extent:Object Extent. An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	* @param isNotCorrectedExtent:Boolean [optional] (Default:true). This indicates if the given extent is already CORRECTED with the aspect ratio of the screen.
	* @param finishedChanging:Boolean [optional] (Default:true). This indicates if this function is called when the changing of the extent is finished (true) 
	*	or if it's busy changing the extent and this is not the final exent (false)
	*/
	public function moveToExtent(extent:Object, updatedelay:Number, movetime:Number, isNotCorrectedExtent:Boolean, finishedChanging:Boolean):Void {
		if (!this.isValidExtent(extent)) {
			return;
		}
		if (isNotCorrectedExtent==undefined){
			isNotCorrectedExtent=true;
		}
		if (finishedChanging==undefined){
			finishedChanging=true;
		}	
		this.clearDrawings();
		flamingo.raiseEvent(this, "onMaptipCancel", this);
		// remember the original uncorrected extent
		// correct the extent and set as mapextent  
		if (!this.isEqualExtent(this._extent, extent)) {
			if(isNotCorrectedExtent){				
				this._extent = this.copyExtent(extent);
			}
			this._mapextent = this.copyExtent(extent);
			this.correctExtent(this._mapextent);
			if(zoomScaleFactor!=undefined || this.resolutions!=undefined){
				//Zooming in steps, get the nearest zoomstep extent
				this._mapextent = getNearestExtent(this._mapextent);
			}
			
			var eventType:Number = null;
			if ((updatedelay == null) || (updatedelay == -1)) {
			    eventType = 1;
			} else {
			    eventType = 3;
			}
			if (finishedChanging)
				flamingo.raiseEvent(this, "onReallyChangedExtent", this, this.copyExtent(extent), eventType);
		}
		//trace("----"+flamingo.getId(this));
		//trace(this.__width+";"+this.__height);
		//trace(this.extent2String(this._mapextent));
		//trace("scalehint:"+this.getScaleHint(this._mapextent));
		//trace("scalehint2:"+this.getScaleHint2(this._mapextent));
		//trace("scale:"+this.getScale(this._mapextent));
		//trace("scale2:"+this.getScale2(this._mapextent));
		// stop previous animation                                        
		clearInterval(this.moveid);
		// start new animtion 
		if (movetime == undefined) {
			movetime = this.movetime;
		}
		if (movetime<=0 || !this.hasextent) {
			this.hasextent = true;
			this._currentextent = this.copyExtent(this._mapextent);
			flamingo.raiseEvent(this, "onStartMove", this);
			this.moving = true;
			this.container._quality = "LOW";
			flamingo.raiseEvent(this, "onChangeExtent", this);
			this.container._quality = "BEST";
			this.moving = false;
			flamingo.raiseEvent(this, "onStopMove", this);
		} else {
			var obj:Object = new Object();
			obj.startextent = this.copyExtent(this._currentextent);
			obj.step = 0;
			obj.nrsteps = Math.abs(this.movesteps);
			var t;
			if (this.movesteps<=0) {
				t = movetime;
			} else {
				t = Math.round(movetime/this.movesteps);
			}
			flamingo.raiseEvent(this, "onStartMove", this);
			this.moving = true;
			this.startupdatetime = new Date();
			this.container._quality = this.movequality;
			this.moveid = setInterval(this, "_move", t, obj);
		}
		this.hasextent = true;
		//now the map is zoomed, panned or whatever,
		//last step is update the layers which have to be updated
		if (updatedelay == undefined) {
			return;
		}
		if (updatedelay<0) {
			return;
		}
		this.update(updatedelay);
	}
	
	private function getNearestExtent(extent:Object):Object {	
		if (minscale==undefined){
			return extent;
		}
		//calculate the scale with the zoomScaleFactor (pre defined scales)
		var curScale:Number = (extent.maxx-extent.minx)/this.__width;
		var calcScale:Number = minscale;
		//do while the calcScale is smaller then or les smaller then a small number (fix for double inaccuracy)
		if (zoomScaleFactor!=undefined){
			while(curScale > calcScale+0.00000000001){
				calcScale = calcScale * zoomScaleFactor;
			}
		}else if (this.resolutions!=undefined){
			var counter:Number=this.resolutions.length-1;
			while(curScale > calcScale+0.00000000001){
				if (counter < 0){
					break;
				}
				calcScale = this.resolutions[counter];
				counter--;
			} 
		}
		
		var intExtent:Object = copyExtent(_initialextent);
		correctExtent(intExtent);
		var initialScale:Number = (intExtent.maxx-intExtent.minx)/this.__width;//Math.max(((_initialextent.maxx-_initialextent.minx)/this.__width)/pixelSize,((_initialextent.maxy-_initialextent.miny)/this.__width)/pixelSize);
		if(calcScale>initialScale && !initExtentToScale){
			return extent;
		}
		var nw = this.__width*calcScale;
		var nh = this.__height*calcScale;
		var x =  extent.minx + ((extent.maxx - extent.minx)/2);
		var y =  extent.miny + ((extent.maxy - extent.miny)/2) 
		extent.minx = x-nw/2;
		extent.miny = y-nh/2;
		extent.maxx = extent.minx+nw;
		extent.maxy = extent.miny+nh;
		
		return extent;
		
	}
	
	//
	private function _move(obj:Object) {
		if (obj.step>=obj.nrsteps) {
			this._currentextent = this.copyExtent(this._mapextent);
			clearInterval(this.moveid);
			//_quality = "LOW";
			flamingo.raiseEvent(this, "onChangeExtent", this);
			this.moving = false;
			flamingo.raiseEvent(this, "onStopMove", this);
			this.container._quality = "BEST";
		} else {
			var p:Number = Math.sin((90/obj.nrsteps*obj.step)*Math.PI/180);
			var ext:Object = new Object();
			ext.minx = obj.startextent.minx+((this._mapextent.minx-obj.startextent.minx)*p);
			ext.miny = obj.startextent.miny+((this._mapextent.miny-obj.startextent.miny)*p);
			ext.maxx = obj.startextent.maxx+((this._mapextent.maxx-obj.startextent.maxx)*p);
			ext.maxy = obj.startextent.maxy+((this._mapextent.maxy-obj.startextent.maxy)*p);
			this._currentextent = ext;
			//_quality = "LOW";
			flamingo.raiseEvent(this, "onChangeExtent", this);
			//_quality = "BEST";
		}
		updateAfterEvent();
		obj.step++;
	}
	
	private function autoRefresh():Void {
		if (!this.updating) {
			refresh();
		}
	}
	
	public function refresh():Void {
		this.update(0, true);
	}
	/**
	* Updates the map. 
	* This will fire the onUpdate event.
	* @param delay:Number [optional] if omitted the onUpdate event will raise immediatelly, otherwhise after the delay time (milliseconds)
	*/
	public function update(delay:Number, forceupdate:Boolean):Void {
		var thisObj:Map = this;
		if (this.holdonupdate&& this.updating) {
			return;
		}
		clearInterval(this.updateid);
		if (delay>0) {
			this.updateid = setInterval(this, "_update", Number(delay), forceupdate);
			flamingo.raiseEvent(thisObj, "onWaitForUpdate", this, delay);
		} else {
			this._update(forceupdate);
		}
	}
	private function _update(forceupdate:Boolean) {
		// stop previous update call
		clearInterval(this.updateid);
		if (forceupdate == undefined) {
			forceupdate = false;
		}
		if (this.isEqualExtent(this._updatedextent, this._mapextent)) {
			if (!forceupdate) {
				this.rememberextent = true;
				return false;
			}
		} else {
			if (this.rememberextent && this.nrprevextents>0) {
				this.prevextents.push(this.copyExtent(this._updatedextent));
				this.nextextents = new Array();
				if (this.prevextents.length>this.nrprevextents) {
					this.prevextents.splice(0, 1);
				}
			}
		}
		// remember the  extent for previuos extent
		this._updatedextent = this.copyExtent(this._mapextent);
		this.rememberextent = true;
		// no delay, so fire event
		flamingo.raiseEvent(this, "onUpdate", this);
		if (this.saveextent && this.hasextent) {
			flamingo.setCookie(flamingo.getId(this)+".mapextent", this._extent);
		}
		//check if any layer is updating, if so don't bother because the layerlistener takes care for raising               
		// a onUpdateComplete-event, if not > raise onUpdateCompleteEvent
		this.checkUpdate();
	}
	/**
	* Cancels an update.
	*/
	public function cancelUpdate():Void {
		clearInterval(this.updateid);
	}
	//
	/**
	* Calculates the distance between two coordinates.
	* @param coord1:Object First coordinate. Coordinate is an object with 2 properties: 'x' and 'y'. (x = longitude and y = latitude).
	* @param coord2:Object Second coordinate. Coordinate is an object with 2 properties: 'x' and 'y'.  (x = longitude and y = latitude).
	* @return Number Distance (in mapunits)
	*/
	public function getDistance(coord1:Object, coord2:Object):Number {
		if (mapunits == "DECIMALDEGREES") {
			return getDistanceDegree(coord1, coord2);
		} else {
			return getDistanceLinear(coord1, coord2);
		}
	}
	/**
	* Calculates the linear distance between two coordinates.
	* @param coord1:Object First coordinate. Coordinate is an object with 2 properties: 'x' and 'y'. (x = longitude and y = latitude).
	* @param coord2:Object Second coordinate. Coordinate is an object with 2 properties: 'x' and 'y'.  (x = longitude and y = latitude).
	* @return Number Distance. (in whatever the mapunits of the mapserver are)
	*/
	public function getDistanceLinear(coord1:Object, coord2:Object):Number {
		var distance:Number = Math.sqrt((Math.pow((coord1.x-coord2.x), 2)+Math.pow((coord1.y-coord2.y), 2)));
		return (distance);
	}
	/**
	* Calculates the "great circle distance" between two coordinates.
	* @param coord1:Object First coordinate. Coordinate is an object with 2 properties: 'x' and 'y'. (x = longitude and y = latitude).
	* @param coord2:Object Second coordinate. Coordinate is an object with 2 properties: 'x' and 'y'.  (x = longitude and y = latitude).
	* @return Number Distance (in meters)
	*/
	public function getDistanceDegree(coord1:Object, coord2:Object):Number {
		//uses formula of great circle Distance
		//var radius_earth = 6377000;
		//var radius_earth = 6372795;
		var radius_earth = 6378137;
		var x1 = coord1.x;
		var y1 = coord1.y;
		var x2 = coord2.x;
		var y2 = coord2.y;
		var dy = rad(y2-y1);
		var dx = rad(x2-x1);
		x1 = rad(x1);
		x2 = rad(x2);
		y1 = rad(y1);
		y2 = rad(y2);
		//var gc = radius_earth*Math.acos(Math.sin(y2)*Math.sin(y1)+Math.cos(y2)*Math.cos(y1)*Math.cos(dx));
		var gc = radius_earth*2*Math.asin(Math.min(1, Math.sqrt(Math.pow(Math.sin(dy/2), 2)+Math.cos(y1)*Math.cos(y2)*Math.pow(Math.sin(dx/2), 2))));
		return (gc);
	}
	private function rad(degrees:Number):Number {
		return (degrees*Math.PI/180);
	}
	/**
	* Calculates an extent(=map dimensions) to a rect(=screen dimensions).
	    * An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'.
	* A rect has 4 properties: 'x', 'y', 'width' and 'height'.
	* @param extent:Object The extent which has to be transformed to a rect.
	* @param extent2:Object [optional] Reference extent. By default the calculations will using the currentextent.
	* @return Object Rect, an object with 4 properties: x, y, width and height  
	*/
	public function extent2Rect(extent:Object, extent2:Object):Object {
		//calculates an extent to a rect using the currentextent
		//a rect contains screen coordinates and the properties:x,y,width and height
		//an extent contains mapcoordiates and the properties:minx,maxx, miny, maxy
		if (extent2 == undefined) {
			extent2 = this._currentextent;
		}
		var msx = (extent2.maxx-extent2.minx)/this.__width;
		var msy = (extent2.maxy-extent2.miny)/this.__height;
		var r:Object = new Object();
		r.x = (extent.minx-extent2.minx)/msx;
		r.y = (extent2.maxy-extent.maxy)/msy;
		r.width = (extent.maxx-extent.minx)/msx;
		r.height = (extent.maxy-extent.miny)/msy;
		return (r);
	}
	/**
	* Calculates a rect(=screen dimensions) to an extent(=map dimensions).
	* An extent has 4 properties 'minx', 'miny', 'miny', 'maxy' and optional 'name'.
	* A rect has 4 properties: 'x', 'y', 'width' and 'height'.
	* @param rect:Object the rect which has to be calculated to an extent.
	* @param extent:Object [optional] Reference extent. By default the calculations will using the currentextent.
	* @return Object Extent, an object with 4 properties: minx, miny, maxx and maxy  
	*/
	public function rect2Extent(rect:Object, extent:Object):Object {
		//calculates a rect to an extent using the current mapextent
		//a rect contains screen coordinates and the properties:x,y,width and height
		//an extent contains mapcoordiates and the properties:minx,maxx, miny, maxy
		if (extent == undefined) {
			extent = this._currentextent;
		}
		
		if (rect.width < 0) {
			rect.width = -rect.width
			rect.x = rect.x - rect.width
		}
		if (rect.height < 0) {
			rect.height= -rect.height
			rect.y = rect.y - rect.height
		}
		var e = new Object();
		var msx = (extent.maxx-extent.minx)/this.__width;
		var msy = (extent.maxy-extent.miny)/this.__height;
		e.minx = extent.minx+(rect.x*msx);
		e.maxy = extent.maxy-(rect.y*msy);
		e.maxx = e.minx+(rect.width*msx);
		e.miny = e.maxy-(rect.height*msy);
		return (e);
	}
	/**
	* Calculates a point(=screen dimensions) to a coordinate(=map dimensions).
	* Both point and coordinate are objects with 2 properties: 'x' and 'y'.
	* @param point:Object the point which has to be calculated to a coordinate.
	* @param extent:Object [optional] Reference extent. By default the calculations will useing the currentextent.
	* @return Object Coordinate.  
	*/
	public function point2Coordinate(point:Object, extent:Object):Object {
		//calculates a pointto a coordinate using the current mapextent
		//a coordinate contains mapcoordinates
		//a point contains screen coordinates
		//both objects have the same properties:x and y
		if (extent == undefined) {
			extent = this._currentextent;
		}
		var c:Object = new Object();
		var msx = (extent.maxx-extent.minx)/this.__width;
		var msy = (extent.maxy-extent.miny)/this.__height;
		c.x = extent.minx+(point.x*msx);
		c.y = extent.maxy-(point.y*msy);
		return (c);
	}
	/**
	* Calculates a coordinate(=map dimensions) to a point(=screen dimensions).
	* Both point and coordinate are objects with 2 properties: 'x' and 'y'.
	* @param coordinate:Object the coordinate which has to be calculated to a point.
	* @param extent:Object [optional] Reference extent. By default the calculations will using the currentextent.
	* @return Object Point.  
	*/
	public function coordinate2Point(coordinate:Object, extent:Object):Object {
		//calculates a coordinate to a point using the current mapextent
		//a coordinate contains mapcoordinates
		//a point contains screen coordinates
		//both objects have the same properties:x and y
		if (extent == undefined) {
			extent = this._currentextent;
		}
		var p:Object = new Object();
		var msx = (extent.maxx-extent.minx)/this.__width;
		var msy = (extent.maxy-extent.miny)/this.__height;
		p.x = (coordinate.x-extent.minx)/msx;
		p.y = (extent.maxy-coordinate.y)/msy;
		return (p);
	}
	/**
	* Determines if a map is busy executing an update.
	* @return Boolean True or false.
	*/
	public function isUpdating():Boolean {
		if (this.updating) {
			return (true);
		} else {
			return (false);
		}
	}
	/**
	* Determines if a map is busy executing an identify.
	* @return Boolean True or false. 
	*/
	public function isIdentifying():Boolean {
		if (this.identifying) {
			return (false);
		} else {
			return (true);
		}
	}
	/** 
	* Converts an extent to a comma seperated string.
	* Name properties will be ignored.
	* @param extent:Object the extent which has to be converted
	* @return String  String representation of an extent.
	*/
	public function extent2String(extent:Object):String {
		return (extent.minx+","+extent.miny+","+extent.maxx+","+extent.maxy);
	}
	/** 
	* Converts comma seperated string to an extent object.
	* The string has the format:minx,miny,maxx,maxy,{name}
	* @param str:String The string which has to be converted.
	* @return Object Extent object.
	*/
	public function string2Extent(str:String):Object {
		var extent:Object = new Object();
		var a:Array = str.split(",");
		extent.minx = Number(a[0]);
		extent.maxx = Number(a[2]);
		extent.miny = Number(a[1]);
		extent.maxy = Number(a[3]);
		if (a[4] != undefined) {
			extent.name = a[4];
		}
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
	/**  
	* Checks if two extents are the same.
	* @param extent:Object Extent 1.
	* @param extent2:Object Extent 2.
	* @return Boolean True or false.
	*/
	public function isEqualExtent(extent:Object, extent2:Object):Boolean {
		if (extent2 == undefined) {
			extent2 = this._mapextent;
		}
		if (extent.minx != extent2.minx) {
			return false;
		}
		if (extent.miny != extent2.miny) {
			return false;
		}
		if (extent.maxx != extent2.maxx) {
			return false;
		}
		if (extent.maxy != extent2.maxy) {
			return false;
		}
		return true;
	}
	/** 
	* Checks if an extent is valid.
	* @param extent:Object Extent. 
	* @return Boolean True or false.
	*/
	public function isValidExtent(extent:Object):Boolean {
		if (isNaN(extent.minx)) {
			return false;
		}
		if (isNaN(extent.miny)) {
			return false;
		}
		if (isNaN(extent.maxy)) {
			return false;
		}
		if (isNaN(extent.maxx)) {
			return false;
		}
		return true;
	}
	/** 
	* Checks if an extent is hit by another extent.
	* @param extent:Object Extent 1.
	* @param extent2:Object [optional] By default hit is calculated with the mapextent.
	* @return Boolean True or false.
	*/
	public function isHit(extent:Object, extent2:Object):Boolean {
		if (extent2 == undefined) {
			extent2 = this._mapextent;
		}
		if (extent.maxx<extent2.minx) {
			return false;
		}
		if (extent.minx>extent2.maxx) {
			return false;
		}
		if (extent.maxy<extent2.miny) {
			return false;
		}
		if (extent.miny>extent2.maxy) {
			return false;
		}
		return true;
	}
	public function copyExtent(obj:Object):Object {
		if (obj == undefined)
			return undefined;
		var extent = new Object();
		for (var attr in obj) {
			extent[attr] = obj[attr];
		}
		extent.minx = Number(extent.minx);
		extent.miny = Number(extent.miny);
		extent.maxx = Number(extent.maxx);
		extent.maxy = Number(extent.maxy);
		return extent;
	}
	private function correctAspectRatio(extent:Object) {
		//This method modifies the extent without making a copy!
		var w:Number = extent.maxx-extent.minx;
		var h:Number = extent.maxy-extent.miny;
		//
		var correction = 1;
		if (this.conformal) {
			var mx = (extent.maxx+extent.minx)/2;
			var my = (extent.maxy+extent.miny)/2;
			var rx = this.getDistance({x:mx-0.5, y:my}, {x:mx+0.5, y:my});
			var ry = this.getDistance({x:mx, y:my-0.5}, {x:mx, y:my+0.5});
			correction = ry/rx;
		}
		var ratio = __width/__height*correction;
		if (ratio<(w/h)) {
			// width is ok, calculate new height
			//var nh:Number = w*this.__height/this.__width*c;
			var nh:Number = w/ratio;
			extent.miny = extent.miny-((nh-h)/2);
			extent.maxy = extent.miny+nh;
		} else {
			//height is ok, calculate new width
			//var nw:Number = h*this.__width/this.__height*c;
			var nw:Number = h*ratio;
			extent.minx = extent.minx-((nw-w)/2);
			extent.maxx = extent.minx+nw;
		}
	}
	public function correctExtent(extent:Object) {
		//This method modifies the extent without making a copy!
		//check 1. does the extent has the same aspectratio as the mapcomponent     
		//correctAspectRatio(extent);
		var w:Number = Number(extent.maxx)-Number(extent.minx);
		var h:Number = Number(extent.maxy)-Number(extent.miny);
		//check 2. does the extent exceeds the fullextent, if so , correct it
		if (this._fullextent != undefined) {
			//var full = this._fullextent.copy();
			//full.correctAspectRatio(this.__width, this.__height)
			//var wfull = full.getWidth();
			//var hfull = full.getHeight();
			//check boundaries
			if (extent.minx<this._fullextent.minx) {
				extent.minx = this._fullextent.minx;
				extent.maxx = extent.minx+w;
				if (extent.maxx>this._fullextent.maxx) {
					extent.maxx = this._fullextent.maxx;
				}
			}
			if (extent.maxx>this._fullextent.maxx) {
				extent.maxx = this._fullextent.maxx;
				extent.minx = extent.maxx-w;
				if (extent.minx<this._fullextent.minx) {
					extent.minx = this._fullextent.minx;
				}
			}
			if (extent.miny<this._fullextent.miny) {
				extent.miny = this._fullextent.miny;
				extent.maxy = extent.miny+h;
				if (extent.maxy>this._fullextent.maxy) {
					extent.maxy = this._fullextent.maxy;
				}
			}
			if (extent.maxy>this._fullextent.maxy) {
				extent.maxy = this._fullextent.maxy;
				extent.miny = extent.maxy-h;
				if (extent.miny<this._fullextent.miny) {
					extent.miny = this._fullextent.miny;
				}
			}
			correctAspectRatio(extent);
		} else {
			correctAspectRatio(extent);
		}
		w = extent.maxx-extent.minx;
		h = extent.maxy-extent.miny;
		//check 3. Does the extent exceeds the minscale or maxscale, if so, correct it                                                                                                                                          
		if (this.minscale != undefined) {
			var s = this.getScale(extent);
			var ratio = 1;
			if (s<this.minscale) {
				var scale = this.minscale;
				var x = (extent.maxx+extent.minx)/2;
				var y = (extent.maxy+extent.miny)/2;
				if (mapunits == "DECIMALDEGREES") {
					if (this.conformal) {
						var rx = this.getDistance({x:x-0.5, y:y}, {x:x+0.5, y:y});
						var ry = this.getDistance({x:x, y:y-0.5}, {x:x, y:y+0.5});
						ratio = rx/ry;
					}
					scale = this.meters2Degrees(scale*ratio)/Math.cos(rad(y));
				}
				var nw = this.__width*scale/ratio;
				var nh = this.__height*scale/ratio;
				extent.minx = x-nw/2;
				extent.miny = y-nh/2;
				extent.maxx = extent.minx+nw;
				extent.maxy = extent.miny+nh;
			}
		}
		if (this.maxscale != undefined) {
			var s = this.getScale(extent);
			var ratio = 1;
			//var s:Number = w/this.__width;
			if (s>this.maxscale) {
				var scale = this.maxscale;
				var x = (extent.maxx+extent.minx)/2;
				var y = (extent.maxy+extent.miny)/2;
				if (mapunits == "DECIMALDEGREES") {
					if (this.conformal) {
						var rx = this.getDistance({x:x-0.5, y:y}, {x:x+0.5, y:y});
						var ry = this.getDistance({x:x, y:y-0.5}, {x:x, y:y+0.5});
						ratio = rx/ry;
					}
					scale = this.meters2Degrees(scale*ratio)/Math.cos(rad(y));
				}
				var nw = this.__width*scale/ratio;
				var nh = this.__height*scale/ratio;
				extent.minx = x-nw/2;
				extent.miny = y-nh/2;
				extent.maxx = extent.minx+nw;
				extent.maxy = extent.miny+nh;
			}
		}
	}
	/** 
	 * Sets a custom cursor.
	 * @param cursor:Object cursorobject
	 */
	public function setCursor(cursor:Object):Void {
		this.cursor = cursor;
		if (this.hit) {
			flamingo.showCursor(this.cursor);
		}
	}
	/** 
	 * Gets the custom cursorid.
	 * @return String Custom cursorid.
	 */
	public function getCursor():Object {
		return this.cursor;
	}
	/** Sets the time of the animated moving between two extents. 
	 * @param value:Number The time in milliseconds (1000 = 1 second).
	 */
	public function setMoveTime(value:Number):Void {
		this.movetime = value;
	}
	/** 
	 * Gets the movetime.
	 * @return Number Movetime.
	 */
	public function getMoveTime():Number {
		return (this.movetime);
	}
	/** 
	 * Sets the number of steps of the moving animation.
	 * More steps means a smoother animation but more computer stress!
	 * @param value:Number  Number of steps.
	 */
	public function setMoveSteps(value:Number) {
		this.movesteps = value;
	}
	/** 
	 * Gets the number of movesteps.
	 * @return Number Number of movesteps.
	 */
	public function getMoveSteps():Number {
		return (this.movesteps);
	}
	/** 
	 * Sets the number of steps by which layers will fadein.
	 * @param value:Number Number of fadesteps.
	 */
	public function setFadeSteps(value:Number) {
		this.fadesteps = value;
	}
	/**
	 * Gets the number of steps by which layers will fadein.
	 * @return Number Number of fadesteps.
	 */
	public function getFadeSteps():Number {
		return (this.fadesteps);
	}
	/**
	 * Sets the minimum scale of a map. The map cannot zoom further in.
	 * @param value:Number Minscale, a number of mapunits by pixels
	 */
	public function setMinScale(value:Number) {
		this.minscale = value;
	}
	/** 
	 * Gets the minimum scale.
	 * @return Number Minscale.
	 */
	public function getMinScale():Number {
		return (this.minscale);
	}
	/** 
	 * Sets the maximum scale of a map. The map cannot zoom further out.
	 * @param value:Number Maxscale, a number of mapunits by pixels.
	 */
	public function setMaxScale(value:Number) {
		this.maxscale = value;
	}
	/** Gets the maximum scale.
	 * @return Number Maxscale.
	 */
	public function getMaxScale():Number {
		var s;
		if (this._fullextent != undefined) {
			s = this.getScale(this._cfullextent);
			if (this.maxscale != undefined) {
				s = Math.min(this.maxscale, s);
			}
		} else {
			s = this.maxscale;
		}
		return s;
	}
	/** 
	 * If set to true a map can only identify when the previous identify is completed.
	 * @param value:Boolean  True or false.
	 */
	public function setHoldOnIdentify(value:Boolean) {
		this.holdonidentify = value;
	}
	/**
	 * Gets the holdonidentify setting.
	 * @return Boolean True or false.
	 */
	public function getHoldOnIdentify():Boolean {
		return (this.holdonidentify);
	}
	/** 
	 * If set to true a map can only update when the previous update is completed.
	 * @param value:Boolean  True or false.
	 */
	public function setHoldOnUpdate(value:Boolean) {
		this.holdonupdate = value;
	}
	/** 
	 * Gets the holdonupdate setting.
	 * @return Boolean True or false.
	 */
	public function getHoldOnUpdate():Boolean {
		return (this.holdonupdate);
	}
	/** 
	 * Sets the total number of previous extents.
	 * @param value:Number Total number of extents that will be stored. 
	 */
	public function setExtentHistory(value:Number) {
		this.nrprevextents = value;
	}
	/** Gets the total number of previous extents.
	 * @return Number Total number of extents that will be stored.
	 */
	public function getExtentHistory():Number {
		return (this.nrprevextents);
	}
	/** Draws a rect on the acetate layer of a map.
	 * The drawing is temporary and will disappear after an update or an extent change.
	 * The position and size of the rect is in screen coordinates.
	 * @param id:String Unique identifier of the drawing.
	 * @param rect:Object Rectangle object. A rect has the folowing attributes: rect.x, rect.y, rect.width and rect.height
	 * @param fillSymbol:Object [optional] Symbol for fillstyle. A fillsymbol has the following attributes: fillSymbol.color and fillSymbol.alpha
	 * @param lineSymbol:Object [optional] Symbol for linestyle. A linesymbol has the following attributes: lineSymbol.color, lineSymbol.alpha and lineSymbol.width
	 */
	public function drawRect(id:String, rect:Object, fillSymbol:Object, lineSymbol:Object):Void {
		var x = rect.x;
		var y = rect.y;
		var width = rect.width;
		var height = rect.height;
		var points:Array = new Array();
		points.push({x:x, y:y});
		points.push({x:x+width, y:y});
		points.push({x:x+width, y:y+height});
		points.push({x:x, y:y+height});
		points.push({x:x, y:y});
		this.draw(id, points, fillSymbol, lineSymbol);
	}
	/** Draws a figure on the acetate layer of a map.
	 * The drawing is temporary and will disappear after an update or an extent change.
	 * The position and size of a figure is in screen coordinates.
	 * @param id:String Unique identifier of the drawing.
	 * @param rect:Object Rectangle object. A rect has the folowing attributes: rect.x, rect.y, rect.width and rect.height
	 * @param fillSymbol:Object Symbol for fillstyle. A fillsymbol has the following attributes: fillSymbol.color and fillSymbol.alpha
	 * @param lineSymbol:Object Symbol for linestyle. A linesymbol has the following attributes: lineSymbol.color, lineSymbol.alpha and lineSymbol.width
	 */
	public function drawCircle(id:String, circle:Object, fillSymbol:Object, lineSymbol:Object) {
		if (id == undefined) {
			return;
		}
		var x = circle.x;
		var y = circle.y;
		var radius = circle.radius;
		if (x == undefined) {
			return;
		}
		if (y == undefined) {
			return;
		}
		if (radius == undefined) {
			return;
		}
		var segments = circle.segments;
		var startangle = circle.startangle;
		var endangle = circle.endangle;
		if (startangle == undefined) {
			startangle = 0;
		}
		if (endangle == undefined) {
			endangle = 360;
		}
		if (segments == undefined) {
			segments = 8;
		}
		var rad = Math.PI/180;
		var segm = (endangle-startangle)/segments;
		var points:Array = new Array();
		points.push({x:x+radius*Math.cos(startangle*rad), y:y+radius*Math.sin(startangle*rad)});
		
		for (var s = startangle+segm; s<=endangle+1; s += segm) {
			var c_x = radius*Math.cos(s*rad);
			var c_y = radius*Math.sin(s*rad);
			var a_x = c_x+radius*Math.tan(segm/2*rad)*Math.cos((s-90)*rad);
			var a_y = c_y+radius*Math.tan(segm/2*rad)*Math.sin((s-90)*rad);
			points.push({x:a_x+x, y:a_y+y, anchorx:c_x+x, anchory:c_y+y});
		}
		this.draw(id, points, fillSymbol, lineSymbol);
	}
	/** Draws a figure on the acetate layer of a map.
	 * The drawing is temporary and will disappear after an update or an extent change.
	 * The position and size of a figure is in screen coordinates.
	 * @param id:String Unique identifier of the drawing.
	 * @param rect:Object Rectangle object. A rect has the folowing attributes: rect.x, rect.y, rect.width and rect.height
	 * @param fillSymbol:Object Symbol for fillstyle. A fillsymbol has the following attributes: fillSymbol.color and fillSymbol.alpha
	 * @param lineSymbol:Object Symbol for linestyle. A linesymbol has the following attributes: lineSymbol.color, lineSymbol.alpha and lineSymbol.width
	 */
	public function draw(id:String, points:Array, fillSymbol:Object, lineSymbol:Object) {
		
		if (id == undefined) {
			return;
		}
		
		if (points == undefined) {
			return;
		}
		if (points.length<=1) {
			return;
		}
		/*if (curve == undefined) {
			curve = false;
		}*/
		if (this.mAcetate == undefined) {
			this.mAcetate = this.container.createEmptyMovieClip("mAcetate", this.container.getNextHighestDepth());
		}
		var figure = this.mAcetate[id];
		if (figure == undefined) {
			figure = this.mAcetate.createEmptyMovieClip(id, this.mAcetate.getNextHighestDepth());
		} else {
			 figure.clear();
		}
		with (figure) {
			if (lineSymbol != undefined) {
				lineStyle(lineSymbol.width, lineSymbol.color, lineSymbol.alpha);
			}
			if (fillSymbol != undefined) {
				beginFill(fillSymbol.color, fillSymbol.alpha);
			}
			
			moveTo(points[0].x, points[0].y);
			for (var i = 1; i<points.length; i++) {
				if (points[i].anchorx != undefined) {
					curveTo(points[i].x, points[i].y, points[i].anchorx, points[i].anchory);
				} else {
					lineTo(points[i].x, points[i].y);
					
				}
			}
			if (fillSymbol != undefined) {
				endFill();
			}
    
		}
	}
	/** Clears drawings.
	 * @param id:String [optional] Unique identifier of a specific drawing. If ommited all drawings are removed.
	 */
	public function clearDrawings(id:String) {
		if (id == undefined) {
			for (var figure in this.mAcetate) {
				this.mAcetate[figure].clear();
			}
		} else {
			this.mAcetate[id].clear();
		}
	}
	
	/**
	* Catches the tooltip from the measuretool and sends it to the flamingo framework.
	* @param tiptext:String Text to be shown.
	* @param delay:Number [optional] Time between hoovering over object and showing tip.
	*/
	
	public function showTooltip(tiptext:String, delay:Number):Void{
		flamingo.showTooltip(tiptext,this,delay);
	}
	
	public function hideTooltip():Void{
		flamingo.hideTooltip();
	}
	/**
	Get the next depth of the layers.
	*/
	public function getNextDepth():Number{
		if (nextDepth==null){
			nextDepth=this.mLayers.getNextHighestDepth();
		}else{
			nextDepth++
		}
		return nextDepth;
	}
	/**
	* Set Marker on the map or updates an existing marker referenced by it's id.
	* @param id marker id. Reference to the marker.
	* @param type marker type: [default, url, or text]. Note: only the default marker type is implemented.
	* @param x [optional] x-coordinate of marker. Default center of current extent.
	* @param y [optional] y-coordinate of marker. Default center of current extent.
	* @param height [optional] height of marker. Note: not implemented.
	* @param htmlText [optional] htmlText if the marker type is text. Note: only the default marker type is implemented.
	*/
	public function setMarker(id:String, type:String, x:Number, y:Number, width:Number, height:Number, htmlText:String):Void {
		if (x == null || y == null) { //place marker in center of the map
			var coordinate:Object = getCenter(this._currentextent);
			x = coordinate.x;
			y = coordinate.y;
		}
		
		if (markers == null){
			markers = new Array();			
		}
		var existingMarker:Boolean = false;
		for (var i:Number=0; i<markers.length; i++) {
			if (markers[i].getId() == id){
				//update the existing marker
				markers[i].setX(x);
				markers[i].setY(y);
				markers[i].setWidth(width);
				markers[i].setHeight(height);					
				markers[i].redraw();
				existingMarker = true;
			}
		}
		if (!existingMarker) {
			//create new marker			
			var mcMarker:Object = this.createMarker(id, type, x, y, width, height, htmlText);			
			markers.push(mcMarker);
		}
		
	}
	/**
	* Remove Marker from the map
	* @param id marker id
	*/
	public function removeMarker(id:String):Void {
		for (var i:Number=0; i<markers.length; i++) {
			if (markers[i].getId() == id){				
				markers[i].removeMovieClip();
				markers.splice(i,1);
			}
		}
	}
	/**
	* Remove All Markers from the map
	*/
	public function removeAllMarkers():Void {
		for (var i:Number=0; i<markers.length; i++) {
			markers[i].removeMovieClip();
		}
		markers = null;
	}
	private function createMarker(id:String,type:String,x:Number,y:Number,width:Number,height:Number,htmlText:String):Object {
		//create new marker			
		var mcMarker:DefaultMarker= new DefaultMarker();
		mcMarker.setId(id);
		mcMarker.setMap(this);
		mcMarker.setX(x);
		mcMarker.setY(y);
		mcMarker.setWidth(width);
		mcMarker.setHeight(height);
		mcMarker.draw();
		
		return mcMarker;
	}
	/*Set a Field of View marker.
	* @param x The x coord of this field of view
	* @param y The y coord of this field of view
	* @param directionAngle The direction where this FOV is in (in degrees)
	* @param fovAngle The angle of the view.
	*/
	public function setFovMarker(x,y,directionAngle,fovAngle){
		markerIDnr++;
		if (this.fovMarker!=null){
			this.fovMarker.removeMovieClip();
		}
		this.fovMarker= new FOVMarker();
		this.fovMarker.setId(""+markerIDnr);
		this.fovMarker.setMap(this);
		this.fovMarker.setX(x);
		this.fovMarker.setY(y);
		this.fovMarker.setDirectionAngle(directionAngle);
		this.fovMarker.setViewAngle(fovAngle);
		this.fovMarker.draw();
		markers.push(fovMarker);
	}
	
	/*give a extent and return as string*/
	public function extentToString(extent):String{
		var str="";
		str+=extent.minx;
		str+=","+extent.miny
		str+=","+extent.maxx;
		str+=","+extent.maxy;
		return str;		
	}
		
	public function persistState (document: XML, node: XMLNode): Void {
			
		// Current theme:
		var themeSelector: Object = getThemeSelector ();
		if (themeSelector && themeSelector.getCurrentTheme () != null) {
			var themeNode: XMLNode = document.createElement ('Theme');
			themeNode.appendChild (document.createTextNode (themeSelector.getCurrentTheme ().getName ()));
			node.appendChild (themeNode);
		}
		
		// Extent:
		var extent: Object = getCurrentExtent ();
		if (extent != null) {
			var extentNode: XMLNode = document.createElement ('Extent');
			extentNode.attributes['minx'] = Math.round (extent.minx);
			extentNode.attributes['miny'] = Math.round (extent.miny);
			extentNode.attributes['maxx'] = Math.round (extent.maxx);
			extentNode.attributes['maxy'] = Math.round (extent.maxy);
			node.appendChild (extentNode);
		}
		
		// Visible layers:
		var layersNode: XMLNode = document.createElement ('LayerVisibility'),
			lyrs: Array = getLayers (),
			mapId: String = _global.flamingo.getId (this);
			
		for (var i: Number = 0; i < lyrs.length; ++ i) {
			var lyrId: String = lyrs[i].substring(mapId.length + 1),
				lyr: Object = _global.flamingo.getComponent (lyrs[i]),
				slyrs: Object = lyr.getLayers (),
				layerNode: XMLNode = document.createElement ('S');
				
			layerNode.attributes['id'] = lyrId;
			layerNode.attributes['visible'] = lyr.getVisible () <= 0 ? "false" : "true";
			
			// Sublayer visibility:
			for (var a: String in slyrs) {
				if (slyrs[a].visible) {
					var subLayerNode: XMLNode = document.createElement ('L');
					subLayerNode.attributes['id'] = a;
					layerNode.appendChild (subLayerNode);					
				}
			}
			
			layersNode.appendChild (layerNode);
		}
		
		node.appendChild (layersNode);
	}
	
	public function restoreState (node: XMLNode): Void {
		
		var extentNode: XMLNode = XMLTools.getChild ("Extent", node),
			themeNode: XMLNode = XMLTools.getChild ("Theme", node),
			layerVisibilityNode: XMLNode = XMLTools.getChild ("LayerVisibility", node);
			
		if (extentNode) {
			var extent: Object = {
				minx: Number (extentNode.attributes["minx"]),
				miny: Number (extentNode.attributes["miny"]),
				maxx: Number (extentNode.attributes["maxx"]),
				maxy: Number (extentNode.attributes["maxy"])
			};
			
			// If no layers have been loaded yet the extent can't be changed and the moveToExtent call has no effect, in that 
			// case the map component will load the extent argument as soon as a layer becomes available.
			moveToExtent (extent);
			_global.flamingo.setArgument (this, "extent", this.extent2String (extent));
		}
		
		if (themeNode) {
			var theme: String = themeNode.firstChild.nodeValue,
				themeSelector: Object = this.getThemeSelector ();
				
			if (themeSelector) {
				_global.flamingo.setArgument (themeSelector, "theme", theme);
			}
		}
		
		if (layerVisibilityNode) {
			for (var i: Number = 0; i < layerVisibilityNode.childNodes.length; ++ i) {
				var node2: XMLNode = layerVisibilityNode.childNodes[i],
					layerId: String = node2.attributes["id"],
					layerVisible: Boolean = node2.attributes["visible"].toLowerCase () == "true",
					visibleSubLayers: Array = [ ];
					
				if (!layerId) {
					continue;
				}
				
				for (var j: Number = 0; j < node2.childNodes.length; ++ j) {
					var subLayerId: String = node2.childNodes[j].attributes["id"];
					if (subLayerId) {
						visibleSubLayers.push (subLayerId);
					}
				}
				
				setLayerVisibility (layerId, layerVisible, visibleSubLayers);
			}
		}
	}
	
	private function setLayerVisibility (layerId: String, layerVisible: Boolean, visibleSubLayers: Array): Void {
		var componentId: String = _global.flamingo.getId (this) + "_" + layerId,
			layerComponent: MovieClip = _global.flamingo.getComponent (componentId),
			listener: Object;
		
		var callback: Function = function (layerComponent2:MovieClip): Void {
			layerComponent2.setVisible (layerVisible);
			layerComponent2.setLayerProperty ("#ALL#", "visible", false);
			for (var i: Number = 0; i < visibleSubLayers.length; ++ i) {
				layerComponent2.setLayerProperty (visibleSubLayers[i], "visible", true);
			}
			layerComponent2.update ();
		};
		
		listener = {
			onGetCapabilities: callback,
			onGetServiceInfo: callback
		};
		
		if (layerComponent && layerComponent.initialized) {
			callback (layerComponent);
		} else {
			_global.flamingo.addListener (listener, componentId, this);
		}
	}
	/**
	 * Getters and setters
	 */
	public function get mBG():MovieClip {
		return _mBG;
	}
	
	public function set mBG(value:MovieClip):Void {
		_mBG = value;
	}
	
	public function get mLayers():MovieClip {
		return _mLayers;
	}
	
	public function set mLayers(value:MovieClip):Void {
		_mLayers = value;
	}
	
	/** 
	 * Dispatched when a map is up and ready to run.
	 * @param map:MovieClip a reference to the map.
	 */
	//public function onInit(map:MovieClip):Void {
	//}
	/** 
	 * Dispatched when a layer is added.
	 * @param map:MovieClip a reference to the map.
	 * @param layer:MovieClip a reference to the layer.
	 */
	//public function onAddLayer(map:MovieClip, layer:MovieClip):Void {
	//}
	/** 
	 * Dispatched when a layer is removed.
	 * @param map:MovieClip a reference to the map.
	 * @param id:String id of layer that has been removed.
	 */
	//public function onRemoveLayer(map:MovieClip, id:String):Void {
	//}
	/** 
	 * Dispatched when a layer is swapped.
	 * @param map:MovieClip a reference to the map.
	 */
	//public function onSwapLayer(map:MovieClip):Void {
	//}
	/**
	* Dispatched when a layer is hidden.
	* @param map:MovieClip a reference to the map.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onHideLayer(map:MovieClip, layer:MovieClip):Void {
	//}
	/**
	* Dispatched when a layer is shown.
	* @param map:MovieClip a reference to the map.
	* @param layer:MovieClip a reference to the layer.
	*/
	//public function onShowLayer(map:MovieClip, layer:MovieClip):Void {
	//}
	/** 
	* Dispatched when a map resizes.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onResize(map:MovieClip):Void {
	//}
	/**
	* Dispatched when the map is shown.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onShow(map:MovieClip):Void {
	//}
	/**
	* Dispatched when the map is hidden.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onHide(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when a map updates.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onUpdate(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when one or more maplayers are ready with their update sequence.
	* @param map:MovieClip a reference to the map.
	* @param layersupdated:Number number of layers already updated.
	* @param updatetotal:Number total number of layers that have to be updated
	*/
	//public function onUpdateProgress(map:MovieClip, layersupdated:Number, updatetotal:Number):Void {
	//}
	/** 
	* Dispatched when an update sequence is completed.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onUpdateComplete(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when an update sequence is about to begin in several seconds...
	* @param map:MovieClip a reference to the map.
	* @param delay:Number Time in milliseconds (1000 = 1 second) to wait for update. 
	*/
	//public function onWaitForUpdate(map:MovieClip,delay:Number):Void {
	//}
	/** 
	* Dispatched when the extent of the map changes.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onChangeExtent(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when the map performs an identify.
	* @param map:MovieClip a reference to the map.
	* @param extent:Object the area of the identify.
	*/
	//public function onIdentify(map:MovieClip, extent:Object):Void {
	//}
	/** 
	* Dispatched when a layer has completed its identify.
	* @param map:MovieClip a reference to the map.
	* @param  layersindentified:Number number of layers already identified.
	* @param  identifytotal:Number total number of layers that have to be identified.
	*/
	//public function onIdentifyProgress(map:MovieClip, layersindentified:Number, identifytotal:Number):Void {
	//}
	/** 
	* Dispatched when a layer has come up with information. When a layer has to identify more layerid's this event will fire each time a layerid has identified.
	* @param map:MovieClip a reference to the map.
	* @param layer:MovieClip a reference to the identified layer
	* @param data:Object data object with the information 
	* @param identifyextent:Object the  extent that is identified 
	* @param nridentified:Number Number of sublayers thas has already been identified.
    * @param total:Number Total number of sublayers that has to be identified.
	*/
	//public function onIdentifyData(map:MovieClip, layer:MovieClip, data:Object, identifyextent:Object, nridentified:Number, total:Number):Void {
	//}
	/** 
	* Dispatched when a map encounters an error.
	* @param map:MovieClip a reference to the map.
	* @param type:String  "identify" or "update"
	* @param error:String an error message.
	* @param layer:MovieClip a reference to the layer which causes the error.
	*/
	//public function onError(map:MovieClip, type:String, error:String, layer:MovieClip):Void {
	//}
	/** 
	* Dispatched when  an identify sequence is completed.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onIdentifyComplete(map:MovieClip):Void {
	//}
	/**
	* Dispatched when the mouse is moved over the map. Fired only once.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onRollOver(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when the mouse is moved of the map. Fired only once.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onRollOut(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when the mouse is moved over the map, when the left mousebutton is pushed. Fired only once.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onDragOver(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when the mouse is moved of the map, when the left mousebutton is pushed. Fired only once.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onDragOut(map:MovieClip):Void {
	//}
	/** 
	* Dispatched when the mouse is moved over the map. This event fires repeatly when the mouse moves.
	* @param map:MovieClip a reference to the map.
	* @param xmouse:Number x-pixel position of the mouse 
	* @param ymouse:Number  y-pixel position of the mouse 
	* @param coord:Object coordinate of the mouse. Object with x and y
	*/
	//public function onMouseMove(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object):Void {
	//}
	/**
	* Dispatched when the mouse is on the map and the user pushes the mousebutton.
	* @param map:MovieClip a reference to the map.
	* @param xmouse:Number x-pixel position of the mouse 
	* @param ymouse:Number  y-pixel position of the mouse 
	* @param coord:Object coordinate of the mouse. Object with x and y
	*/
	//public function onMouseDown(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object):Void {
	//}
	/** 
	* Dispatched when the mouse is on the map and the user pushes the mousebutton.
	* @param map:MovieClip a reference to the map.
	* @param xmouse:Number x-pixel position of the mouse 
	* @param ymouse:Number  y-pixel position of the mouse 
	* @param coord:Object coordinate of the mouse. Object with x and y
	*/
	//public function onMouseUp(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object):Void {
	//}
	/**
	* Dispatched when the mouse is on the map and the user turns the mousewheel.
	* @param map:MovieClip a reference to the map.
	* @param delta:Number number of steps moved.
	*/
	//public function onMouseWheel(map:MovieClip, delta:Number):Void {
	//}
	/** 
	* Dispatched when the mouse hoovers on a spot.
	* The map's property 'mattipdelay' has to be defined.
	* @param map:MovieClip a reference to the map.
	* @param xmouse:Number x-pixel position of the mouse 
	* @param ymouse:Number  y-pixel position of the mouse 
	* @param coord:Object coordinate of the mouse. Object with x and y
	*/
	//public function onMaptip(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object):Void {
	//}
	/** 
	* Dispatched when the mouse hoovers to another spot.
	* @param map:MovieClip a reference to the map.
	*/
	//public function onMaptipCancel(map:MovieClip):Void {
	//}
	
	}//TODO, Check if all the raise events are in the event list