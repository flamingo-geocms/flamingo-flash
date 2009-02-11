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
/** @component LogoRiscMap
* preloader for the dutch riscmap.
* @file LogoRiscMap.fla (sourcefile)
* @file LogoRiscMap.swf (compiled component, needed for publication on internet)
* @file LogoRiscMap.xml (configurationfile, needed for publication on internet)
* @configstring preloadtitle  text which is shown during the loading of a configuration.
*/
var version:String = "2.0";
var thisObj = this;
var preloadtitle = "";
//------------------------------------------
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function() {
	thisObj.preloadtitle = flamingo.getString(this, "preloadtitle");
};
lFlamingo.onResize = function() {
	resize();
};
lFlamingo.onConfigProgress = function(nrcomps:Number, totalcomps:Number, nrconfigs:Number, totalconfigs:Number) {
	thisObj._visible =true
	var p = Math.round((nrcomps/totalcomps*100)*nrconfigs/totalconfigs);
	thisObj.mLogo.txt.htmlText = "<span class='preloadtitle'>"+thisObj.preloadtitle.split("[percentage]").join(p)+"</span>";
};
lFlamingo.onConfigComplete = function() {
	thisObj.mLogo.txt.htmlText = "<span class='preloadtitle'>"+thisObj.preloadtitle.split("[percentage]").join("100")+"</span>";
	thisObj.mLogo.onEnterFrame = function() {
		this._xscale = this._yscale=this._xscale-10;
		this._alpha = this._alpha-10;
		if (this._alpha<=0) {
			delete this.onEnterFrame;
			this.removeMovieClip();
		    thisObj._visible =false
		}
	};
};
flamingo.addListener(lFlamingo, flamingo, this);
//---------------------------------------
init();
/** @tag <fmc:LogoRiscMap>  
* @hierarchy childnode of <flamingo> 
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LogoRiscMap "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	this.swapDepths(25879)
	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
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
	//add logo
	if (this.mLogo == undefined) {
	  this.attachMovie("mLogo", "mLogo", 1);
	}
	//load default attributes, strings, styles and cursors         
	flamingo.parseXML(this, xml);
	this.mLogo.txt.styleSheet = flamingo.getStyleSheet(this);
	this.preloadtitle = flamingo.getString(this, "preloadtitle");
	resize();
}
function resize() {
	
	var w = Stage.width;
	var h = Stage.height;
	this.mLogo._x = (w/2);
	this.mLogo._y = (h/2);
}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}