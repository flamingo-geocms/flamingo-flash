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
* @file IdentifyResultsHTML.fla (sourcefile)
* @file IdentifyResultsHTML.swf (compiled component, needed for publication on internet)
* @file IdentifyResultsHTML.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";
//-------------------------------
//var info:Object;
var thisObj = this;
var skin = "";
var stripdatabase:Boolean = true;
var denystrangers:Boolean = true;
var wordwrap:Boolean = true;
var textinfo:String = "";
//---------------------------------
var lMap:Object = new Object();
lMap.onIdentify = function(map:MovieClip, extent:Object) {
	show();
	var s = flamingo.getString(thisObj, "startidentify", "start identify...");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	txtInfo.htmlText = "";
	textinfo = "";
};
lMap.onIdentifyProgress = function(map:MovieClip, layersindentified:Number, layerstotal:Number, sublayersindentified:Number, sublayerstotal:Number) {
	var p:String = String(Math.round(sublayersindentified/sublayerstotal*100));
	if (isNaN(p)) {
		p = "0";
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
		if (infostring != undefined) {
			//this layer is defined so convert infostring
			var stripdatabase = flamingo.getString(thisObj, stringid, "", "stripdatabase");
			for (var record in data[layerid]) {
				textinfo += convertInfo(infostring, data[layerid][record]);
				textinfo += "";
			}
		} else {
			//for this layer no infostring is defined
			if (not denystrangers) {
				textinfo += newline+"<b>"+id+"."+layerid+"</b>";
				for (var record in data[layerid]) {
					for (var field in data[layerid][record]) {
						var a = field.split(".");
						var fieldname = "["+a[a.length-1]+"]";
						textinfo += newline+fieldname+"="+data[layerid][record][field];
					}
					//txtInfo.htmlText += newline;
				}
			}
		}
	}
	txtInfo.htmlText = textinfo;
	//trace(txtInfo.htmlText)
};
function convertInfo(infostring:String, record:Object):String {
	var t:String;
	t = infostring;
	//remove all returns
	t = infostring.split("\r").join("");
	//convert \\t to \t 
	t = t.split("\\t").join("\t");
	for (var field in record) {
		var value = record[field];
		
		
		
		var fieldname = field;
		if (stripdatabase) {
			var a = field.split(".");
			var fieldname = "["+a[a.length-1]+"]";
		}
		t = t.split(fieldname).join(value);
	}
	return t;
}
lMap.onIdentifyComplete = function(map:MovieClip) {
	var s = flamingo.getString(thisObj, "identify", "identify progress [progress]%");
	s = s.split("[progress]").join("100");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	_global['setTimeout'](finish, 500);
};
function finish() {
	txtHeader.htmlText = "<span class='status'>"+flamingo.getString(thisObj, "finishidentify", "identify progress 100%")+"</span>";
}
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
lParent.onHide = function(mc:MovieClip) {
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
	var parent = this;
	while (not flamingo.isVisible(this) or parent != undefined) {
		parent = flamingo.getParent(parent);
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
* @attr stripdatabase  (defaultvalue = "true") true or false. False: the whole database fieldname will be used and have to be put between square brackets. True: the fieldname will be stripped until the last '.'
* @attr denystrangers  (defaultvalue = "true") true or false. True: only configured layerid's will be shown. False: not configured layerid's will be shown in a default way.
* @attr wordwrap  (defaultvalue = "true") True or false.
* @attr skin  (defaultvalue = "") Skin. No skins available at this moment.
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
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}