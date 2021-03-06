/*-----------------------------------------------------------------------------
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
import tools.Logger;
/**
 * coremodel.service.arcims.ArcIMSConnector
 */
class coremodel.service.arcims.ArcIMSConnector {
	//meta
	var version:String = "2.0.1";
	//algemeen
	var server:String = "";
	var service:String = "";
	var servlet:String = "servlet/com.esri.esrimap.Esrimap";
	var xmlheader:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
	//getServiceInfo defaults
	var renderer:Boolean = false;
	var extensions:Boolean = false;
	var fields:Boolean = false;
	//getImage defaults
	var outputtype:String = "png24";
	var map:Boolean = true;
	var backgroundcolor:Number = 0xFBFBFB;
	var transcolor:Number = 0xFBFBFB;
	var layerliststring:String = "";
	var legend:Boolean = false;
	var legendcolor:Number = 0xffffff;
	var legendwidth:Number = 250;
	var legendfont:String = "arial";
	var titlefontsize:Number = 12;
	var valuefontsize:Number = 12;
	var layerfontsize:Number = 12;
	var legendcolumns:Number = 1;
	//getFeatures defaults
	var featurelimit:Number = 10;
	var skipfeatures:Boolean = false;
	var geometry:Boolean = false;
	var envelope:Boolean = false;
	var beginrecord:Number = 1;
	var request:String;
	var response:String;
	var responsetime:Number;
	var error:String;
	var url:String;
	var requestid:Number = 0;
	var requesttype:String;
	
	var layerOrder:Boolean = false;
	
	var starttime:Date;
	//-----------------------
	private var busy:Boolean = false;
	private var layerid:String;
	private var events:Object;
	//-----------------------
	private var DEBUG:Boolean = false;
	private var recordedValues:Object = new Object();
	private var visualisationSelected:Object = new Object();
	private var identifyColorLayer:String;
	private var identifyColorLayerKey:String;
	private var record:Boolean = false;
	static var  serviceInfoResponses:Array = null;
	static var  serviceInfoResponseListeners:Array = null;
	
	/**
	 * setIdentifyColorLayer
	 * @param	s
	 */
	function setIdentifyColorLayer(s:String) {
		this.identifyColorLayer = s;
	}
	/**
	 * setIdentifyColorLayerKey
	 * @param	s
	 */
	function setIdentifyColorLayerKey(s:String) {
		this.identifyColorLayerKey = s;
	}
	/**
	 * setRecord
	 * @param	b
	 */
	function setRecord(b:Boolean) {
		this.record = b;
	}
	/**
	 * setVisualisationSelected
	 * @param	visual
	 */
	function setVisualisationSelected(visual:Object) {
		this.visualisationSelected = visual;
	}
	/**
	 * setRecorded
	 * @param	layerid
	 * @param	layerkey
	 * @param	values
	 */
	function setRecorded(layerid:String, layerkey:String, values:Array) {
		if (this.recordedValues[layerid] == undefined) {
			this.recordedValues[layerid] = new Object();
		}
		this.recordedValues[layerid][layerkey] = new Array();
		this.recordedValues[layerid][layerkey] = values;

	}
	/**
	 * addRecorded
	 * @param	layerid
	 * @param	layerkey
	 * @param	values
	 */
	function addRecorded(layerid:String, layerkey:String, values:Array) {
		log("addRecorded");
		if (this.recordedValues[layerid] == undefined) {
			this.recordedValues[layerid] = new Object();
		}
		if (recordedValues[layerid][layerkey] == undefined) {
			this.recordedValues[layerid][layerkey] = new Array();
		}
		for (var v = 0; v<values.length; v++) {
			log("values: "+values[v]);
			var addValue:Boolean = true;
			for (var i = 0; i<recordedValues[layerid][layerkey].length && addValue; i++) {
				if (recordedValues[layerid][layerkey][i] == values[v]) {
					addValue = false;
				}
			}
			log("addvalue: "+addValue);
			if (addValue) {
				log(this.recordedValues[layerid][layerkey]);
				this.recordedValues[layerid][layerkey].push(values[v]);
			}
		}
	}
	/**
	 * setRecordedValues
	 * @param	o
	 */
	function setRecordedValues(o:Object) {
		this.recordedValues = o;
	}
	/**
	 * getRecord
	 */
	function getRecord() {
		return record;
	}
	/**
	 * getVisualisationSelected
	 */
	function getVisualisationSelected() {
		return visualisationSelected;
	}
	/**
	 * addListener
	 * @param	listener
	 */
	function addListener(listener:Object) {
		events.addListener(listener);
	}
	/**
	 * addInfoReponseListener
	 * @param	listener
	 */
	static function addInfoReponseListener(listener:Object) {
		if(serviceInfoResponseListeners==null){
			 serviceInfoResponseListeners = new Array();
		}
		serviceInfoResponseListeners.push(listener); 
	}
	/**
	 * removeListener
	 * @param	listener
	 */
	function removeListener(listener:Object) {
		events.removeListener(listener);
	}
	/**
	 * ArcIMSConnector
	 * @param	server
	 */
	function ArcIMSConnector(server:String) {
		if(serviceInfoResponses==null){
			serviceInfoResponses = new Array();
		}	
		this.server = server;
		events = new Object();
		AsBroadcaster.initialize(events);
	}
	private function _getUrl(srequest:String):String {
		var _server:String = this.server;
		var _service:String = this.service;
		var _servlet:String = this.servlet;
		if (_server == "") {
			_server = _root._url;
			var p:Number = _server.indexOf("//", 0);
			p = _server.indexOf("/", p+2);
			_server = _server.substr(0, p);
		}
		if (_server.substr(_server.length-1, 1).toLowerCase() != "/") {
			_server = _server+"/";
		}
		if (_server.substr(0, 4).toLowerCase() != "http" && _server.substr(0, 4).toLowerCase() != "file") {
			_server = "http://"+_server;
		}
		var extra:String = "";
		if (_servlet.substr(0, 1).toLowerCase() == "/") {
			_servlet = _servlet.substr(1, _servlet.length-1);
		}
		extra = "";
		var service:String = "";
		if (srequest == "getServices") {
			_service = "catalog";
		}
		if (srequest == "getFeatures") {
			extra = "&CustomService=Query";
		}
		return (_server+_servlet+"?ServiceName="+_service+"&ClientVersion=4.0&Form=false&Encode=false"+extra);
	}
	private function _sendrequest(sxml:String, requesttype:String, objecttag:Object):Number {
		//_global.flamingo.tracer("busy" + busy);
		if (this.busy) {
			this.error = "busy processing request...";
			this.events.broadcastMessage("onError",this.error,objecttag,this.requestid);
			return null;
		}
		this.requestid++;
		this.requesttype = requesttype;
		this.busy = true;
		this.url = this._getUrl(requesttype);
		this.request = sxml;
		var xrequest:XML = new XML(sxml);
		xrequest.contentType = "text/xml";
		var xresponse:XML = new XML();
		xresponse.ignoreWhite = true;
		var thisObj:ArcIMSConnector = this;
		this.error = "";
		this.response = "";
		this.events.broadcastMessage("onRequest",this,requesttype);
		xresponse.onLoad = function(success:Boolean):Void  {
			thisObj.response = this.toString();
			var newDate:Date = new Date();
			thisObj.responsetime = (newDate.getTime()-thisObj.starttime.getTime())/1000;
			if (success) {
				if (this.firstChild.nodeName == "ERROR") {
					thisObj.error = this.firstChild.childNodes[0].nodeValue;
					thisObj.events.broadcastMessage("onResponse",thisObj);
					thisObj.events.broadcastMessage("onError",thisObj.error,objecttag,thisObj.requestid);
				} else if (this.firstChild.firstChild.nodeName == "ERROR") {
					thisObj.error = this.firstChild.firstChild.childNodes[0].nodeValue;
					thisObj.events.broadcastMessage("onResponse",thisObj);
					thisObj.events.broadcastMessage("onError",thisObj.error,objecttag,thisObj.requestid);
				} else if (this.firstChild.firstChild.firstChild.nodeName == "ERROR") {
					thisObj.error = this.firstChild.firstChild.firstChild.childNodes[0].nodeValue;
					thisObj.events.broadcastMessage("onResponse",thisObj);
					thisObj.events.broadcastMessage("onError",thisObj.error,objecttag,thisObj.requestid);
				} else {
					thisObj.events.broadcastMessage("onResponse",thisObj);
					switch (requesttype) {
						case "getServices" :
							thisObj._processServices(this,objecttag,thisObj.requestid);
							break;
						case "getImage" :
							thisObj._processImage(this,objecttag,thisObj.requestid);
							break;
						case "getRasterInfo" :
							thisObj._processRasterInfo(this,objecttag,thisObj.requestid);
							break;
						case "getServiceInfo" :
							thisObj._storeServiceInfo(this);
							break;
						case "getFeatures" :
							thisObj._processFeatures(this,objecttag,thisObj.requestid);
							break;
					}
				}
			} else {
				thisObj.error = "connection failed...";
				thisObj.events.broadcastMessage("onResponse",thisObj);
				thisObj.events.broadcastMessage("onError",thisObj.error,objecttag,thisObj.requestid);
			}
			thisObj.busy = false;
			delete this;
		};
		this.starttime = new Date();
		xrequest.sendAndLoad(url,xresponse);
		return (thisObj.requestid);
	}
	/**
	 * getServices
	 * @param	objecttag
	 * @return
	 */
	function getServices(objecttag:Object):Number {
		var sxml:String = this.xmlheader+"\n<GETCLIENTSERVICES/>";
		return (this._sendrequest(sxml, "getServices", objecttag));
	}
	private function _processServices(xml:XML, objecttag:Object, requestid:Number):Void {
		var services:Object = new Object();
		var xnSERVICES = xml.firstChild.firstChild.firstChild.childNodes;
		for (var i = 0; i<xnSERVICES.length; i++) {
			if (xnSERVICES[i].nodeName == "SERVICE") {
				var s:Object = new Object();
				s.name = xnSERVICES[i].attributes.name;
				s.servicegroup = xnSERVICES[i].attributes.servicegroup;
				s.access = xnSERVICES[i].attributes.access;
				s.type = xnSERVICES[i].attributes.type;
				s.version = xnSERVICES[i].attributes.version;
				s.status = xnSERVICES[i].attributes.status;
				services[s.name] = s;
			}
		}
		this.events.broadcastMessage("onGetServices",services,objecttag,requestid);
	}
	/**
	 * getServiceInfo
	 * @param	service
	 * @param	objecttag
	 * @return
	 */
	function getServiceInfo(service:String, objecttag:Object):Number {
		if (service != undefined) {
			this.service = service;
		}
		var infoResponseId:String = server + "_" + service;
		//_global.flamingo.tracer("ArcImsConnector nog geen request verstuurd " + infoResponseId + serviceInfoResponses[infoResponseId]);
		if(serviceInfoResponses[infoResponseId] != null){
			//_global.flamingo.tracer("ArcImsConnector request al verstuurd" + infoResponseId);
			if(serviceInfoResponses[infoResponseId].xml != null){
				//_global.flamingo.tracer("ArcImsConnector request al binnen " + infoResponseId);
				_processServiceInfo(serviceInfoResponses[infoResponseId].xml,objecttag);
			} 
		} else {
			serviceInfoResponses[infoResponseId] = new Object();
			var str:String = this.xmlheader+"\n";
			str = str+"<ARCXML version=\"1.1\">\n";
			str = str+"<REQUEST>\n";
			str = str+"<GET_SERVICE_INFO  dpi = \"96\" envelope=\"false\" renderer=\""+String(this.renderer)+"\" extensions=\""+String(this.extensions)+"\" fields=\""+String(this.fields)+"\"/>\n";
			str = str+"</REQUEST>\n";
			str = str+"</ARCXML>";
			objecttag.infoResponseId = infoResponseId;
			return (this._sendrequest(str, "getServiceInfo", objecttag));
		}
	}
	/**
	 * getServiceInfoFromStore
	 * @param	server
	 * @param	service
	 * @param	listener
	 */
	static function getServiceInfoFromStore(server:String,service:String, listener:Object):Void{
		var infoResponseId:String = server + "_" + service;
		if(serviceInfoResponses[infoResponseId].xml != null){
			_processServiceInfo(serviceInfoResponses[infoResponseId].xml,listener);
		} 
		
	}
	 
	private function _storeServiceInfo(xml:XML):Void {
		var infoResponseId:String = server + "_" + service;
		if(serviceInfoResponses[infoResponseId]!=null && serviceInfoResponses[infoResponseId].xml == null){
			serviceInfoResponses[infoResponseId].xml = xml;
		}
		for(var i:Number=0;i<serviceInfoResponseListeners.length;i++){
			serviceInfoResponseListeners[i].onStoreServiceInfo();	 
		}
	}
		
		  
	private static function _processServiceInfo(xml:XML, listener:Object):Void {
		var layer:Object;
		var field:Object;
		var layers = new Object();
		var extent = new Object();
		var xnSI = xml.firstChild.firstChild.firstChild.childNodes;
		for (var i:Number = 0; i<xnSI.length; i++) {
			switch (xnSI[i].nodeName) {
				case "LAYERINFO" :
					layer = new Object();
					layer.type = xnSI[i].attributes.type;
					if (layer.type == "featureclass") {
						layer.fclasstype = xnSI[i].firstChild.attributes.type;
					}
					layer.visible = false;
					layer.legend = false;
					if (xnSI[i].attributes.visible == "true") {
						layer.visible = true;
						layer.legend = true;
					}
					layer.name = xnSI[i].attributes.name;
					layer.id = xnSI[i].attributes.id;
					layer.minscale = ArcIMSConnector._asNumber(xnSI[i].attributes.minscale);
					layer.maxscale = ArcIMSConnector._asNumber(xnSI[i].attributes.maxscale);
					layer.fields = new Object();
					layer.query = "";
					//veld informatie
					var xnFCLASS:Array = xnSI[i].childNodes;
					for (var j:Number = 0; j<xnFCLASS.length; j++) {
						if (xnFCLASS[j].nodeName == "FCLASS") {
							var xnFIELD = xnFCLASS[j].childNodes;
							for (var k:Number = 0; k<xnFIELD.length; k++) {
								if (xnFIELD[k].nodeName == "FIELD") {
									field = new Object();
									field.name = xnFIELD[k].attributes.name;
									field.shortname = ArcIMSConnector._stripGeodatabase(field.name);
									field.type = xnFIELD[k].attributes.type;
									field.size = xnFIELD[k].attributes.size;
									field.precision = xnFIELD[k].attributes.precision;
									layer.fields[field.name] = field;
								}
							}
						}
					}
					layers[layer.id] = layer;
					break;
				case "PROPERTIES" :
					var xnPROPERTIES:Array = xnSI[i].childNodes;
					for (var j:Number = 0; j<xnPROPERTIES.length; j++) {
						if (xnPROPERTIES[j].nodeName == "ENVELOPE") {
							extent.name = xnPROPERTIES[j].attributes.name;
							extent.minx = ArcIMSConnector._asNumber(xnPROPERTIES[j].attributes.minx);
							extent.miny = ArcIMSConnector._asNumber(xnPROPERTIES[j].attributes.miny);
							extent.maxx = ArcIMSConnector._asNumber(xnPROPERTIES[j].attributes.maxx);
							extent.maxy = ArcIMSConnector._asNumber(xnPROPERTIES[j].attributes.maxy);
						}
					}
					break;
				case "ENVIRONMENT" :
					break;
			}
		}

		listener.onGetServiceInfo(extent,layers);
		//this.events.broadcastMessage("onGetServiceInfo",extent,layers,objecttag,requestid);
	}
	/**
	 * getImage
	 * @param	service
	 * @param	extent
	 * @param	size
	 * @param	layers
	 * @param	objecttag
	 * @return
	 */
	function getImage(service:String, extent:Object, size:Object, layers:Object, objecttag:Object):Number {
		if (service != undefined) {
			this.service = service;
		}
		var str:String = this.xmlheader+"\n";
		str = str+"<ARCXML version=\"1.1\">\n";
		str = str+"<REQUEST>\n";
		str = str+"<GET_IMAGE autoresize=\"true\">\n";
		str = str+"<PROPERTIES>\n";
		var rgb1:Object = _getRGB(this.backgroundcolor);
		if (!isNaN(this.transcolor)) {
			var rgb2:Object = _getRGB(this.transcolor);
			str = str+"<BACKGROUND  color=\""+rgb1.r+","+rgb1.g+","+rgb1.b+"\""+" transcolor=\""+rgb2.r+","+rgb2.g+","+rgb2.b+"\"  />\n";
		} else {
			str = str+"<BACKGROUND  color=\""+rgb1.r+","+rgb1.g+","+rgb1.b+"\"  />\n";
		}
		str = str+"<ENVELOPE minx=\""+String(extent.minx)+"\" miny=\""+String(extent.miny)+"\" maxx=\""+String(extent.maxx)+"\" maxy=\""+String(extent.maxy)+"\" />\n";
		if (!this.map) {
			str = str+"<DRAW map = \"false\" />";
		}
		str = str+"<IMAGESIZE width=\""+size.width+"\" height=\""+size.height+"\" />\n";
		str = str+"<OUTPUT type=\""+this.outputtype+"\" />";
		if (this.layerliststring.length>0) {
			str = str+this.layerliststring;
		} else {
			if (layers != undefined) {
				str = str+"<LAYERLIST order=\""+ this.layerOrder +"\" >\n";
				for (var id in layers) {
					if (layers[id].visible != undefined) {
						if (!layers[id].visible) {
							str = str+"<LAYERDEF id=\""+id+"\" visible=\""+String(layers[id].visible)+"\">\n";
						} else {
							str = str+"<LAYERDEF id=\""+id+"\" visible=\""+String(layers[id].visible)+"\">\n";
							if (layers[id].layerdefstring.length>0) {
								str = str+layers[id].layerdefstring;
							}
							if ((layers[id].query!=undefined && layers[id].query.length > 0) || (layers[id].spatialQuery!=undefined && layers[id].spatialQuery.length > 0)) {
								str += "<SPATIALQUERY";
								if (layers[id].query.length > 0){
									str += " where=\"" + layers[id].query + "\"";
								}
								str += ">";
								if (layers[id].spatialQuery.length > 0) {
									str += layers[id].spatialQuery;
								}
								str += "</SPATIALQUERY>";								
							}
							
						}
						var otherPartAdded = false;
						var keyCount:Number = 0;
						for (var key in this.recordedValues[id]) {
							keyCount++;
						}
						if (keyCount>1) {
							str += "<GROUPRENDERER>";
						}
						for (var key in this.recordedValues[id]) {
							if (this.recordedValues[id][key].length>0) {
								str += '<VALUEMAPRENDERER lookupfield="'+key+'">';
								for (var i = 0; i<this.recordedValues[id][key].length; i++) {
									str += '<EXACT value="'+this.recordedValues[id][key][i]+'" label="label">';
									str += '<SIMPLEPOLYGONSYMBOL ';
									if (visualisationSelected[id]["antialiasing"] != undefined) {
										str += 'antialiasing="'+visualisationSelected[id]["antialiasing"]+'" ';
									}
									if (visualisationSelected[id]["boundary"] != undefined) {
										str += 'boundary="'+visualisationSelected[id]["boundary"]+'" ';
									}
									if (visualisationSelected[id]["boundarycaptype"] != undefined) {
										str += 'boundarycaptype="'+visualisationSelected[id]["boundarycaptype"]+'" ';
									}
									if (visualisationSelected[id]["boundarycolor"] != undefined) {
										str += 'boundarycolor="'+visualisationSelected[id]["boundarycolor"]+'" ';
									}
									if (visualisationSelected[id]["boundaryjointype"] != undefined) {
										str += 'boundaryjointype="'+visualisationSelected[id]["boundaryjointype"]+'" ';
									}
									if (visualisationSelected[id]["boundarytransparency"] != undefined) {
										str += 'boundarytransparency="'+visualisationSelected[id]["boundarytransparency"]+'" ';
									}
									if (visualisationSelected[id]["boundarytype"] != undefined) {
										str += 'boundarytype="'+visualisationSelected[id]["boundarytype"]+'" ';
									}
									if (visualisationSelected[id]["boundarywidth"] != undefined) {
										str += 'boundarywidth="'+visualisationSelected[id]["boundarywidth"]+'" ';
									}
									if (visualisationSelected[id]["fillcolor"] != undefined) {
										str += 'fillcolor="'+visualisationSelected[id]["fillcolor"]+'" ';
									}
									if (visualisationSelected[id]["fillinterval"] != undefined) {
										str += 'fillinterval="'+visualisationSelected[id]["fillinterval"]+'" ';
									}
									if (visualisationSelected[id]["filltransparency"] != undefined) {
										str += 'filltransparency="'+visualisationSelected[id]["filltransparency"]+'" ';
									}
									if (visualisationSelected[id]["filltype"] != undefined) {
										str += 'filltype="'+visualisationSelected[id]["filltype"]+'" ';
									}
									if (visualisationSelected[id]["overlap"] != undefined) {
										str += 'overlap="'+visualisationSelected[id]["overlap"]+'" ';
									}
									if (visualisationSelected[id]["transparency"] != undefined) {
										str += 'transparency="'+visualisationSelected[id]["transparency"]+'" ';
									}
									str += '/>';
									str += '</EXACT>';
								}
								if (!otherPartAdded) {
									str += '<OTHER>';
									str += '<SIMPLEPOLYGONSYMBOL ';
									if (visualisationSelected[id]["other_antialiasing"] != undefined) {
										str += 'antialiasing="'+visualisationSelected[id]["other_antialiasing"]+'" ';
									}
									if (visualisationSelected[id]["other_boundary"] != undefined) {
										str += 'boundary="'+visualisationSelected[id]["other_boundary"]+'" ';
									}
									if (visualisationSelected[id]["other_boundarycaptype"] != undefined) {
										str += 'boundarycaptype="'+visualisationSelected[id]["other_boundarycaptype"]+'" ';
									}
									if (visualisationSelected[id]["other_boundarycolor"] != undefined) {
										str += 'boundarycolor="'+visualisationSelected[id]["other_boundarycolor"]+'" ';
									}
									if (visualisationSelected[id]["other_boundaryjointype"] != undefined) {
										str += 'boundaryjointype="'+visualisationSelected[id]["other_boundaryjointype"]+'" ';
									}
									if (visualisationSelected[id]["other_boundarytransparency"] != undefined) {
										str += 'boundarytransparency="'+visualisationSelected[id]["other_boundarytransparency"]+'" ';
									}
									if (visualisationSelected[id]["other_boundarytype"] != undefined) {
										str += 'boundarytype="'+visualisationSelected[id]["other_boundarytype"]+'" ';
									}
									if (visualisationSelected[id]["other_boundarywidth"] != undefined) {
										str += 'boundarywidth="'+visualisationSelected[id]["other_boundarywidth"]+'" ';
									}
									if (visualisationSelected[id]["other_fillcolor"] != undefined) {
										str += 'fillcolor="'+visualisationSelected[id]["other_fillcolor"]+'" ';
									}
									if (visualisationSelected[id]["other_fillinterval"] != undefined) {
										str += 'fillinterval="'+visualisationSelected[id]["other_fillinterval"]+'" ';
									}
									if (visualisationSelected[id]["other_filltransparency"] != undefined) {
										str += 'filltransparency="'+visualisationSelected[id]["other_filltransparency"]+'" ';
									}
									if (visualisationSelected[id]["other_filltype"] != undefined) {
										str += 'filltype="'+visualisationSelected[id]["other_filltype"]+'" ';
									}
									if (visualisationSelected[id]["other_overlap"] != undefined) {
										str += 'overlap="'+visualisationSelected[id]["other_overlap"]+'" ';
									}
									if (visualisationSelected[id]["other_transparency"] != undefined) {
										str += 'transparency="'+visualisationSelected[id]["other_transparency"]+'" ';
									}
									str += '/></OTHER>';
									otherPartAdded = true;
								}
								str += '</VALUEMAPRENDERER>';
							}
						}
						if (keyCount>1) {
							str += "</GROUPRENDERER>";
						}
						str = str+"\n</LAYERDEF>";
					}
				}
				str = str+"</LAYERLIST>";
			}
		}
		if (this.legend) {
			var rgb:Object = _getRGB(this.legendcolor);
			str = str+"<LEGEND width =\""+String(this.legendwidth)+"\" font=\""+this.legendfont+"\" titlefontsize=\""+String(this.titlefontsize)+"\" valuefontsize=\""+String(this.valuefontsize)+"\" layerfontsize=\""+String(this.layerfontsize)+"\" autoextend=\"true\"  backgroundcolor=\""+rgb.r+","+rgb.g+","+rgb.b+"\" columns=\""+String(this.legendcolumns)+"\"  cansplit=\""+"true"+"\" >\n";
			if (layers != undefined) {
				str = str+"<LAYERS>\n";
				for (var id in layers) {
					if (layers[id].legend == false) {
						str = str+"<LAYER id=\""+id+"\"/>\n";
					}
				}
				str = str+"</LAYERS>\n";
			}
			str = str+"</LEGEND>\n";
		}
		str = str+"</PROPERTIES>\n";

		//Set Buffers
		if (layers != undefined) {
			for (var id in layers) {
				if (layers[id].buffer != undefined) {
					str = str+"<LAYER type=\"featureclass\" visible=\""+String(layers[id].visible)+"\" name=\"zone met straal "+layers[id].buffer.radius+"m\" id=\"gLayer\">\n<DATASET fromlayer=\""+id+"\"/>\n";
					if (layers[id].query == undefined || layers[id].query == "") {
						str = str+"<SPATIALQUERY>\n";
					} else {
						str = str+"<SPATIALQUERY where=\""+layers[id].query+"\">";
					}
					str = str+"<BUFFER distance=\""+layers[id].buffer.radius+"\" bufferunits=\"METER\" />\n</SPATIALQUERY>\n<SIMPLERENDERER>\n";
					str = str+"<SIMPLEPOLYGONSYMBOL fillcolor=\""+layers[id].buffer.fillcolor+"\" filltransparency=\""+layers[id].buffer.filltransparency+"\" boundarycolor=\""+layers[id].buffer.boundarycolor+"\" boundarywidth=\""+layers[id].buffer.boundarywidth+"\" filltype=\"lightgray\" boundarycaptype=\"round\"  />\n</SIMPLERENDERER>\n</LAYER>";
				}
			}
		}
		
		str = str+"</GET_IMAGE>\n";
		str = str+"</REQUEST>\n";
		str = str+"</ARCXML>";
		return (this._sendrequest(str, "getImage", objecttag));
	}
	private function _processImage(xml:XML, objecttag:Object, requestid:Number):Void {
		var extent = new Object();
		var imageurl:String;
		var legendurl:String;
		var xnIMAGE:Array = xml.firstChild.firstChild.firstChild.childNodes;
		for (var i:Number = 0; i<xnIMAGE.length; i++) {
			switch (xnIMAGE[i].nodeName) {
				case "ENVELOPE" :
					extent.minx = ArcIMSConnector._asNumber(xnIMAGE[i].attributes.minx);
					extent.miny = ArcIMSConnector._asNumber(xnIMAGE[i].attributes.miny);
					extent.maxx = ArcIMSConnector._asNumber(xnIMAGE[i].attributes.maxx);
					extent.maxy = ArcIMSConnector._asNumber(xnIMAGE[i].attributes.maxy);
					break;
				case "OUTPUT" :
					imageurl = xnIMAGE[i].attributes.url;
					break;
				case "LEGEND" :
					legendurl = xnIMAGE[i].attributes.url;
					break;
			}
		}
		this.events.broadcastMessage("onGetImage",extent,imageurl,legendurl,objecttag,requestid);
	}
	private function _processRasterInfo(xml:XML, objecttag:Object, requestid:Number):Void {
		var data:Array = new Array();
		var xRASTERINFO:Array = xml.firstChild.firstChild.firstChild.childNodes;
		for (var i:Number = 0; i<xRASTERINFO.length; i++) {
			switch (xRASTERINFO[i].nodeName) {
				case "BANDS" :
					var record:Object = new Object();
					var xBANDS = xRASTERINFO[i].childNodes;
					for (var j:Number = xBANDS.length-1; j>=0; j--) {
						if (xBANDS[j].nodeName == "BAND") {
							var nr = xBANDS[j].attributes.number;
							var val = xBANDS[j].attributes.value;
							record["band_"+nr] = val;
						}
					}
					data.push(record);
					break;
			}
		}
		this.events.broadcastMessage("onGetRasterInfo",this.layerid,data,objecttag,requestid);
	}
	/**
	 * getRasterInfo
	 * @param	service
	 * @param	layerid
	 * @param	point
	 * @param	coordsys
	 * @param	objecttag
	 * @return
	 */
	function getRasterInfo(service:String, layerid:String, point:Object, coordsys:String, objecttag:Object):Number {
		this.layerid = layerid;
		if (service != undefined) {
			this.service = service;
		}
		var str:String = this.xmlheader+"\n";
		str = str+"<ARCXML version=\"1.1\">\n";
		str = str+"<REQUEST>\n";
		str = str+"<GET_RASTER_INFO x='"+point.x+"' y='"+point.y+"' layerid='"+layerid+"' >";
		if (coordsys != undefined) {
			str = str+"<COORDSYS id='"+coordsys+"' />";
		}
		str = str+"</GET_RASTER_INFO>";
		str = str+"</REQUEST>\n";
		str = str+"</ARCXML>";
		//trace(str);
		return (this._sendrequest(str, "getRasterInfo", objecttag));
	}
	/**
	 * getFeatures
	 * @param	service
	 * @param	layerid
	 * @param	extent
	 * @param	subfields
	 * @param	query
	 * @param	objecttag
	 * @return
	 */
	function getFeatures(service:String, layerid:String, extent:Object, subfields:String, query:String, objecttag:Object):Number {
		this.layerid = layerid;
		if (service != undefined) {
			this.service = service;
		}
		if (subfields == undefined) {
			subfields = "#ALL#";
		}
		if (query == undefined) {
			query = "";
		}
		var str:String = this.xmlheader+"\n";
		str = str+"<ARCXML version=\"1.1\">\n";
		str = str+"<REQUEST>\n";
		if (this.skipfeatures) {
			str = str+"<GET_FEATURES skipfeatures=\"true\" outputmode=\"newxml\">\n";
		} else {
			str = str+"<GET_FEATURES geometry=\""+String(this.geometry)+"\" compact=\"true\" checkesc=\"true\" envelope=\""+String(this.envelope)+"\" featurelimit=\""+String(this.featurelimit)+"\" beginrecord=\""+String(this.beginrecord)+"\" outputmode=\"newxml\">\n";
		}
		//str = str+"<ENVIRONMENT>\n";
		//str = str+"<SEPARATORS cs=\"\" ts=\";\" />\n";
		//str = str+"</ENVIRONMENT>\n";
		str = str+"<LAYER id=\""+layerid+"\" />\n";
		var sf:String = subfields;
		if ((this.geometry || this.envelope) && subfields != "#ALL#") {
			sf = "#SHAPE# "+subfields;
		}
		if (extent == undefined) {
			str = str+"<QUERY subfields =\""+sf+"\" featurelimit=\""+String(this.featurelimit)+"\" searchorder=\"optimize\" where=\""+query+"\"/>\n";
		} else {
			str = str+"<SPATIALQUERY subfields =\""+sf+"\" featurelimit=\""+String(this.featurelimit)+"\" searchorder=\"optimize\" where=\""+query+"\">\n";
			str = str+"<SPATIALFILTER relation=\"area_intersection\">\n";
			str = str+"<ENVELOPE maxx=\""+String(extent.maxx)+"\" maxy=\""+String(extent.maxy)+"\" minx=\""+String(extent.minx)+"\" miny=\""+String(extent.miny)+"\" /> \n";
			str = str+"</SPATIALFILTER>\n";
			str = str+"</SPATIALQUERY>\n";
		}
		str = str+"</GET_FEATURES>\n";
		str = str+"</REQUEST>\n";
		str = str+"</ARCXML>";
		//trace(str);
		return (this._sendrequest(str, "getFeatures", objecttag));
	}
	private function _processFeatures(xml:XML, objecttag:Object, requestid:Number):Void {
		//trace(xml);
		var count:Number = 0;
		var hasmore:Boolean = false;
		var data:Array = new Array();
		var FEATURES = xml.firstChild.firstChild.firstChild.childNodes;
		for (var i = FEATURES.length; i>=0; i--) {
			switch (FEATURES[i].nodeName) {
				case "FEATURECOUNT" :
					count = Number(FEATURES[i].attributes.count);
					if (FEATURES[i].attributes.hasmore.toLowerCase() == "true") {
						hasmore = true;
					}
					break;
				case "FEATURE" :
					var record:Object = new Object();
					var FEATURE = FEATURES[i].childNodes;
					for (var j = 0; j<FEATURE.length; j++) {
						switch (FEATURE[j].nodeName) {
							case "FIELDS" :
								var FIELDS = FEATURE[j].childNodes;
								for (var k = 0; k<FIELDS.length; k++) {
									record[FIELDS[k].attributes.name] = FIELDS[k].attributes.value;
								}
								break;
							case "ENVELOPE" :
								var ext:Object = new Object();
								ext.minx = ArcIMSConnector._asNumber(FEATURE[j].attributes.minx);
								ext.miny = ArcIMSConnector._asNumber(FEATURE[j].attributes.miny);
								ext.maxx = ArcIMSConnector._asNumber(FEATURE[j].attributes.maxx);
								ext.maxy = ArcIMSConnector._asNumber(FEATURE[j].attributes.maxy);
								record["SHAPE.ENVELOPE"] = ext;
								break;
							case "MULTIPOINT" :
								var multipoint:Array = new Array();
								var xmultipoint = FEATURE[j].childNodes;
								for (var k = 0; k<xmultipoint.length; k++) {
									if (xmultipoint[k].nodeName == "COORDS") {
										var COORDS = xmultipoint[k].childNodes;
										for (var l = 0; l<COORDS.length; l++) {
											var xy:Array = COORDS[l].nodeValue.split(" ");
											multipoint.push({x:ArcIMSConnector._asNumber(xy[0]), y:ArcIMSConnector._asNumber(xy[1])});
										}
									}
								}
								//record["SHAPE.MULTIPOINT"] = FEATURE[j].childNodes;
								record["SHAPE.MULTIPOINT"] = multipoint;
								break;
							case "POLYLINE" :
								record["SHAPE.POLYLINE"] = FEATURE[j].childNodes;
								break;
							case "POLYGON" :
								record["SHAPE.POLYGON"] = FEATURE[j].childNodes;
								break;
						}
					}
					data.push(record);
					break;
			}
		}
		var identifyColorLayerLayers:Array = this.identifyColorLayer.split(",");
		var identifyColorLayerKeyArray:Array = this.identifyColorLayerKey.split(",");
		log("identifyColorLayer "+this.identifyColorLayer);
		for (var i = 0; i<identifyColorLayerLayers.length; i++) {
			//als de layer voorkomt in de te kleuren layers.
			log("this.layerid "+this.layerid);
			if (this.layerid == identifyColorLayerLayers[i]) {

				//als de er nog geen array is voor deze layer
				log("Record true/false: "+this.record);
				if (this.record) {

					if (recordedValues[identifyColorLayerLayers[i]] == undefined) {
						recordedValues[identifyColorLayerLayers[i]] = new Object();

					}
					if (recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]] == undefined) {
						recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]] = new Array();
					}
					//doorloop alle gevonden waarden. 
					for (var d = 0; d<data.length; d++) {
						var pvalue = data[d][identifyColorLayerKeyArray[i]];
						log("Key: "+identifyColorLayerKeyArray[i]);
						log("Pvalues "+pvalue);
						var addValue:Boolean = true;
						for (var r = 0; r<recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]].length && addValue; r++) {
							log("Recorded Values: "+recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]][r]);
							if (recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]][r] == pvalue) {

								recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]].splice(r,1);
								addValue = false;
							}
						}
						if (addValue) {
							recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]].push(pvalue);
						}
					}
				} else {
					recordedValues[identifyColorLayerLayers[i]] = new Object();
					recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]] = new Array();
					for (var d = 0; d<data.length; d++) {
						recordedValues[identifyColorLayerLayers[i]][identifyColorLayerKeyArray[i]].push(data[d][identifyColorLayerKeyArray[i]]);
					}
				}
			}
		}
		if (record && recordedValues[this.layerid] != undefined) {
			this.events.broadcastMessage("onRecord",this.layerid,recordedValues);
		}
		this.events.broadcastMessage("onGetFeatures",this.layerid,data,count,hasmore,objecttag,requestid);
	}
	private static function _asNumber(s:String):Number {
		if (s == undefined) {
			return (undefined);
		}
		if (s.indexOf(",", 0) != -1) {
			var a:Array = s.split(",");
			s = a[0]+"."+a[1];
		}
		return (Number(s));
	}
	private static function _stripGeodatabase(s:String):String {
		var a:Array = s.split(".");
		return (a[a.length-1]);
	}
	private function _getRGB(hex:Number):Object {
		return ({r:hex >> 16, g:(hex & 0x00FF00) >> 8, b:hex & 0x0000FF});
	}
	/**
	 * log
	 * @param	stringtolog
	 */
	function log(stringtolog:Object) {
		if (this.DEBUG) {
			var newDate:Date = new Date();
			trace(newDate+"ArcImsConnector: "+stringtolog);
		}
	}
	
	function setLayerOrder (layerOrder:Boolean) {
		this.layerOrder = layerOrder;
	}
	
}