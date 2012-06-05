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
/** @component cmc:Debugger
* Debugger for debugging ArcIMSlayers and OGWMSLayers. 
* It shows the requestes and responses that go up and down the server.
* @file Debugger.fla (sourcefile)
* @file Debugger.swf (compiled component, needed for publication on internet)
* @file Debugger.xml (configurationfile, needed for publication on internet)
* @configstring on on string. 
* @configstring off off string.
* @configstyle .onoff fontstyle of on/off string
* @configstyle .layer fontstyle of the layer.
* @configstyle .event fontstyle of the event.
* @configstyle .url fontstyle of the url.
* @configstyle .request fontstyle of the reques.
* @configstyle .response fontstyle of the response.
* @configstyle .error fontstyle of an error.
* @configstyle .attribute fontstyle of other attributes.
* @configstyle .default fontstyle of all other strings.
*/
var version:String = "2.0";
var off:Boolean = false;
//-------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<Debugger>" +
							"<string id='on'  en='debugger on' nl='debugger aan'/>" +
							"<string id='off'  en='debugger off' nl='debugger uit'/>" +
							"<style id='.onoff' font-family='verdana' font-size='13px' color='#3366cc' display='block' font-weight='bold'/>" +
							"<style id='.default' font-family='verdana' font-size='11px' color='#666666' display='block' font-weight='normal'/>" +
							"<style id='.layer' font-family='verdana' font-size='13px' color='#333333' display='block' font-weight='bold'/>" +
							"<style id='.event' font-family='verdana' font-size='12px' color='#666666' display='block' font-weight='bold'/>" +
							"<style id='.attribute' font-family='verdana' font-size='10px' color='#666666' display='block' font-weight='normal'/>" +
							"<style id='.value' font-family='verdana' font-size='11px' color='#666666' display='block' font-weight='normal'/>" +
							"<style id='.url' font-family='verdana' font-size='11px' color='#666666' display='block' font-weight='normal' font-style='italic'/>" +
							"<style id='.request' font-family='verdana' font-size='11px' color='#990099' display='block' font-weight='normal'/>" +
							"<style id='.response' font-family='verdana' font-size='11px' color='#009900' display='block' font-weight='normal'/>" +
							"<style id='.error' font-family='verdana' font-size='11px' color='#ff0000' display='block' font-weight='normal'/>" +
						"</Debugger>"							;
var debugobjects:Object = new Object();
//---------------------------------
var lObject:Object = new Object();
lObject.onIdentify = function(layer:MovieClip, identifyextent:Object) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		debugobjects[layerid] = new Object();
		debugobjects[layerid]["onIdentify"] = new Object();
		debugobjects[layerid]["onIdentify"].identifyextent = identifyextent.toString();
		debugobjects[layerid]["onIdentify"].nrequest = 0;
		refresh();
	}
};
lObject.onRequest = function(layer:MovieClip, type:String, obj:Object) {
	if (not off) {
		if (type == "identify") {
			var layerid:String = flamingo.getId(layer);
			debugobjects[layerid]["onIdentify"].nrequest++;
			var nr = debugobjects[layerid]["onIdentify"].nrequest;
			debugobjects[layerid]["onIdentifyRequest "+nr] = new Object();
			for (var attr in obj) {
				var val = obj[attr];
				if (attr.toLowerCase() == "response" or attr.toLowerCase() == "request") {
					val = val.split("><").join(">\n<");
					val = val.split("<").join("&lt;");
					val = val.split(">").join("&gt;");
				}
				debugobjects[layerid]["onIdentifyRequest "+nr][attr] = val;
			}
			refresh();
		}
		if (type == "update") {
			var layerid:String = flamingo.getId(layer);
			debugobjects[layerid]["onUpdateRequest"] = new Object();
			for (var attr in obj) {
				var val = obj[attr];
				if (attr.toLowerCase() == "response" or attr.toLowerCase() == "request") {
					val = val.split("><").join(">\n<");
					val = val.split("<").join("&lt;");
					val = val.split(">").join("&gt;");
				}
				debugobjects[layerid]["onUpdateRequest"][attr] = val;
			}
			refresh();
		}
	}
};
lObject.onResponse = function(layer:MovieClip, type:String, obj:Object) {
	if (not off) {
		if (type == "identify") {
			var layerid:String = flamingo.getId(layer);
			var nr = debugobjects[layerid]["onIdentify"].nrequest;
			debugobjects[layerid]["onIdentifyResponse "+nr] = new Object();
			for (var attr in obj) {
				var val = obj[attr];
				if (attr.toLowerCase() == "response" or attr.toLowerCase() == "request") {
					val = val.split("><").join(">\n<");
					val = val.split("<").join("&lt;");
					val = val.split(">").join("&gt;");
				}
				debugobjects[layerid]["onIdentifyResponse "+nr][attr] = val;
			}
			refresh();
		}
		if (type == "update") {
			var layerid:String = flamingo.getId(layer);
			debugobjects[layerid]["onUpdateResponse"] = new Object();
			for (var attr in obj) {
				var val = obj[attr];
				if (attr.toLowerCase() == "response" or attr.toLowerCase() == "request") {
					val = val.split("><").join(">\n<");
					val = val.split("<").join("&lt;");
					val = val.split(">").join("&gt;");
				}
				debugobjects[layerid]["onUpdateResponse"][attr] = val;
			}
			refresh();
		}
	}
};
lObject.onIdentifyData = function(layer:MovieClip, features:Object, identifyextent:Object) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		var nr = debugobjects[layerid]["onIdentify"].nrequest;
		debugobjects[layerid]["onIdentifyData "+nr] = new Object();
		debugobjects[layerid]["onIdentifyData "+nr].features = features;
		debugobjects[layerid]["onIdentifyData "+nr].identifyextent = identifyextent.toString();
		refresh();
	}
};
lObject.onError = function(layer:MovieClip, type:String, error:String) {
	if (not off) {
		if (type == "identify") {
			var layerid:String = flamingo.getId(layer);
			var nr = debugobjects[layerid]["onIdentify"].nrequest;
			debugobjects[layerid]["onIdentifyError "+nr] = new Object();
			debugobjects[layerid]["onIdentifyError "+nr].error = error;
			refresh();
		}
		if (type == "update") {
			var layerid:String = flamingo.getId(layer);
			debugobjects[layerid]["onUpdateError"] = new Object();
			debugobjects[layerid]["onUpdateError"].error = error;
			refresh();
		}
	}
};
lObject.onIdentifyComplete = function(layer:MovieClip, identifytime:Number) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		debugobjects[layerid]["onIdentifyComplete"] = new Object();
		debugobjects[layerid]["onIdentifyComplete"].identifytime = identifytime;
		delete debugobjects[layerid]["onIdentify"].nrequest;
		refresh();
	}
};
lObject.onUpdate = function(layer:MovieClip, nrtry) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		debugobjects[layerid] = new Object();
		debugobjects[layerid]["onUpdate"] = new Object();
		debugobjects[layerid]["onUpdate"].nrtry = nrtry;
		refresh();
	}
};
lObject.onUpdateProgress = function(layer:MovieClip, bytesloaded:Number, bytestotal:Number) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		debugobjects[layerid]["onUpdateProgress"] = new Object();
		debugobjects[layerid]["onUpdateProgress"].bytesloaded = bytesloaded;
		debugobjects[layerid]["onUpdateProgress"].bytestotal = bytestotal;
		refresh();
	}
};
lObject.onUpdateComplete = function(layer:MovieClip, requesttime:Number, loadtime:Number, totalbytes:Number) {
	if (not off) {
		var layerid:String = flamingo.getId(layer);
		debugobjects[layerid]["onUpdateComplete"] = new Object();
		debugobjects[layerid]["onUpdateComplete"].requesttime = requesttime;
		debugobjects[layerid]["onUpdateComplete"].loadtime = loadtime;
		debugobjects[layerid]["onUpdateComplete"].totalbytes = totalbytes;
		refresh();
	}
};
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(mc:MovieClip, lang:String) {
	resize();
};
flamingo.addListener(lFlamingo, "flamingo", this);
//----------------
init();
/** @tag <cmc:Debugger>  
* This tag defines a debugger. It listens to 1 or more ArcIMSLayers and/or OGWMSLayers.
* @hierarchy childnode of <flamingo> or a container component. e.g. <cmc:Window>
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Debugger "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//
	// Create text field.
	this.attachMovie("mBG", "mBG", 0);
	this.createTextField("txtH", 1, 0, 0, 100, 100);
	txtH.wordWrap = false;
	txtH.html = true;
	txtH.selectable = false;
	
	this.createTextField("mText", 2, 0, 0, 100, 100);
	mText.wordWrap = false;
	mText.html = true;
	this.createClassObject(mx.controls.UIScrollBar, "mSBV", 3);
	mSBV.setScrollTarget(mText);
	this.createClassObject(mx.controls.UIScrollBar, "mSBH", 4);
	mSBH.horizontal = true;
	mSBH.setScrollTarget(mText);
	//
	//defaults
	this.setConfig(defaultXML);

	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	
	mText.styleSheet = flamingo.getStyleSheet(this);
	txtH.styleSheet = flamingo.getStyleSheet(this);
		resize();
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
	if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
		return;
	}
	//load default attributes, strings, styles and cursors           
	flamingo.parseXML(this, xml);
	flamingo.addListener(lObject, listento, this);
	resize();
}
function resize() {
	if (off) {
		var s:String = flamingo.getString(this, "on", "debugger on");
		txtH.htmlText = "<span class='onoff'><a href=\"asfunction:setOn\">"+s+"</a></span>";
	} else {
		var s:String = flamingo.getString(this, "off", "debugger off");
		txtH.htmlText = "<span class='onoff'><a href=\"asfunction:setOff\">"+s+"</a></span>";
	}
	var r = flamingo.getPosition(this);
	var x = r.x;
	var y = r.y;
	var w = r.width;
	var h = r.height;
	var sb = 16;
	mBG._x = x;
	mBG._y = y;
	mBG._width = w;
	mBG._height = h;
	//
	txtH._x = x;
	txtH._y = y;
	txtH._width = w;
	var th = txtH.textHeight+5;
	txtH._height = th;
	//
	mText._x = x;
	mText._y = y+th;
	mText._height = h-th-sb;
	mText._width = w-sb;
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
function setOff() {
	off = true;
	delete debugobjects;
	debugobjects = new Object();
	resize();
	refresh();
}
function setOn() {
	off = false;
	delete debugobjects;
	debugobjects = new Object();
	resize();
	refresh();
}
function refresh() {
	var s:String = "<span class='default'>---------------------------------------------------------------------------------------------------------------------------------------------------------------";
	for (var layer in debugobjects) {
		s += newline+"<span class='layer'>"+layer+"</span>";
		for (var events in debugobjects[layer]) {
			s += newline+"<img src=\"lightning\"><span class='event'>"+events+"</span>";
			s += "<textformat indent=\"30\">";
			for (var attr in debugobjects[layer][events]) {
				var val = debugobjects[layer][events][attr];
				s += newline+"<span class='attribute'>"+attr+":</span><br><span class='"+attr+"'>"+val+"</span>";
			}
			s += "</textformat>";
		}
		s += newline+newline+"---------------------------------------------------------------------------------------------------------------------------------------------------------------";
	}
	s += "</span>";
	mText.htmlText = s;
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}