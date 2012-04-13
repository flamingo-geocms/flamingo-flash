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

import gui.Map;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/** @component ToolDefault
* Tool for panning a map.
* @file flamingo/classes/gui/tools/ToolDefault.as (sourcefile)
* @file flamingo/classes/gui/tools/AbstractTool.as
* @file flamingo/classes/gui/button/AbstractButton.as
* @file flamingo/classes/core/AbstractPositionable.as
* @file ToolDefault.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor pan Cursor shown when the tool is hoovering over a map.
* @configcursor grab Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/
/** @tag <fmc:ToolDefault>  
* This tag defines a tool for panning a map. There are two actions; 1  dragging and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr pandelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags the map. In this time the user can pickup the map again and the update of the map wil be postponed.
* @attr zoomdelay  (defaultvalue "0") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags a rectangle. 
* @attr zoomfactor  (defaultvalue "200") A percentage the map will zoom after the user clicked the map.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
*/
/**
 * ToolDefault to pan the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.tools.ToolDefault extends AbstractTool{
	
	var defaultXML:String;
	var pandelay:Number = 1000;
	var clickdelay:Number = 1000;
	var xold:Number;
	var yold:Number;	
	var map:Map;
		
	var zoomfactor:Number = 200;
	var zoomdelay:Number = 0;
	
	var clickCounter:Number = 0;
	var clickTimerId:Number;
	// use superpan. If false use pan.
	var useSuperPan:Boolean = true;
	//for superpan
	var velocityid:Number;
	var autopanid:Number;
	var vx:Number;
	var vy:Number;		
	//maphit?
	var maphit:Boolean=true;
	var panning:Boolean;
	//for counting the autopans
	var autoPans:Number = 0;
	var maxAutoPans:Number = 10;
	//mouse values.
	var mouseDownCoord = new Object();
	var mouseDown:Boolean = false;
	var msx;
	var msy;
	/**
	 * Constructor for ToolDefault.
	 * @param	id the id of the button
	 * @param	toolGroup the toolgroup where this tool is in.
	 * @param	container the movieclip that holds this button 
	 * @see 	gui.tools.AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolDefault(id:String, toolGroup:ToolGroup ,container:MovieClip) {	
		super(id, toolGroup, container);			
		toolDownSettings = new SpriteSettings(0, 17*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(SpriteSettings.buttonSize, 17*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 17*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);			
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolDefault>" +
						"<string id='tooltip' nl='Pan(slepen),zoom(dubbel klik) en identify(enkel klik)' en='Pan(drag),zoom(dubble click) and identify (single click)'/>" +
				        "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
				        "<cursor id='default'/>" +
				        "<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab_wrinkle'/>" +
				        "</ToolDefault>"; 
		
		this.cursorId = "default";
		init();
	}
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	private function init() {
		var thisObj:ToolDefault = this;
		this.lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			thisObj.maphit = true;					
			thisObj.onMouseDown(map, xmouse, ymouse, coord);
		}
		this.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object){
			thisObj.onMouseUp(map, xmouse, ymouse, coord);
		}
		
		this.lMap.onRollOut = function(map:MovieClip ){
			thisObj.onRollOut(map);
		}
		this.lMap.onDragOut = function(map:MovieClip){
			thisObj.onDragOut(map);
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
			case "zoomfactor" :
				zoomfactor = Number(val);
				break;
			case "zoomdelay" :
				zoomdelay = Number(val);
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
	/**
	 * On Mouse Down
	 * @param	map the map
	 * @param	xmouse x coord	
	 * @param	ymouse y coord
	 * @param	coord world coords
	 */
	public function onMouseDown(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		this.map = Map(map);		
		clearInterval(this.autopanid);
		this.cancel();
		mouseDownCoord.x = xmouse;
		mouseDownCoord.y = ymouse;
		mouseDownCoord.extent= map.getCurrentExtent();
		mouseDown = true;			
		this.velocityid = setInterval(this,"velocity", 100, map);
		if (! this._parent.updating) {
			this._parent.cancelAll();
			var e = map.getCurrentExtent();
			msx = (e.maxx-e.minx)/map.getMovieClipWidth();
			msy = (e.maxy-e.miny)/map.getMovieClipHeight();
			var x = mouseDownCoord.x;
			var y = mouseDownCoord.y;
			//onmove do PAN
			var thisObj:ToolDefault = this;
			this.lMap.onMouseMove = function(mapMove:MovieClip, xmouseMove:Number, ymouseMove:Number, coordMove:Object) {
				thisObj.onMouseMove(mapMove, xmouseMove, ymouseMove, coordMove);
				//updateAfterEvent();
			};
		}
	}	
	/**
	 * On mouse move
	 * @param	mapMove the map
	 * @param	xmouseMove x coord
	 * @param	ymouseMove y coord
	 * @param	coordMove world coords
	 */
	public function onMouseMove(mapMove:MovieClip, xmouseMove:Number, ymouseMove:Number, coordMove:Object) {
		if (this.mouseDown){
			clearInterval(this.clickTimerId);				
			mapMove.setCursor(this.cursors["grab"]);
			var dx = (mouseDownCoord.x-xmouseMove)*msx;
			var dy = (ymouseMove-mouseDownCoord.y) * msy;
			var e = mouseDownCoord.extent;
			mapMove.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0,true,false);
			//updateAfterEvent();
		};
	}
	/**
	 * On mouse up
	 * @param	map
	 * @param	xmouse
	 * @param	ymouse
	 * @param	coord
	 */
	public function onMouseUp(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		mouseDown = false;
		clearInterval(this.velocityid);
		delete this.lMap.onMouseMove;
		map.setCursor(this.cursors["cursor"]);
		if (map.isEqualExtent(mouseDownCoord.extent, map.getCurrentExtent())) {
			clickCounter++;
			var doubleClick:Boolean = false;
			if (clickCounter == 1) {
				var thisObj:ToolDefault = this;
				clickTimerId = setInterval(function() { 
					clearInterval(thisObj.clickTimerId);
					thisObj.clickCounter = 0; 
					if (!thisObj.mouseDown)
						thisObj.doIdentify(map,xmouse,ymouse,coord);
				}, 250);
			}else if (clickCounter == 2) {
				this.clickCounter = 0; 
				doubleClick = true;
				clearInterval(clickTimerId);
				this.doZoomIn(map,xmouse,ymouse,coord);
			}else {
				this.clickCounter = 0;
			}
		}
		else {
			if (!this.useSuperPan) {
				var msx = (mouseDownCoord.extent.maxx-mouseDownCoord.extent.minx)/map.getMovieClipWidth();
			
				var msy = (mouseDownCoord.extent.maxy - mouseDownCoord.extent.miny) / map.getMovieClipHeight();		
				
				var dx = (mouseDownCoord.x-xmouse)*msx;
				var dy = (ymouse-mouseDownCoord.y)*msy;
				var extent={minx:mouseDownCoord.extent.minx+dx, miny:mouseDownCoord.extent.miny+dy, maxx:mouseDownCoord.extent.maxx+dx, maxy:mouseDownCoord.extent.maxy+dy};
				if (!map.isEqualExtent(mouseDownCoord.extent, extent)) {
					this.flamingo.raiseEvent(map, "onReallyChangedExtent", map, map.copyExtent(extent), 1);
				}						
				//_parent._cursorid = "cursor";
				var delay = this.pandelay;
				map.update(delay);
				this._parent.updateOther(map, delay);
			}else{				
				clearInterval(this.velocityid);
				if ((Math.abs(this.vx)>10 || Math.abs(this.vy)>10) && this.maphit) {
					this.vx = Math.round(this.vx/10);
					this.vy = Math.round(this.vy/10);
					startAutoPan();
				}else{ 
					map.update(0);			
				}
			}
		}
	}		
	/**
	 * On mouse roll out
	 * @param	map the map
	 */
	function onRollOut(map:MovieClip) {
		this.maphit = false;
		this.cancel()
	}	
	/**
	 * On mouse drag out
	 * @param	map the map
	 */
	function onDragOut(map:MovieClip) {
		this.maphit = false;
		this.cancel()
	}
	/**
	 * Auto pan functions
	 */
	/**
	 * Calculates the speed of dragging between 2 calls.
	 * @param	map the movie clip that contains the map
	 */
	function velocity(map:MovieClip) {		
		this.vx = this.xold-map.container._xmouse;
		this.vy = this.yold - map.container._ymouse;
		this.xold = map.container._xmouse;
		this.yold = map.container._ymouse;
	}
	/**
	 * Start the auto pan.
	 */	
	function startAutoPan() {
		clearInterval(this.autopanid);
		this.autoPans = 0;
		this.autopanid = setInterval(this,"autoPan",100, map);				
	}
	/**
	 * Auto pan
	 * @param	map the movie clip that contains the map
	 */
	function autoPan(map:MovieClip) {
		this.panning = true;
		this.autoPans++;
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.__width;
		var msy = (e.maxy-e.miny)/map.__height;
		var dx = vx*msx;
		var dy = -vy * msy;
		map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
		updateAfterEvent();
		if (this.autoPans >= this.maxAutoPans) {
			this.cancel();
		}		
		//slowly hit the breaks... 
		this.vx = this.vx / 1.15;
		this.vy = this.vy / 1.15;		
	}
	/**
	 * Cancel the panning and dragging speed interval
	 */
	function cancel() {
		//trace("CANCEL");
		if (this.panning) {
			this.map.update();
			//_parent.updateOther(panmap, delay);
			clearInterval(this.autopanid);
			clearInterval(this.velocityid);
			panning = false;
		}
	}
	/**
	 * Do a identify
	 * @param	map the map
	 * @param	xmouse x pixel
	 * @param	ymouse y pixel
	 * @param	coord world coords
	 */
	public function doIdentify(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		if (this._parent.defaulttool==undefined){
			map.setCursor(this.cursors["cursor"]);
		}
		if (map.isHit({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y})) {
			map.identify({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});			
		}
	}
	/**
	 * do a zoomin
	 * @param	map the map
	 * @param	xmouse x pixel
	 * @param	ymouse y pixel
	 * @param	coord world coord
	 */
	public function doZoomIn(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
		var x:Number;
		var y:Number;
		if (! this.parent.updating) {
			this.parent.cancelAll();
			x = xmouse;
			y = ymouse;			
			map.moveToPercentage(this.zoomfactor, coord, this.clickdelay);
			this.parent.updateOther(map, this.zoomdelay);	
		}
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	/**
	 * Dispatched when the extent is changed finally
	 * @param	map the map component
	 * @param	extent the new extent
	 */
	//public function onReallyChangedExtent(map:MovieClip, extent:Object){
	//}
	
}