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
/** @component Image
* Image component for loading png's, jpg's or swf's.
* Supported arguments: url   eg. flamingo.swf?config=mymap.xml&amp;image1.url=homer.png
* @file Image.fla (sourcefile)
* @file Image.swf (compiled component, needed for publication on internet)
* @file Image.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";
//---------------------------------------
var defaultXML:String = "";
var url:String;
var scale9:Array;
var alpha:Number = 100;
var shadow:Boolean = false;
var vstretch:Boolean = true;
var hstretch:Boolean = true;
var __width:Number;
var __height:Number;
var rotation:Number = 0;
var mask:Boolean = false;
//-------------------------------------
//listeners
var lParent = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this),this);
var lFlamingo:Object = new Object();
lFlamingo.onConfigComplete = function() {
	//deal with arguments
	var arg = flamingo.getArgument(this, "url");
	if (arg != undefined) {
		this.setImage(arg);
		flamingo.deleteArgument(this, "url");
	}
};
flamingo.addListener(lFlamingo, "flamingo", this);
init();
/** @tag <fmc:Image>  
* This tag defines a image component.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @attr vstretch (defaultvalue = "true") True or false. Stretches the image vertical to the available space.
* @attr hstretch (defaultvalue = "true") True or false. Stretches the image horizontal to the available space.
* @attr mask (defaultvalue = "false") True or false. 
* @attr rotation (defaultvalue = "0") Rotation of image in degrees.
* @attr alpha (defaultvalue = "100") Transparency of the image.
* @attr url Url of the image.
* @attr shadow (defaultvalue = "false") True or false.
* @attr scale9 A comma seperated list of four numbers. e.g. scale9="10,10,10,10" Defines the scale behaviour of the image.
*/

/**
 * init
 */
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Image "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
	
	this._visible = false;
	
	//defaults
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
/**
 * Configurates a component by setting a xml.
 * @param xml:Object Xml or string representation of a xml.
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
		case "vstretch" :
			if (val.toLowerCase() == "true") {
				vstretch = true;
			} else {
				vstretch = false;
			}
			break;
		case "hstretch" :
			if (val.toLowerCase() == "true") {
				hstretch = true;
			} else {
				hstretch = false;
			}
			break;
		case "mask" :
			if (val.toLowerCase() == "true") {
				mask = true;
			} else {
				mask = false;
			}
			break;
		case "rotation" :
			rotation = Number(val);
			break;
		case "shadow" :
			if (val.toLowerCase() == "true") {
				shadow = true;
			} else {
				shadow = false;
			}
		case "alpha" :
			this.alpha = Number(val);
			break;
		case "url" :
			url = val;
			break;
		case "scale9" :
			scale9 = new Array();
			var a:Array = val.split(",");
			for (var i = 0; i<a.length; i++) {
				scale9.push(Number(a[i]));
			}
			break;
		}
	}
	this.setImage(url);
}
/**
* Shows or hides a component.
* @param visible:Boolean true or false.
*/
function setVisible(visible:Boolean) {
	this.visible = this._visible=visible;
}
/**
* Sets the transparency of an image.
* @param alpha:Number A number between 0 and 100, 0=transparent, 100=opaque
*/
function setAlpha(alpha:Number) {
	this.alpha = alpha;
	mHolder._alpha = alpha;
}
/**
* Sets a Image.
* @param url:String Url of image.
*/
function setImage(url:String) {
	if (url == undefined) {
		return;
	}
	var thisObj = this;
	url = flamingo.correctUrl(url);
	this.createEmptyMovieClip("mHolder", 0);
	var listener:Object = new Object();
	listener.onLoadInit = function(mc:MovieClip) {
		flamingo.raiseEvent(thisObj, "onSetImage", thisObj, url);
		resize();
	};
	var mcl:MovieClipLoader = new MovieClipLoader();
	mcl.addListener(listener);
	mcl.loadClip(url, mHolder);
}
/**
 * resize
 */
function resize() {
	var r = flamingo.getPosition(this);
	this._x = r.x;
	this._y = r.y;
	this.__width = r.width;
	this.__height = r.height;
	if (this.mask) {
		this.scrollRect = new flash.geom.Rectangle(0, 0, (this.__width), (this.__height));
	}
	mHolder._alpha = alpha;
	mHolder._rotation = rotation;
	if (vstretch) {
		mHolder._height = this.__height;
	} else {
		mHolder._yscale = 100;
	}
	if (hstretch) {
		mHolder._width = this.__width;
	} else {
		mHolder._xscale = 100;
	}
	if (scale9.length == 4) {
		this.mHolder.scale9Grid = new flash.geom.Rectangle(scale9[0], scale9[1], scale9[2], scale9[3]);
	} else {
		this.mHolder.scale9Grid = null;
	}
	if (shadow) {
		_dropShadow(this.mHolder);
	}
}
/**
 * _dropShadow
 * @param	mc
 */
function _dropShadow(mc:MovieClip) {
	import flash.filters.DropShadowFilter;
	var distance:Number = 2;
	var angleInDegrees:Number = 45;
	var color:Number = 0x333333;
	var alpha:Number = .8;
	var blurX:Number = 2;
	var blurY:Number = 2;
	var strength:Number = 0.5;
	var quality:Number = 3;
	var inner:Boolean = false;
	var knockout:Boolean = false;
	var hideObject:Boolean = false;
	var filter:DropShadowFilter = new DropShadowFilter(distance, angleInDegrees, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
	//var filterArray:Array = mc.filters;
	//filterArray.push(filter);
	mc.filters = [filter];
	//filterArray;
}
/**
* Dispatched when a the component is up and running.
* @param comp:MovieClip a reference to the component.
*/
//public function onInit(comp:MovieClip):Void {
/**
* Dispatched when an image is loaded.
* @param comp:MovieClip a reference to the component.
* @param url:String url of loaded image.
*/
//public function onSetImage(comp:MovieClip, url:String):Void {
