/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems BV
 -----------------------------------------------------------------------------*/
/** @component TabControl
* This component will show a tabcontrol with two tabpages
* @file TabControl.as (sourcefile)
* @file TabControl.fla (sourcefile)
* @file TabControl.swf (compiled component, needed for publication on internet)
* @configstring tab1Label Title of the first tabpage
* @configstring tab2Label Title of the second tabpage
*/

var version:String = "3.0";

//-------------------------------
var __width:Number;
var __height:Number;
var tab1Id:String;
var tab1Label:String;
var tab2Id:String;
var tab2Label:String;
//----------------------------------

//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function() {
	refresh();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function( lang:String ) {
	setTabLabels()
	refresh();
};
flamingo.addListener(lFlamingo, "flamingo", this);

//----------------
init();
/** @tag <fmc:TabControl>  
* This tag defines a tabcontrol with two tabpages.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
* <fmc:TabControl left="right -210" right="right -5" top="30" tab1Id="LayerLegend" tab2Id="SymbolLegend">
	<string id="tab1Label"><nl>Onderwerpen</nl><en>Subjects</en></string>
	<string id="tab2Label"><nl>Legenda</nl><en>Legend</en></string>
* </fmc:TabControl>
* @attr tab1Id Id of the first tabpage's component
* @attr tab1Label Title of the first tabpage. With a String tag you can add multilanguage support.
* @attr tab2Id Id of the second tabpage's component
* @attr tab2Label Title of the second tabpage. With a String tag you can add multilanguage support.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>TabControl "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;

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
	
	initTabs();
}

function initTabs(){
	//Init tabpages
	var tab1Content:MovieClip = flamingo.getComponent(this.tab1Id);
	var tab2Content:MovieClip = flamingo.getComponent(this.tab2Id);

	setTabLabels()
	tab1.bottomLine._visible = false;
	tab1Content._visible = true;
	tab2Content._visible = false;
	
	numberOfTabs = 2;
	for (var i:Number = 1; i<=numberOfTabs; i++) {
		line = eval("tab"+i);
		line.onRelease = function() {
			for (var j:Number = 1; j<=numberOfTabs; j++) {
				otherTabs = eval("this._parent.tab"+j);
				otherTabs.bottomLine._visible = true;
			}
			this.bottomLine._visible = false;
			contentFrame = Number(this._name.substr(3, 1));
		
			tab1Content._visible = (contentFrame == 1);
			tab2Content._visible = (contentFrame == 2);
		}
	}
}

function setTabLabels()
{
	this.tab1.lbl.text = "<font color=\"#6666CC\" fontFamily =\"Verdana\"><b>"+flamingo.getString(this, "tab1Label", tab1Label)+"</b></font>";
	this.tab2.lbl.text = "<font color=\"#6666CC\" fontFamily =\"Verdana\"><b>"+flamingo.getString(this, "tab2Label", tab2Label)+"</b></font>";
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
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "skin" :
			skin = val+"_buffer";
			break;
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		case "tab1id" :
			this.tab1Id = val;
			break;
		case "tab1label" :
			this.tab1Label = val;
			break;
		case "tab2id" :
			this.tab2Id = val;
			break;
		case "tab2label" :
			this.tab2Label = val;
			break;
		default :
			break;
		}
	}	
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "pan", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}

function refresh() {
	resize();
}
function resize() {
	var rect:Object = flamingo.getPosition(this)
	this._x = rect.x
	this._y = rect.y
	this._width = rect.width
	this._height = rect.height
}

