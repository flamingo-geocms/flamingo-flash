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

import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/** @component ToolPan
* Tool for panning a map.
* @file flamingo/classes/gui/tools/ToolPan.as (sourcefile)
* @file flamingo/classes/gui/tools/AbstractTool.as
* @file flamingo/classes/gui/button/AbstractButton.as
* @file flamingo/classes/core/AbstractPositionable.as
* @file ToolPan.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor pan Cursor shown when the tool is hoovering over a map.
* @configcursor grab Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/
/** @tag <fmc:ToolPan>  
* This tag defines a tool for panning a map. There are two actions; 1  dragging and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr pandelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags the map. In this time the user can pickup the map again and the update of the map wil be postponed.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
*/
/**
 * ToolPan to pan the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.tools.ToolPan extends AbstractTool{
	
	var defaultXML:String;
	var pandelay:Number = 1000;
	var clickdelay:Number = 1000;
	var xold:Number;
	var yold:Number;	
	var skin = "_pan";	
	
	/**
	 * Constructor for ToolPan.
	 * @param	id the id of the button
	 * @param	toolGroup the toolgroup where this tool is in.
	 * @param	container the movieclip that holds this button 
	 * @see 	gui.tools.AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolPan(id:String, toolGroup:ToolGroup ,container:MovieClip) {	
		super(id, toolGroup, container);			
		toolDownSettings = new SpriteSettings(0, 14*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(SpriteSettings.buttonSize, 14*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 14*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);			
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolPan>" +
						"<string id='tooltip' nl='kaartbeeld slepen' en='pan'/>" +
				        "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
				        "<cursor id='pan'  url='fmc/CursorsMap.swf' linkageid='pan'/>" +
				        "<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab_wrinkle'/>" +
				        "</ToolPan>"; 
		
		this.cursorId = "pan";
		init();
	}
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	private function init() {
		var thisObj:ToolPan = this;
		this.lMap.onMouseDown = function(mapOnMouseDown:MovieClip, xmouseOnMouseDown:Number, ymouseOnMouseDown:Number, coordOnMouseDown:Object) {
			if (! thisObj._parent.updating) {
				thisObj._parent.cancelAll();
				var e = mapOnMouseDown.getCurrentExtent();
				var msx = (e.maxx-e.minx)/mapOnMouseDown.getMovieClipWidth();
				var msy = (e.maxy-e.miny)/mapOnMouseDown.getMovieClipHeight();
				mapOnMouseDown.setCursor(thisObj.cursors["grab"]);
				var x = xmouseOnMouseDown;
				var y = ymouseOnMouseDown;

				thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					var dx = (x-xmouse)*msx;
					var dy = (ymouse-y)*msy;
					map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0,true,false);
					//updateAfterEvent();
				};
				thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					var dx:Number = Math.abs(xmouse-x);
					var dy:Number = Math.abs(ymouse-y);
					
					var extent={minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy};
					if (!map.isEqualExtent(e, extent)) {
						thisObj.flamingo.raiseEvent(map, "onReallyChangedExtent", map, map.copyExtent(extent), 1);
					}			
					//_parent._cursorid = "cursor";
					var delay = thisObj.pandelay;
					
					if (dx<=2 and dy<=2) {
						map.moveToCoordinate(coord, -1, 10);
						delay = thisObj.clickdelay;
					}
					map.setCursor(thisObj.cursors["pan"]);
					map.update(delay);
					thisObj._parent.updateOther(map, delay);
					delete thisObj.lMap.onMouseMove;
					delete thisObj.lMap.onMouseUp;
				};
			}
		};
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolPan "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	* @param xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors       
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "clickdelay" :
				clickdelay = Number(val);
				break;
			case "pandelay" :
				pandelay = Number(val);
				break;
			case "zoomscroll" :
				if (val.toLowerCase() == "true") {
					zoomscroll = true;
				} else {
					zoomscroll = false;
				}
				break;
			case "skin" :
				skin = val+"_pan";
				break;
			case "enabled" :
				if (val.toLowerCase() == "true") {
					enabled = true;
				} else {
					enabled = false;
				}
				break;
			default :
				break;
			}
		}
		//
		this.setEnabled(enabled);
		flamingo.position(this);
	}	
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
}