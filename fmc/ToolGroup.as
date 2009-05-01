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
/** @component Toolgroup
* Container component for tools.
* @file ToolGroup.fla (sourcefile)
* @file ToolGroup.swf (compiled component, needed for publication on internet)
* @file ToolGroup.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";
//-------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<Toolgroup>" +
						"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
						"</Toolgroup>";
var tool:String;
var defaulttool:String;
//------------------------
var identifying:Boolean = false;
var updating:Boolean = false;
//----listener objects---------
var lFlamingo:Object = new Object();
lFlamingo.onConfigComplete = function() {
	checkFinishUpdate();
	checkFinishIdentify();
	setTool(tool);
};
flamingo.addListener(lFlamingo, "flamingo", this);
//-------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//-------------------------
var lMap:Object = new Object();
lMap.onIdentify = function(map:MovieClip) {

	if (map.holdonidentify) {
		identiying = true;
		flamingo.getComponent(tool).startIdentifying();
	}
};
lMap.onIdentifyComplete = function(map:MovieClip) {
	if (identiying) {
		checkFinishIdentify();
	}
};
lMap.onMouseUp= function(){
		if (defaulttool.length>0) {
		if (tool != defaulttool) {
			setTool(defaulttool);
		}
	}
	
}
lMap.onUpdate = function(map:MovieClip) {

	if (map.holdonupdate) {
		updating = true;
		flamingo.getComponent(tool).startUpdating();
	}
};
lMap.onUpdateComplete = function(map:MovieClip) {
	if (updating) {
		checkFinishUpdate();
	}
};
//-------------------------------
init();
//----------------------------------
/** @tag <fmc:Toolgroup>  
* This tag defines a toolgroup. Listens to 1 or more maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
  <fmc:ToolGroup left="210" top="0" tool="zoom" listento="map">
      <fmc:ToolZoomin id="zoom"/>
      <fmc:ToolZoomout left="30"/>
      <fmc:ToolPan left="60"/>
      <fmc:ToolIdentify left="90"/>
      <fmc:ToolMeasure left="120" unit=" m" magicnumber="1">
         <string id="tooltip" en="measure meters"/>
  	 </fmc:ToolMeasure>
  </fmc:ToolGroup>
* @attr tool  Id of the tool that is set.
* @attr defaulttool  Id of the tool that is set after each update event of a map.
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolGroup "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		var attr:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (attr) {
		case "clear" :
			if (val.toLowerCase() == "true") {
				this.clear();
			}
			break;
		case "tool" :
			tool = val.toLowerCase();
			break;
		case "defaulttool" :
			defaulttool = val.toLowerCase();
			break;
		default :
			break;
		}
	}
	var xTools:Array = xml.childNodes;
	if (xTools.length>0) {
		for (var i:Number = xTools.length-1; i>=0; i--) {
			addTool(xTools[i]);
		}
	}
	flamingo.addListener(lMap, listento, this);
	resize();
}
function resize() {
	var p = flamingo.getPosition(this);
	_x = p.x;
	_y = p.y;
}
function checkFinishUpdate() {
	for (var i:Number = 0; i<listento.length; i++) {
		var c = flamingo.getComponent(listento[i]);
		if (c.updating and c.holdonupdate) {
			updating = true;
			return;
		}
	}
	updating = false;
	flamingo.getComponent(tool).stopUpdating();
}
function checkFinishIdentify() {
	for (var i:Number = 0; i<listento.length; i++) {
		var c = flamingo.getComponent(listento[i]);
		if (c.identifying and c.holdonidentify) {
			identifying = true;
			return;
		}
	}
	identifying = false;
	flamingo.getComponent(tool).stopIdentifying();
}
function cancelAll() {
	for (var i:Number = 0; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		mc.cancelUpdate();
	}
}
function updateOther(map:MovieClip, delay:Number) {
	for (var i:Number = 0; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		if (mc != map) {
			mc.moveToExtent(map.getMapExtent(), delay);
		}
	}
}
/**
* Removes all tools from the toolgroup.
*/
function clear() {
	for (var id in this) {
		if (typeof (this[id]) == "movieclip") {
			this.removeTool(id);
		}
	}
}
/**
* Removes a tool from the toolgroup.
* @param id:String Toolid
*/
function removeTool(id:String) {
	flamingo.killComponent(id);
}
/**
* Gets a list of componentids.
* @return List of componentids.
*/
function getTools():Array {
	var tools:Array = new Array();
	for (var id in this) {
		if (typeof (this[id]) == "movieclip") {
			tools.push(id);
		}
	}
	return tools;
}
/** 
* Adds a tool to the toolgroup.
* @param xml:Object Xml or string representation of xml, describing tool.
*/
function addTool(xml:Object):Void {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	var toolid = xml.attributes.id;
	if (toolid == undefined) {
		toolid = flamingo.getUniqueId();
	}
	if (flamingo.exists(toolid)) {
		//id already exists
		if (flamingo.getParent(toolid) == this) {
			flamingo.addComponent(xml, toolid);
		} else {
			flamingo.killComponent(toolid);
			var mc:MovieClip = this.createEmptyMovieClip(toolid, this.getNextHighestDepth());
			flamingo.loadComponent(xml, mc, toolid);
		}
	} else {
		var mc:MovieClip = this.createEmptyMovieClip(toolid, this.getNextHighestDepth());
		flamingo.loadComponent(xml, mc, toolid);
	}
}
function setCursor(cursor:Object) {
	for (var i:Number = 0; i<listento.length; i++) {
		flamingo.getComponent(listento[i]).setCursor(cursor);
	}
}
/** 
* Sets a tool.
* @param toolid:String Id of tool that has to be set.
*/
function setTool(toolid:String):Void {
	if (toolid == undefined) {
		return;
	}
	flamingo.raiseEvent(this, "onReleaseTool", this, tool);
	flamingo.getComponent(tool)._releaseTool();
	tool = toolid;
	flamingo.getComponent(tool)._pressTool();
	flamingo.raiseEvent(this, "onSetTool", this, tool);
}
function initTool(mc:MovieClip, uplink:String, overlink:String, downlink:String, hitlink:String, maplistener:Object, cursorid:String, tooltipid:String) {
	this.resize();
	mc._pressed = false;
	mc._enabled = true;
	mc.attachMovie(uplink, "mSkin", 1);
	mc.attachMovie(hitlink, "mHit", 0, {_alpha:0});
	mc.mHit.useHandCursor = false;
	mc.setVisible = function(b:Boolean) {
		mc.visible = b;
		mc._visible = b;
	};
	mc.setEnabled = function(b:Boolean) {
		if (b) {
			mc._alpha = 100;
		} else {
			mc._alpha = 20;
			if (mc._pressed) {
				setCursor(undefined);
				mc._releaseTool();
			}
		}
		mc._enabled = b;
		mc.enabled = b;
	};
	mc._releaseTool = function() {
		if (mc._enabled) {
			mc._pressed = false;
			mc.attachMovie(uplink, "mSkin", 1);
			flamingo.removeListener(maplistener, listento, this);
			mc.releaseTool();
		}
	};
	//
	mc._pressTool = function() {
		if (mc._enabled) {
			mc._pressed = true;
			mc.attachMovie(downlink, "mSkin", 1);
			setCursor(mc.cursors[cursorid]);
			flamingo.addListener(maplistener, listento, this);
			mc.pressTool();
		}
	};
	//
	mc.mHit.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(mc, tooltipid), mc);
		if (mc._enabled) {
			if (not mc._pressed) {
				mc.attachMovie(overlink, "mSkin", 1);
			}
		}
	};
	//
	mc.mHit.onRollOut = function() {
		if (not mc._pressed) {
			mc.attachMovie(uplink, "mSkin", 1);
		}
	};
	//
	mc.mHit.onPress = function() {
		if (mc._enabled) {
			setTool(flamingo.getId(mc));
		}
	};
}
/**
* Dispatched when a tool is released.
* @param toolgroup:MovieClip a reference or id of the toolgroup.
* @param toolid:MovieClip Id of tool which is released.
*/
//public function onReleaseTool(toolgroup:MovieClip, toolid:String):Void {
//
/**
* Dispatched when a tool is set.
* @param toolgroup:MovieClip a reference or id of the toolgroup.
* @param toolid:MovieClip Id of tool which is set.
*/
//public function onSetTool(toolgroup:MovieClip, toolid:String):Void {
//
/**
* Dispatched when the component is up and running.
* @param toolgroup:MovieClip a reference or id of the toolgroup.
*/
//public function onInit(toolgroup:MovieClip):Void {
//
