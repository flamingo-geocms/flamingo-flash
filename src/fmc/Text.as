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
/** @component fmc:Text
* Text component. This component uses a standard Flash TextField with html support. 
* When showing large amounts of text or when scrollbars are necesarry, use TextArea instead.
* @file Text.fla (sourcefile)
* @file Text.swf (compiled component, needed for publication on internet)
* @file Text.xml (configurationfile, needed for publication on internet)
*/
/**
 * 
 */
//------------------------
var version:String = "2.0";
//------------------------------------------

var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<Text>" +
						"<style id='a' font-family='verdana' font-size='13px' color='#0033cc' display='block' font-weight='normal'/>" +
						"<style id='.text' font-family='verdana' font-size='13px' color='#666666' display='block' font-weight='bold'/>" +
						"</Text>";
var lParent:Object = new Object();
lParent.onResize = function(m:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(lang:String) {
	refresh();
	resize();
};
flamingo.addListener(lFlamingo, "flamingo", this);
//------------------------
init();
/** @tag <fmc:Text>  
* This tag defines a text. Use standard string and style tags for configuring the text. The string tag has to have id="text".
* Use <![CDATA[...]]> tags to configure html text and avoid interferance with the config xml. See example.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
* <fmc:Text left="10" top="10" width="100" height="20">
* <string id="text">
* <nl>een nederlandse tekst</nl>
* <en>an english text</en>
* </string>
* </fmc:Text>
*/

/**
 * This tag defines a text. 
 */
function init():Void {	
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Text "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}
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
		case "textarea" :
			if (val.toLowerCase() == "true") {
				this.usetextarea = true;
			} else {
				this.usetextarea = false;
			}
			break;
		}
	}
	this.useHandCursor = false;
	var mc:TextField = this.createTextField("ta", 0, 0, 0, 10, 10);
	mc.selectable = false;
	mc.multiline = true;
	mc.wordWrap = true;
	mc.condenseWhite = true;
	mc.html = true;
	mc.styleSheet = flamingo.getStyleSheet(this);
	refresh();
	resize();
}
//------------------------
/**
 * refresh
 */
function refresh() {
	this.setText(flamingo.getString(this, "text"));
}
/**
 * resize
 */
function resize() {
	var r = flamingo.getPosition(this);
	this._x = r.x;
	this._y = r.y;
	ta._width = ta.textWidth+5;
	ta._height = ta.textHeight+5;
}
/**
* Sets a text to the component.
* @param txt:String Text to be set.
*/
function setText(txt:String) {
	if (txt == undefined) {
		txt = "";
	}
	ta._width = 10000;
	ta._height = 10000;
	ta.htmlText = trim(txt);
	ta._width = ta.textWidth+5;
	ta._height = ta.textHeight+5;
}
/**
* Hides a Text component.
*/
function hide() {
	_visible = false;
}
/**
* Shows a Text component.
*/
function show() {
	_visible = true;
}
/**
 * resize
 */
function resize() {
	var r = flamingo.getPosition(this);
	this._x = r.x;
	this._y = r.y;
	if (usetextarea) {
		ta.setSize(r.width, r.height);
	} else {
		ta._width = r.width;
		ta._height = r.height;
	}
}
/**
 * trimL
 * @param	txt
 * @return
 */
function trimL(txt:String):String {
	for (var i = 0; i<txt.length; i++) {
		if (txt.charCodeAt(i)>32) {
			return txt.substr(i, txt.length);
		}
	}
	return txt;
}
/**
 * trimR
 * @param	txt
 * @return
 */
function trimR(txt:String):String {
	for (var i = txt.length; i>0; i--) {
		if (txt.charCodeAt(i)>32) {
			return txt.substring(0, i+1);
		}
	}
	return txt;
}
/**
 * trim left and right
 * @param	txt
 * @return
 */
function trim(txt:String):String {
	txt = trimL(txt);
	return trimR(txt);
}
