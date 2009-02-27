﻿/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

This file is part of Flamingo MapComponents.

Flamingo MapComponents is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------*/
/** @component LayerOGWMS
* Open Gis WMS layer. (Tested with Demis, Geoserver, Degree, Esri and Mapserver)
* @file OGWMSConnector.as (sourcefile)
* @file LayerOGWMS.fla (sourcefile)
* @file LayerOGWMS.swf (compiled layer, needed for publication on internet)
* @file LayerOGWMS.xml (configurationfile for layer, needed for publication on internet)
*/
var version:String = "2.0";
//---------------------------------
var visible:Boolean;
var query_layers:String;
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
//-------------------------------------
var updating:Boolean = false;
var layers:Object = new Object();
var timeoutid:Number;
var nrcache:Number = 0;
var map:MovieClip;
var caches:Object = new Object();
var thisObj:MovieClip = this;
var extent:Object;
var maptipextent:Object;
var identifyextent:Object;
var aka:Object = new Object();
//-------------------------------------
//listenerobject for map
var lMap:Object = new Object();
lMap.onUpdate = function(map:MovieClip) {
	update();
};
lMap.onChangeExtent = function(map:MovieClip) {
	updateCaches();
};
lMap.onIdentify = function(map:MovieClip, identifyextent:Object):Void  {
	identify(identifyextent);
};
lMap.onIdentifyCancel = function(map:MovieClip):Void  {
	thisObj.cancelIdentify();
};
lMap.onMaptip = function(map:MovieClip, x:Number, y:Number, coord:Object):Void  {
	thisObj.startMaptip(x, y);
};
lMap.onMaptipCancel = function(map:MovieClip):Void  {
	thisObj.stopMaptip();
};
lMap.onHide = function(map:MovieClip):Void  {
	thisObj.update();
};
lMap.onShow = function(map:MovieClip):Void  {
	thisObj.update();
};
flamingo.addListener(lMap, flamingo.getParent(this), this);
//-------------------------------------------------
init();
//-------------------------------------------------
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
* @attr limitedtofullextent  (defaultvalue = "false") True or false.
* @attr timeout  (defaultvalue = "10") Time in seconds when the layer will dispatch an onErrorUpdate event.
* @attr retryonerror (defaultvalue = "0") Number of retrys when encountering an error.
* @attr showerrors  (defaultvalue = "false") True or false. If true errors will be displayed in a standard flamingo error window.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
* @attr fullextent  Extent of layer (comma seperated list of minx,miny,maxx,maxy). When the map is outside this extent, no update will performed.
* @attr alpha (defaultvalue = "100") Transparency of the layer.
*/
/** @tag <layer>  
* This defines a sublayer of an OG-WMS service.
* @hierarchy childnode of <fmc:LayerOGWMS> 
* @attr id  layerid, same as in the getcapabilities listing.
* @attr aka  The layerid of a layer in the getfeatureinfo response.
* @attr maptip Configuration string for a maptip. Fieldnames between square brackets will be replaced  with their actual values. For multi-language support use a standard string tag with id='maptip'.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LayerOGWMS "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	map = flamingo.getParent(this);
	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
	this.setConfig(xml);
	delete xml;
	//custom
	//custom
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}
/**
* Configurates a component by setting a xml.
* @attr xml:Object Xml or string representation of a xml.
*/
function setConfig(xml:Object) {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	//load default attributes, strings, styles and cursors                     
	flamingo.parseXML(this, xml);
	//parse custom attributes
	attributes = new Object();
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "id" :
		case "visible" :
		case "name" :
		case "width" :
		case "height" :
		case "left" :
		case "right" :
		case "top" :
		case "bottom" :
		case "xcenter" :
		case "ycenter" :
		case "listento" :
		case "maxwidth" :
		case "maxheight" :
		case "minwidth" :
		case "minheight" :
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
		case "fullextent" :
			this.fullextent = map.string2Extent(val);
			break;
		case "layers" :
			if (val.toUpperCase() == "#ALL#") {
				val = "#ALL#";
			}
			this.slayers = val;
			setLayerProperty(val, "visible", true);
			break;
		case "styles" :
			styles = val;
			if (styles.length>0) {
				var a_styles = flamingo.asArray(styles);
				var a_layers = flamingo.asArray(slayers);
				if (a_styles.length == a_layers.length) {
					for (var i = 0; i<a_styles.length; i++) {
						this.setLayerProperty(a_layers[i], "style", a_styles[i]);
					}
				}
			}
			break;
		case "maptip_layers" :
			this.canmaptip = true;
			if (val.toUpperCase() == "#ALL#") {
				val = "#ALL#";
			}
			maptip_layers = val;
			setLayerProperty(val, "maptip", true);
			setLayerProperty(val, "queryable", true);
			break;
		case "query_layers" :
			if (val.toUpperCase() == "#ALL#") {
				val = "#ALL#";
			}
			query_layers = val;
			setLayerProperty(val, "identify", true);
			setLayerProperty(val, "queryable", true);
			break;
		case "alpha" :
			this._alpha = Number(val);
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
		case "getcapabilitiesurl" :
			this.getcapabilitiesurl = val;
			break;
		case "getfeatureinfourl" :
			this.getfeatureinfourl = val;
			break;
		case "url" :
			this.url = val;
			break;
		default :
			if (attr.toLowerCase().indexOf("xmlns:", 0) == -1) {
				this.attributes[attr] = val;
			}
			break;
		}
	}
	var xlayers:Array = xml.childNodes;
	if (xlayers.length>0) {
		for (var i:Number = xlayers.length-1; i>=0; i--) {
			if (xlayers[i].nodeName.toLowerCase() == "layer") {
				var id;
				for (var attr in xlayers[i].attributes) {
					if (attr.toLowerCase() == "id") {
						id = xlayers[i].attributes[attr];
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
					flamingo.parseString(xlayers[i], layers[id].language);
					for (var attr in xlayers[i].attributes) {
						var val:String = xlayers[i].attributes[attr];
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
	}
	//get extra information about mapserver and the layers                                                                 
	if (url == undefined and getcapabilitiesurl == undefined) {
		return;
	}
	var lConn = new Object();
	lConn.onError = function(error:String, objecttag:Object) {
		if (thisObj.showerrors) {
			flamingo.showError("LayerOGWMS error", error);
		}
		flamingo.raiseEvent(thisObj, "onError", thisObj, "init", error);
	};
	lConn.onRequest = function(connector:OGWMSConnector) {
		//flamingo.tracer(requestobject.url);
		flamingo.raiseEvent(thisObj, "onRequest", thisObj, "init", connector);
	};
	lConn.onResponse = function(connector:OGWMSConnector) {
		//trace(responseobject.response);
		flamingo.raiseEvent(thisObj, "onResponse", thisObj, "init", connector);
	};
	lConn.onGetCapabilities = function(service, servicelayers, obj, reqid) {
		//flamingo.tracer("getCapap");
		if (name == undefined) {
			name = service.title;
		}
		thisObj._parseLayers(servicelayers);
		flamingo.raiseEvent(thisObj, "onGetCapabilities", thisObj);
		//if (thisObj.slayers == "#ALL#") {
		thisObj.update();
		//}
	};
	var cogwms:OGWMSConnector = new OGWMSConnector();
	cogwms.addListener(lConn);
	var args:Object = new Object();
	args.VERSION = wmsversion;
	for (var attr in this.attributes) {
		args[attr.toUpperCase()] = this.attributes[attr];
	}
	var c_url = this.getcapabilitiesurl;
	if (c_url == undefined) {
		c_url = this.url;
	}
	cogwms.getCapabilities(c_url, args);
}
/**
* Sets the transparency of a layer.
* @param alpha:Number A number between 0 and 100, 0=transparent, 100=opaque
*/
function setAlpha(alpha:Number) {
	this._alpha = alpha;
}
function _parseLayers(tlayers:Object) {
	for (var item in tlayers) {
		if (item == "layers") {
			for (var layerid in tlayers[item]) {
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
				for (var attr in tlayers[item][layerid]) {
					//
					if (thisObj.layers[layerid][attr] == undefined) {
						thisObj.layers[layerid][attr] = tlayers[item][layerid][attr];
					}
					if (attr == "styles") {
						var s_style = tlayers[item][layerid].style;
						var s_url = tlayers[item][layerid].styles[s_style].legendurl;
						flamingo.raiseEvent(thisObj, "onGetLegend", thisObj, s_url, layerid);
					}
				}
			}
		}
		_parseLayers(tlayers[item]);
	}
}
/**
* Updates a layer. Only one request will be fired at a time.
* After the image is loaded the function checks if the mapextent is changed meanwhile.
* If so, the function fires another request.
*/
function update() {
	_update(1);
}
function _update(nrtry:Number) {
	if (not visible) {
		_visible = false;
		return;
	}
	//only one request will be fired at once                                                                                    
	if (updating) {
		return;
	}
	if (this.url == undefined) {
		return;
	}
	if (not map.hasextent) {
		return;
	}
	extent = map.getMapExtent();
	var ms:Number = map.getScaleHint(extent);
	if (minscale != undefined) {
		if (ms<=minscale) {
			flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
			flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
			_visible = false;
			return;
		}
	}
	if (maxscale != undefined) {
		if (ms>maxscale) {
			flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
			flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
			_visible = false;
			return;
		}
	}
	var layerstring = getLayersString();
	if (layerstring.length<=0) {
		flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
		flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
		_visible = false;
		return;
	}
	//var requestedextent = map.getMapExtent();                                                                                    
	if (fullextent != undefined) {
		if (not map.isHit(fullextent)) {
			flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
			flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, 0, 0);
			_visible = false;
			return;
		}
	}
	updating = true;
	_visible = true;
	nrcache++;
	var cachemovie:MovieClip = createEmptyMovieClip("mCache"+nrcache, nrcache);
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
	caches[nrcache] = "";
	//extent;
	//listener for OGWMSConnector
	var lConn:Object = new Object();
	lConn.onRequest = function(connector:OGWMSConnector) {
		//flamingo.tracer(requestobject.url);
		flamingo.raiseEvent(thisObj, "onRequest", thisObj, "update", connector);
	};
	lConn.onResponse = function(connector:OGWMSConnector) {
		//trace(responsobject.response);
		flamingo.raiseEvent(thisObj, "onResponse", thisObj, "update", connector);
	};
	lConn.onError = function(error:String, objecttag:Object) {
		thisObj._stoptimeout();
		if (thisObj.showerrors) {
			flamingo.showError("LayerOGWMS error", error);
		}
		updating = false;
		if (nrtry<retryonerror) {
			nrtry++;
			_update(nrtry);
		} else {
			flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
		}
	};
	lConn.onGetMap = function(imageurl:String, objecttag:Object) {
		var requesttime = (new Date()-starttime)/1000;
		//listener for MovieClipLoader
		var listener:Object = new Object();
		listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
			thisObj._stoptimeout();
			updating = false;
			flamingo.raiseEvent(thisObj, "onUpdateError", thisObj, error);
		};
		listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
			thisObj._stoptimeout();
			flamingo.raiseEvent(thisObj, "onUpdateProgress", thisObj, bytesLoaded, bytesTotal);
		};
		listener.onLoadInit = function(mc:MovieClip) {
			thisObj._stoptimeout();
			var loadtime = (new Date()-starttime)/1000;
			thisObj.updateCache(cachemovie);
			if (thisObj.map.fadesteps>0) {
				var step = (100/map.fadesteps)+1;
				thisObj.onEnterFrame = function() {
					cachemovie._alpha = cachemovie._alpha+step;
					if (cachemovie._alpha>=100) {
						delete this.onEnterFrame;
						flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, requesttime, loadtime, mc.getBytesTotal());
						this.updating = false;
						this._clearCache();
						if (not map.isEqualExtent(extent) or _getVisLayers() != vislayers) {
							this.update();
						}
					}
				};
			} else {
				cachemovie._alpha = 100;
				flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, requesttime, loadtime, mc.getBytesTotal());
				thisObj.updating = false;
				thisObj._clearCache();
				if (not map.isEqualExtent(extent) or _getVisLayers() != vislayers) {
					thisObj.update();
				}
			}
		};
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener(listener);
		mcl.loadClip(imageurl, cachemovie.mHolder);
		var starttime:Date = new Date();
		thisObj._starttimeout();
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
	if (this.transparent != undefined) {
		args.TRANSPARENT = this.transparent.toString().toUpperCase();
	}
	var s_styles = this.getStylesString();
	if (s_styles.length>=0) {
		args.STYLES = s_styles;
	}
	for (var attr in this.attributes) {
		args[attr.toUpperCase()] = this.attributes[attr];
	}
	// 
	var starttime:Date = new Date();
	//
	var vislayers = _getVisLayers();
	flamingo.raiseEvent(thisObj, "onUpdate", thisObj, nrtry);
	cogwms.getMap(url, args);
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
	flamingo.raiseEvent(thisObj, "onUpdateError", thisObj, "timeout, connection failed...");
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
	if (url == undefined and getfeatureinfourl == undefined) {
		return;
	}
	if (not _visible or not visible) {
		return;
	}
	if (fullextent != undefined) {
		if (not map.isHit(fullextent, identifyextent)) {
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
		flamingo.raiseEvent(thisObj, "onResponse", thisObj, "identify", connector);
	};
	lConn.onRequest = function(connector:OGWMSConnector) {
		flamingo.raiseEvent(thisObj, "onRequest", thisObj, "identify", connector);
	};
	lConn.onError = function(error:String, obj:Object, requestid:String) {
		if (thisObj.showerrors) {
			flamingo.showError("LayerOGWMS error", error);
		}
		flamingo.raiseEvent(thisObj, "onError", thisObj, "identify", error);
	};
	lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
		if (thisObj.map.isEqualExtent(thisObj.identifyextent, obj)) {
			var identifytime = (new Date()-starttime)/1000;
			for (var layer in features) {
				var realname = thisObj.aka[layer];
				if (realname != undefined) {
					features[realname] = features[layer];
					delete features[layer];
				}
			}
			flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, features, obj, nrlayersqueried, nrlayersqueried);
			flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, identifytime);
		}
	};
	var args:Object = new Object();
	args.BBOX = this.extent2String(map.getMapExtent());
	args.WIDTH = Math.ceil(map.__width);
	args.HEIGHT = Math.ceil(map.__height);
	args.LAYERS = querylayerstring;
	args.QUERY_LAYERS = querylayerstring;
	args.INFO_FORMAT = this.info_format;
	args.FORMAT = this.format;
	args.EXCEPTIONS = this.exceptions;
	args.VERSION = this.wmsversion;
	args.SRS = this.srs;
	var rect = map.extent2Rect(this.identifyextent);
	args.X = String(Math.round(rect.x+(rect.width/2)));
	args.Y = String(Math.round(rect.y+(rect.height/2)));
	args.FEATURE_COUNT = String(feature_count);
	for (var attr in this.attributes) {
		args[attr.toUpperCase()] = this.attributes[attr];
	}
	var cogwms:OGWMSConnector = new OGWMSConnector();
	cogwms.addListener(lConn);
	flamingo.raiseEvent(thisObj, "onIdentify", thisObj, thisObj.identifyextent);
	if (getfeatureinfourl != undefined) {
		var reqid = cogwms.getFeatureInfo(getfeatureinfourl, args, this.map.copyExtent(this.identifyextent));
	} else {
		var reqid = cogwms.getFeatureInfo(url, args, this.map.copyExtent(this.identifyextent));
	}
	var starttime:Date = new Date();
}
function stopMaptip() {
	this.showmaptip = false;
	this.maptipextent = undefined;
}
function startMaptip(x:Number, y:Number) {
	if (not this.canmaptip) {
		return;
	}
	if (url == undefined and getfeatureinfourl == undefined) {
		return;
	}
	if (not _visible or not visible) {
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
		if (not this.map.isHit(this.fullextent, this.maptipextent)) {
			return;
		}
	}
	this.showmaptip = true;
	var lConn:Object = new Object();
	lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
		if (thisObj.showmaptip) {
			if (thisObj.map.isEqualExtent(thisObj.maptipextent, obj)) {
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
						flamingo.raiseEvent(thisObj, "onMaptipData", thisObj, maptip);
					}
				}
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
	args.FEATURE_COUNT = 1;
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
/**
* Hides a layer.
* @param map:MovieClip [optional]
*/
function hide() {
	visible = false;
	update();
	flamingo.raiseEvent(thisObj, "onHide", thisObj);
}
/**
* Shows a layer.
* @param map:MovieClip [optional]
*/
function show() {
	visible = true;
	updateCaches();
	update();
	flamingo.raiseEvent(thisObj, "onShow", thisObj);
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
	var a:Array = flamingo.asArray(list);
	for (var i = 0; i<a.length; i++) {
		var id = a[i];
		if (layers[id].visible == false) {
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
	//                             
	for (var id in layers) {
		if (layers[id].styles == undefined) {
			return s;
		}
	}
	//
	if (slayers == "#ALL#") {
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
			this["mCache"+nr].removeMovieClip();
			delete caches[nr];
		}
	}
}
function updateCaches() {
	for (var nr in caches) {
		updateCache(this["mCache"+nr]);
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
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				_visible = false;
				return;
			}
		}
		_visible = true;
		var r:Object = map.extent2Rect(cache.extent);
		//cache.scrollRect = new flash.geom.Rectangle(0, 0, map.__width, map.__height);
		cache._x = r.x;
		cache._y = r.y;
		cache._width = r.width;
		cache._height = r.height;
	}
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
		var a_ids = flamingo.asArray(ids);
		for (var i = 0; i<a_ids.length; i++) {
			var id = a_ids[i];
			if (layers[id] == undefined and not initialized) {
				layers[id] = new Object();
				layers[id][field] = value;
			} else {
				layers[id][field] = value;
			}
		}
	}
	flamingo.raiseEvent(thisObj, "onSetLayerProperty", thisObj, ids);
}
/** 
* Gets a property of a layer in the layers collection.
* @param id:String Layerid.
* @param field:String Property. e.g. "visible", "legend", "identify"
* @return Object Value of property.
*/
function getLayerProperty(id:String, field:String):Object {
	if (layers[id] == undefined) {
		return layers[id][field];
	}
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
function moveToLayer(ids:String, coord:Object, updatedelay:Number, movetime:Number):Void {
	var zoomtoscale;
	if (ids == undefined or ids == "") {
		if (maxscale != undefined) {
			zoomtoscale = maxscale*0.9;
		}
		if (mincale != undefined) {
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
	if (id.length == 0 or id == undefined) {
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
	//returns 0 : not visible or 1:  visible or 2: visible but not in scalerange
	var ms:Number = map.getScaleHint(extent);
	//var vis:Boolean = flamingo.getVisible(this)
	if (id.length == 0 or id == undefined) {
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
//public function onSetLayerProperty(layer:MovieClip, ids:String):Void {
/**
* Dispatched when a layer has data for a maptip.
* @param layer:MovieClip A reference to the layer.
* @param maptip:String  the maptip
*/
//public function onMaptipData(layer:MovieClip, maptip:String):Void {
//