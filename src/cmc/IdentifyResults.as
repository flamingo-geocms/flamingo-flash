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
/** @component IdentifyResults
* This component shows the response of an identify. It just shows the raw data the application get's from the server.
* Simple and quick. If you want to present the data in a custom way, use IdentfyResultsHtml instead.
* @file IdentifyResults.fla (sourcefile)
* @file IdentifyResults.swf (compiled component, needed for publication on internet)
* @file IdentifyResults.xml (configurationfile, needed for publication on internet)
* @configstring startidentify Text showed at the start of an identify.
* @configstring identify Text showed during an identify. The string "[progress]" will be replaced by a percentage of the progress.
* @configstring finishidentify Text showed at the finish of an identify.
* @configstring seperator Seperator between field and value.
* @configstyle .maplayer Fontstyle of maplayers.
* @configstyle .layer Fontstyle of layers.
* @configstyle .field Fontstyle of fields.
* @configstyle .value Fontstyle of values.
* @configstyle .seperator Fontstyle of the seperator
* @configstyle .error Fontstyle of an error.
*/
import tools.Logger;
var version:String = "2.0";
//-------------------------------

var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<IdentifyResults>" +
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
						"<style id='.error' font-family='verdana' font-size='11px' color='#ff6600' display='block' font-weight='normal'/>"+
						"</IdentifyResults>";
var stripdatabase:Boolean = true;
var showOnIdentify: Boolean = true;
var results:Object;
var thisObj = this;
var skin = "";
//---------------------------------
var lMap:Object = new Object();
lMap.onIdentify = function(map:MovieClip, extent:Object) {
	if(showOnIdentify) {
	  show();
	}
	var s = flamingo.getString(thisObj, "startidentify", "start identify...");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	results = new Object();
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
	//get unique id of maplayer and use this id for storing data in results object
	var id = flamingo.getId(maplayer);
	if (results[id] == undefined) {
		results[id] = data;
	} else {
		for (var layerid in data) {
			results[id][layerid] = data[layerid];
		}
	}
	refresh();
};
lMap.onError = function(map:MovieClip, maplayer:MovieClip, type:String, error:String) {
	if (type == "identify") {
		var id = flamingo.getId(maplayer);
		var id = flamingo.getId(maplayer);
		if (results[id] == undefined) {
			results[id] = new Object();
		}
		results[id]["ERROR"] = error;
	}
};
lMap.onIdentifyComplete = function(map:MovieClip) {
	var s = flamingo.getString(thisObj, "identify", "identify progress [progress]%");
	s = s.split("[progress]").join("100");
	txtHeader.htmlText = "<span class='status'>"+s+"</span>";
	_global['setTimeout'](finish, 500);
	refresh();
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
	var parent = flamingo.getParent(this);
	while (! flamingo.isVisible(parent) && parent != undefined) {
		parent._visible = true;
		parent.show();
		parent = flamingo.getParent(parent);
	}
}
/** @tag <cmc:IdentifyResults>  
* This tag defines a window for showing identify results. This components listens to maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <cmc:Window>
* @example 
* <cmc:IdentifyResults left="10" top="10" width="30%" height="100%" listento="map"/> 
* @attr stripdatabase  (defaultvalue = "true") true or false. False: the whole database fieldname will be shown. True: the fieldname will be stripped until the last '.'
* @attr skin  (defaultvalue = "") Skin. No skins available at this moment.
* @attr showonidentify  (defaultvalue = "true") If the component and all parents should be made visible on the onIdentify event.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>IdentifyResults "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
	//
	// Create text field.
	this.createTextField("txtHeader", 1, 0, 0, 100, 100);
	txtHeader.wordWrap = false;
	txtHeader.html = true;
	txtHeader.selectable = false;
	//
	this.createTextField("txtInfo", 2, 0, 0, 100, 100);
	txtInfo.wordWrap = false;
	txtInfo.html = true;
	txtInfo.multiline = true;
	this.createClassObject(mx.controls.UIScrollBar, "mSBV", 3);
	mSBV.setScrollTarget(txtInfo);
	this.createClassObject(mx.controls.UIScrollBar, "mSBH", 4);
	mSBH.horizontal = true;
	mSBH.setScrollTarget(txtInfo);
	//defaults
	this.setConfig(defaultXML);
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
	//
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
		case "stripdatabase" :
			if (val.toLowerCase() == "true") {
				stripdatabase = true;
			} else {
				stripdatabase = false;
			}
			break;
		case "showonidentify":
			showOnIdentify = val.toLowerCase() == "true";
			break;
		}
	}
	//
	flamingo.addListener(lMap, listento, this);
	txtInfo.styleSheet = flamingo.getStyleSheet(this);
	txtHeader.styleSheet = flamingo.getStyleSheet(this);
	resize();
}
function resize() {
	txtHeader.htmlText = "  ";
	var r = flamingo.getPosition(this);
	var x = r.x;
	var y = r.y;
	var w = r.width;
	var h = r.height;
	var sb = 30;
	//
	txtHeader._x = x;
	txtHeader._y = y;
	txtHeader._width = w;
	var th = txtHeader.textHeight+5;
	txtHeader._height = th;
	//
	txtInfo._x = x;
	txtInfo._y = y+th;
	txtInfo._height = h-th-sb;
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
	var sep = flamingo.getString(this, "seperator", "=");
	var a:Array;
	var f:String;
	var field:String;
	var val:String;
	var str:String = "";
	var comp:MovieClip;
	var name;
	for (var maplayer in results) {
		var comp = flamingo.getComponent(maplayer);
		name = comp.name;
		if (name == undefined) {
			name = maplayer;
		}
		str += newline+"<img src=\""+skin+"_service\"><span class='maplayer'>"+name+"</span>";
		for (var layer in results[maplayer]) {
			var layername = comp.layers[layer].name;
			if (layername == undefined) {
				layername = layer;
			}
			features = results[maplayer][layer];
			if (typeof (features) == "string") {
				str += newline+"<img src=\""+skin+"_error\"><span class='error'>ERROR: "+features+"</span>";
				//str += newline;
			} else {
				//type is object indicating we are dealing with some information
				str += newline+"<img src=\""+skin+"_layer\"><span class='layer'>"+layername+"</span>";
				for (var r = 0; r<features.length; r++) {
					str += newline;
					for (var field in features[r]) {
						f = field;
						if (stripdatabase) {
							a = f.split(".");
							f = a[a.length-1];
							//trace(field+":"+features[r][field])
						}
						var v = features[r][field];
						//deal wiht linebreak symbol
						if (v.indexOf("<br/>")>0) {
							txtInfo.htmlText = "           <span class='field'>"+f+"</span><span class='seperator'>"+sep+"</span>";
							var w = txtInfo.textWidth+2;
							v = v.split("<br/>").join("<br/><textformat tabstops='["+w+"]'>\t</textformat>");
						}
						if (v.indexOf("<br>")>0) {
							txtInfo.htmlText = "           <span class='field'>"+f+"</span><span class='seperator'>"+sep+"</span>";
							var w = txtInfo.textWidth+2;
							v = v.split("<br>").join("<br/><textformat tabstops='["+w+"]'>\t</textformat>");
						}
						str += newline+"           <span class='field'>"+f+"</span> <span class='seperator'>"+sep+"</span><span class='value'>"+v+"</span>";
					}
					//str += newline;
					str += "</p>";
				}
			}
		}
	}
	str += "</textformat>";
	txtInfo.htmlText = str;
	txtInfo.scroll = txtInfo.maxscroll;
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}