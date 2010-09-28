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
/** @component IdentifyResultsHTML
* This component shows the response of an identify in a textwindow. 
* It will show a predefined (html) string and replaces the fieldnames (between square brackets) with their actually values.
* This component uses a standard Flash textfield.
* @file	IdentifyResultsHTML.fla (sourcefile)
* @file IdentifyResultsHTML.swf (compiled component, needed for publication on internet)
* @file IdentifyResultsHTML.xml (configurationfile, needed for publication on internet)
* @change	2009-03-04 NEW attributes htmlfield and htmlwindow  
*/
var version:String = "2.0";
//-------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<IdentifyResultsHTML>" +
						"<string id='startidentify'  en='start identify...' nl='informatie opvragen...'/>" +
						"<string id='identify'  en='progress...([progress]%)' nl='voortgang...([progress]%)'/>" +
						"<string id='finishidentify'  en='' nl=''/>" +
						"<string id='seperator'  en=':' nl='='/>" +
						"<style id='.status' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
						"<style id='.maplayer' font-family='verdana' font-size='13px' color='#006600' display='block' font-weight='bold'/>" +
						"<style id='.layer' font-family='verdana' font-size='13px' color='#006600' display='block' font-weight='normal'/>" +
						"<style id='.field' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
						"<style id='.value' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
						"<style id='.seperator' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
						"<style id='.error' font-family='verdana' font-size='11px' color='#ff6600' display='block' font-weight='normal'/>" +
						"</IdentifyResultsHTML>";

var thisObj = this;
var skin = "";
var stripdatabase:Boolean = true;
var showOnIdentify: Boolean = true;
var denystrangers:Boolean = true;
var wordwrap:Boolean = true;
var textinfo:String = "";
var htmlwindow:String = null;
var htmlfield:String = null;
var seperatedfields:Array = null;
var seperator:String = ",";
var emptyWhenNotFound:Boolean = false;
var infoStrings:Object;
var showInOrder:Boolean = false;
var order:Array = null;
//---------------------------------
var lMap:Object = new Object();
lMap.onIdentify = function(map:MovieClip, extent:Object) {
	if(showOnIdentify) {
		show();
	}
	var s = flamingo.getString(thisObj, "startidentify", "start identify...");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	txtInfo.htmlText = "";
	textinfo = "";
	infoStrings = new Object();
};
lMap.onIdentifyProgress = function(map:MovieClip, layersindentified:Number, layerstotal:Number, sublayersindentified:Number, sublayerstotal:Number) {
	var p:String="0";
	if (sublayerstotal!=0){		
		p = String(Math.round(sublayersindentified/sublayerstotal*100));
		if (isNaN(p)) {
			p = "0";
		}
	}
	var s = flamingo.getString(thisObj, "identify", "identify progress [progress]%");
	s = s.split("[progress]").join(p);
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
};
lMap.onIdentifyData = function(map:MovieClip, maplayer:MovieClip, data:Object, extent:Object) {
	flamingo.raiseEvent(map, "onCorrectIdentifyIcon", map, extent);
	var layerid = flamingo.getId(maplayer);
	var mapid = flamingo.getId(map);
	var id = layerid.substring(mapid.length+1, layerid.length);
	//store info 
	//if (info[id] == undefined) {
	//info[id] = new Object();
	//}
	for (var layerid in data) {
		//store info 
		//info[id][layerid] = data[layerid];
		//
		// get string from language object
		var stringid = id+"."+layerid;
		var infostring = flamingo.getString(thisObj, stringid);
		var lyrInfo:String = "";
		if (infostring != undefined) {
			//this layer is defined so convert infostring
			var stripdatabase = flamingo.getString(thisObj, stringid, "", "stripdatabase");
			for (var record in data[layerid]) {
				var tInfo:String = convertInfo(infostring, data[layerid][record]);
				textinfo += tInfo;
				lyrInfo += tInfo;
			}
		} else {
			//for this layer no infostring is defined
			if (not denystrangers) {
				textinfo += newline+"<b>"+id+"."+layerid+"</b>";
				for (var record in data[layerid]) {
					for (var field in data[layerid][record]) {
						var a = field.split(".");
						var fieldname = "["+a[a.length-1]+"]";
						var tInfo:String = newline+fieldname+"="+data[layerid][record][field];
						textinfo += tInfo;
						lyrInfo += tInfo;
					}
				}
			}
		}
		//Store in Object for later display (showInOrder=="true"); 
		infoStrings[stringid] = lyrInfo;
	}
	if(!showInOrder){
		txtInfo.htmlText = textinfo;
	}
};
function convertInfo(infostring:String, record:Object):String {
	var t:String;
	t = infostring;
	//remove all returns
	t = infostring.split("\r").join("");
	//convert \\t to \t 
	t = t.split("\\t").join("\t");
	for (var field in record) {
		var sep:Boolean = false;
		for (var i:Number=0;i<seperatedfields.length;i++) {
			if(seperatedfields[i]==field){
				sep=true
			}
		}
		var value:String = record[field];
		//replace < with &lt; < causes problems in a htmlTextField
		var valArray:Array = value.split("<");
		if(valArray.length>1){
			value=valArray[0];
			for(var i:Number=1;i<valArray.length;i++){
				value+="&lt;" + valArray[i];
			}
		}
		var fieldname = field;
		if (stripdatabase) {
			var a = field.split(".");
			var fieldname = "["+a[a.length-1]+"]";
		}
		if(sep){
			valArray = value.split(seperator);
			var strArray:Array = t.split(fieldname);
			var from:Number = strArray[0].lastIndexOf("#sep#");
			var to:Number = t.indexOf("#sep#", from + 5);
			if(from==-1 || to==-1){
				_global.flamingo.tracer("Configuration Error:Splitter(s)(#sep#) missing in string for seperatedfield " + fieldname);
			}
			var totalStr = + t.substr(0,from) + "\r";
			for (var i:Number=0;i<valArray.length;i++){
				totalStr += t.substring(from + 5,to).split(fieldname).join(valArray[i])+ "\r"; 	
			}	
			totalStr += t.substr(to + 5);
			t=totalStr;
		} else {
			t = t.split(fieldname).join(value);
		}	
	}
	if(emptyWhenNotFound){
		t = makeEmptyWhenNotFound(t);	
	}
	return t;
}

function makeEmptyWhenNotFound(str:String):String {
	var tStr = str;
	//global.flamingo.tracer(tStr.indexOf("["));
	while(tStr.indexOf("[") != -1){
		var begin:Number = tStr.indexOf("[");
		var end:Number =  tStr.indexOf("]") + 1;
		if(end == -1 || end<begin){
			return tStr;
		}
		//replace the [] that belong to tabstops with #tab# and #/tab# 
		if(tStr.indexOf("tabstops") != -1 && (tStr.indexOf("[") - tStr.indexOf("tabstops"))<15){
			var tabs:String  = tStr.substring(begin + 1, end -1); 
			tStr = tStr.split(tStr.substring(begin,end)).join("#tab#" + tabs + "#/tab#");
		} else {
			tStr = tStr.split(tStr.substring(begin,end)).join("");
		} 
	}
	while(tStr.indexOf("#sep#") != -1){
		var begin:Number = tStr.indexOf("#sep#");
		var end:Number =  tStr.substr(begin + 5).indexOf("#sep#") + 10 + begin;
		if(end == -1 || end<begin){
			return tStr;
		}
		tStr = tStr.split(tStr.substring(begin,end)).join(""); 
	}
	//put the [] that belong to tabstops back
	while(tStr.indexOf("#tab#") != -1){
		var begin:Number = tStr.indexOf("#tab#");
		var end:Number =  tStr.indexOf("#tab#") + 5;
		if(end == -1 || end<begin){
			return tStr;
		}
		tStr = tStr.split(tStr.substring(begin,end)).join("["); 
		var begin:Number = tStr.indexOf("#/tab#");
		var end:Number =  tStr.indexOf("#/tab#") + 6;
		if(end == -1 || end<begin){
			return tStr;
		}
		tStr = tStr.split(tStr.substring(begin,end)).join("]"); 
	}
	return tStr;
	
}


lMap.onIdentifyComplete = function(map:MovieClip) {
	var s = flamingo.getString(thisObj, "identify", "identify progress [progress]%");
	s = s.split("[progress]").join("100");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	if(showInOrder){
		showOrderedText(map);
	}
	_global['setTimeout'](finish, 500);	
};

function finish() {
	txtHeader.htmlText = "<span class='status'>"+flamingo.getString(thisObj, "finishidentify", "identify progress 100%")+"</span>";

	
}

function showOrderedText(map:MovieClip):Void{
		var orderedText:String = "";
		if(order!=null){
			for(var i:Number = 0; i< order.length; i++){
				if(infoStrings[tools.Utils.trim(order[i])]!=undefined){
		
					orderedText += infoStrings[tools.Utils.trim(order[i])];
				}
			}
		} else {
			var lyrs:Array = map.getLayers();
			var mapid = flamingo.getId(map);
			for(var i:Number = 0; i< lyrs.length; i++){
				var id = lyrs[i].substring(mapid.length+1, lyrs[i].length);
				var lyr:Object = _global.flamingo.getComponent(lyrs[i]);
				var querylayerstring:String = lyr.identifyids;
				if(querylayerstring!=undefined){
					var queryLyrs:Array = querylayerstring.split(",");
					for(var j:Number = 0; j< queryLyrs.length; j++){
						var qLyr:String = queryLyrs[j];
						if(infoStrings[id +"."+qLyr]!=undefined){
							orderedText += infoStrings[id +"."+qLyr];
						}
					}
				}
			} 
		}
		if(orderedText.length == 0){
			txtInfo.htmlText = _global.flamingo.getString(this, "noresults", "no results");
		} else {
			txtInfo.htmlText = orderedText;
		}
}
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
lParent.onHide = function(mc:MovieClip) {
	txtInfo.scroll = 1;
	hideIcon();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//---------------------------------------
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(fw:MovieClip, lang:String) {
	resize();
};
flamingo.addListener(lFlamingo, "flamingo", this);
//---------------------------------------
init();
function show() {
	//make sure that this component is visible
	_visible = true;
	var parent = flamingo.getParent(this);
	while (not flamingo.isVisible(parent) and parent != undefined) {
		parent.show();
		parent._visible = true;
	}
}
/** @tag <fmc:IdentifyResultsHTML>  
* This tag defines a window for showing identify results. It listens to maps. Use standard string and style tags for configuring the text.
* The id's of the string tags are the id's of the the maplayer followed by a "." and completed with the layer id. See example.
* Use CDATA tags to avoid interferance with the config xml. See example.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
* <fmc:IdentifyResultsHTML  width="30%" height="100%" right="right" listento="map" >
*        <style id=".bold" font-family="verdana" font-size="18px" color="#333333" display="block" font-weight="bold"/>
*        <style id=".normal" font-family="verdana" font-size="11px" color="#333333" display="block" font-weight="normal"/>
*        <style id=".uitleg" font-family="verdana" font-size="11px" color="#0033cc" display="block" font-weight="normal" font-style="italic"/>
*
*        <string id="risicokaart.p_BRZO" stripdatabase="true">
*          <nl>
*				<span class='normal'>
*                <img src="stuff/legenda_pub/obj_BRZO3.swf" width='18' height='18' hspace='5' vspace='5'><span class='bold'>BRZO</span>
*                <span class='uitleg'>In het Besluit Risico's Zware Ongevallen (BRZO 1999) staan criteria die aangeven welke bedrijven een risico van zware ongevallen hebben...<u>lees meer</u></span>
*
*                <textformat tabstops='[20,150,100]'>
*                \tBevoegd gezag\t[BEVOEGD_GEZAG]
*                \tNaam inrichting\t[NAAM_INRICHTING]
*                \tStraat\t[STRAAT]
*                \tHuisnummer\t[HUISNUMMER]
*                \tPlaats\t[PLAATS]
*                \tGemeente\t[GEMEENTE]
*                \tMilieuvergunning\t[WM_VERGUNNING]
*               </textformat>
*               </span>
*             
*           </nl>
*         </string>
* </fmc:IdentifyResultsHTML>
* @example 
* Example of an identify configuration in which a asfunction is called getHtmlText with
* an url to a server component (in this case a jsp page) that returns html text to the viewer.
* The html text will be shown in a TextArea component (attr htmlfield). This component might be within 
* a Window component (attr htmlwindow) that opens when the html text is loaded. 
* <fmc:Window skin="g" top="60" right="right -100" width="400" height="300" bottom="-70"
*        canresize="true" canclose="true" title="Identify results" visible="false">
*        <fmc:IdentifyResultsHTML id="identify" width="100%" height="100%" listento="map" htmlwindow="htmlwindow" clobfield="clobfield">
*			...
*            <string id="cultuurhistorie.monumenten" stripdatabase="true">
*                <en>
*                    <![CDATA[<span class='normal'>
*					<span class='bold'>Monumenten</span>
*					<textformat tabstops='[150]'>
*						Archief nummer\t[ARCHIEF_NR]
*						Mon nummer\t[MON_NR]
*						<a href="asfunction:getHtmlText,http://gisopenbaar.overijssel.nl/bach/BachGetCLOB.jsp?nr=[MON_NR]&clob_column=toelichting" target="_blank"><u>Klik hier voor toelichting</u></a>
*					</textformat>
*					</span>
*					]]>
*                </en>
*            </string>
*         </fmc:IdentifyResultsHTML>
*</fmc:Window>
*<fmc:Window id="htmlwindow" skin="g" top="100" right="right -50" width="400" height="300" bottom="-70"
*        canresize="true" canclose="true" title="Toelichting" visible="false">
*	<fmc:Textarea id="htmlfield" width="100%" height="100%"/>
*</fmc:Window>
* @attr stripdatabase  (defaultvalue = "true") true or false. False: the whole database fieldname will be used and have to be put between square brackets. True: the fieldname will be stripped until the last '.'
* @attr denystrangers  (defaultvalue = "true") true or false. True: only configured layerid's will be shown. False: not configured layerid's will be shown in a default way.
* @attr wordwrap  (defaultvalue = "true") True or false.
* @attr skin  (defaultvalue = "") Skin. No skins available at this moment.
* @attr showonidentify  (defaultvalue = "true") If the component and all parents should be made visible on the onIdentify event.
* @attr htmlwindow (no defaultvalue) id of the Window component that will open when the asfunction openHtml is called.
* This window must contain the TextArea which is reffered to in the htmlfield attribute.   
* @attr htmlfield  (no defaultvalue) id of a TextArea component in which the html text will be shown. The TextArea can be anywhere in
* the flamingo viewer. 
* @attr seperatedfields (no defaultvalue) A (list of) field(s) for which the value is a seperated string. Use the attribute seperator 
* to indicate the seperator character(s). For the seperated values part of the string will be repeated. This part is indicated by
* "#sep#" at the start and the end. 
* For example: 
* \tplanteksten:#sep#\t<a href="http://www.ruimtelijkeplannen.nl/documents/[identificatie]/[verwijzingNaarTekst]" target="_blank"><u>[verwijzingNaarTekst]</u></a>#sep#       
* @attr seperator (defaultvalue = ",") Indicates the seperator character(s) for the seperatedfields.
* @attr emptywhennotfound (defaultvalue = false) Shows the output value as an empty string when the response doesnot contain the requested field.  
* @attr showinorder (defaultvalue = false) When true the identify output will be shown in the order as configured in the attribute stringorder or 
* in case the stringorder attribute is not present as configured in the map configuration (layer order) and layer configuration (identifyIds or query_layers attribute). 
* Ordering using layer and identifyIds/query_layers configuration is only possible for LayerArcIMS, LayerArcServer and for LayerOGWMS layers when the WMS layername (as configured in the LayerOGWMS) 
* corresponds with the WFS Featuretype name (as configured in the IdentifyResultsHTML).   
* @attr stringorder A commaseperated string of stringids indicating the order in wich the identify results will be shown.
* The results will only be shown when all the results are received from the server.
* @example 
* <fmc:IdentifyResultsHTML id="identifyResults" wordwrap="false" showinorder="true"
*    stringorder="bpVoorontwerp.Bestemmingsplangebied
*    ,bpVoorontwerp.Enkelbestemming
*    ,bpVoorontwerp.Dubbelbestemming
*    ,bpVoorontwerp.Bouwvlak
*    ,bpVoorontwerp.Gebiedsaanduiding
*    ,bpVoorontwerp.Lettertekenaanduiding
*    ,bpVoorontwerp.Bouwaanduiding
*    ,bpVoorontwerp.Functieaanduiding
*    ,bpVoorontwerp.Maatvoering
*    ,bpVoorontwerp.Figuur">
* 
* 	<string id="bpVoorontwerp.Enkelbestemming" stripdatabase="true">
*    	....
* 	</string>  
* 	...
*	<string id="bpVoorontwerp.Bestemmingsplangebied" stripdatabase="true">
*    	....
* 	</string>  
* </fmc:IdentifyResultsHTML>
*/

function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>IdentifyResultsHTML "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//
	this.createTextField("txtHeader", 1, 0, 0, 100, 100);
	txtHeader.wordWrap = true;
	//false;
	txtHeader.html = true;
	txtHeader.selectable = false;
	//
	this.createTextField("txtInfo", 2, 0, 0, 100, 100);
	txtInfo.wordWrap = false;
	txtInfo.html = true;
	txtInfo.multiline = true;
	//
	this.createClassObject(mx.controls.UIScrollBar, "mSBV", 3);
	mSBV.setScrollTarget(txtInfo);
	//
	this.createClassObject(mx.controls.UIScrollBar, "mSBH", 4);
	mSBH.horizontal = true;
	mSBH.setScrollTarget(txtInfo);
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
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "skin" :
			skin = val;
			break;
		case "wordwrap" :
			if (val.toLowerCase() == "true") {
				wordwrap = true;
			} else {
				wordwrap = false;
			}
			break;
		case "stripdatabase" :
			if (val.toLowerCase() == "true") {
				stripdatabase = true;
			} else {
				stripdatabase = false;
			}
			break;
		case "denystrangers" :
			if (val.toLowerCase() == "true") {
				denystrangers = true;
			} else {
				denystrangers = false;
			}
			break;
		case "htmlwindow":
			htmlwindow = val;
			break;
		case "htmlfield":
			htmlfield = val;
			break;	
		case "showonidentify":
			showOnIdentify = val.toLowerCase() == "true";
			break;	
		case "seperatedfields":	
			seperatedfields=val.split(","); 
			break;
		case "seperator":	
			seperator=val; 
			break;
		case "emptywhennotfound":
			if (val.toLowerCase() == "true") {
				emptyWhenNotFound=true;
			}	
			break;		
		case "showinorder":
			if (val.toLowerCase() == "true") {
				showInOrder=true;
			}	
			break;
		case "stringorder":
			order = val.split(",");
		}			

	}
	//    
	txtInfo.styleSheet = flamingo.getStyleSheet(this);
	txtInfo.wordWrap = wordwrap;
	txtHeader.styleSheet = flamingo.getStyleSheet(this);
	flamingo.addListener(lMap, listento, this);
	//
	resize();
}
/**
* Adds a string object described by xml.
* @param xml Object XML description of the string object.
* @return Boolean True or false. Indicates succes or failure. 
*/	
function addStringObject(xml:Object):Boolean {
	flamingo.setString(xml, this.strings);
	return true;
}
/**
* Removes a string object described by it's id.
* @param id String id of the string object.
* @return Boolean True or false. Indicates succes or failure. 
*/	
function removeStringObject(stringid:String):Boolean {
	if (this.strings[stringid] != null) {
		delete this.strings[stringid];
		return true;
	} else {
		return false;
	}
}
/**
* Removes all string objects.
* @return Boolean True or false. Indicates succes or failure. 
*/	
function removeAllStringObjects():Boolean {
	if (this.strings != null) {
		delete this.strings;
		return true;
	} else {
		return false;
	}
}
function resize() {
	txtHeader.htmlText = "  ";
	var r = flamingo.getPosition(this);
	var x = r.x;
	var y = r.y;
	var w = r.width;
	var h = r.height;
	var sb = 16;
	//
	txtHeader._x = x;
	txtHeader._y = y;
	txtHeader._width = w;
	var th = txtHeader.textHeight+5;
	txtHeader._height = th;
	//
	txtInfo._x = x;
	txtInfo._y = y+th;
	txtInfo._height = h-th;
	txtInfo._width = w-sb;
	//
	mSBV.setSize(sb, h-th-sb);
	mSBV.move(x+w-sb, y+th);
	//
	mSBH.setSize(w-sb, sb);
	mSBH.move(x, y+h-sb);
	//
	var mc = createEmptyMovieClip("mLine", 10);
	with (mc) {
		lineStyle(0, "0x999999", 60);
		moveTo(x, y+th);
		lineTo(x+w, y+th);
	}
}
function hideIcon() {
	for (var i = 0; i<listento.length; i++) {
		var map = flamingo.getComponent(listento[i]);
		map.cancelIdentify();
		flamingo.raiseEvent(map, "onHideIdentifyIcon", map);
	}
}
function refresh() {
	txtInfo.htmlText = str;
	txtInfo.scroll = txtInfo.maxscroll;
}

function getHtmlText(url:String):Void {
	xmlServer = new XML();
  	xmlResponse = new XML();
  	xmlResponse.onLoad = onLoadHtmlText;
  	xmlServer.sendAndLoad(url, xmlResponse);
}  

function onLoadHtmlText(success:Boolean):Void { 
  	if (htmlfield != null) {
  		if (htmlwindow != null) {
			var htmlWindow:Object = flamingo.getComponent(htmlwindow);
			htmlWindow.setVisible(true);
		}
		var htmlField:Object = flamingo.getComponent(htmlfield);
		htmlField.setText(xmlResponse.toString());
	} else {
		flamingo.tracer("Configuration Error:No TextArea (attr htmlfield) configured to show html"); 
	}
  }


/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}