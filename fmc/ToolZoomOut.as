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
/** @component ToolZoomout
* Tool for zooming a map by dragging a rectangle or just clicking the map
* @file ToolZoomout.fla (sourcefile)
* @file ToolZoomout.swf (compiled component, needed for publication on internet)
* @file ToolZoomout.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor busy Cursor shown when a map is updating and holdonupdate(attribute of Map) is set to true.
*/
var version:String = "2.0";

//-----------------------------------------
var zoomfactor:Number = 50;
var zoomdelay:Number = 0;
var clickdelay:Number = 1000;
var zoomscroll:Boolean = true;
var skin="_zoomout"
var enabled = true
var rect:Object = new Object()
var thisObj = this
//-----------------------------------------
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
	var x:Number;
	var y:Number;
	if (not _parent.updating) {
		_parent.cancelAll();
		x = xmouse;
		y = ymouse;
		lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			thisObj.rect.x  = Math.min(x, xmouse)
			thisObj.rect.y  = Math.min(y, ymouse)
			thisObj.rect.width  = Math.abs(xmouse-x)
			thisObj.rect.height = Math.abs(ymouse-y)
		map.drawRect("zoomrect", thisObj.rect ,{color:0x000000,alpha:10},{color:0xffffff,alpha:60,width:0});

		};
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			var dx:Number = Math.abs(xmouse-x);
			var dy:Number = Math.abs(ymouse-y);
			if (dx<5 and dy<5) {
				map.moveToPercentage(zoomfactor, coord, clickdelay);
			} else {
				var center:Object = new Object();
				center.x = thisObj.rect.x+thisObj.rect.width/2;
				center.y = thisObj.rect.y+thisObj.rect.height/2;
				var coord = map.point2Coordinate(center);
				var ext = map.getCurrentExtent();
				var zf = Math.max(thisObj.rect.width/map.__width*100, 20);
				map.moveToPercentage(zf, coord, zoomdelay);
			}
			_parent.updateOther(map, zoomdelay);
			//puin ruimen                                
			//map.clearDrawings();
			delete lMap.onMouseMove;
			delete lMap.onMouseUp;
		};
	}
};
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolZoomout>  
* This tag defines a tool for zooming a map. There are two actions; 1 dragging a rectangle and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr zoomdelay  (defaultvalue "0") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags a rectangle. 
* @attr zoomfactor  (defaultvalue "50") A percentage the map will zoom after the user clicks the map.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolZoomout "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		case "zoomfactor" :
			zoomfactor = Number(val);
			break;
		case "zoomdelay" :
			zoomdelay = Number(val);
			break;
		case "clickdelay" :
			clickdelay = Number(val);
			break;
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "skin" :
			skin = val+"_zoomout";
			break
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		default :
			break;
		}
	}
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}
//default functions-------------------------------
function startIdentifying() {
}
function stopIdentifying() {
}
function startUpdating() {

	_parent.setCursor(this.cursors["busy"]);
}
function stopUpdating() {
	
	_parent.setCursor(this.cursors["cursor"]);
}
function releaseTool() {
}
function pressTool() {
	//the toolgroup sets default a cursor
	//override this default if a map is busy
	if (_parent.updating) {
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