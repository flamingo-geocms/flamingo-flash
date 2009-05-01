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
/** @component ToolPan
* Tool for panning a map.
* @file ToolPan.fla (sourcefile)
* @file ToolPan.swf (compiled component, needed for publication on internet)
* @file ToolPan.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor pan Cursor shown when the tool is hoovering over a map.
* @configcursor grab Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/

/*
* Changes oct 2008:
* Instead of using properties map.__width and map.__heigth use was made of the 
* new methods map.getMovieClipWidth() en map.getMovieClipHeigth()
* Author:Linda Vels,IDgis bv
*/

var version:String = "2.0";


//-------------------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolPan>" +
						"<string id='tooltip' nl='kaartbeeld slepen' en='pan'/>" +
				        "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
				        "<cursor id='pan'  url='fmc/CursorsMap.swf' linkageid='pan'/>" +
				        "<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab_wrinkle'/>" +
				        "</ToolPan>";
var pandelay:Number = 1000;
var clickdelay:Number = 1000;
var xold:Number;
var yold:Number;
var thisObj:MovieClip = this;
var zoomscroll:Boolean = true;
var skin = "_pan";
var enabled = true;
//---------------------
var lMap:Object = new Object();
lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
	if (thisObj.zoomscroll) {
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
	if (not _parent.updating) {
		_parent.cancelAll();
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.getMovieClipWidth();
		var msy = (e.maxy-e.miny)/map.getMovieClipHeight();
		map.setCursor(thisObj.cursors["grab"]);
		var x = xmouse;
		var y = ymouse;

		lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			var dx = (x-xmouse)*msx;
			var dy = (ymouse-y)*msy;
			map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
			updateAfterEvent();
		};
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			//_parent._cursorid = "cursor";
			var delay = pandelay;
			var dx:Number = Math.abs(xmouse-x);
			var dy:Number = Math.abs(ymouse-y);
			if (dx<=2 and dy<=2) {
				map.moveToCoordinate(coord, -1, 10);
				delay = clickdelay;
			}
			map.setCursor(thisObj.cursors["pan"]);
			map.update(delay);
			_parent.updateOther(map, delay);
			delete lMap.onMouseMove;
			delete lMap.onMouseUp;
		};
	}
};
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolPan>  
* This tag defines a tool for panning a map. There are two actions; 1  dragging and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr pandelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags the map. In this time the user can pickup the map again and the update of the map wil be postponed.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolPan "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;

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
		case "clickdelay" :
			clickdelay = Number(val);
			break;
		case "pandelay" :
			pandelay = Number(val);
			break;
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "skin" :
			skin = val+"_pan";
			break;
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
	//
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "pan", "tooltip");
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
	_parent.setCursor(this.cursors["pan"]);
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