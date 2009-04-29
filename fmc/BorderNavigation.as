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
/** @component BorderNavigation
* Navigation buttons at the border of a map.
* @file BorderNavigation.fla (sourcefile)
* @file BorderNavigation.swf (compiled component, needed for publication on internet)
* @file BorderNavigation.xml (configurationfile, needed for publication on internet)
* @configstring tooltip_north tooltiptext of north button
* @configstring tooltip_south tooltiptext of south button
* @configstring tooltip_west tooltiptext of west button
* @configstring tooltip_east tooltiptext of east button
* @configstring tooltip_northwest tooltiptext of northwest button
* @configstring tooltip_southwest tooltiptext of southwest button
* @configstring tooltip_southeast tooltiptext of southeast button
* @configstring tooltip_northeast tooltiptext of northeast button
*/
var version:String = "2.0";

//---------------------------------------
var deafultXML:String = "";
var buttons:Array = new Array("W", "S", "N", "E", "NW", "NE", "SE", "SW");
var fbN:FlamingoButton;
var fbS:FlamingoButton;
var fbE:FlamingoButton;
var fbW:FlamingoButton;
var offset:Number = 0;
var skin = "";
var _moveid:Number;
var thisObj = this;
var updatedelay:Number = 500;
//listeners
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip ) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
init();
/** @tag <fmc:BorderNavigation>  
* This tag defines navigation buttons at the border of a map. It listens to 1 or more map components
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:BorderNavigation left="10" top="10" right="right -10" bottom="50%" skin="" buttons="N,S,W,E,NE,SE,NW,SW" listento="map,map1" offset="6"/>
* @attr buttons (defaultvalue = "W,S,N,E,NE,NW,SE,SW") Comma seperated list of buttons. W=West, S=South etc. Reconized values: W,S,N,E,NE,NW,SE,SW
* @attr updatedelay (defaultvalue = "500") Time in milliseconds (1000 = 1 sec.) in which the map will be updated.
* @attr offset (defaultvalue = "0") Offset in pixels applied to all buttons. For main positioning use the default positioning attributes (left, top etc.).
* @attr skin (defaultvalue = "") Skin of the buttons. Available skins: default ("") "f1" and "f2".  When using the "f1" or "f2"  skin only the N,W,S,E buttons can be used.
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>BorderNavigation "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
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
	this._visible = visible;
	flamingo.raiseEvent(this,"onInit",this);
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
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "buttons" :
			buttons = val.toUpperCase().split(",");
			break;
		case "offset" :
			offset = Number(val);
			break;
		case "updatedelay" :
			updatedelay = Number(val);
			break;
		case "skin" :
			skin = val;
			break;
		}
	}

	refresh();

	
}
function refresh() {
	for (var i = 0; i<buttons.length; i++) {
		var pos = buttons[i];
		switch (pos) {
		case "W" :
			fbW = new FlamingoButton(createEmptyMovieClip("mW", 1), skin+"_W_up", skin+"_W_over", skin+"_W_down", skin+"_W_up");
			fbW.onPress = function() {
				startMove("W");
			};
			fbW.onRelease = function() {
				stopMove();
			};
			fbW.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_west"), thisObj.mW);
			};
			fbW.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "E" :
			fbE = new FlamingoButton(createEmptyMovieClip("mE", 2), skin+"_E_up", skin+"_E_over", skin+"_E_down", skin+"_E_up");
			fbE.onPress = function() {
				startMove("E");
			};
			fbE.onRelease = function() {
				stopMove();
			};
			fbE.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_east"), thisObj.mE);
			};
			fbE.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "N" :
			fbN = new FlamingoButton(createEmptyMovieClip("mN", 3), skin+"_N_up", skin+"_N_over", skin+"_N_down", skin+"_N_up");
			fbN.onPress = function() {
				startMove("N");
			};
			fbN.onRelease = function() {
				stopMove();
			};
			fbN.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_north"), thisObj.mN);
			};
			fbN.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "S" :
			fbS = new FlamingoButton(createEmptyMovieClip("mS", 4), skin+"_S_up", skin+"_S_over", skin+"_S_down", skin+"_S_up");
			fbS.onPress = function() {
				startMove("S");
			};
			fbS.onRelease = function() {
				stopMove();
			};
			fbS.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_south"), thisObj.mS);
			};
			fbS.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "NE" :
			fbNE = new FlamingoButton(createEmptyMovieClip("mNE", 5), skin+"_NE_up", skin+"_NE_over", skin+"_NE_down", skin+"_NE_up");
			fbNE.onPress = function() {
				startMove("NE");
			};
			fbNE.onRelease = function() {
				stopMove();
			};
			fbNE.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_northeast"), thisObj.mNE);
			};
			fbNE.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "SE" :
			fbSE = new FlamingoButton(createEmptyMovieClip("mSE", 6), skin+"_SE_up", skin+"_SE_over", skin+"_SE_down", skin+"_SE_up");
			fbSE.onPress = function() {
				startMove("SE");
			};
			fbSE.onRelease = function() {
				stopMove();
			};
			fbSE.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_southeast"), thisObj.mSE);
			};
			fbSE.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "SW" :
			fbSW = new FlamingoButton(createEmptyMovieClip("mSW", 7), skin+"_SW_up", skin+"_SW_over", skin+"_SW_down", skin+"_SW_up");
			fbSW.onPress = function() {
				startMove("SW");
			};
			fbSW.onRelease = function() {
				stopMove();
			};
			fbSW.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_southwest"), thisObj.mSW);
			};
			fbSW.onReleaseOutside = function() {
				stopMove();
			};
			break;
		case "NW" :
			fbNW = new FlamingoButton(createEmptyMovieClip("mNW", 8), skin+"_NW_up", skin+"_NW_over", skin+"_NW_down", skin+"_NW_up");
			fbNW.onPress = function() {
				startMove("NW");
			};
			fbNW.onRelease = function() {
				stopMove();
			};
			fbNW.onRollOver = function() {
				flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_northwest"), thisObj.mNW);
			};
			fbNW.onReleaseOutside = function() {
				stopMove();
			};
			break;
		}
	}
	resize();
}
function resize(map:MovieClip) {
	var r = flamingo.getPosition(this);
	var left = r.x-offset;
	var top = r.y-offset;
	var right = r.x+r.width+offset;
	var bottom = r.y+r.height+offset;
	var xcenter = (right+left)/2;
	var ycenter = (top+bottom)/2;
	if (fbW != undefined) {
		fbW.move(left, ycenter);
	}
	if (fbE != undefined) {
		fbE.move(right, ycenter);
	}
	if (fbN != undefined) {
		fbN.move(xcenter, top);
	}
	if (fbS != undefined) {
		fbS.move(xcenter, bottom);
	}
	if (fbNE != undefined) {
		fbNE.move(right, top);
	}
	if (fbSE != undefined) {
		fbSE.move(right, bottom);
	}
	if (fbSW != undefined) {
		fbSW.move(left, bottom);
	}
	if (fbNW != undefined) {
		fbNW.move(left, top);
	}
}
function startMove(dir:String) {
	map = flamingo.getComponent(listento[0]);
	var dx = 0;
	var dy = 0;
	var e = map.getCurrentExtent();
	var msx = (e.maxx-e.minx)/map.__width;
	var msy = (e.maxy-e.miny)/map.__height;
	switch (dir) {
	case "N" :
		dy = map.__height/40*msy;
		break;
	case "W" :
		dx = -map.__width/40*msx;
		break;
	case "S" :
		dy = -map.__height/40*msy;
		break;
	case "E" :
		dx = map.__width/40*msx;
		break;
	case "NE" :
		dy = map.__height/40*msy;
		dx = map.__width/40*msx;
		break;
	case "SE" :
		dx = map.__width/40*msx;
		dy = -map.__height/40*msy;
		break;
	case "SW" :
		dy = -map.__height/40*msy;
		dx = -map.__width/40*msx;
		break;
	case "NW" :
		dx = -map.__width/40*msx;
		dy = map.__height/40*msy;
		break;
	}
	var obj:Object = new Object();
	obj.map = map;
	obj.dx = dx;
	obj.dy = dy;
	_moveid = setInterval(this, "_move", 10, obj);
}
function stopMove() {
	clearInterval(_moveid);
	updateMaps();
}
function _move(obj:Object) {
	var e = obj.map.getCurrentExtent();
	e.minx = e.minx+obj.dx;
	e.miny = e.miny+obj.dy;
	e.maxx = e.maxx+obj.dx;
	e.maxy = e.maxy+obj.dy;
	obj.map.moveToExtent(e, -1, 0);
}
function updateMaps() {
	var map = flamingo.getComponent(listento[0]);
	map.update(updatedelay);
	for (var i:Number = 1; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		mc.moveToExtent(map.getMapExtent(), updatedelay);
	}
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}