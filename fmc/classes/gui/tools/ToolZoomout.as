/**
 * Tool Test
 * @author Roy Braam
 */

import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;

class gui.tools.ToolZoomout extends AbstractTool implements ComponentInterface
{	
	//-----------------------------------------
	var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolZoomout>" +
							"<string id='tooltip' nl='uitzoomen' en='zoom out'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='zoomout'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</ToolZoomout>";
	var zoomfactor:Number = 50;
	var zoomdelay:Number = 0;
	var clickdelay:Number = 1000;
	var zoomscroll:Boolean = true;
	var skin="_zoomout"
	var enabled = true
	var rect:Object = new Object()
	var thisObj = this
	/**
	 * Constructor for creating a toolzoomout
	 * @param	id the id of the tool
	 * @param	toolGroup the toolgroup where this tool is added
	 * @param	container the visible part of this tool (movieclip)
	 * @see AbstractTool
	 */
	public function ToolZoomout(id:String, toolGroup:ToolGroup ,container:MovieClip) {		
		this.toolDownLink = "assets/img/ToolZoomout_down.png";
		this.toolUpLink = "assets/img/ToolZoomout_up.png";
		this.toolOverLink = "assets/img/ToolZoomout_over.png";
		this.tooltipId = "tooltip";
		super(id, toolGroup, container);		
		init();
	}	
	
	//--------------------------------------------------
	/** @tag <fmc:ToolZoomout>  
	* This tag defines a tool for zooming a map. There are two actions; 1 dragging a rectangle and 2 clicking the map (the map wil recenter at the position the user has clicked).
	* @hierarchy childnode of <fmc:ToolGroup> 
	* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
	* @attr zoomdelay  (defaultvalue "0") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags a rectangle. 
	* @attr zoomfactor  (defaultvalue "50") A percentage the map will zoom after the user clicks the map.
	* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
	* @attr enabled (defaultvalue="true") True or false.
	* @attr skin (defaultvalue="") Available skins: "", "f2"
	*/
	function init() {
		var thisObj = this;
		this.lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
			if (thisObj.zoomscroll) {
				if (! thisObj._parent.updating) {
					thisObj._parent.cancelAll();
					var zoom;
					if (delta<=0) {
						zoom = 80;
					} else {
						zoom = 120;
					}
					
					
					var w = map.getWidth();
					var h = map.getHeight();
					var c = map.getCenter();
					var cx = (w/2)-((w/2)/(zoom/100));
					var cy = (h/2)-((h/2)/(zoom/100));
					var px = (coord.x-c.x)/(w/2);
					var py = (coord.y-c.y)/(h/2);
					coord.x = c.x+(px*cx);
					coord.y = c.y+(py*cy);
					map.moveToPercentage(zoom, coord, 500, 0);
					
					thisObj._parent.updateOther(map, 500);
				}
			}
		};
		lMap.onMouseDown = function(mapOnMouseMove:MovieClip, xmouseOnMouseMove:Number, ymouseOnMouseMove:Number, coordOnMouseMove:Object) {
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
		_global.flamingo.position(this.container);
	}
	//default functions-------------------------------
	function startIdentifying() {
	}
	function stopIdentifying() {
	}
	function startUpdating() {
		this._parent.setCursor(this.cursors["busy"]);
	}
	function stopUpdating() {		
		this._parent.setCursor(this.cursors["cursor"]);
	}

	/**
	 * Events
	 */
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	
}