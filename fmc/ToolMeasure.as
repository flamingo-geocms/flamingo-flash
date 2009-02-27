﻿/*-----------------------------------------------------------------------------
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
/** @component ToolMeasure
* Tool for measuring a single distance on a map.
* @file ToolMeasure.fla (sourcefile)
* @file ToolMeasure.swf (compiled component, needed for publication on internet)
* @file ToolMeasure.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
*/

/*
* Changes oct 2008
* Instead of using the flamingo methods showTooltip() and hideTooltip use
* is made of the map methodesshowTooltip and hideTooltip() 
* Author:Linda Vels,IDgis bv
*/

var version:String = "2.0";
//-------------------------------------------
var unit:String = "";
var decimals:Number = 0;
var magicnumber:Number = 1;
var zoomscroll:Boolean = true;
var skin = "_measure";
var enabled = true;
//-------------------------------------------
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
	x = xmouse;
	y = ymouse;

	lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		var r:Number = Math.sqrt((Math.pow((xmouse-x), 2)+Math.pow((ymouse-y), 2)));
		map.drawCircle("circle_1",{x:x,y:y,radius:r},{color:0x000000,alpha:10},undefined) //{color:0x333333,alpha:100,width:0})
		//map.drawCircle("circle_2",{x:x+1,y:y+1,radius:r},undefined,{color:0xffffff,alpha:100,width:0})
		map.draw("line_2", [{x:x+1, y:y+1},{x:xmouse+1,y:ymouse+1}], undefined,{color:0xffffff,alpha:100,width:0.1})
        map.draw("line_1" ,[{x:x, y:y},{x:xmouse,y:ymouse}], undefined,{color:0x333333,alpha:100,width:0.1})
		
		var d:Number = map.getDistance(map.point2Coordinate({x:x, y:y}), map.point2Coordinate({x:xmouse, y:ymouse}));
		d = d/magicnumber;
		if (decimals>0) {
			d = Math.round(d*decimals)/decimals;
		}
		//flamingo.showTooltip(d+unit, map, 0);
		map.showTooltip(d+unit, 0);
		
	};
	lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		map.clearDrawings()
		map.hideTooltip();
		delete lMap.onMouseMove;
		delete lMap.onMouseUp;
	};
};
//-------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolMeasure>  
* This tag defines a tool for measuring a distance.
* @hierarchy childnode of <fmc:ToolGroup>
* @example
  <fmc:ToolGroup left="210" top="0" tool="zoom" listento="map">
      <fmc:ToolZoomin id="zoom"/>
      <fmc:ToolZoomout left="30"/>
      <fmc:ToolSuperPan left="60" skin=""/>
      <fmc:ToolIdentify  id="identify" left="90" enabled="false"/>
      <fmc:ToolMeasure left="120" unit=" km" magicnumber="1000">
         <string id="tooltip" en="measure kilometers"/>
  	  </fmc:ToolMeasure>
	  <fmc:ToolMeasure left="150" unit=" m" magicnumber="1">
         <string id="tooltip" en="measure meters"/>
  	  </fmc:ToolMeasure>
  </fmc:ToolGroup>
* @attr units  (defaultvalue "") String attached to the distance number.
* @attr decimals  (defaultvalue "") Number of decimals.
* @attr magicnumber (defaultvalue "1") A number by which the distance is divided, in order to support multiple measure-units.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolMeasure "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		case "units" :
			unit = val;
			break;
		case "magicnumber" :
			magicnumber = Number(val);
			break;
		case "decimals" :
			decimals = Math.pow(10, Number(val));
			break;
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "skin" :
			skin = val+"_measure";
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
}
function stopUpdating() {
}
function releaseTool() {
}
function pressTool() {
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