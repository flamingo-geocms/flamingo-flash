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
/** @component MonitorLayer
* This component will monitor progress of single maplayers. Very suitable for maps with just one layer.
* @file MonitorLayer.fla (sourcefile)
* @file MonitorLayer.swf (compiled component, needed for publication on internet)
* @file MonitorLayer.xml (configurationfile, needed for publication on internet)
* @configstring loading String shown when a layer is downloading images. The string "[layer]" is replaced by the layer's name. The string "[percentage]" is replaced by actual percentage number. 
* @configstring waiting String shown when a layer is waiting for response from the server. The string "[layer]" is replaced by the layer's name. The string "[percentage]" is replaced by actual percentage number.
* @configstyle .text Fontstyle of load and wait strings.
*/
var version:String = "2.0";
//-------------------------------
var monitorobjects:Object = new Object();
var skin:String = "";
//---------------------------------
var lLayer:Object = new Object();
lLayer.onUpdate = function(layer:MovieClip) {
	var id = flamingo.getId(layer);
	monitorobjects[id] = new Object();
	if (layer.name.length>0) {
		monitorobjects[id].name = layer.name;
	} else {
		monitorobjects[id].name = id;
	}
	monitorobjects[id].progress = undefined;
	monitor();
};
lLayer.onUpdateProgress = function(layer:MovieClip, bytesloaded:Number, bytestotal:Number) {
	p = 0;
	if (bytestotal>0) {
		var p = bytesloaded/bytestotal*100;
	}
	monitorobjects[flamingo.getId(layer)].progress = p;
	monitor();
};
lLayer.onError = function(layer:MovieClip, type:String, error:String) {
	//if (type == "update") {
		delete monitorobjects[flamingo.getId(layer)];
		monitor();
	//}
};
lLayer.onUpdateComplete = function(layer:MovieClip) {
	delete monitorobjects[flamingo.getId(layer)];
	monitor();
};
//---------------------------------------
var lMap:Object = new Object();
lMap.onAddLayer = function(map:MovieClip, layer:MovieClip) {
	flamingo.addListener(lLayer, layer);
};
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//----------------
init();
/** @tag <fmc:MonitorLayer>  
* This tag defines a monitor. listens to 1 or more maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @attr skin (defaultvalue="") Skin. Available skins: "", "f1".
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>MonitorLayer "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
	this.setConfig(xml);
	delete xml;
	//custom
	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
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
		}
	}
	setSkin();
	flamingo.addListener(lMap, listento, this);
	resize();
}
function resize() {
	flamingo.position(this);
}
function monitor() {
	for (var id in monitorobjects) {
		mError._visible = false;
		var p = monitorobjects[id].progress;
		if (p>0) {
			mProgress.gotoAndStop(Math.round(mProgress._totalframes*p/100));
			var t = flamingo.getString(this, "loading", "");
			t = t.split("[layer]").join(monitorobjects[id].name);
			t = t.split("[percentage]").join(String(Math.round(p)));
			mProgress.txt.htmlText = "<span class='text'>"+t+"</span>";
			mProgress._visible = true;
			mBusy._visible = false;
			mBusy.stop();
		} else {
			var t = flamingo.getString(this, "waiting", "");
			t = t.split("[layer]").join(monitorobjects[id].name);
			mBusy.txt.htmlText = "<span class='text'>"+t+"</span>";
			mBusy.play();
			mBusy._visible = true;
			mProgress._visible = false;
		}
		return;
	}
	mError._visible = true;
	mBusy._visible = false;
	mProgress._visible = false;
}
function setSkin() {
	this.useHandCursor = false;
	var mc:MovieClip = attachMovie(skin+"_progress", "mProgress", 0);
	mc.txt.styleSheet = flamingo.getStyleSheet(this);
	mc._visible = false;
	mc.stop();
	var mc:MovieClip = attachMovie(skin+"_busy", "mBusy", 1);
	mc.txt.styleSheet = flamingo.getStyleSheet(this);
	mc._visible = false;
	mc.stop();
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}