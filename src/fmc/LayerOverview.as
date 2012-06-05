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
/** @component fmc:LayerOverview
* This layer drawes an overview (rectangle) on a map. When the overview becomes too small, a crosshair will be displayed.
* @file LayerOverview.fla (sourcefile)
* @file LayerOverview.swf (compiled layer, needed for publication on internet)
* @file LayerOverview.xml (configurationfile for layer, needed for publication on internet)
* @configcursor pan 
* @configcursor grab
*/
/**
 * 
 */
//----------------------------------------
var version:String = "2.0";

// this layer is rather complicated stuff because this layer can be updated by two different sources
// Definitions:
// 1. map=the map to which this layer belongs
// 2. overviewmap = the map for which this layer is the overview
// 3. overview = this layer
// update() = the function to update the overview (this layer) based on the extent of the overviewmap
// updateOverviewMap() = function to update overviewmap based on the extent of this layer.
// followOverview() = function in which the map follows the overview extent multiplied  by followfactor
// extent is the extent of the overviewmap
//---------------------------

var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<LayerOverview>" +
						"<cursor id='pan'  url='fmc/CursorsMap.swf' linkageid='pan'/>" +
    					"<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab' />" +
    					"</LayerOverview>";
var followfactor:Number;
var skin = "";
var color:Number;
var minheight:Number = 18;
var minwidth:Number = 18;
var usehandle:Boolean = true;
//---------------------------
var extent:Object;
var dragid:Number;
var updateoverview:Boolean = true;
var dragging:Boolean = false;
var thisObj = this;
var map:MovieClip;
var updating:Boolean = false;
var lFlamingo:Object = new Object();
lFlamingo.onLoadConfig = function( ) {
	//first action when all components are loaded
	var overviewmap = flamingo.getComponent(listento[0]);
	extent = overviewmap.getCurrentExtent();
	update();
	followOverview();
	// we needed this event once, so release some memory usage
	flamingo.removeListener(lFlamingo, "flamingo", this);
};
flamingo.addListener(lFlamingo, "flamingo", this);
var lOverviewMap:Object = new Object();
lOverviewMap.onUpdate = function(map:MovieClip) {
	if (map.holdonupdate) {
		updating = true;
	}
};
lOverviewMap.onUpdateComplete = function(map:MovieClip) {
	if (updating) {
		checkFinishUpdate();
	}
};
lOverviewMap.onChangeExtent = function(overviewmap:MovieClip) {
	if (updateoverview) {
		extent = overviewmap.getCurrentExtent();
		update();
		followOverview();
	}
};
lOverviewMap.onStopMove = function(overviewmap:MovieClip) {
	extent = overviewmap.getCurrentExtent();
	updateoverview = true;
	followOverview();
};
//-------------------------------
//Listeners for the map for which this layer is the overview
var lMap:Object = new Object();
lMap.onStopMove = function(map:MovieClip) {
	if (not dragging) {
		update();
	}
};
flamingo.addListener(lMap, flamingo.getParent(this),this);
//---------------------------------
init();
//-------------------------
/** @tag <fmc:LayerOverview>  
* This tag defines an overview layer
* @hierarchy childnode of <fmc:Map>  
* @attr color  Color of the rectangle and crosshair in a hexadecimal notation.
* @attr followfactor A percentage describing how much the parent map will follow the overview. e.g. followfactor="200"
* @attr minheight (defaultvalue = "18") Minimum height (in pixels) of overview rectangle before turning into the crosshair.
* @attr minwidth(defaultvalue = "18") Minimum width (in pixels) of overview rectangle before turning into the crosshair.
* @attr usehandle (defaultvalue="true") True or false. True: a resize button is shown in the lower right corner to drag the overview. False: The complete overview can be dragged.
*/

/**
 * This tag defines an overview layer
 */
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LayerOverview "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
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
	//this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}
/**
 * Configurates a component by setting a xml.
 * @param	xml:Object Xml or string representation of a xml.
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
		case "color" :
			if (val.charAt(0) == "#") {
				color = Number("0x"+val.substring(1, val.length));
			} else {
				color = Number(val);
			}
			break;
		case "minwidth" :
			minwidth = Number(val);
			break;
		case "minheight" :
			minheight = Number(val);
			break;
		case "followfactor" :
			followfactor = Number(val);
			break;
		case "skin" :
			skin = val;
			break;
		case "usehandle" :
			if (val.toLowerCase() == "true") {
				usehandle = true;
			} else {
				usehandle = false;
			}
			break;
		}
	}
	map = flamingo.getParent(this);
	//attach rect movie from library and set clipevents
	var mc:MovieClip = this.attachMovie(skin+"_overview", "mOverviewRect", 0);
	if (color != undefined) {
		var colorTrans:flash.geom.ColorTransform = new flash.geom.ColorTransform();
		colorTrans.rgb = color;
		var trans:flash.geom.Transform = new flash.geom.Transform(mOverviewRect);
		trans.colorTransform = colorTrans;
	}
	if (usehandle) {
		var mc:MovieClip = this.attachMovie(skin+"_handle", "mHandle", 1);
		initMc(mc, mOverviewRect);
	} else {
		initMc(mc, mc);
	}
	//crossair
	var mc:MovieClip = this.attachMovie(skin+"_overview_crosshair", "mOverviewCrosshair", 2);
	if (color != undefined) {
		var colorTrans:flash.geom.ColorTransform = new flash.geom.ColorTransform();
		colorTrans.rgb = color;
		var trans:flash.geom.Transform = new flash.geom.Transform(mOverviewCrosshair.cross);
		trans.colorTransform = colorTrans;
	}
	flamingo.addListener(lOverviewMap, listento[0], this);
	initMc(mc, mc);
	_visible = false;
	updateOverview();
}
/**
 * initMc
 * @param	mc
 * @param	target
 */
function initMc(mc:MovieClip, target:MovieClip) {
	mc.useHandCursor = false;
	mc.onPress = function() {
		if (not thisObj.updating) {
			
			
			flamingo.showCursor(thisObj.cursors["grab"]);
			this.startDrag();
			dragging = true;
		}
	};
	mc.onRollOver = function() {
		if (not this.dragging) {
			flamingo.showCursor(thisObj.cursors["pan"]);
			this.hit = true;
		}
	};
	mc.onRollOut = function() {
		if (not this.dragging) {
			flamingo.hideCursor();
			this.hit = false;
		}
	};
	mc.onDragOver = function() {
		if (not this.dragging) {
			flamingo.showCursor(thisObj.cursors["pan"]);
			this.hit = true;
		}
	};
	mc.onDragOut = function() {
		if (not this.dragging) {
			flamingo.hideCursor();
			this.hit = false;
		}
	};
	mc.onMouseMove = function() {
		if (dragging) {
			if (mc != target) {
				target._x = mc._x+mc._width-target._width;
				target._y = mc._y+mc._height-target._height;
			}
			var map = flamingo.getParent(thisObj);
			var dx = 0;
			var dy = 0;
			if (mOverviewRect._x<0) {
				dx = Math.round(mOverviewRect._x);
				//dx = -1;
			}
			if ((mOverviewRect._x+mOverviewRect._width)>map.__width-0) {
				dx = Math.round((mOverviewRect._x+mOverviewRect._width)-map.__width);
				//dx = 1;
			}
			if (mOverviewRect._y<0) {
				dy = Math.round(mOverviewRect._y);
				//dy = -1;
			}
			if ((mOverviewRect._y+mOverviewRect._height)>map.__height-0) {
				dy = Math.round((mOverviewRect._y+mOverviewRect._height)-map.__height);
				//dy = 1;
			}
			if (dx != 0 or dy != 0) {
				clearInterval(dragid);
				dragid = setInterval(dragOverview, 50, map, dx, dy);
			} else {
				clearInterval(dragid);
			}
		}
	};
	mc.onMouseUp = function() {
		clearInterval(dragid);
		if (dragging) {
			stopDrag();
			dragging = false;
			flamingo.showCursor(thisObj.cursors["pan"]);
			updateOverviewMap();
			following = false;
		}
	};
}
/**
 * updateOverviewMap
 */
function updateOverviewMap() {
	// the next update sequence of the overviewmap must not affect this layer
	var map = flamingo.getParent(this);
	var overviewmap = flamingo.getComponent(listento[0]);
	//
	if (mOverviewRect._visible) {
		var rect:Object = new Object();
		rect.x = mOverviewRect._x;
		rect.y = mOverviewRect._y;
		rect.width = mOverviewRect._width;
		rect.height = mOverviewRect._height;
		overviewmap.moveToExtent(map.rect2Extent(rect), 0);
	} else if (mOverviewCrosshair._visible) {
		var coord = map.point2Coordinate({x:mOverviewCrosshair._x, y:mOverviewCrosshair._y});
		var newextent = new Object();
		var w = extent.maxx-extent.minx;
		var h = extent.maxy-extent.miny;
		newextent.minx = coord.x-(w/2);
		newextent.miny = coord.y-(h/2);
		newextent.maxx = newextent.minx+w;
		newextent.maxy = newextent.miny+h;
		overviewmap.moveToExtent(newextent, 0);
	}
	updateoverview = false;
}
/**
 * update
 */
function update() {
	// this function reposition this layer in the parent map based on its extent
	//var map = flamingo.getParent(this);
	//trace(extent.minx)
	if (extent.minx == undefined or isNaN(extent.minx)) {
		mOverviewRect._visible = false;
		mOverviewCrosshair._visible = false;
		mHandle._visible = false;
		return;
	}
	var rect = map.extent2Rect(extent);
	if (rect.width>minwidth and rect.height>minheight) {
		mOverviewRect._x = rect.x;
		mOverviewRect._y = rect.y;
		mOverviewRect._width = rect.width;
		mOverviewRect._height = rect.height;
		if (mHandle != undefined) {
			mHandle._visible = true;
			mHandle._x = rect.x+rect.width-mHandle._width;
			//-mHandle._width
			mHandle._y = rect.y+rect.height-mHandle._height;
			//-mHandle._height
		}
		mOverviewCrosshair._visible = false;
		if ((rect.width/map.__width)<0.75 and (rect.width/map.__width)<0.75) {
			mOverviewRect._visible = true;
			mHandle._visible = true;
		} else {
			mOverviewRect._visible = false;
			mHandle._visible = false;
		}
		/*
		mOverviewCrosshair.onEnterFrame = function() {
		this._alpha =this._alpha-10;
		if (this._alpha<=0) {
		this._visible = false;
		this._alpha = 100;
		delete this.onEnterFrame;
		
		}
		};
		
		        */
	} else {
		mHandle._visible = false;
		mOverviewRect._visible = false;
		mOverviewCrosshair._x = rect.x+(rect.width/2);
		mOverviewCrosshair._y = rect.y+(rect.height/2);
		mOverviewCrosshair._visible = true;
		/*
		mOverviewRect.onEnterFrame = function() {
		this._alpha = this._alpha-10;
		if (this._alpha<=0) {
		this._visible = false;
		this._alpha = 100;
		delete this.onEnterFrame;
		
		}
		};
		*/
	}
	_visible = true;
}
/**
 * followOverview
 */
function followOverview() {
	// this function zooms the parent map based on the extent of the overview and the followfactor
	if (followfactor == undefined) {
		return;
	}
	var followext:Object = new Object();
	var nw = (extent.maxx-extent.minx)/100*followfactor;
	var nh = (extent.maxy-extent.miny)/100*followfactor;
	followext.minx = ((extent.maxx+extent.minx)/2)-nw/2;
	followext.miny = ((extent.maxy+extent.miny)/2)-nh/2;
	followext.maxx = followext.minx+nw;
	followext.maxy = followext.miny+nh;
	flamingo.getParent(this).moveToExtent(followext, 1000, 0);
}
/**
 * dragOverview
 * @param	map
 * @param	dx
 * @param	dy
 */
function dragOverview(map:MovieClip, dx, dy) {
	var e = map.getCurrentExtent();
	var msx = (e.maxx-e.minx)/map.__width;
	var msy = (e.maxy-e.miny)/map.__height;
	dx = dx*msx;
	dy = -dy*msy;
	map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
	//updateAfterEvent();
}
/**
 * checkFinishUpdate
 */
function checkFinishUpdate() {
	for (var i:Number = 0; i<listento.length; i++) {
		var c = flamingo.getComponent(listento[i]);
		if (c.updating and c.holdonupdate) {
			updating = true;
			return;
		}
	}
	updating = false;
}
