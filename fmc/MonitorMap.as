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
/** @component MonitorMap
* This component will monitor the update progress of a map.
* This component is very suitable for maps with more than one layer.
* If a map has just one layer, use MonitorLayer instead.
* @file MonitorMap.fla (sourcefile)
* @file MonitorMap.swf (compiled component, needed for publication on internet)
* @file MonitorMap.xml (configurationfile, needed for publication on internet)
* @configstring loading String shown when map is downloading images. The string "[percentage]" is replaced by actual percentage number. The string "[map" is replaced by the map's name.
* @configstring waiting String shown when map is waiting for response from the server. The string "[percentage]" is replaced by actual percentage number. The string "[map" is replaced by the map's name.
* @configstyle .text Fontstyle of load and wait strings.
*/
var version:String = "2.0";


//-------------------------------
var skin:String = "";
//---------------------------------
var lMap:Object = new Object();
lMap.onAddLayer = function(map:MovieClip) {
	monitor(0, map);
};
//Added onRemoveLayer handler, IDgis/HHA
lMap.onRemoveLayer = function(map:MovieClip) {
	monitor(100, map);
};
lMap.onUpdate = function(map:MovieClip) {

	monitor(0, map);
};
lMap.onUpdateProgress = function(map:MovieClip, layersupdated:Number, totalupdate:Number) {
	monitor(layersupdated/totalupdate*100, map);
};
lMap.onUpdateComplete = function(map:MovieClip) {
  //_global.flamingo.tracer("onUpdateComplete");
	monitor(100, map);
};
lMap.onIdentify = function(map:MovieClip, extent:Object) {
  //_global.flamingo.tracer("onIdentify");
	monitor(0, map);
};
lMap.onIdentifyProgress = function(map:MovieClip, layersidentified:Number, layerstotal:Number, sublayersidentified:Number, sublayerstotal:Number) {
  //_global.flamingo.tracer("onIdentifyProgress, " + layersidentified + "/" + layerstotal);
	monitor(layersidentified / layerstotal * 100, map);
};
lMap.onIdentifyComplete = function(map:MovieClip) {
  //_global.flamingo.tracer("onIdentifyComplete");
	monitor(100, map);
};
//---------------------------------------
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip ) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//----------------
init();
/** @tag <fmc:MonitorMap>  
* This tag defines a monitor.  Listens to 1 or more maps
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>.
* @attr skin (defaultvalue="") Skin. Available skins: "", "f1".
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>MonitorMap "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
function monitor(perc:Number, map:MovieClip) {
	var mapname = map.name;
	if (mapname == undefined or mapname.length == 0) {
		mapname = flamingo.getId(map);
	}
	if (perc == 100) {
		mBusy.stop();
		mBusy._visible = false;
		mProgress.gotoAndStop(Math.round(mProgress._totalframes*100/100));
		var t = flamingo.getString(this, "loading", "loading...");
		t = t.split("[percentage]").join("100");
		t = t.split("[map]").join(mapname);
		mProgress.txt.htmlText = "<span class='text'>"+t+"</span>";
		mProgress.onEnterFrame = function() {
			this._alpha = this._alpha-20;
			if (this._alpha<=0) {
				this._visible = false;
				this._alpha = 100;
				delete this.onEnterFrame;
			}
		};
	} else if (perc>0) {
		mBusy.stop();
		mBusy._visible = false;
		mProgress.gotoAndStop(Math.round(mProgress._totalframes*perc/100));
		var t = flamingo.getString(this, "loading", "loading...");
		t = t.split("[percentage]").join(String(Math.round(perc)));
		t = t.split("[map]").join(flamingo.getId(mapname));
		mProgress.txt.htmlText = "<span class='text'>"+t+"</span>";
		mProgress._visible = true;
	} else {
		mProgress.stop();
		mProgress._visible = false;
		t = flamingo.getString(this, "waiting", "waiting...");
		t = t.split("[percentage]").join(String(Math.round(perc)));
		t = t.split("[map]").join(flamingo.getId(mapname));
		mBusy.txt.htmlText = "<span class='text'>"+t+"</span>";
		mBusy.play();
		mBusy._visible = true;
	}
	return;
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