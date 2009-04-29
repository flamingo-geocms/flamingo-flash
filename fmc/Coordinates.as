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
/** @component Coordinates
* Shows coordinates when the mouse is moved over the map.
* @file Coordinates.fla (sourcefile)
* @file Coordinates.swf (compiled component, needed for publication on internet)
* @file Coordinates.xml (configurationfile, needed for publication on internet)
* @configstring xy (default = "[x] [y]") textstring to define coordinates. The values "[x]" and "[y]" are replaced by the actually coordinates.
* @configstyle .xy fontstyle of coordinates(xy) string
*/
var version:String = "2.0";
//-------------------------------

var defaultXML:String = "<string id='xy' nl='[x] [y]' en='[x] [y]'/>" +
						"<style id='.xy' font-family='verdana' font-size='12px' color='#333333' display='block' font-weight='normal'/>";
//---------------------------------
var thisObj:MovieClip = this;
var decimals:Number = 0;
var xy:String;
var resized:Boolean = false;
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(lang:String) {
	thisObj.setString();
};
flamingo.addListener(lFlamingo, "flamingo", this);
var lMap:Object = new Object();
lMap.onRollOut = function(map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {
	tCoord.htmlText = "";
};
lMap.onMouseMove = function(map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {

	var x = coord.x;
	var y = coord.y;
	if (isNaN(x) or isNaN(y)){
		tCoord.htmlText = "";
		return
	}
	if (decimals>0) {
		x = Math.round(x*decimals)/decimals;
		y = Math.round(y*decimals)/decimals;
	}
	var s = xy;
	s = s.split("[x]").join(x);
	s = s.split("[y]").join(y);

	tCoord.htmlText = "<span class='xy'>"+s+"</span>";
	tCoord._width = tCoord.textWidth+5;
	tCoord._height = tCoord.textHeight+5;
	if (not resized) {
		resize();
		resized = true;
	}
};
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(c:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//---------------------------------------
//---------------------------------------
init();
/** @tag <fmc:Coordinates>  
* This tag defines coordinates. It listens to 1 or more mapcomponents.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example 
* <fmc:Coordinates  listento="map,map1"  left="x10" top="bottom -40" decimals="6">
*    <string id="xy" en="lat [y] &lt;br&gt;lon [x] "  nl="breedtegraad [y]  lengtegraad [x]"/>
* </fmc:Coordinates/>
* @attr decimals Number of decimals
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true
		t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Coordinates "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
		return;
	}
	this._visible = false
	
	
	
	var t = this.createTextField("tCoord", 0, 0, 0, 0, 0);
	
	t.multiline = true;
	t.wordWrap = false;
	t.html = true;
	t.selectable = false;
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
	resized = false
	//load default attributes, strings, styles and cursors    
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "decimals" :
			decimals = Math.pow(10, Number(val));
			break;
		}
	}
	flamingo.addListener(lMap, listento, this);
	tCoord.styleSheet = flamingo.getStyleSheet(this);
	this.setString()
}

function setString(){
	this.xy = flamingo.getString(thisObj, "xy", "[x] [y]");
}

function resize() {
	var r = flamingo.getPosition(this)
	this._x = r.x
	this._y = r.y
}
/**
* Shows or hides coordinates.
* This will raise the onSetVisible event.
* @param vis:Boolean True or false.
*/
function setVisible(vis:Boolean):Void {
	this._visible = vis;
	this.visible = vis;
	flamingo.raiseEvent(this, "onSetVisible", this, vis);
}

/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}