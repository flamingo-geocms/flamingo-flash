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
/** @component TextArea
* Text area. This component uses a standard Flash TextArea component
* Use this component to show large amounts of text. Scrollbars will be shown if necessary.
* @file TextArea.fla (sourcefile)
* @file TextArea.swf (compiled component, needed for publication on internet)
* @file TextArea.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";
//------------------------------------------

var defaultXML:String= "<?xml version='1.0' encoding='UTF-8'?>" +
						"<TextArea>" +
						"<style id='a' font-family='verdana' font-size='13px' color='#0033cc' display='block' font-weight='normal'/>" +
  					   "<style id='.text' font-family='verdana' font-size='13px' color='#666666' display='block' font-weight='bold'/>" +
  					   "</TextArea>";
var usetextarea:Boolean = true;
var wordwrap:Boolean = true;
//true
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
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
/** @tag <fmc:TextArea>  
* This tag defines a textarea. Use standard string and style tags for configuring the text. The string tag has to have id="text".
* Use CDATA tags <![CDATA[...]]> to configure html text and avoid interferance with the config xml. See example.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
* <fmc:TextArea left="10" top="10" width="100" height="20">
* <string id="text">
* <nl>een nederlandse tekst</nl>
* <en>an english text</en>
* </string>
* </fmc:TextArea>
*/

/**
 * This tag defines a textarea.
 */
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>TextArea "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;

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
	this.useHandCursor = false;
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
		case "wordwrap" :
			if (val.toLowerCase() == "true") {
				this.wordwrap = true;
			} else {
				this.wordwrap = false;
			}
			break;
		}
	}
	
	if (usetextarea) {
		var mc = this.createClassObject(mx.controls.TextArea, "ta", 1);
		mc.html = true;
		mc.condenseWhite = true;
		mc.styleSheet = flamingo.getStyleSheet(this);
		mc.hScrollPolicy = "auto";
		//on, auto
		mc.vScrollPolicy = "auto";
		mc.wordWrap = wordwrap;
		_global.styles.TextArea.backgroundColor = undefined;
		mc.setStyle("backgroundColor", "");
	} else {
		var mc:TextField = this.createTextField("ta", 0, 0, 0, 10, 10);
		mc.selectable = false;
		mc.multiline = true;
		mc.wordWrap = wordwrap;
		mc.condenseWhite = true;
		mc.html = true;
		mc.styleSheet = flamingo.getStyleSheet(this);
	}
	refresh();
	resize();
}
//------------------------
/**
 * refresh
 */
function refresh() {
	setText(flamingo.getString(this, "text"));
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
		ta._width = ta.textWidth+5;
		//r.width;
		ta._height = ta.textHeight+5;
		//r.height;
	}
	//
}
/**
* Sets a text to the TextArea component.
* @param txt:String Text to be set.
*/
function setText(txt:String) {
	if (txt == undefined) {
		txt = "";
	}
	if (usetextarea) {
		ta.text = txt;
	} else {
		ta.htmlText = trim(txt);
		ta._width = ta.textWidth+5;
		ta._height = ta.textHeight+5;
	}
}
/**
* Hides a TextArea component.
*/
function hide() {
	_visible = false;
}
/**
* Showes a TextArea component.
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
 * trim left
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
 * trim right
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
