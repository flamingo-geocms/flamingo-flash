/**
 * ...
 * @author Roy Braam
 */

import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;

/** @component ToolZoomin
* Tool for zooming the a map by dragging a rectangle or just clicking the map
* @file ToolZoomin.fla (sourcefile)
* @file ToolZoomin.swf (compiled component, needed for publication on internet)
* @file ToolZoomin.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor busy Cursor shown when a map is updating and holdonupdate(attribute of Map) is set to true.
*/
//--------------------------------------------------
/** @tag <fmc:ToolZoomin>  
* This tag defines a tool for zooming a map. There are two actions; 1 dragging a rectangle and 2 clicking the map (the map wil recenter at the position the user has clicked).
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr clickdelay  (defaultvalue "1000") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user clicks the map. In this time the user can click again and the update of the map wil be postponed.
* @attr zoomdelay  (defaultvalue "0") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags a rectangle. 
* @attr zoomfactor  (defaultvalue "200") A percentage the map will zoom after the user clicked the map.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
class gui.tools.ToolZoomin extends AbstractTool implements ComponentInterface{
	var version:String = "2.0";

	//----------------------------
	var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolZoomin>" +
							"<string id='tooltip' nl='inzoomen' en='zoom in'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='zoomin'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</ToolZoomin>";
	var zoomfactor:Number = 200;
	var zoomdelay:Number = 0;
	var clickdelay:Number = 1000;
	var zoomscroll:Boolean = true;
	var skin = "_zoomin";
	var enabled = true;
	var rect:Object = new Object();
//----------------------------
	/**
	 * Constructor for creating a toolzoomout
	 * @param	id the id of the tool
	 * @param	toolGroup the toolgroup where this tool is added
	 * @param	container the visible part of this tool (movieclip)
	 * @see AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolZoomin(id:String, toolGroup:ToolGroup ,container:MovieClip) {		
		this.toolDownLink = "assets/img/ToolZoomin_down.png";
		this.toolUpLink = "assets/img/ToolZoomin_up.png";
		this.toolOverLink = "assets/img/ToolZoomin_over.png";
		this.tooltipId = "tooltip";
		super(id, toolGroup, container);		
		init();
	}	
	/*Init function*/
	private function init() {
		Logger.console("INIT: " + this.id);
		Logger.console("Old listener name :" +this.lMap.name);
		var thisObj:ToolZoomin = this;
		this.lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
			if (thisObj.zoomscroll) {
				if (!thisObj._parent.updating) {
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
		this.lMap.onMouseDown = function(mapOnMouseDown:MovieClip, xmouseOnMouseDown:Number, ymouseOnMouseDown:Number, coordOnMouseDown:Object) {
			var x:Number;
			var y:Number;
			if (! thisObj._parent.updating) {
				thisObj._parent.cancelAll();
				x = xmouseOnMouseDown;
				y = ymouseOnMouseDown;
				thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					thisObj.rect.x  = x
					thisObj.rect.y  = y
					thisObj.rect.width  =(xmouse-x)
					thisObj.rect.height = (ymouse-y)
					map.drawRect("zoomrect", thisObj.rect ,{color:0x000000,alpha:10},{color:0xffffff,alpha:60,width:0});
				};
				thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					var dx:Number = Math.abs(xmouse-x);
					var dy:Number = Math.abs(ymouse-y);
					if (dx<5 and dy<5) {
						map.moveToPercentage(thisObj.zoomfactor, coord, thisObj.clickdelay);
					} else {
						//var r:Object = new Object();
						//r.x = Math.min(x, xmouse);
						//r.y = Math.min(y, ymouse);
						//r.width = map.mAcetate.mRect1234._width;
						//r.height = map.mAcetate.mRect1234._height;
						var ext = map.rect2Extent(thisObj.rect);
						map.moveToExtent(ext, thisObj.zoomdelay);
					}
					thisObj._parent.updateOther(map, thisObj.zoomdelay);
					//puin ruimen                                
					//map.clearDrawings();
					delete thisObj.lMap.onMouseMove;
					delete thisObj.lMap.onMouseUp;
				};
			}
		};
		this.lMap.name = "ToolZoomIn";
		
		if (this.flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolZoomin "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
				skin = val+"_zoomin";
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
		_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
		this.setEnabled(enabled);
		//this.setVisible(visible);
		flamingo.position(this);
	}
	public function setPosition():Void {
		this.container._x = 60;
	}
	//default functions-------------------------------
	function startIdentifying() {
	}
	function stopIdentifying() {
	}
	function startUpdating() {

		_parent.setCursor(this.cursors["busy"]);
	}
	function stopUpdating() {
		
		_parent.setCursor(this.cursors["cursor"]);
	}
	/*************************************************************
	 * Events
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}