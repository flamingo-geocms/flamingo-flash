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
import display.spriteloader.SpriteSettings;
import gui.tools.ToolGroup;
import tools.Logger;

/** @component ToolZoomout
* Tool for zooming a map by dragging a rectangle or just clicking the map
* @file flamingo/classes/gui/tools/ToolZoomout.as (sourcefile)
* @file flamingo/classes/gui/tools/AbstractTool.as
* @file flamingo/classes/gui/button/AbstractButton.as
* @file flamingo/classes/core/AbstractPositionable.as
* @file ToolZoomout.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor busy Cursor shown when a map is updating and holdonupdate(attribute of Map) is set to true.
*/
//--------------------------------------------------
/** @tag <fmc:ToolZoomout>  
* This tag defines a tool for zooming a map. There are two actions; 1 dragging a rectangle and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr zoomdelay  (defaultvalue "0") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags a rectangle. 
* @attr zoomfactor  (defaultvalue "50") A percentage the map will zoom after the user clicks the map.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
*/
/**
 * Tool for zooming a map by dragging a rectangle or just clicking the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.tools.ToolZoomout extends AbstractTool
{	
	//-----------------------------------------	
	var zoomfactor:Number = 50;
	var zoomdelay:Number = 0;
	var clickdelay:Number = 1000;
	var skin:String = "_zoomout";
	var enabled = true
	var rect:Object = new Object()
	
	/**
	 * Constructor for creating a toolzoomout
	 * @param	id the id of the tool
	 * @param	toolGroup the toolgroup where this tool is added
	 * @param	container the visible part of this tool (movieclip)
	 * @see AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolZoomout(id:String, toolGroup:ToolGroup ,container:MovieClip) {	
		super(id, toolGroup, container);		
		toolDownSettings = new SpriteSettings(0, 16*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(SpriteSettings.buttonSize,  16*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize,  16*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolZoomout>" +
							"<string id='tooltip' nl='uitzoomen' en='zoom out'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='zoomout'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</ToolZoomout>";			
		init();
	}	
	/**
	 * Init the component with the defaults and already loaded configs
	 */	
	private function init() {			
		var thisObj:ToolZoomout = this;
		//onmousedown event when this tool is active
		this.lMap.onMouseDown = function(mapOnMouseMove:MovieClip, xmouseOnMouseMove:Number, ymouseOnMouseMove:Number, coordOnMouseMove:Object) {
			var x:Number;
			var y:Number;
			if (! thisObj._parent.updating) {
				thisObj._parent.cancelAll();
				x = xmouseOnMouseMove;
				y = ymouseOnMouseMove;
				thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					thisObj.rect.x  = Math.min(x, xmouse)
					thisObj.rect.y  = Math.min(y, ymouse)
					thisObj.rect.width  = Math.abs(xmouse-x)
					thisObj.rect.height = Math.abs(ymouse-y)
					map.drawRect("zoomrect", thisObj.rect ,{color:0x000000,alpha:10},{color:0xffffff,alpha:60,width:0});
				};
				thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					var dx:Number = Math.abs(xmouse-x);
					var dy:Number = Math.abs(ymouse-y);
					if (dx<5 and dy<5) {
						map.moveToPercentage(thisObj.zoomfactor, coord, thisObj.clickdelay);
					} else {
						var center:Object = new Object();
						center.x = thisObj.rect.x+thisObj.rect.width/2;
						center.y = thisObj.rect.y+thisObj.rect.height/2;
						var coordUp = map.point2Coordinate(center);
						var ext = map.getCurrentExtent();
						var zf = Math.max(thisObj.rect.width/map.__width*100, 20);
						map.moveToPercentage(zf, coordUp, thisObj.zoomdelay);
					}
					thisObj._parent.updateOther(map, thisObj.zoomdelay);
					//puin ruimen                                
					//map.clearDrawings();
					delete thisObj.lMap.onMouseMove;
					delete thisObj.lMap.onMouseUp;
				};
			}
		};
		this.lMap.name = "ToolZoomOut";
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolZoomout "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;

		//defaults
		this.setConfig(defaultXML);
		//custom
		var xmls:Array = _global.flamingo.getXMLs(this);
		for (var i = 0; i < xmls.length; i++){
			this.setConfig(xmls[i]);
		}
		delete xmls;
		//remove xml from repository
		flamingo.deleteXML(this);
		this._visible = this.visible;
		flamingo.raiseEvent(this, "onInit", this.id);			
	}
		
	/*****************************************************************************
	 * config/parse functions
	 */
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "zoomfactor" :
				zoomfactor = Number(val);
				break;
			case "zoomdelay" :
				zoomdelay = Number(val);
				break;
			case "clickdelay" :
				clickdelay = Number(val);
				break;
			case "zoomscroll" :
				if (val.toLowerCase() == "true") {
					zoomscroll = true;
				} else {
					zoomscroll = false;
				}
				break;
			case "skin" :
				skin = val+"_zoomout";
				break
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
		this.setEnabled(enabled);
		//this.setVisible(this.visible);
		flamingo.position(this);
	}
	//default functions-------------------------------	
	function startUpdating() {
		this._parent.setCursor(this.cursors["busy"]);
	}
	function stopUpdating() {		
		this._parent.setCursor(this.cursors["cursor"]);
	}

	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	
}