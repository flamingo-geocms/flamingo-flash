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

import display.spriteloader.SpriteSettings;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
/** @component ToolIdentify
* Tool for identifying maps.
* @file flamingo/classes/gui/tools/ToolIdentify.as (sourcefile)
* @file flamingo/classes/gui/tools/AbstractTool.as
* @file flamingo/classes/gui/button/AbstractButton.as
* @file flamingo/classes/core/AbstractPositionable.as
* @file ToolIdentify.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor click Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/
/** @tag <fmc:ToolIdentify>  
* This tag defines a tool for identifying maps.
* The positioning of the tool is relative to the position of toolGroup.
* @hierarchy childnode of <fmc:ToolGroup>
* @attr zoomscroll (defaultvalue "true")  True or false. Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr identifyall (defaultvalue="true") True: identify all maps. False: identify only the map that's being clicked on.
*/
/**
 * Tool identify to do a identify on the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.tools.ToolIdentify extends AbstractTool{
	var defaultXML:String;
	var skin = "_identify";
	var identifyall:Boolean;
	/**
	 * Constructor for ToolIdentify.
	 * @param	id the id of the button
	 * @param	toolGroup the toolgroup where this tool is in.
	 * @param	container the movieclip that holds this button 
	 * @see 	gui.tools.AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolIdentify(id:String, toolGroup:ToolGroup ,container:MovieClip) {		
		super(id, toolGroup, container);	
		toolDownSettings = new SpriteSettings(3, 903, 23, 24, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(49, 903, 23, 24, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(98, 904, 20, 19, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolIdentify>" +
							"<string id='tooltip' nl='informatie opvragen' en='identify'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='identify'/>" +
							"<cursor id='click'  url='fmc/CursorsMap.swf' linkageid='identify_click'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy' />" +
							"</ToolIdentify>";
		
		init();
	}
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	private function init() {
		var thisObj:ToolIdentify = this;
		this.lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			map.setCursor(thisObj.cursors["click"]);
		};
		this.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {			
			if (thisObj._parent.defaulttool==undefined){
				map.setCursor(thisObj.cursors["cursor"]);
			}
			if (map.isHit({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y})) {
				if (thisObj.identifyall) {
					for (var i:Number = 0; i<thisObj.listento.length; i++) {
						var mc = thisObj.flamingo.getComponent(thisObj.listento[i]);
						mc.identify({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
					}
				} else {
					map.identify({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
				}
			}
		};

		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolIdentify "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
			xml = new XML(String(xml));
			xml= xml.firstChild;
		}
		//load default attributes, strings, styles and cursors   
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "skin" :
				skin = val+"_identify";
				break;
			case "identifyall" :
				if (val.toLowerCase() == "true") {
					identifyall = true;
				} else {
					identifyall = false;
				}
				break;
			case "zoomscroll" :
				if (val.toLowerCase() == "true") {
					zoomscroll = true;
				} else {
					zoomscroll = false;
				}
				break;
			case "enabled" :
				if (val.toLowerCase() == "true") {
					enabled = true;
				} else {
					enabled = false;
				}
				break;
			}
		}
		this.setEnabled(enabled);
		flamingo.position(this);

	}
	//default functions-------------------------------
	function startIdentifying() {		
		_parent.setCursor(this.cursors["busy"]);
	}
	function stopIdentifying() {
		_parent.setCursor(this.cursors["cursor"]);
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	
}