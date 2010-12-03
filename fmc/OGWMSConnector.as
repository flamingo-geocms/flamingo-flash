dynamic class OGWMSConnector {
	//meta
	var version:String = "2.0";
	//-----------------------
	private var busy:Boolean = false;
	private var events:Object;
	var requestid:Number = 0;
	var url:String;
	var queryLayers:String; 
	var requesttype:String;
	var responsetime:Number;
	var response:String
	var error:String;

	private var capService:Object = null;
	private var capLayers:Object = null;
	private var capObj:Object = null;
	private var capReqid:Number = 0;
	private var instanceId:Number = 0;
	
	static private var instances:Array = new Array();
	
	static function getInstance(url:String):OGWMSConnector {
		var instance:OGWMSConnector = null;
		//_global.flamingo.tracer("getInstance, url = " + url);
		for (var i:String in instances) {
		    instance = OGWMSConnector(instances[i]);
		    //_global.flamingo.tracer("instance.getCapUrl() = " + instance.getCapUrl());
		    if (instance.getCapUrl() == url) {
		        return instance;
		    }
		}
		instance = new OGWMSConnector(url, instances.length);
		instances.push(instance);
		return instance;
	}
	
	//-----------------------------------
	function addListener(listener:Object) {
		events.addListener(listener);
	}
	function removeListener(listener:Object) {
		events.removeListener(listener);
	}

	function OGWMSConnector(capUrl:String, id:Number) {
		this.capUrl = capUrl;
		this.instanceId = id;
		events = new Object();
		AsBroadcaster.initialize(events);
	}
	
	function getCapUrl():String {
	  return this.capUrl;
	}

	function getCapabilities(url:String, args:Object, responseHandler:Object):Number {
		if (this.capService == null && !this.busy) {
    		if (args == undefined) {
    			var args:Object = new Object();
    		}
    		args.REQUEST = "GetCapabilities";
    		return (this._request(url, args, null));
    } else if (!this.busy) {
		    responseHandler.onGetCapabilities(this.capService, this.capLayers, this.capObj, this.capReqid);
    }
	}
	function getMap(url:String, args:Object, obj:Object):Number {
		if (args == undefined) {
			var args:Object = new Object();
		}
		this.response=""
		args.REQUEST = "GetMap";
		return (this._request(url, args, obj));
	}
	function getFeatureInfo(url:String, args:Object, obj:Object):Number {
		if (args == undefined) {
			var args:Object = new Object();
		}
		queryLayers = args.QUERY_LAYERS;
		args.REQUEST = "GetFeatureInfo";
		return (this._request(url, args, obj));
	}
	private function _request(url:String, args:Object, obj:Object):Number {
		if (this.busy) {
			this.error = "busy processing request...";
			this.events.broadcastMessage("onError", this.error, obj, this.requestid);
			return;
		}
		this.error = "";
		this.busy = true;
		this.requestid++;
		var req_url = url;
		for (var arg in args) {
			req_url = this._changeArgs(req_url, arg, args[arg]);
		}
		this.url = req_url;
		this.requesttype = args.REQUEST;
		this.events.broadcastMessage("onRequest", this);
		//flamingo.tracer("A:"+args.REQUEST.toUpperCase() )
		if (args.REQUEST.toUpperCase() == "GETMAP") {
			this.busy = false;
			this.events.broadcastMessage("onGetMap", req_url, obj, this.requestid);
			this.events.broadcastMessage("onResponse", this);
		} else {
			var xrequest:XML = new XML();
			xrequest.ignoreWhite = true;
			var thisObj:Object = this;
			xrequest.onLoad = function(success:Boolean) {
				//trace("----------------------------------------")
				//_global.flamingo.tracer(success);
				//_global.flamingo.tracer(this.toString());
				thisObj.responsetime = (new Date()-starttime)/1000;
				thisObj.response = this.toString();
				if (success) {
					if (this.firstChild.nodeName.toLowerCase() == "serviceexceptionreport") {
						error = this.firstChild.toString();
						thisObj.events.broadcastMessage("onResponse", thisObj);
						thisObj.events.broadcastMessage("onError", error, obj, thisObj.requestid);
					} else {
						thisObj.events.broadcastMessage("onResponse", thisObj);
						switch (args.REQUEST.toUpperCase()) {
						case "GETCAPABILITIES" :
							thisObj._processCapabilities(this, obj, thisObj.requestid);
							break;
						case "GETFEATUREINFO" :
							thisObj._processFeatureInfo(this, obj, thisObj.requestid);
							break;
						case "GETMAP" :
							thisObj.events.broadcastMessage("onGetMap", req_url, obj, thisObj.requestid);
							thisObj.events.broadcastMessage("onResponse", thisObj);
							break;
						}
					}
				} else {
					thisObj.error = thisObj.url + " connection failed...";
					thisObj.events.broadcastMessage("onResponse", thisObj);
					thisObj.events.broadcastMessage("onError", thisObj.error, obj, reqid);
				}
				thisObj.busy = false;
				// do some cleaning
				delete this;
			};
			var starttime:Date = new Date();
			xrequest.load(req_url);
		}
		return (this.requestid);
	}
	private function _processFeatureInfo(xml:XML, obj, reqid) {		
		//switch (xml.firstChild.nodeName.toLowerCase()) {
		//dirty to have a handler for every implementation of the getFeatureResponse. But the spec's ain't saying things about the resonse format.
		switch (xml.firstChild.localName.toLowerCase()) {
		case "msgmloutput" :
			_process_msGMLOutput(xml, obj, reqid);
			break;
		case "featurecollection" :
			_process_featureCollection(xml, obj, reqid);
			break;
		case "featureinforesponse" :			
			//bah :( :
			//is with seperate field objects in fields tag?
			if (xml.firstChild.firstChild.localName.toLowerCase()=="fields"){
				_process_featureInfoResponseWithSeperateFields(xml, obj, reqid);
			}else{
				_process_featureInfoResponse(xml, obj, reqid);
			}
			break;
		case undefined :
			//var lines = xml.split(String.fromCharCode(13))
			var s:String = xml.toString();
			if (s.indexOf("GetFeatureInfo results:", 0)>=0) {
				_process_getfeatureinforesults(s, obj, reqid);
			} else {
				this.events.broadcastMessage("onError", "cannot parse unknown output format...", obj, reqid);
			}
			break;
		default :
			this.events.broadcastMessage("onError", "cannot parse unknown output format...", obj, reqid);
		}
	}
	private function _process_featureInfoResponseWithSeperateFields(xml, obj, reqid){
		//Oraclemaps output
		var features:Object = new Object();
		var layer:String;
		var val:String;
		var featureObjects:Array = xml.firstChild.childNodes;	
		for (var i:Number = 0; i<featureObjects.length; i++) {
			var feature:Object = new Object();
			var layer = "?";
			var attributeObjects:Array = featureObjects[i].childNodes;
			if(attributeObjects.length == 0){
				for (attr in featureObjects[i].attributes) {
					var ob:Object = new Object;
					var attributes:Object = new Object;
					attributes.name = attr;
					attributes.value = featureObjects[i].attributes[attr];
					ob.attributes = attributes;
					attributeObjects.push(ob);
					//iff _LAYERID_ is a child of the fields set the value as the layer name.
					if (attributes.name=='_LAYERID_'){
						layer=attributes.value;
					}
				}
			}
			for (var a:Number = 0; a < attributeObjects.length; a++) {
				var attributeName:String=attributeObjects[a].attributes.name;
				var attributeValue:String=attributeObjects[a].attributes.value;
				feature[attributeName] = attributeValue;
				//try to solve the layer name....
				if (layer=="?"){
					if (attributeName.indexOf(".")>0 && attributeName.toLowerCase().indexOf("geometry")!=0){
						var tokens:Array = attributeName.split(".");
						layer="";
						for (var t=0; t < tokens.length-1; t++){
							if (layer.length> 0){
								layer+=".";
							}
							layer+=tokens[t];
						}
					}
					//if still "?" take the first querylayer
					if (layer=="?"){
						var qLayers:String = queryLayers;
						layer = qLayers.split(",")[0];
					}	
				}																								  
			}
			if (features[layer] == undefined) {
				features[layer] = new Array();
			}
			features[layer].push(feature);
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_getfeatureinforesults(s:String, obj, reqid) {
		//GetFeatureInfo results:
		//
		//Layer &apos;EHS_Bos_natuurgebied_2005_V&apos;
		//   Feature 1233: 
		//     OBJECTID = &apos;1233&apos;
		//     OMSCHRIJVING = &apos;Bos- en natuurgebied&apos
		//etc.
		var features:Object = new Object();
		var a:Array;
		var field:String;
		var val:String;
		var layer:String;
		var feature:Object;
		var lines = s.split(newline);
		var line:String;
		for (var i:Number = 1; i<lines.length; i++) {
			line = this.trim(lines[i]);
			if (line.length == 0) {
				continue;
			}
			if (line.indexOf("Layer ") == 0) {
				//layer
				a = line.split(" ");
				layer = this.trimApos(line.substring(6, line.length));
				features[layer] = new Array();
				continue;
			}
			if (line.indexOf("Feature ") == 0) {
				//feature
				feature = new Object();
				features[layer].push(feature);
				continue;
			}
			if (line.indexOf(" = ")>=0) {
				//value
				a = line.split(" = ");
				field = this.trim(a[0]);
				val = this.trimApos(this.trim(a[1]));
				feature[field] = val;
				continue;
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_featureInfoResponse(xml:XML, obj, reqid) {
		//ESRI output
		var features:Object = new Object();
		var layer:String;
		var val:String;
		var xfields:Array = xml.firstChild.childNodes;
		for (var i:Number = 0; i<xfields.length; i++) {
			var feature:Object = new Object();
			var layer = xfields[i].attributes._LAYERID_;
			if (layer == undefined) {
				layer = "?";
			}
			for (var attr in xfields[i].attributes) {
				feature[attr] = xfields[i].attributes[attr];
				if (feature[attr] == undefined) {
					feature[attr] = "";
				}
			}
			if (features[layer] == undefined) {
				features[layer] = new Array();
			}
			features[layer].push(feature);
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	private function _process_featureCollection(xml:XML, obj, reqid) {
		//GML or Demis output format
		//DEMIS
		//..FEATURECOLLECTION
		//....GML.BOUNDEDBY
		//....GML.FEATUREMEMBER
		//.......LAYER
		//.......FIELD1
		//.......FIELD2
		//
		//DEEGREE/GEOSERVER
		//..FEATURECOLLECTION
		//....GML.BOUNDEDBY
		//....GML.FEATUREMEMBER
		//.......LAYERNAME
		//..........FIELD1
		//..........FIELD2
		var features:Object = new Object();
		var layer:String;
		var val:String;
		var xfeatures:Array = xml.firstChild.childNodes;
		for (var i:Number = 0; i<xfeatures.length; i++) {
			switch (xfeatures[i].nodeName.toLowerCase()) {
			case "gml:boundedby" :
				break;
			case "gml:featuremember" :
				var feature:Object = new Object();
				layer = "";
				var xfeature:Array = xfeatures[i].childNodes;
				var xfirstnode = xfeature[0];
				if (xfirstnode.nodeName.toLowerCase() == "layer") {
					//DEMIS
					layer = xfirstnode.firstChild.nodeValue;
					for (var j:Number = 1; j<xfeature.length; j++) {
						val = xfeature[j].firstChild.nodeValue;
						if (val == undefined) {
							val = "";
						}
						feature[xfeature[j].nodeName] = val;
					}
				} else {
					//DEEGREE/GEOSERVER
					layer = xfirstnode.localName;
					feature = parseFeature(xfirstnode);
				}
				if (features[layer] == undefined) {
					features[layer] = new Array();
				}
				features[layer].push(feature);
				break;
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	
	private function parseFeature(xmlNode:XMLNode):Object {
		if ((xmlNode.nodeName == "gml:boundedBy") || (xmlNode.nodeName == "gml:MultiSurface")
							  || (xmlNode.nodeName == "gml:MultiLineString")
							  || (xmlNode.nodeName == "gml:MultiPoint")
							  || (xmlNode.nodeName == "gml:Surface")
							  || (xmlNode.nodeName == "gml:LineString")
							  || (xmlNode.nodeName == "gml:Point")) {
			return null;
		}
		
		var object:Object = new Object();
		if (xmlNode.firstChild.attributes["gml:id"] != null) {
			object["featureCollection"] = "true";
		}
		
		var childNode:XMLNode = null;
		var value:Object = null;
		for (var i:Number = 0; i < xmlNode.childNodes.length; i++) {
			childNode = xmlNode.childNodes[i];
			if (childNode.firstChild.nodeType == 1) {
				value = parseFeature(childNode);
			} else {
				value = childNode.firstChild.nodeValue;
			}
			if (value == null) {
				value = "";
			}
			object[childNode.localName] = value;
		}
		return object;
	}
	
	private function _process_msGMLOutput(xml:XML, obj, reqid) {
		//Mapserver's output format
		var features:Object = new Object();
		var xOutput:XMLNode = xml.firstChild;
		var nlayers:Number = xOutput.childNodes.length;
		for (var ilayer:Number = 0; ilayer<nlayers; ilayer++) {
			var xlayer:XMLNode = xOutput.childNodes[ilayer];
			var layer:String = xlayer.nodeName.substr(0, xlayer.nodeName.length-"_layer".length);
			if (features[layer] == undefined) {
				features[layer] = new Array();
			}
			var nfeatures:Number = xlayer.childNodes.length;
			for (var ifeature:Number = 0; ifeature<nfeatures; ifeature++) {
				var xfeature:XMLNode = xlayer.childNodes[ifeature];
				var feature:Object = new Object();
				var nfields:Number = xfeature.childNodes.length;
				for (var ifield:Number = 0; ifield<nfields; ifield++) {
					var xfield:XMLNode = xfeature.childNodes[ifield];
					switch (xfield.nodeName.toLowerCase()) {
					case "gml:boundedby" :
						break;
					default :
						var fieldname:String = xfield.nodeName;
						var fieldvalue:String = xfield.firstChild.nodeValue;
						if (fieldvalue == undefined) {
							fieldvalue = "";
						}
						feature[fieldname] = fieldvalue;
						break;
					}
				}
				features[layer].push(feature);
			}
		}
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	//private function getFeatureMember(xml:XML):Object{
	//}
	private function _processCapabilities(xml:XML, obj, reqid) {
		var service:Object = new Object();
		//use an Array instead of an Object for layers
		//Reason:some WMS(group) Layers do not have a name. The name
		//was used to identify the Layer in the layers Object.
		//var layers:Object = new Object();
		var layers:Array = new Array();
		var xService = xml.firstChild.childNodes[0];
		for (var i:Number = xService.childNodes.length-1; i>=0; i--) {
			var val:String = xService.childNodes[i].firstChild.nodeValue;
			switch (xService.childNodes[i].nodeName.toLowerCase()) {
			case "name" :
				service.name = val;
				break;
			case "title" :
				service.title = val;
				break;
			case "abstract" :
				service.abstract = val;
				break;
			}
		}		
		var xCapability = xml.firstChild.childNodes[1];
		for (var i:Number = xCapability.childNodes.length-1; i>=0; i--) {
			switch (xCapability.childNodes[i].nodeName.toLowerCase()) {
			case "request" :
				break;
			case "exception" :
				break;
			case "layer" :
				layers = this._getLayers(xCapability.childNodes[i], layers);
				break;
			}
		}
		this.capService = service;
		this.capLayers = layers;
		this.capObj = obj;
		this.capReqid = reqid;
		this.events.broadcastMessage("onGetCapabilities", service, layers, obj, reqid);
	}
	private function _getLayers(xml:XML, layers:Array):Array{
		var layer:Object = new Object();
		layer.layers = new Array();
		layer.queryable = false;
		if (xml.attributes.queryable == "1") {
			layer.queryable = true;
		}
		layer.opaque = false;
		if (xml.attributes.opaque == "1") {
			layer.opaque = true;
		}
		layer.nosubsets = false;
		if (xml.attributes.noSubsets == "1") {
			layer.nosubsets = true;
		}
		layer.cascaded = false;
		if (xml.attributes.cascaded == "1") {
			layer.cascaded = true;
		}
		for (var j:Number = xml.childNodes.length; j>=0; j--) {			
			switch (xml.childNodes[j].nodeName.toLowerCase()) {
			case "name" :
				layer.name = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "title" :
				layer.title = xml.childNodes[j].firstChild.nodeValue;
				//_global.flamingo.tracer("OGWMSConnector processCapabilities layer title " + layer.title ); 
				break;
			case "abstract" :
				layer.abstract = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "srs" :
				layer.srs = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "latlonboundingbox" :
				var ext:Object = new Object();
				ext.minx = this._asNumber(xml.childNodes[j].attributes.minx);
				ext.miny = this._asNumber(xml.childNodes[j].attributes.miny);
				ext.maxx = this._asNumber(xml.childNodes[j].attributes.maxx);
				ext.maxy = this._asNumber(xml.childNodes[j].attributes.maxy);
				layer.latlonboundingbox = ext;
				break;
			case "boundingbox" :
				var ext:Object = new Object();
				ext.minx = this._asNumber(xml.childNodes[j].attributes.minx);
				ext.miny = this._asNumber(xml.childNodes[j].attributes.miny);
				ext.maxx = this._asNumber(xml.childNodes[j].attributes.maxx);
				ext.maxy = this._asNumber(xml.childNodes[j].attributes.maxy);
				ext.srs = xml.childNodes[j].attributes.SRS;
				layer.boundingbox = ext;
				break;
			case "scalehint" :
				layer.minscale = this._asNumber(xml.childNodes[j].attributes.min);
				layer.maxscale = this._asNumber(xml.childNodes[j].attributes.max);
				break;
			case "minscaledenominator" :
				layer.minscaledenominator = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "maxscaledenominator" :
				layer.maxscaledenominator = xml.childNodes[j].firstChild.nodeValue;
				break;
			case "style" :
				if (layer.styles == undefined) {
					layer.styles = new Object();
				}
				var style = new Object();
				var xstyle = xml.childNodes[j];
				for (var k:Number = 0; k<xstyle.childNodes.length; k++) {
					switch (xstyle.childNodes[k].nodeName.toLowerCase()) {
					case "name" :
						style.name = xstyle.childNodes[k].firstChild.nodeValue;
						if (layer.style == undefined) {
							layer.style = style.name;
						}
					case "title" :
						style.title = xstyle.childNodes[k].firstChild.nodeValue;
					case "legendurl" :
						var xlegendurl = xstyle.childNodes[k];
						for (var l:Number = 0; l<xlegendurl.childNodes.length; l++) {
							switch (xlegendurl.childNodes[l].nodeName.toLowerCase()) {
							case "onlineresource" :
								style.legendurl = xlegendurl.childNodes[l].attributes["xlink:href"];
								break;
							}
						}
						break;
					}
				}
				layer.styles[style.name] = style;
				break;
			case "layer" :
				layer.layers = this._getLayers(xml.childNodes[j], layer.layers);		
				break;
			}
		}
		//layers[layer.name] = layer;
		layers.push(layer);
		return (layers);
	}
	private function _changeArgs(url:String, arg:String, val:String):String {
		var amp = "&";
		if (url.indexOf("?") == -1) {
			return url+"?"+arg+"="+val;
		}
		var p1:Number = url.toLowerCase().indexOf("&"+arg.toLowerCase()+"=", 0);
		if (p1 == -1) {
			var p1:Number = url.toLowerCase().indexOf("?"+arg.toLowerCase()+"=", 0);
			if (p1 == -1) {
				return (url+amp+arg+"="+val);
			}
			var p2:Number = url.indexOf("&", p1);
			var s1:String = url.substring(0, p1);
			if (p2 == -1) {
				return (s1+"?"+arg+"="+val);
			}
			var s2:String = url.substring(p2, url.length);
			return (s1+"?"+arg+"="+val+s2);
		}
		var p2:Number = url.indexOf("&", p1);
		var s1:String = url.substring(0, p1);
		if (p2 == -1) {
			return (s1+amp+arg+"="+val);
		}
		var s2:String = url.substring(p2, url.length);
		return (s1+amp+arg+"="+val+s2);
	}
	private function _asNumber(s:String):Number {
		if (s == undefined) {
			return (undefined);
		}
		if (s.indexOf(",", 0) != -1) {
			var a:Array = s.split(",");
			s = a[0]+"."+a[1];
		}
		return (Number(s));
	}
	private function lTrim(s:String):String {
		var TAB = 9;
		var LINEFEED = 10;
		var CARRIAGE = 13;
		var SPACE = 32;
		var i = 0;
		while (s.charCodeAt(i) == SPACE || s.charCodeAt(i) == CARRIAGE || s.charCodeAt(i) == LINEFEED || s.charCodeAt(i) == TAB) {
			i++;
		}
		return s.substring(i, s.length);
	}
	private function rTrim(s:String):String {
		var TAB = 9;
		var LINEFEED = 10;
		var CARRIAGE = 13;
		var SPACE = 32;
		var i = s.length-1;
		while (s.charCodeAt(i) == SPACE || s.charCodeAt(i) == CARRIAGE || s.charCodeAt(i) == LINEFEED || s.charCodeAt(i) == TAB) {
			i--;
		}
		return s.substring(0, i+1);
	}
	private function trim(s:String):String {
		return lTrim(rTrim(s));
	}
	private function trimApos(s:String):String {
		if (s.substr(0, 6) == "&apos;") {
			s = s.substring(6, s.length);
		}
		if (s.substr(s.length-6, 6) == "&apos;") {
			s = s.substring(0, s.length-6);
		}
		return s;
	}
}
