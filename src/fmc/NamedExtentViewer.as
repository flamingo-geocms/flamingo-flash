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
/** @component NamedExtentViewer
* Shows names of extents.
* @file NamedExtentViewer.fla (sourcefile)
* @file NamedExtentViewer.swf (compiled layer, needed for publication on internet)
* @file NamedExtentViewer.xml (configurationfile for layer, needed for publication on internet)
* @configstyle .extent Fontstyle of the extentname.
*/
var version:String = "2.0";

var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<NamedExtentViewer>" +
						"<style id='.extent' font-family='verdana' font-size='18px' color='#333333' display='block' font-weight='bold'/>" +
						"</NamedExtentViewer>";
//---------------------------------
//properties which can be set in ini
//---------------------------------
//listenerobject for map


var lMap:Object = new Object();
lMap.onUpdate = function(map:MovieClip):Void  {
		var e = map.getMapExtent();
	if (e.name != undefined) {
		tExtent.htmlText = "<span class='extent'>"+e.name+"</span>";
	} else {
		tExtent.htmlText = "";
	}
	//tExtent.htmlText = "";
}
lMap.onUpdateComplete = function(map:MovieClip):Void  {
	var e = map.getMapExtent();
	if (e.name != undefined) {
		tExtent.htmlText = "<span class='extent'>"+e.name+"</span>";
	} else {
		tExtent.htmlText = "";
	}
};

//-----------------------------------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//-----------------------------------------------------------------
init();
//-----------------------------------
/** @tag <fmc:NamedExtentViewer>  
* This tag defines an NamedExtentViewer. It listens to just one map.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
* <fmc:NamedExtentViewer  xcenter="50%"  width="400" height="50" bottom="95" listento="themap" />
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>NameExtentViewer "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	
	this._visible = false;
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
		createTextField("tExtent", 0, 0, 0, 1, 1);
	//mc.mLabel.border = true;
	tExtent.wordWrap = true;
	tExtent.multiline = true;
	tExtent.html = true;
	tExtent.selectable = false;
	//

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
	//load default attributes, strings, styles and cursors 
	flamingo.parseXML(this, xml);
	//parse custom attributes
	
	tExtent.styleSheet = flamingo.getStyleSheet(this);
	flamingo.addListener(lMap, listento[0], this);
	resize();
}
function resize() {
	var r = flamingo.getPosition(this);
	tExtent._x = r.x;
	tExtent._y = r.y;
	tExtent._width = r.width;
	tExtent._height = r.height;
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}