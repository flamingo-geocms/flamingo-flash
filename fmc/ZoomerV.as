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
/** @component ZoomerV
* A vertical zoombar.
* @file ZoomerV.fla (sourcefile)
* @file ZoomerV.swf (compiled component, needed for publication on internet)
* @file ZoomerV.xml (configurationfile, needed for publication on internet)
* @configstring tooltip_zoomin Tooltip of zoomin button.
* @configstring tooltip_zoomout Tooltip of zoomout button.
* @configstring tooltip_slider Tooltip of slider button.
*/
var version:String = "2.0";
//---------------------------------------
var defaultXML:String = "<string id='tooltip_zoomin' en='zoom in' nl='inzoomen'/>" +
  						"<string id='tooltip_zoomout' en='zoom out' nl='uitzoomen'/>";
var skin = "";
var _zoomid:Number;
var thisObj = this;
var bSlide:Boolean = false;
var center:Object;
var updatedelay:Number = 500;
//listeners
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//---------------------------------------
var lMap = new Object();
lMap.onInit = function(map:MovieClip) {
	refresh();
};
lMap.onChangeExtent = function(map:MovieClip) {
	refresh();
};
lMap.onUpdate = function(map:MovieClip) {
	refresh();
};
//---------------------------------------
init();
/** @tag <fmc:ZoomerV>  
* This tag defines a vertical zoombar. It listens to 1 or more maps.
* @example
* <fmc:Window top="100" left="100" width="300" bottom="bottom" canresize="true" canclose="true" title="Identify results">
* @example
* <fmc:ZoomerV left="10" top="10" height="300" listento="map">
*    <string id="tooltip_zoomin" en="zoomin" nl="inzoomen"/>
*    <string id="tooltip_zoomout" en="zoomout" nl="uitzoomen"/>
*    <string id="tooltip_slider" en="..." nl="..."/>
* </fmc:ZoomerV>
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @attr updatedelay (defaultvalue="500") Amount of time in milliseconds(1000 = 1 second) between releasing the zoomin/out and slider buttons and the update of a map.
* @attr skin (defaultvalue="") Available skins: "", "f2" 
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true
		t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ZoomerV "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
		return;
	}
	this._visible = false
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
	this._visible = this.visible
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
			case "skin" :
			skin = val;
			break;
		case "updatedelay" :
			updatedelay = Number(val);
			break;
		}
	}

	flamingo.addListener(lMap, listento[0], this);
	//build buttons
	//
	bZoomin = new FlamingoButton(createEmptyMovieClip("mZoomin", 1), skin+"_zoomin_up", skin+"_zoomin_over", skin+"_zoomin_down", skin+"_zoomin_up", this);
	bZoomin.onPress = function() {
		cancelUpdate();
		var map = flamingo.getComponent(listento[0]);
		_zoomid = setInterval(this, "_zoom", 10, map, 105);
	};
	bZoomin.onRelease = function() {
		clearInterval(_zoomid);
		updateMaps();
	};
	bZoomin.onReleaseOutside = function() {
		clearInterval(_zoomid);
		updateMaps();
	};
	bZoomin.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_zoomin"), mZoomin);
	};
	//
	bZoomout = new FlamingoButton(createEmptyMovieClip("mZoomout", 2), skin+"_zoomout_up", skin+"_zoomout_over", skin+"_zoomout_down", skin+"_zoomout_up", this);
	bZoomout.onPress = function() {
		cancelUpdate();
		var map = flamingo.getComponent(listento[0]);
		_zoomid = setInterval(this, "_zoom", 10, map, 95);
	};
	bZoomout.onRelease = function() {
		clearInterval(_zoomid);
		updateMaps();
	};
	bZoomout.onReleaseOutside = function() {
		clearInterval(_zoomid);
		updateMaps();
	};
	bZoomout.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_zoomout"), mZoomout);
	};
	//
	bSlider = new FlamingoButton(createEmptyMovieClip("mSlider", 4), skin+"_slider_up", skin+"_slider_over", skin+"_slider_down", skin+"_slider_up", this);
	bSlider.onPress = function() {
		cancelUpdate();
		var l = mSlider._x;
		var t = mSliderbar._y;
		var r = mSlider._x;
		var b = mSliderbar._y+mSliderbar._height;
		startDrag(mSlider, false, l, t, r, b);
		var map = flamingo.getComponent(listento[0]);
		center = map.getCenter();
		this.onMouseMove = function() {
			bSlide = true;
			zoomSlider();
		};
	};
	bSlider.onRelease = function() {
		bSlide = false;
		delete this.onMouseMove;
		stopDrag();
		updateMaps();
	};
	bSlider.onReleaseOutside = function() {
		bSlide = false;
		delete this.onMouseMove;
		stopDrag();
		updateMaps();
	};
	bSlider.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_slider"), mSlider);
	};
	//
	this.attachMovie(skin+"_slider_bar", "mSliderbar", 3);
	//
	resize();
	refresh();
}
function zoomSlider() {
	var map = flamingo.getComponent(listento[0]);
	//var mq = map.movequality
	var max = map.getMaxScale();
	var min = map.getMinScale();
	if (min == undefined) {
		min = 0.001;
	}
	p = (mSlider._y-mSliderbar._y)/mSliderbar._height*100;
	p = p/21.544347;
	p = p*p*p;
	p = Math.min(100, p);
	p = Math.max(0, p);
	var scale = min+((max-min)*p/100);
	map.moveToScale(scale, center, -1, 0);
}
function refresh() {
	if (bSlide) {
		return;
	}
	var map = flamingo.getComponent(listento[0]);
	var max = map.getMaxScale();
	var min = map.getMinScale();
	if (min == undefined) {
		min = 0;
	}
	var p
	var scale = map.getScale();
	if (scale == min) {

		p = 0;
	} else if (scale == max) {

		p = 100;
	} else {
		
		var p = (scale-min)/(max-min)*100;
		p = Math.pow(p, (1/3))*21.544347;
		p = Math.min(100, p);
		p = Math.max(0, p);
		if (isNaN(p)) {
			p = 0;
		}
	}

	mSlider._y = mSliderbar._y+(mSliderbar._height*p/100);

}
function resize() {
	var r = flamingo.getPosition(this);
	mZoomin._x = r.x;
	mZoomin._y = r.y;
	mZoomout._x = r.x;
	mZoomout._y = r.y+r.height-mZoomout._height;
	mSliderbar._x = r.x+mZoomin._width/2-mSliderbar._width/2;
	mSliderbar._y = r.y+mZoomin._height+mSlider._height/2;
	mSliderbar._height = r.height-mZoomout._height-mZoomin._height-mSlider._height;
	mSlider._x = mSliderbar._x;
	mSlider._y = mSliderbar._y;
	refresh()
}
function _zoom(map:MovieClip, perc:Number) {
	if (map.getScale() == 0) {
		if (perc>100) {
			clearInterval(_zoomid);
			//zoomin
		} else {
			map.moveToScale(0.001, undefined, -1, 0);
			//zoomout
		}
	}
	map.moveToPercentage(perc, undefined, -1, 0);
}
function updateMaps() {
	var map = flamingo.getComponent(listento[0]);
	map.update(updatedelay);
	for (var i:Number = 1; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		mc.moveToExtent(map.getMapExtent(), updatedelay);
	}
}
function cancelUpdate() {
	for (var i:Number = 0; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		mc.cancelUpdate();
	}
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}