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
/** @component ToolIdentify
* Tool for identifying maps.
* @file ToolIdentify.fla (sourcefile)
* @file ToolIdentify.swf (compiled component, needed for publication on internet)
* @file ToolIdentify.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor click Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/

/*
* Changes oct 2008
* Instead of using property map.hit use was made of the 
* method map.isHit() 
* Author:Linda Vels,IDgis bv
*/

var version:String = "2.0";


//-------------------------------------------
var thisObj = this;
var skin = "_identify";
var enabled = true;
var zoomscroll:Boolean = true;
var identifyall:Boolean = true;
//--------------------------------------------
var lMap:Object = new Object();
lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
	if (zoomscroll) {
		if (not _parent.updating) {
			_parent.cancelAll();
			if (delta<=0) {
				var zoom = 80;
			} else {
				var zoom = 120;
			}
			var w = map.getWidth();
			var h = map.getHeight();
			var c = map.getCenter();
			var cx = (w/2)-((w/2)/(zoom/100));
			var cy = (h/2)-((h/2)/(zoom/100));
			var px = (coord.x-c.x)/(w/2);
			var py = (coord.y-c.y)/(h/2);
			coord.x = c.x+(px*cx);
			coord.y = c.y+(py*cy);
			map.moveToPercentage(zoom, coord, 500, 0);
			_parent.updateOther(map, 500);
		}
	}
};
lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {

		map.setCursor(thisObj.cursors["click"]);
};
lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {

	
	if (thisObj._parent.defaulttool==undefined){
		map.setCursor(thisObj.cursors["cursor"]);
	}
	if (map.isHit({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y})) {
		if (identifyall) {
			for (var i:Number = 0; i<_parent.listento.length; i++) {
				var mc = flamingo.getComponent(_parent.listento[i]);
				mc.identify({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
			}
		} else {
			map.identify({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
		}
	}
};
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolIdentify>  
* This tag defines a tool for identifying maps.
* The positioning of the tool is relative to the position of toolGroup.
* @hierarchy childnode of <fmc:ToolGroup>
* @attr zoomscroll (defaultvalue "true")  True or false. Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr identifyall (defaultvalue="true") True: identify all maps. False: identify only the map that's being clicked on.
* @attr skin (defaultvalue="") Available skins: "", "f2" 
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolIdentify "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		var attr:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (attr) {
		case "skin" :
			skin = val+"_identify";
			break;
		case "identifyall" :
			if (val.toLowerCase() == "true") {
				identifyall = true;
			} else {
				identifyall = false;
			}
			break;
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		}
	}
	this._parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);

}
//default functions-------------------------------
function startIdentifying() {
	
		_parent.setCursor(this.cursors["busy"]);
}
function stopIdentifying() {
	
		_parent.setCursor(this.cursors["cursor"]);
}
function startUpdating() {
}
function stopUpdating() {
}
function releaseTool() {
}
function pressTool() {
	//the toolgroup sets default a cursor
	//override this default if a map is busy
	if (_parent.identifying) {
		
			_parent.setCursor(this.cursors["busy"]);
	}
}
//---------------------------------
/**
* Disable or enable a tool.
* @param enable:Boolean true or false
*/
//public function setEnabled(enable:Boolean):Void {
//}
/**
* Shows or hides a tool.
* @param visible:Boolean true or false
*/
//public function setVisible(visible:Boolean):Void {
//}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}