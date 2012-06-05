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
/** @component LanguagePicker
* Component for changing languages to nl, en, de and fr.
* @file LanguagePicker.fla (sourcefile)
* @file LanguagePicker.swf (compiled component, needed for publication on internet)
* @file LanguagePicker.xml (configurationfile for component, needed for publication on internet)
*/



//keep track of versions
var version:String = "2.0";
//----------------------
var defaultXML:String = "";
// Add listener to parent of this movie for resizing
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//--------------------------------
init();
//---------------
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LanguagePicker "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
	// make buttons
	initButtons();
	//read defaults xml
	//read custom xml's
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}

/** @tag <cmc:LanguagePicker>  
* This tag defines a language picker. 
* @hierarchy childnode of <flamingo> or a container component. e.g. <cmc:Window>
* @example <cmc:LanguagePicker left="10" top="10"  />
*/
function setConfig(xml:XML) {
	// parse all default attributes, such as left,right etc.
	flamingo.parseXML(this, xml);
	reset();
	resize();
}
function initButtons() {
	en.useHandCursor = false;
	nl.useHandCursor = false;
	de.useHandCursor = false;
	fr.useHandCursor = false;
	en.onRollOver = function() {
		this._alpha = 100;
		flamingo.showTooltip("English language", this);
	};
	en.onRelease = function() {
		flamingo.setLanguage("en");
		reset();
	};
	en.onRollOut = en.onDragOut=function () {
		reset();
	};
	nl.onRollOver = function() {
		this._alpha = 100;
		flamingo.showTooltip("Nederlandse taal", this);
	};
	nl.onRollOut = nl.onDragOut=function () {
		reset();
	};
	nl.onRelease = function() {
		flamingo.setLanguage("nl");
		reset();
	};
	de.onRollOver = function() {
		this._alpha = 100;
		flamingo.showTooltip("Deutsche sprache", this);
	};
	de.onRollOut = de.onDragOut=function () {
		reset();
	};
	de.onRelease = function() {
		flamingo.setLanguage("de");
		reset();
	};
	fr.onRollOver = function() {
		this._alpha = 100;
		flamingo.showTooltip("Langue Francaise", this);
	};
	fr.onRollOut = fr.onDragOut=function () {
		reset();
	};
	fr.onRelease = function() {
		flamingo.setLanguage("fr");
		reset();
	};
}
function reset() {
	de._alpha = 0;
	en._alpha = 0;
	fr._alpha = 0;
	nl._alpha = 0;
	var lang = flamingo.getLanguage().toLowerCase();
	this[lang]._alpha = 100;
}
function resize() {
	var r = flamingo.getPosition(this);
	_x = r.x;
	_y = r.y;
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}