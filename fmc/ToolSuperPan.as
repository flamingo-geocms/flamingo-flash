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
/** @component ToolSuperPan
* Tool for zooming and panning a map like a 'google' way. The user can zoom, pan and throw the map.
* Be very aware that this tool has a huge impact on ArcIMS and OG-WMS mapservices.
* @file ToolSuperPan.fla (sourcefile)
* @file ToolSuperPan.swf (compiled component, needed for publication on internet)
* @file ToolSuperPan.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor grab Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/

/*
* Changes oct 2008
* Instead of using properties map.__width and map.__heigth use was made of the 
* new methods map.getMovieClipWidth() en map.getMovieClipHeigth()
* Author:Linda Vels,IDgis bv
*/

var version:String = "2.0";

//-------------------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolSuperPan>" +
						"<string id='tooltip' nl='slepen, gooien en zoomen met het wieltje' en='pan, throw, and zoom with mousewheel'/>" +
				        "<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='pan'/>" +
				        "<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab'/>" +
				        "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
				        "</ToolSuperPan>";
var delay:Number = 800;
var velocityid:Number;
var autopanid:Number;
var vx:Number;
var vy:Number;
var xold:Number;
var yold:Number;
var panning:Boolean = false;
var extent:Object;
var thisObj:MovieClip = this;
var skin = "_superpan";
var enabled = true;
var panmap:MovieClip 
var maphit:Boolean 
//---------------------
var lMap:Object = new Object();
lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
	cancel()
	
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
	
};
lMap.onRollOut = function(map:MovieClip ){
	maphit = false
	cancel()
}
lMap.onDragOut = function(map:MovieClip){
	maphit = false
	cancel()
}
lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
	maphit = true
	cancel()
	//trace("mousedown:"+flamingo.getId(map));
	if (not _parent._busy) {
		_parent.cancelAll();
		
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.getMovieClipWidth();
		var msy = (e.maxy-e.miny)/map.getMovieClipHeight();
		map.setCursor(thisObj.cursors["grab"]);
		var x = xmouse;
		var y = ymouse;
		xold = xmouse;
		yold = ymouse;
		velocityid = setInterval(velocity, 50, map);
		lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			var dx = (x-xmouse)*msx;
			var dy = (ymouse-y)*msy;
			map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
			updateAfterEvent();
		};
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			delete lMap.onMouseMove;
			delete lMap.onMouseUp;
			//trace("mouseup:"+flamingo.getId(map));
			clearInterval(velocityid);
			//var dx:Number = Math.abs(xmouse-x);
			//var dy:Number = Math.abs(ymouse-y);
			//if (dx<=2 and dy<=2) {
			//map.moveToCoordinate(coord,undefined,undefined,-1,10);
			//delay = clickdelay
			//}
			if ((Math.abs(vx)>10 or Math.abs(vy)>10) and maphit) {
				vx = Math.round(vx/10);
				vy = Math.round(vy/10);
				clearInterval(autopanid);
				panmap = map
				autopanid = setInterval(autoPan, 50, map);
				
			} else {
				//var dx:Number = Math.abs(xmouse-x);
				//var dy:Number = Math.abs(ymouse-y);
				//if (dx<=2 and dy<=2) {
				//map.moveToCoordinate(coord, undefined, undefined, -1, 10);
				//}
				
				_parent.updateOther(map, delay);
			}
			map.update(delay);
			
			map.setCursor(thisObj.cursors["cursor"]);
			
		};
	}
};
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolSuperPan>  
* This tag defines a tool for panning and zooming a map. There are 3 actions; 1  dragging and 2 use the scrollwheel and 3 throw the map away.
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr delay  (defaultvalue "800") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags the map. In this time the user can click again and the update of the map wil be postponed.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolSuperPan "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	//if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
		//return;
	//}
	//load default attributes, strings, styles and cursors       
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var attr:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (attr) {
		case "delay" :
			delay = Number(val);
			break;
		case "skin" :
			skin = val+"_superpan";
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
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);

}
function velocity(map:MovieClip) {
	vx = xold-map._xmouse;
	vy = yold-map._ymouse;
	xold = map._xmouse;
	yold = map._ymouse;
}
function autoPan(map:MovieClip) {

	panning = true;
	var e = map.getCurrentExtent();
	var msx = (e.maxx-e.minx)/map.__width;
	var msy = (e.maxy-e.miny)/map.__height;
	var dx = vx*msx;
	var dy = -vy*msy;
	map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
	updateAfterEvent();
}
function cancel() {
	//trace("CANCEL");
	if (panning) {
		panmap.update(delay);
		_parent.updateOther(panmap, delay);
		clearInterval(autopanid);
		clearInterval(velocityid);
		panning = false;
	}
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
	cancel();
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