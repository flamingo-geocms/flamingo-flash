
/**
 * Tool Test
 * @author Roy Braam
 */
import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
import display.spriteloader.SpriteSettings;

/** @component ToolZoomout
 * Tool for zooming a map by dragging a rectangle or just clicking the map
 * @file ToolZoomout.fla (sourcefile)
 * @file ToolZoomout.swf (compiled component, needed for publication on internet)
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
 * @attr skin (defaultvalue="") Available skins: "", "f2"
 */


class gui.tools.ToolZoomout extends AbstractTool implements ComponentInterface
{
	
	//-----------------------------------------
	
	var zoomfactor:Number = 50;
	var zoomdelay:Number = 0;
	var clickdelay:Number = 1000;
	var skin:String = "_zoomout";
	var enabled = true;
	var rect:Object = new Object();
	var thisObj = this;
	
	/**
	 * Constructor for creating a toolzoomout
	 * @param	id the id of the tool
	 * @param	toolGroup the toolgroup where this tool is added
	 * @param	container the visible part of this tool (movieclip)
	 * @see AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	
	
	public function ToolZoomout(id:String, toolGroup:ToolGroup, container:MovieClip)
	{
		super(id, toolGroup, container);
		toolDownSettings = new SpriteSettings(2, 1209, 25, 23, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(48, 1209, 25, 23, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(97, 1210, 22, 19, 0, 0, true, 100);
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" + "<ToolZoomout>" + "<string id='tooltip' nl='uitzoomen' en='zoom out'/>" + "<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='zoomout'/>" + "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" + "</ToolZoomout>";
		init();
	}
	
	private function init()
	{
		var thisObj:ToolZoomout = this;
		
		//onmousedown event when this tool is active
		
		this.lMap.onMouseDown = function(mapOnMouseMove:MovieClip, xmouseOnMouseMove:Number, ymouseOnMouseMove:Number, coordOnMouseMove:Object)
		{
			var x:Number;
			var y:Number;
			if(!thisObj._parent.updating)
			{
				thisObj._parent.cancelAll();
				x = xmouseOnMouseMove;
				y = ymouseOnMouseMove;
				thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object)
				{
					thisObj.rect.x = Math.min(x, xmouse);
					thisObj.rect.y = Math.min(y, ymouse);
					thisObj.rect.width = Math.abs(xmouse - x);
					thisObj.rect.height = Math.abs(ymouse - y);
					map.drawRect("zoomrect", thisObj.rect, 
					{
						color : 0x000000,
						alpha : 10
					}, 
					{
						color : 0xffffff,
						alpha : 60,
						width : 0
					});
				};
				thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object)
				{
					var dx:Number = Math.abs(xmouse - x);
					var dy:Number = Math.abs(ymouse - y);
					if(dx<5 && dy<5)
					{
						map.moveToPercentage(thisObj.zoomfactor, coord, thisObj.clickdelay);
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
		if(flamingo == undefined)
		{
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolZoomout " + this.version + "</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
		
		//defaults
		
		this.setConfig(defaultXML);
		
		//custom
		
		var xmls:Array = _global.flamingo.getXMLs(this);
		for(var i = 0; i < xmls.length; i++)
		{
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
	
	
	function setConfig(xml:Object)
	{
		if(typeof(xml) == "string")
		{
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		
		//load default attributes, strings, styles and cursors
		
		flamingo.parseXML(this, xml);
		
		//parse custom attributes
		
		for(var a in xml.attributes)
		{
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch(attr){
				case "zoomfactor":
					zoomfactor = Number(val);
					break;
				case "zoomdelay":
					zoomdelay = Number(val);
					break;
				case "clickdelay":
					clickdelay = Number(val);
					break;
				case "zoomscroll":
					if(val.toLowerCase() == "true")
					{
						zoomscroll = true;
					}
					break;
				case "skin":
					skin = val + "_zoomout";
					break;
				case "enabled":
					if(val.toLowerCase() == "true")
					{
						enabled = true;
					}
					break;
				default:
					break;
			};
		}
		this.setEnabled(enabled);
		
		//this.setVisible(this.visible);
		
		flamingo.position(this);
	}
	
	//default functions-------------------------------
	
	
	function startIdentifying()
	{
	}
	
	function stopIdentifying()
	{
	}
	
	function startUpdating()
	{
		this._parent.setCursor(this.cursors["busy"]);
	}
	
	function stopUpdating()
	{
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