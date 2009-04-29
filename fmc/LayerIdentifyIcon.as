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
/** @component LayerIdentifyIcon
* This layer shows an icon when the user performs an identify.
* @file LayerIdentifyIcon.fla (sourcefile)
* @file LayerIdentifyIcon.swf (compiled layer, needed for publication on internet)
* @file LayerIdentifyIcon.xml (configurationfile for layer, needed for publication on internet)
*/
var version:String = "2.0";

//---------------------------------
var defaultXML:String = "";
//properties which can be set in ini
var skin:String = "";
//---------------------------------
var visible:Boolean;
var extent:Object;
//-----------------------------------
//listenerobject for map
var lMap:Object = new Object();
lMap.onChangeExtent = function(map:MovieClip):Void  {
	if (_visible and map.hasextent) {
		var rect = map.extent2Rect(extent);
		var x = rect.x+(rect.width/2);
		var y = rect.y+(rect.height/2);
		mIdentify._x = x;
		mIdentify._y = y;
	}
};
lMap.onIdentify = function(map:MovieClip, identifyextent:Object):Void  {
	visible = true;
	_visible = true;
	extent = identifyextent;
	var rect = map.extent2Rect(extent);
	var x = rect.x+(rect.width/2);
	var y = rect.y+(rect.height/2);
	var mc = attachMovie(skin+"_icon", "mIdentify", 0, {_x:x, _y:y});
};
lMap.onCorrectIdentifyIcon = function(map:MovieClip, identifyextent:Object):Void  {
	visible = true;
	_visible = true;
	extent = identifyextent;
	var rect = map.extent2Rect(extent);
	var x = rect.x+(rect.width/2);
	var y = rect.y+(rect.height/2);
	var mc = attachMovie(skin+"_icon", "mIdentify", 0, {_x:x, _y:y});
};
lMap.onHideIdentifyIcon = function(map:MovieClip):Void  {
	visible = false;
	_visible = false;
};
flamingo.addListener(lMap, flamingo.getParent(this), this);
//-----------------------------------------------------------------
init();
//-----------------------------------
/** @tag <fmc:LayerIdentifyIcon>  
* This tag defines an identifyicon layer
* @hierarchy childnode of <fmc:Map> 
* @attr skin  (defaultvalue "") Skin. Avaliable skins: "", "heartbeat", "f1"
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LayerIdentifyIcon "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	map = flamingo.getParent(this);
	//defaults
	var xml:XML = new XML(defaultXML);
	this.setConfig(xml);
	delete xml;
	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
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
			this.skin = val;
			break;
		}
	}
	visible = false;
	_visible = false;

}
/** 
* Changes the visiblity of a layer.
* @param vis:Boolean True (visible) or false (not visible).
*/
function setVisible(vis:Boolean) {
	if (vis) {
		this.show();
	} else {
		this.hide();
	}
}
/**
* Hides a layer.
*/
function hide(map:MovieClip) {
	visible = false;
	_visible = false;
	flamingo.raiseEvent(this, "onHide", this);
}
/**
* Shows a layer.
*/
function show(map:MovieClip) {
	visible = true;
	_visible = true;
	flamingo.raiseEvent(this, "onShow", this);
}
/** 
* Gets the scale of the layer
* @return Number Scale.
*/
function getScale():Number {
	return map.getScale();
}
/** 
* Checks if a maplayer is visible.
* @return Number -2, -1, 0, 1, or  2
* -2 = maplayer is not visible and maplayer is out of scale
* -1 = maplayer is not visible;
*  1 = maplayer is visible;
* -2 = maplayer is visible and maplayer is out of scale
*/
function getVisible():Number {
	//returns 0 : not visible or 1:  visible or 2: visible but not in scalerange
	var ms:Number = map.getScale();
	//var vis:Boolean = flamingo.getVisible(this)
	if (visible) {
		if (minscale != undefined) {
			if (ms<minscale) {
				return 2;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				return 2;
			}
		}
		return 1;
	} else {
		if (minscale != undefined) {
			if (ms<minscale) {
				return -2;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				return -2;
			}
		}
		return -1;
	}
}
/**
* Dispatched when a the layer is up and running and ready to update for the first time.
* @param layer:MovieClip a reference to the layer.
*/
//public function onInit(layer:MovieClip):Void {
/**
* Dispatched when the layer is hidden.
* @param layer:MovieClip a reference to the layer.
*/
//public function onHide(layer:MovieClip):Void {
/**
* Dispatched when the layer is shown.
* @param layer:MovieClip a reference to the layer.
*/
//public function onShow(layer:MovieClip):Void {
