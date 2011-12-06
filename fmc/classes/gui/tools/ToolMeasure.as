/**
 * ...
 * @author Roy Braam
 */

import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
import display.spriteloader.SpriteSettings;

/** @component ToolMeasure
* Tool for measuring a single distance on a map.
* @file ToolMeasure.fla (sourcefile)
* @file ToolMeasure.swf (compiled component, needed for publication on internet)
* @file ToolMeasure.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
*/
/** @tag <fmc:ToolMeasure>  
* This tag defines a tool for measuring a distance.
* @hierarchy childnode of <fmc:ToolGroup>
* @example
  <fmc:ToolGroup left="210" top="0" tool="zoom" listento="map">
      <fmc:ToolZoomin id="zoom"/>
      <fmc:ToolZoomout left="30"/>
      <fmc:ToolSuperPan left="60" skin=""/>
      <fmc:ToolIdentify  id="identify" left="90" enabled="false"/>
      <fmc:ToolMeasure left="120" unit=" km" magicnumber="1000">
         <string id="tooltip" en="measure kilometers"/>
  	  </fmc:ToolMeasure>
	  <fmc:ToolMeasure left="150" unit=" m" magicnumber="1">
         <string id="tooltip" en="measure meters"/>
  	  </fmc:ToolMeasure>
  </fmc:ToolGroup>
* @attr units  (defaultvalue "") String attached to the distance number.
* @attr decimals  (defaultvalue "") Number of decimals.
* @attr magicnumber (defaultvalue "1") A number by which the distance is divided, in order to support multiple measure-units.
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
class gui.tools.ToolMeasure extends AbstractTool implements ComponentInterface{
	//-------------------------------------------
	var unit:String = "";
	var decimals:Number = 0;
	var magicnumber:Number = 1;
	var skin:String = "_toolmeasure";
	
	/**
	 * Constructor for creating a Tool Measure
	 * @see AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */	
	public function ToolMeasure(id:String, toolGroup:ToolGroup ,container:MovieClip) {		
		super(id, toolGroup, container);		
		toolOverSettings = new SpriteSettings(4, 951, 23, 23, 0, 0, true, 100);
		toolDownSettings = new SpriteSettings(49, 951, 23, 23, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(97, 953, 20, 20, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolMeasure>" +
						"<string id='tooltip' nl='afstand meten' en='measure'/>" +
						"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='measure'/>" +
						"</ToolMeasure>";
						
		init();
	}
	
	/**
	 * Init function
	 **/
	function init() {
		var thisObj:ToolMeasure = this;
		//onmousedown event when this tool is active	
		this.lMap.onMouseDown = function(mapOnMouseDown:MovieClip, xmouseOnMouseDown:Number, ymouseOnMouseDown:Number, coordOnMouseDown:Object) {
			var x:Number;
			var y:Number;
			x = xmouseOnMouseDown;
			y = ymouseOnMouseDown;

			thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
				var r:Number = Math.sqrt((Math.pow((xmouse-x), 2)+Math.pow((ymouse-y), 2)));
				map.drawCircle("circle_1",{x:x,y:y,radius:r},{color:0x000000,alpha:10},undefined) //{color:0x333333,alpha:100,width:0})
				//map.drawCircle("circle_2",{x:x+1,y:y+1,radius:r},undefined,{color:0xffffff,alpha:100,width:0})
				map.draw("line_2", [{x:x+1, y:y+1},{x:xmouse+1,y:ymouse+1}], undefined,{color:0xffffff,alpha:100,width:0.1})
				map.draw("line_1" ,[{x:x, y:y},{x:xmouse,y:ymouse}], undefined,{color:0x333333,alpha:100,width:0.1})
				
				var d:Number = map.getDistance(map.point2Coordinate({x:x, y:y}), map.point2Coordinate({x:xmouse, y:ymouse}));
				d = d/thisObj.magicnumber;
				if (thisObj.decimals>0) {
					d = Math.round(d*thisObj.decimals)/thisObj.decimals;
				}
				//flamingo.showTooltip(d+unit, map, 0);
				map.showTooltip(d+thisObj.unit, 0);
				
			};
			thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
				map.clearDrawings()
				map.hideTooltip();
				delete thisObj.lMap.onMouseMove;
				delete thisObj.lMap.onMouseUp;
			};
		};
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolMeasure "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "units" :
				unit = val;
				break;
			case "magicnumber" :
				magicnumber = Number(val);
				break;
			case "decimals" :
				decimals = Math.pow(10, Number(val));
				break;
			case "zoomscroll" :
				if (val.toLowerCase() == "true") {
					zoomscroll = true;
				} else {
					zoomscroll = false;
				}
				break;
			case "skin" :
				skin = val+"_measure";
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
	}
	function stopIdentifying() {
	}
	function startUpdating() {
	}
	function stopUpdating() {
	}
	/************************************************************
	 * Events
	 **/ 
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}