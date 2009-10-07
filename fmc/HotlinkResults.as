/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems B.V. - Abeer.Mahdi@Realworld-systems.com
* Documentation and comments updated at 7-10-2009 - Eric Richters, Realworld Systems B.V.
 -----------------------------------------------------------------------------*/
/** @component HotlinkResults
* This component shows the response of an hotlink. It just shows the url data the application get's from the server in a new webbrowser window.
* Simple and quick. 
* @file HotLinkResults.as (sourcefile)
* @file HotLinkResults.fla (sourcefile)
* @file HotLinkResults.swf (compiled component, needed for publication on internet)
* @configstyle .error Fontstyle of an error.
*/
var version:String = "3.1";

var defaultXML:String = "";
//-------------------------------
var id:String;
var results:Object;
var thisObj = this;
var UrlArray:Array = new Array();
//---------------------------------
var lMap:Object = new Object();

//obtain the URL and show the content in a new browser window when hotlinkdata becomes available
lMap.onHotlinkData = function(map:MovieClip, maplayer:MovieClip, data:Object, extent:Object) {
	for(var i=0; i< UrlArray.length; i++){
		var UrlMaplayer = UrlArray[i].id.split(".")[0];
		var UrlLayerId = UrlArray[i].id.split(".")[1];
		if(maplayer.id == UrlMaplayer)
		{
			var t = UrlArray[i].href;		
			for (var layerid in data) {			
				
				if(layerid == UrlLayerId)
				{
					for (var record in data[layerid]) 
					{
						var r:Object = data[layerid][record];				
						for (var field in r)
						{					
							if(ContainsString(t,"["+field+"]"))
							{								
								var value = r[field];
								t = t.split("["+field+"]").join(value);
								getURL(t, "_blank", "POST");
							}
						}
					}
				}
			}
		}
	}
};

//error handler for hotlink errors in map
lMap.onError = function(map:MovieClip, maplayer:MovieClip, type:String, error:String) {
	if (type == "hotlink") {
		var id = flamingo.getId(maplayer);
		var id = flamingo.getId(maplayer);
		if (results[id] == undefined) {
			results[id] = new Object();
		}
		results[id]["ERROR"] = error;
	}
};
//---------------------------------------
init();
/** @tag <tpc:HotlinkResults>  
* This tag defines an url showing hotlink results. This components listens to maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example 
* <fmc:HotlinkResults id="hotlink" left="10" top="10" width="30%" height="100%" listento="map"/> 
*   <url name="Historie weg" id="verkeersintensiteiten.3" href="[HIS_WEG]" />
*	<url name="Historie weg" id="verkeersintensiteiten.3" href="[DET_WEG]" />
* </fmc:HotlinkResults>
* @attr id  layerid, same as in the mxd.
*/
/** @tag <url>  
* This defines the url which opens in a new internet browser as a result of hotlink
*
* @attr name name of the url.
* @attr id the id of the layer which wil be hotlinked. The id is the id of the layerArcIMS or layerArcServer component "." id of the maplayer as in the mapservie.
* @attr href the url with wil be shown. The name of the field must be within '[' and ']' brackets
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>HotlinkResults "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//defaults
	this.setConfig(defaultXML);
	
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
	for (var attr in xml.attributes) {
		var attr:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (attr) {
			case "id" :
				id = val;
				break;
		}
	}
		
	//Parse URL tag
	var xUrls:Array = xml.childNodes;
	if (xUrls.length>0) 
	{
		for (var i:Number = 0; i < xUrls.length; i++) 
		{
			if (xUrls[i].nodeName.toLowerCase() == "url") 
			{
				var Url:Object = new Object();
				for (var attrUrls in xUrls[i].attributes) 
				{		
					var val:String = xUrls[i].attributes[attrUrls];
					switch (attrUrls.toLowerCase())
					{
						case "id" :
							Url.id = val;
							break;
						case "href" :
							Url.href = val;
							break;
						case "name" :
							Url.name = val;
							break;
					}
				}
				UrlArray[i] = Url;
			}
		}
	}
	flamingo.addListener(lMap, listento, this);
	txtInfo.styleSheet = flamingo.getStyleSheet(this);
	txtHeader.styleSheet = flamingo.getStyleSheet(this);
}
/*
 * This function returns true if a certain string is found in the given string otherwise false
 */
function ContainsString(myString:String, otherString:String):Boolean
{
	if (myString.indexOf(otherString) != -1) 
	{
		return true;
	} 
	return false;	
}
