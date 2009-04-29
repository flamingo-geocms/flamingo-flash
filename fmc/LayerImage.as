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
/** @component LayerImage
* Image layer. Can load swf, png or jpg images
* @file LayerImage.fla (sourcefile)
* @file LayerImage.swf (compiled layer, needed for publication on internet)
* @file LayerImage.xml (configurationfile for layer, needed for publication on internet)
*/
var version:String = "2.0";

var defaultXML:String = "";
//---------------------------------
//properties which can be set in ini
var imageurl:String;
var extent:Object;
var maxscale:Number;
var minscale:Number;
var visible:Boolean;
var initialized:Boolean = false
//---------------------------------
var thisObj:MovieClip = this;
var map:MovieClip;
//listenerobject for map
var lMap:Object = new Object();
lMap.onChangeExtent = function(map:MovieClip):Void  {
	thisObj.update();
};
lMap.onHide = function(map:MovieClip):Void  {
	thisObj.update();
};
lMap.onShow = function(map:MovieClip):Void  {
	thisObj.update();
};
flamingo.addListener(lMap, flamingo.getParent(this), this);
//-------------------------
init();
//-------------------------
/** @tag <fmc:LayerImage>  
* This tag defines a image layer.
* @hierarchy childnode of <fmc:Map> 
* @attr extent  Extent of layer. Comma seperated list of minx,miny,maxx,maxy.
* @attr url The url of the png, swf or jpg containing the mapimage. The url can be absolute or relative to flamingo.swf.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
* @attr alpha (defaultvalue = "100") Transparency of the layer.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LayerImage "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	map = flamingo.getParent(this);
	//defaults
	var xml:XML = new XML(defaultXML);
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
	if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
		return;
	}
	//load default attributes, strings, styles and cursors    
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "url" :
		case "imageurl" :
			imageurl = val;
			break;
		case "alpha" :
			this._alpha = Number(val);
			break;
		case "extent" :
			extent = map.string2Extent(val);
			break;
		case "maxscale" :
			maxscale = Number(val);
			break;
		case "minscale" :
			minscale = Number(val);
			break;
		}
	}

	setImage(imageurl, extent);
}
/**
* Sets the transparency of a layer.
* @param alpha:Number A number between 0 and 100, 0=transparent, 100=opaque
*/
function setAlpha(alpha:Number) {
	this._alpha = alpha;
}
/**
* loads an image into the layer.
* @param url:String 
* @param extent:Object  
*/
function setImage(url:String, extent:Object) {

	if (url != undefined and map.isValidExtent(extent)) {
	
		imageurl = flamingo.getNocacheName(flamingo.correctUrl(url), "hour");
		extent = extent;
		var listener:Object = new Object();
		//
		listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
			flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
		};
		//
		listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
			flamingo.raiseEvent(thisObj, "onUpdateProgress", thisObj, bytesLoaded, bytesTotal);
		};
		//
		listener.onLoadInit = function(mc:MovieClip) {
            thisObj.initialized = true
			var loadtime = (new Date()-starttime)/1000;
			thisObj.update();
			
			//mHolder.cacheAsBitmap = true;
			flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, loadtime, mc.getBytesTotal());
			if (thisObj.map.fadesteps>0) {
				var step = (100/map.fadesteps)+1;
				thisObj.onEnterFrame = function() {
					thisObj.mHolder._alpha = thisObj.mHolder._alpha+step;
					if (thisObj.mHolder._alpha>=100) {
						
						delete thisObj.onEnterFrame;
					}
				};
			} else {
				thisObj.mHolder._alpha = 100;
			}
		};
		//
		var mc = this.createEmptyMovieClip("mHolder", 1);
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener(listener);
		mHolder._alpha = 0;

		mcl.loadClip(imageurl, mHolder);
		var starttime:Date = new Date();
		flamingo.raiseEvent(thisObj, "onUpdate", thisObj);
		
	}
}

/**
* Updates a layer.
*/
function update() {
	if (not this.initialized) {
		return
	}
	if (visible) {
		if (not map.hasextent) {
			mHolder._visible = false;
			return;
		}
		if (not map.isHit(extent)) {
			mHolder._visible = false;
			return;
		}
		var ms:Number = map.getScale();
		if (minscale != undefined) {
			if (ms<=minscale) {
				mHolder._visible = false;
				return;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				mHolder._visible = false;
				return;
			}
		}
		var r:Object = map.extent2Rect(extent);
		mHolder._x = r.x;
		mHolder._y = r.y;
		mHolder._width = r.width;
		mHolder._height = r.height;
		
		
		if (mHolder._xscale>20000) {
			mHolder._visible = false;
		} else {
			mHolder._visible = true;
		}
	} else {
		mHolder._visible = false;
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
* Shows a layer.
*/
function show():Void {
	visible = true;
	_visible = true;
	update();
	flamingo.raiseEvent(thisObj, "onShow", thisObj);
}
/**
* Hides a layer.
*/
function hide():Void {
	visible = false;
	_visible = false;
	update();
	flamingo.raiseEvent(thisObj, "onHide", thisObj);
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
* Dispatched when the layerimage is downloaded.
* @param layer:MovieClip a reference to the layer.
* @param bytesloaded:Number   Number of bytes already downloaded. 
* @param bytestotal:Number   Total of bytes to be downloaded.
*/
//public function onUpdateProgress(layer:MovieClip, bytesloaded:Number, bytestotal:Number):Void {
//
/**
* Dispatched when a the layer is up and running and ready to update for the first time.
* @param layer:MovieClip a reference to the layer.
*/
//public function onInit(layer:MovieClip):Void {
/** Dispatched when the layer is completely updated.
* @param layer:MovieClip a reference to the layer.
* @param updatetime:Object total time of the update sequence
*/
//public function onUpdateComplete(layer:MovieClip, updatetime:Number):Void {
/**
* Dispatched when the layer is updated and an error occurs.
* @param layer:MovieClip a reference to the layer.
* @param error:String error message
*/
//public function onUpdateError(layer:MovieClip, error:String):Void {
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