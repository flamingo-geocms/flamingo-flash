/*-----------------------------------------------------------------------------
Copyright (C) 2007  Roy Braam (B3Partners BV, http://www.b3partners.nl
*/

dynamic class OGWFSConnector {
	//meta
	var version:String = "2.0";
	//-----------------------
	private var busy:Boolean = false;
	private var events:Object;
	var requestid:Number = 0;
	var url:String;
	var requesttype:String;
	var responsetime:Number;
	var response:String
	var error:String;
	var featureTypes:Object = new Object();
	//TODO: get version with cap.
	var wfsVersion:String;
	var geomName:String;
	var srs:String;
	var maxFeatures:String='0';
	var wfsLayers:String;
	var wfsUrl:String;
	var namespaces:Object;
	
	
	//some constants
	private static var DEBUG:Boolean=false;
	private static var WMS_VERSION:String="VERSION";
	private static var WMS_REQUEST:String="REQUEST";
	private static var WMS_LAYERS:String="LAYERS";
	private static var WMS_QUERY_LAYERS:String="QUERY_LAYERS";
	private static var WMS_INFO_FORMAT:String="INFO_FORMAT";
	private static var WMS_FEATURE_COUNT:String="FEATURE_COUNT";
	private static var WMS_UPDATESEQUENCE:String="UPDATESEQUENCE";
	private static var WMS_MAX_FEATURES:String="MAX_FEATURES";
	private static var WMS_STYLES:String="STYLES";
	private static var WMS_SRS:String="SRS";
	private static var WMS_BBOX:String="BBOX";
	private static var WMS_WIDTH:String="WIDTH";
	private static var WMS_HEIGHT:String="HEIGHT";
	private static var WMS_FORMAT:String="FORMAT";
	private static var WMS_TRANSPARENT:String="TRANSPARENT";
	private static var WMS_BGCOLOR:String="BGCOLOR";
	private static var WMS_EXCEPTIONS:String="EXCEPTIONS";
	private static var WMS_TIME:String="TIME";
	private static var WMS_ELEVATION:String="ELEVATION";
	private static var WMS_X:String="X";
	private static var WMS_Y:String="Y";
	private static var WMS_SLD:String="SLD";
	private static var WMS_SLD_BODY:String="SLD_BODY";
	
	private static var WFS_TYPENAME:String="TYPENAME";
	
	private static var WFS_REQUEST_GETFEATURE:String="GETFEATURE";
	private static var WFS_REQUEST_DESCRIBEFEATURETYPE:String="DESCRIBEFEATURETYPE";

	
	//-----------------------------------
	function addListener(listener:Object) {
		events.addListener(listener);
	}
	function removeListener(listener:Object) {
		events.removeListener(listener);
	}
	function OGWFSConnector(server:String) {
		setWfsUrl(server);
		this.url=server;
		events = new Object();
		AsBroadcaster.initialize(events);
	}
	/**
	Do a WFS GetFeature Request.
	*/
	function getFeature(url:String, args:Object, conditions:Object):Number {
		this.geomName=geomName;
		if (args == undefined) {
			var args:Object = new Object();
		}
		args.REQUEST = "getFeature";
		return (this._request(url, args, conditions));
	}
	/**
	Do a describeFeatureType request (not used or tested yet)
	*/
	function describeFeatureType(url:String, args:Object):Number {
		log ("function describeFeatureType");
		if (args == undefined) {
			var args:Object = new Object();
		}
		args.REQUEST = "describeFeatureType";
		return (this._request(url, args,undefined));
	}
	/**
	The request
	*/
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
		//****
		this.url = req_url;			
		this.requesttype = args.REQUEST;
		this.events.broadcastMessage("onRequest", this);
		//flamingo.tracer("A:"+args.REQUEST.toUpperCase() )
		var xrequest:XML = new XML();
		xrequest.ignoreWhite = true;
		var thisObj:Object = this;
		xrequest.onLoad = function(success:Boolean) {
			log('Onload XML');
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
					case WFS_REQUEST_GETFEATURE :
						thisObj._processGetFeature(this, obj, thisObj.requestid);
						break;	
					case WFS_REQUEST_DESCRIPEFEATURETYPE :
						thisObj._processDescribeFeatureType(this, obj, thisObj.requestid);
						break;	
					}
				}
			} else {
				log("error loading xml");
				thisObj.error = "connection failed...";
				thisObj.events.broadcastMessage("onResponse", thisObj);
				thisObj.events.broadcastMessage("onError", thisObj.error, obj, reqid);
			}
			thisObj.busy = false;
			// do some cleaning
			delete this;
		};
		var starttime:Date = new Date();
		var hostUrl:String;
		if (wfsUrl!=undefined){
			hostUrl=wfsUrl;
		}
		else{
			hostUrl= getClearUrl(req_url);
		}
		//log("whats the diverence??: "+url+" with: "+hostUrl);
		var requestXml:XML= createRequestXml(req_url,obj);					
		log ("The Request: "+requestXml.toString());
		log("The URL: "+hostUrl);
		requestXml.contentType="text/xml";
		requestXml.sendAndLoad(hostUrl,xrequest);
		return (this.requestid);
	}
	/**
	Process the returned getFeature
	*/
	private function _processGetFeature(xml:XML, obj, reqid) {
		log("Process getFeature");
		log("the XML: "+xml.toString());
		var features:Object = new Object();
		var featureMembers:Array = xml.firstChild.childNodes;		
		//iterate layers
		for (var i =0; i < featureMembers.length; i++){
			var feature:Object = new Object();
			var featureName:String=featureMembers[i].firstChild.nodeName;
			if (featureName.toLowerCase()!="gml:envelope"){
				featureName=removePrefix(featureName);
				log ("FeatureName: "+featureName);
				if (features[featureName]==undefined){
					features[featureName]= new Array();
				}			
				for (var a=0; a < featureMembers[i].firstChild.childNodes.length; a++){
					var atr:XMLNode = featureMembers[i].firstChild.childNodes[a];					
					if (atr.nodeName.toLowerCase()=="gml:boundedby"){	
						if (atr.firstChild.nodeName.toLowerCase()=="gml:envelope" || atr.firstChild.nodeName.toLowerCase()=="gml:box"){
							var min:String;
							var max:String;
							if(atr.firstChild.firstChild.nodeName.toLowerCase()=="gml:coordinates"){
								if(atr.firstChild.childNodes[0].nodeType==1){
									min=atr.firstChild.childNodes[0].firstChild.nodeValue.split(" ")[0];
									max=atr.firstChild.childNodes[0].firstChild.nodeValue.split(" ")[1];								
								}else{
									min=atr.firstChild.childNodes[0].nodeValue.split(" ")[0];
									max=atr.firstChild.childNodes[0].nodeValue.split(" ")[1];
								}
							}
							else{
								if(atr.firstChild.childNodes[0].nodeType==1){
									min=atr.firstChild.childNodes[0].firstChild.nodeValue;
									max=atr.firstChild.childNodes[1].firstChild.nodeValue;
								}else{
									min=atr.firstChild.childNodes[0].nodeValue;
									max=atr.firstChild.childNodes[1].nodeValue;
								}																
							}
							feature['BOUNDEDBY']=min+','+max;	
												
						//version 1.0.0
						}
					}else if(atr.nodeName.indexOf("gml:")>0){
						//a geom object.... Ignore
					}
					else{					
						var fieldValue:String= atr.firstChild.nodeValue;
						var fieldKey=removePrefix(atr.nodeName);
						if (fieldValue==undefined){
							fieldValue="";
						}
						feature[fieldKey]=trim(fieldValue);
					}				
				}
				features[featureName].push(feature);
			}
		}		
		this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
	}
	/**
	Process the returned DescribeFeature request. (NOT TESTED)
	*/
	private function _processDescribeFeatureType(xml:XML, obj, regid){
		log("process DescribeFeatureType");
		var elements:Array = xml.firstChild.childNodes;
		var describedElements:Array = new Array();
		//Get all elements.
		for (var i=0; i < elements.length; i ++){
			if (elements[i].localName == "element"){
				var id:String =elements[i].attributes.name;
				if (featureTypes[id]==undefined){
					featureTypes[id]=new Object();
				}if (elements[i].attributes.type.split(':').length > 1){
					featureTypes[id].type=elements[i].attributes.type.split(':')[1];
					featureTypes[id].typePrefix=elements[i].attributes.type.split(":")[0];
				}else{
					featureTypes[id].type=elements[i].attributes.type;
				}
				featureTypes[id].name=id;
			}
		}
		for (var i =0; i < elements.length; i++){
			if (elements[i].localName=="complexType"){
				for (var f=0; f<featureTypes.length; f++){
					if (featureTypes[f].type == elements[i].attributes.name){
						var attributes:Array =elements[i].firstChild.firstChild.firstChild.childNodes;
						var geomName:String;
						for (var a =0; a < attributes.length && geomName==undefined; a++){
							if (attributes[a].attributes.type=="gml:GeometryPropertyType"){
								geomName=attributes[a].attributes.name;
							}
						}
						featureTypes[f].geometryName=geomName;
						describedElements.push(featureTypes[f]);						
					}
				}				
			}
		}
		this.events.broadcastMessage("onDescribeFeatureType", describedElements, obj, reqid);
	}
	/**
	Create the request XML body. Not
	*/
	private function createRequestXml(wmsUrl:String, conditions:Object):XML{
		log("function createRequestXml(wmsUrl:String):XML");
		var reqXml:XML;		
		var req=getParam(wmsUrl,WMS_REQUEST);
		if (req.toUpperCase() == WFS_REQUEST_GETFEATURE){
			var layerArray:Array;
			if (wfsLayers!=undefined){
				layerArray=wfsLayers.split(",");
			}else{
				layerArray=getParam(wmsUrl,WMS_QUERY_LAYERS).split(",");
			}
			if (layerArray.length > 0){
				if (conditions.key!=undefined && conditions.value!=undefined){
					return createGetFeatureRequest(wfsVersion,layerArray,conditions);
				}else{
					var bbox:String = getParam(wmsUrl,WMS_BBOX);
					log("Bbox in create : "+bbox);
					return createGetFeatureRequest(wfsVersion,layerArray,string2Extent(bbox));
				}
			}
		}else if(req.toUpperCase() == WFS_REQUEST_DESCRIBEFEATURETYPE){
			log(WFS_REQUEST_DESCRIBEFEATURETYPE);
			var typeNamesString:String=getParam(wmsUrl,WFS_TYPENAME);
			log (typeNamesString);
			return createDescribeFeatureTypeRequest(wfsVersion, typeNamesString.split(','));
		}else{
			log("REQUEST NOT SUPPORTED");
			return reqXml;
		}
	}
	/**
	Create the DescribeFeatureTypeRequest Body
	*/
	private function createDescribeFeatureTypeRequest(version:String, typeNames:Array):XML{
		log (typeNames.length);
		var reqXml:XML= new XML();
		var reqString:String;
		reqString='<?xml version="1.0" encoding="UTF-8"?>';
		reqString+='<wfs:DescribeFeatureType service="WFS" version="'+version+'" ';
		reqString+='xmlns:wfs="http://www.opengis.net/wfs" xmlns:gml="http://www.opengis.net/gml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
		for (var pref in namespaces){
			reqString+=' xmlns:'+pref+'="'+namespaces[pref]+'"';
		}
		reqString+='>';
		for (var i =0; i < typeNames.length; i++){
			if (typeNames[i] != undefined){
				reqString+='<TypeName>'+typeNames[i]+'</TypeName>';
			}
		}
		reqString+='</DescribeFeatureType>';
		log("The describeFeatureType String: "+reqString);
		reqXml.parseXML(reqString);
		return reqXml;
	}
	/**
	Create the GetFeatureRequest Body
	*/
	private function createGetFeatureRequest(version:String, types:Array, conditions:Object):XML{
		var reqXml:XML= new XML();
		var reqString:String;
		reqString='<?xml version="1.0" encoding="UTF-8"?>';
		reqString+='<wfs:GetFeature service="WFS" version="'+version+'" ';
		if (maxFeatures>0){
			reqString+='maxFeatures="'+maxFeatures+'" ';
		}
		reqString+='xmlns:wfs="http://www.opengis.net/wfs" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" ';
		//reqString+='xmlns:app="http://www.deegree.org/app" ';		
		for (var pref in namespaces){
			reqString+=' xmlns:'+pref+'="'+namespaces[pref]+'"';
		}
		reqString+='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
		var multiKeys:Array;
		if (conditions.key!=undefined && conditions.key.indexOf(",")>0){
			multiKeys=conditions.key.split(",");
		}
		for (var i=0 ; i < types.length; i++){
			if (types[i]!=undefined){
				reqString+='<wfs:Query typeName="'+types[i]+'"';				
				if (srs!=undefined && srs.toUpperCase().indexOf('EPSG:')!=-1 && version=="1.1.0"){
					reqString+=' srsName="'+srs+'" ';
				}
				reqString+='>'
				//Create filter	with bbox
				if (conditions.minx!=undefined && conditions.maxx!=undefined && conditions.miny!=undefined && conditions.maxy!=undefined){
					if (version== '1.0.0'){	
						reqString+='<ogc:Filter>';	
						reqString+='<ogc:BBOX>';
						reqString+='<ogc:PropertyName>'+geomName+'</ogc:PropertyName>';
						
						reqString+='<gml:Box';
						if (srs!=undefined && srs.toUpperCase().indexOf('EPSG:')!=-1){
							reqString+=' srsName="'+srs+'"';
						}
						reqString+='>';
						reqString+='<gml:coordinates>'+conditions.minx+','+conditions.miny+' '+conditions.maxx+','+conditions.maxy;					
						reqString+='</gml:coordinates></gml:Box>';
						reqString+='';
						reqString+='</ogc:BBOX>';
						reqString+='</ogc:Filter>';
					}else if(version=='1.1.0'){
						//TODO: Test
						reqString+='<ogc:Filter>';	
						reqString+='<ogc:BBOX>';
						reqString+='<ogc:PropertyName>'+geomName+'</ogc:PropertyName>';
						
						/*reqString+='<gml:Box';
						if (srs!=undefined && srs.toUpperCase().indexOf('EPSG:')!=-1){
							reqString+=' srsName="'+srs+'"';
						}
						reqString+='>';
						reqString+='<gml:coordinates>'+conditions.minx+','+conditions.miny+' '+conditions.maxx+','+conditions.maxy;					
						reqString+='</gml:coordinates></gml:Box>';
						reqString+='';*/
						reqString+='<gml:Envelope><gml:lowerCorner>';
						reqString+=conditions.minx+' '+conditions.miny;
						reqString+='</gml:lowerCorner><gml:upperCorner>';
						reqString+=+conditions.maxx+' '+conditions.maxy;
						reqString+='</gml:upperCorner></gml:Envelope>';						
						reqString+='</ogc:BBOX>';
						reqString+='</ogc:Filter>';
						
					}
				//create filter with key value pair
				}else if (conditions.key!=undefined && conditions.value!=undefined){						
					reqString+='<ogc:Filter>';						
					//version 1.0.0 has no matchCase attribute
					reqString+="<ogc:PropertyIsLike wildCard='*' singleChar='.' escape='!'";
					reqString+=" matchCase='false'";					
					reqString+=">";
					if (multiKeys!=undefined){
						if (i < multiKeys.length){
							reqString+='<ogc:PropertyName>'+multiKeys[i]+'</ogc:PropertyName>';
						}else{
							reqString+='<ogc:PropertyName>'+multiKeys[multiKeys.length-1]+'</ogc:PropertyName>';
						}
					}else{
						reqString+='<ogc:PropertyName>'+conditions.key+'</ogc:PropertyName>';
					}
					reqString+='<ogc:Literal>'+conditions.value+'</ogc:Literal>';
					reqString+='</ogc:PropertyIsLike>';
					reqString+='</ogc:Filter>';
				}									
				reqString+='</wfs:Query>';					
			}
		}		
		reqString+='</wfs:GetFeature>';		
		reqXml.parseXML(reqString);
		return reqXml;
	}
	function setWfsVersion(s:String){
		wfsVersion=s;
	}
	function setGeomName(s:String){
		geomName=s;
	}
	function setSrs(s:String){
		srs=s;
	}
	function setMaxFeatures(s:String){
		maxFeatures=s;
	}
	function setWfsLayers(s:String){
		wfsLayers=s;
	}
	function setWfsUrl(s:String){
		wfsUrl=s;
	}
	function setNamespaces(n:Object){
		namespaces=n;
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
	
	private function getParam(url:String, key:String):String{		
		var startIndex:Number;
		var endIndex:Number;
		var returnValue:String;
		startIndex=url.toLowerCase().indexOf('&'+key.toLowerCase()+'=');
		if (startIndex < 0){
			startIndex=url.toLowerCase().indexOf('?'+key.toLowerCase()+'=');
		}
		if(startIndex>0){
			endIndex=url.indexOf('&',startIndex+1);
			if (endIndex<0){
				endIndex=url.length;
			}						
			returnValue=url.slice(startIndex+2+key.length,endIndex);
		}		
		return returnValue;
	}
	private function removeParam(originalUrl:String, key:String):String{
		var startIndex:Number;
		var endIndex:Number;
		var returnValue:String;
		startIndex=originalUrl.toLowerCase().indexOf('&'+key.toLowerCase()+'=');
		if (startIndex < 0 ){
			startIndex=originalUrl.toLowerCase().indexOf('?'+key.toLowerCase()+'=');
		}
		if(startIndex>0){
			endIndex=originalUrl.indexOf('&',startIndex+1);
			returnValue=originalUrl.substring(0,startIndex);
			if (endIndex>0){
				returnValue+=originalUrl.substring(endIndex,originalUrl.length);				
			}
		}else{
			returnValue=originalUrl;
		}
		return returnValue;
	}
	private function log(toLog:Object){
		if (DEBUG){
			trace(new Date()+ " OGWFSConnector "+ +toLog.toString());
		}
	}
	private function getClearUrl(originalUrl:String):String{		
		var	clearUrl:String=removeParam(originalUrl,WMS_VERSION);
		clearUrl=removeParam(clearUrl,WMS_VERSION);
		clearUrl=removeParam(clearUrl,WMS_REQUEST);
		clearUrl=removeParam(clearUrl,WMS_LAYERS);
		clearUrl=removeParam(clearUrl,WMS_STYLES);
		clearUrl=removeParam(clearUrl,WMS_SRS);
		clearUrl=removeParam(clearUrl,WMS_BBOX);
		clearUrl=removeParam(clearUrl,WMS_WIDTH);
		clearUrl=removeParam(clearUrl,WMS_HEIGHT);
		clearUrl=removeParam(clearUrl,WMS_FORMAT);
		clearUrl=removeParam(clearUrl,WMS_TRANSPARENT);
		clearUrl=removeParam(clearUrl,WMS_BGCOLOR);
		clearUrl=removeParam(clearUrl,WMS_EXCEPTIONS);
		clearUrl=removeParam(clearUrl,WMS_TIME);
		clearUrl=removeParam(clearUrl,WMS_ELEVATION);
		clearUrl=removeParam(clearUrl,WMS_SLD);
    	clearUrl=removeParam(clearUrl,WMS_SLD_BODY);
		clearUrl=removeParam(clearUrl,WMS_QUERY_LAYERS);
		clearUrl=removeParam(clearUrl,WMS_INFO_FORMAT);
		clearUrl=removeParam(clearUrl,WMS_FEATURE_COUNT);
		clearUrl=removeParam(clearUrl,WMS_MAX_FEATURES);
		clearUrl=removeParam(clearUrl,WMS_UPDATESEQUENCE);
		clearUrl=removeParam(clearUrl,WMS_X);
		clearUrl=removeParam(clearUrl,WMS_Y);
		
		//wfs
		clearUrl=removeParam(clearUrl,WFS_TYPENAME);		
		return clearUrl;		
	}
	private function removePrefix(original:String):String{
		if (original.indexOf(":")>0){
			return original.split(":")[1];
		}else{
			return original;
		}
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
	var TAB   = 9;
	var LINEFEED = 10;
	var CARRIAGE = 13; 
	var SPACE = 32; 	
	function trim(string):String {
       var s:String = new String(string);		
	   var i = 0;   
	   while(s.charCodeAt(i) == SPACE 
		  || s.charCodeAt(i) == CARRIAGE 
		  || s.charCodeAt(i) == LINEFEED 
		  || s.charCodeAt(i) == TAB) {
		  i++;
	   }   
	   s= s.substring(i,s.length);
	   
	   i = s.length - 1;
		  
	   while(s.charCodeAt(i) == SPACE 
		   || s.charCodeAt(i) == CARRIAGE 
		   || s.charCodeAt(i) == LINEFEED 
		   || s.charCodeAt(i) == TAB) {
		  i--;
	   }		  
	   return s.substring(0,i+1);
	} 
}