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
/** @component LayerGrid
* Grid layer.
* @file LayerGrid.fla (sourcefile)
* @file LayerGrid.swf (compiled layer, needed for publication on internet)
* @file LayerGrid.xml (configurationfile for layer, needed for publication on internet)
*/
var version:String = "2.0";
//------------------------------------
//properties which can be set in ini
var gridheight:Number;
var gridwidth:Number;
var gridlinecolor:Number = 0x777777;
var gridlinealpha:Number = 20;
var gridlinewidth:Number = 0;
var maxlines = 10000;
var maxscale:Number;
var minscale:Number;
//------------------------------------
var map:MovieClip;
var thisObj:MovieClip = this;
//------------------------------------
var lMap:Object = new Object();
lMap.onChangeExtent = function(map:MovieClip) {
	update();
};
lMap.onHide = function(map:MovieClip):Void  {
	thisObj.update();
};
lMap.onShow = function(map:MovieClip):Void  {
	thisObj.update();
};
flamingo.addListener(lMap, flamingo.getParent(this), this);
//----------------------------------------------------
init();
//----------------------------------------------------
/** @tag <fmc:LayerGrid>  
* This tag defines a  grid layer.
* @hierarchy childnode of <fmc:Map> 
* @example 
* <fmc:Map id="map" conform="true" mapunits="DECIMALDEGREES" left="10" top="10" right="right -10" bottom="50%" fullextent="-180,-90,180,90"  extent="-180,-90,180,90"  >
* <fmc:LayerGrid  gridwidth="10" gridheight="10" minscale="11000"/>
* <fmc:LayerGrid  gridwidth="5" gridheight="5" maxscale="11000" minscale="5000"/>
* <fmc:LayerGrid  gridwidth="2" gridheight="2" maxscale="5000" minscale="1000"/>
* <fmc:LayerGrid  gridwidth="1" gridheight="1" maxscale="1000" minscale = "500"/>
* <fmc:LayerGrid  gridwidth="0.5" gridheight="0.5" maxscale="500" minscale="100"/>
* <fmc:LayerGrid  gridwidth="0.1" gridheight="0.1" maxscale="100"/>
* </fmc:Map>
* @attr gridwidth  Width of the grid in mapunits.
* @attr gridheight Height of the grid in mapunits.
* @attr maxlines (defaultvalue "10000") Maximum number of gridlines. If number of gridlines exceeds this value, no grid will be visible.
* @attr gridlinecolor (defaultvalue "#777777") Color of the gridline.
* @attr gridlinewidth (defaultvalue "0") Width of gridline.
* @attr gridlinealpha (defaultvalue "20") Alpha blending of the gridline.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Coordinates "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	map = flamingo.getParent(this);
	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
	this.setConfig(xml);
	delete xml;
	//custom
	//custom
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
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
		case "maxlines" :
			maxlines = Number(val);
			break;
		case "gridlinewidth" :
			gridlinewidth = Number(val);
			break;
		case "gridlinecolor" :
			if (val.charAt(0) == "#") {
				gridlinecolor = Number("0x"+val.substring(1, val.length-1));
			} else {
				gridlinecolor = Number(val);
			}
			break;
		case "gridlinealpha" :
			gridlinealpha = Number(val);
			break;
		case "gridwidth" :
			gridwidth = Number(val);
			break;
		case "gridheight" :
			gridheight = Number(val);
			break;
		case "maxscale" :
			maxscale = Number(val);
			break;
		case "minscale" :
			minscale = Number(val);
			break;
		}
	}
	update();
}
/**
* Updates the layer.
*/
function update() {
	if (visible) {
		if (map == undefined) {
			var map = flamingo.getParent(this);
		}
		if (not map.hasextent) {
			return;
		}
		var ms:Number = map.getScale();
		if (minscale != undefined) {
			if (ms<=minscale) {
				_visible = false;
				return;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				_visible = false;
				return;
			}
		}
		_visible = true;
		if (gridwidth != undefined or gridheight != undefined) {
			var currentextent:Object = map.getCurrentExtent();
			thisObj.createEmptyMovieClip("mGrid", 0);
			//calculate pixelsize of gridcell
			var e = map.getCurrentExtent();
			var msx = (e.maxx-e.minx)/map.__width;
			var msy = (e.maxy-e.miny)/map.__height;
			var pixelw = gridwidth/msx;
			var pixelh = gridheight/msy;
			//calculate how many gridlines are visible
			var xn = map.__width/pixelw;
			var yn = map.__height/pixelh;
			if ((xn*yn)>maxlines) {
				//more than 100 gridlines doesn't make sense, so quit updating
				return;
			}
			//calculate startpoint of grid rounded with gridsize in real coordinates                        
			var x = Math.floor(currentextent.minx/gridwidth)*gridwidth;
			var y = Math.floor(currentextent.maxy/gridheight)*gridheight;
			//calculate startpoint of grid in pixels
			px = (x-currentextent.minx)/msx;
			py = (currentextent.maxy-y)/msy;
			mGrid.lineStyle(gridlinewidth, gridlinecolor, gridlinealpha);
			//drawlines
			for (var x:Number = px; x<map.__width; x=x+pixelw) {
				mGrid.moveTo(x, 0);
				mGrid.lineTo(x, map.__height);
			}
			for (var y:Number = py; y<map.__height; y=y+pixelh) {
				mGrid.moveTo(0, y);
				mGrid.lineTo(map.__width, y);
			}
		}
	} else {
		_visible = false;
	}
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
function hide() {
	visible = false;
	update();
	flamingo.raiseEvent(thisObj, "onHide", thisObj);
}

/**
* Shows a layer.
*/
function show() {
	visible = true;
	update();
	flamingo.raiseEvent(thisObj, "onShow", thisObj);
}
/** 
* Gets the scale of the layer
* @return Number Scale.
*/
function getScale():Number {
	return map.getScale();
}
/** 
* Moves the map to a scale where the maplayer is visible.
* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
*/
function moveToLayer(coord:Object, updatedelay:Number, movetime:Number) {
	var zoomtoscale;
	if (maxscale != undefined) {
		zoomtoscale = maxscale*0.9;
	}
	if (minscale != undefined) {
		zoomtoscale = minscale*1.1;
	}
	if (zoomtoscale != undefined) {
		map.moveToScale(zoomtoscale, coord, updatedelay, movetime);
	}
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
* Dispatched when  the layer is up and running and ready to update for the first time.
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
