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
/** @component Maptip
* This component shows the result of a maptip request as a tooltip. 
* The content of the maptips have to be configured at the layers. See documentation of LayerArcIMS, LayerOGWMS, etc.
* Beware: a map will only display maptips when its 'maptipdelay' attribute is set.
* @file Maptip.fla (sourcefile)
* @file Maptip.swf (compiled component, needed for publication on internet)
* @file Maptip.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";

//-------------------------------
var thisObj = this;
//---------------------------------
var lMap:Object = new Object();
lMap.onAddLayer = function(map:MovieClip, layer:MovieClip){
  flamingo.addListener(thisObj.lLayer, layer, thisObj)
};
lMap.onMaptipCancel = function(map:MovieClip):Void  {
	flamingo.hideTooltip();
};
var lLayer:Object = new Object()
lLayer.onMaptipData = function(layer:MovieClip, maptip:String){

	flamingo.showTooltip(maptip, layer.map, 0, false);
}

this.init();

/** @tag <fmc:Maptip>  
* This tag shows maptips as tooltips on a map. This component listens to maps.
* The default size and positioning attributes will have no affect this component.
* @hierarchy childnode of <flamingo>
* @example 
* <fmc:Maptip listento="map"/> 
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Maptip "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	//
	flamingo.addListener(lMap, listento, this);

}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}