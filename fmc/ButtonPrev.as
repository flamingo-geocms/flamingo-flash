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
/** @component ButtonPrev
* A button to zoom the map to the previous extent.
* @file ButtonPrev.fla (sourcefile)
* @file ButtonPrev.swf (compiled component, needed for publication on internet)
* @file ButtonPrev.xml (configurationfile, needed for publication on internet)
* @configstring tooltip tooltiptext of the button
*/

/*
* Changes oct 2008
* Instead of using property map.nextextents use was made of the 
* new method map.getNextExtents() 
* Author:Linda Vels,IDgis bv
*/

var version = "2.0";

//-------------------------------
var defaultXML:String = "<string id='tooltip'  en='previous extent' nl='stap terug'/>";
var skin:String = "";
var button:FlamingoButton;
//---------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
var lMap:Object = new Object();
lMap.onUpdate = function(map:MovieClip) {
	if (map.getPrevExtents().length>0) {
		button.setEnabled(true);
	} else {
		button.setEnabled(false);
	}
};
//---------------------------------------
init();
/** @tag <fmc:ButtonPrev>  
* This tag defines a button for zooming the map to the previous extent. It listens to 1 or more maps
* Beware! To make this button work properly, it is necessary that the "nrprevextents" of the map is set!
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:ButtonPrev  right="50% 140" top="71" listento="map"/>
* @attr skin (defaultvalue = "") Skin of the button. Available skins: default ("") and "f2".
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ButtonPrev "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		}
	}
	flamingo.addListener(lMap, listento[0], this);
	button = new FlamingoButton(this.createEmptyMovieClip("mButton", 0), skin+"_up", skin+"_over", skin+"_down", skin+"_up", this);
	button.setEnabled(false);
	button.onPress = function() {
		_execute();
	};
	button.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(this, "tooltip"), this);
	};
	resize();

}
function resize() {
	flamingo.position(this);
}
function click() {
	button.press();
}
function _execute() {
	for (var i = 0; i<listento.length; i++) {
		var map = flamingo.getComponent(listento[i]);
		if (map.getHoldOnUpdate() and map.isUpdating()) {
			return;
		}
	}
	for (var i = 0; i<listento.length; i++) {
		flamingo.getComponent(listento[i]).moveToPrevExtent();
	}
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}