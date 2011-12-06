/**
 * ...
 * @author Roy Braam
 */
import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import display.spriteloader.SpriteSettings;
import tools.Logger;
/** @component ToolSuperPan
* Tool for zooming and panning a map like a 'google' way. The user can zoom, pan and throw the map.
* Be very aware that this tool has a huge impact on ArcIMS and OG-WMS mapservices.
* @file ToolSuperPan.fla (sourcefile)
* @file ToolSuperPan.swf (compiled component, needed for publication on internet)
* @file ToolSuperPan.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor grab Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/
/** @tag <fmc:ToolSuperPan>  
* This tag defines a tool for panning and zooming a map. There are 3 actions; 1  dragging and 2 use the scrollwheel and 3 throw the map away.
* @hierarchy childnode of <fmc:ToolGroup> 
* @attr delay  (defaultvalue "800") Time in milliseconds (1000 = 1 second) between releasing the mouse and updating the map when the user drags the map. In this time the user can click again and the update of the map wil be postponed.
* @attr enabled (defaultvalue="true") True or false.
* @attr skin (defaultvalue="") Available skins: "", "f2"
*/
class gui.tools.ToolSuperPan extends AbstractTool implements ComponentInterface{
	var delay:Number = 800;
	var velocityid:Number;
	var autopanid:Number;
	var vx:Number;
	var vy:Number;
	var xold:Number;
	var yold:Number;
	var panning:Boolean = false;
	var extent:Object;
	var skin = "_superpan";
	var panmap:MovieClip 
	var maphit:Boolean 	
	var thisObj:ToolSuperPan = this;
	/**
	 * Constructor for creating a ToolSuperPan
	 * @see AbstractTool#Constructor(id:String, toolGroup:ToolGroup ,container:MovieClip);
	 */
	public function ToolSuperPan(id:String, toolGroup:ToolGroup ,container:MovieClip) {
		super(id, toolGroup, container);		
		toolOverSettings = new SpriteSettings(3, 1045, 24, 23, 0, 0, true, 100);
		toolDownSettings = new SpriteSettings(49, 1045, 24, 23, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(97, 1046, 20, 18, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolSuperPan>" +
							"<string id='tooltip' nl='slepen, gooien en zoomen met het wieltje' en='pan, throw, and zoom with mousewheel'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='pan'/>" +
							"<cursor id='grab' url='fmc/CursorsMap.swf' linkageid='grab'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</ToolSuperPan>";
				
		init();
	}
	/**
	 * init function
	 */
	private function init() {
		var thisObj:ToolSuperPan = this;
		this.lMap.onRollOut = function(map:MovieClip ){
			thisObj.maphit = false
			thisObj.cancel()
		}
		this.lMap.onDragOut = function(map:MovieClip){
			thisObj.maphit = false
			thisObj.cancel()
		}
		this.lMap.onMouseDown = function(mapOnMouseDown:MovieClip, xmouseOnMouseDown:Number, ymouseOnMouseDown:Number, coordOnMouseDown:Object) {
			thisObj.maphit = true
			thisObj.cancel()
			//trace("mousedown:"+flamingo.getId(map));
			if (! thisObj._parent._busy) {
				thisObj._parent.cancelAll();
				
				var e = mapOnMouseDown.getCurrentExtent();
				var msx = (e.maxx-e.minx)/mapOnMouseDown.getMovieClipWidth();
				var msy = (e.maxy-e.miny)/mapOnMouseDown.getMovieClipHeight();
				mapOnMouseDown.setCursor(thisObj.cursors["grab"]);
				var x = xmouseOnMouseDown;
				var y = ymouseOnMouseDown;
				thisObj.xold = xmouseOnMouseDown;
				thisObj.yold = ymouseOnMouseDown;
				//call interval to calculate the speed of dragging.
				thisObj.velocityid = setInterval(thisObj,"velocity", 100, mapOnMouseDown);
				thisObj.lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					var dx = (x-xmouse)*msx;
					var dy = (ymouse-y)*msy;
					map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
					//updateAfterEvent();
				};
				thisObj.lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
					delete thisObj.lMap.onMouseMove;
					delete thisObj.lMap.onMouseUp;
					//trace("mouseup:"+flamingo.getId(map));
					clearInterval(thisObj.velocityid);
					//var dx:Number = Math.abs(xmouse-x);
					//var dy:Number = Math.abs(ymouse-y);
					//if (dx<=2 and dy<=2) {
					//map.moveToCoordinate(coord,undefined,undefined,-1,10);
					//delay = clickdelay
					//}
					
					if ((Math.abs(thisObj.vx)>10 || Math.abs(thisObj.vy)>10) && thisObj.maphit) {
						thisObj.vx = Math.round(thisObj.vx/10);
						thisObj.vy = Math.round(thisObj.vy/10);
						clearInterval(thisObj.autopanid);
						thisObj.panmap = map
						thisObj.autopanid = setInterval(thisObj,"autoPan", 100, map);
						
					} else {
						//var dx:Number = Math.abs(xmouse-x);
						//var dy:Number = Math.abs(ymouse-y);
						//if (dx<=2 and dy<=2) {
						//map.moveToCoordinate(coord, undefined, undefined, -1, 10);
						//}
						
						thisObj._parent.updateOther(map, thisObj.delay);
					}
					map.update(thisObj.delay);
					
					map.setCursor(thisObj.cursors["cursor"]);
					
				};
			}
		};
		
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolSuperPan "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	 * Config functions
	 */ 
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;
		}
		//if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
			//return;
		//}
		//load default attributes, strings, styles and cursors       
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "delay" :
				delay = Number(val);
				break;
			case "skin" :
				skin = val+"_superpan";
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
		flamingo.position(this);

	}
	/**
	 * Auto pan functions
	 */
	/**
	 * Calculates the speed of dragging between 2 calls.
	 * @param	map the movie clip that contains the map
	 */
	function velocity(map:MovieClip) {		
		this.vx = this.xold-map._xmouse;
		this.vy = this.yold-map._ymouse;
		this.xold = map._xmouse;
		this.yold = map._ymouse;
	}
	/**
	 * Auto pan
	 * @param	map the movie clip that contains the map
	 */
	function autoPan(map:MovieClip) {
		panning = true;
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.__width;
		var msy = (e.maxy-e.miny)/map.__height;
		var dx = vx*msx;
		var dy = -vy*msy;
		map.moveToExtent({minx:e.minx+dx, miny:e.miny+dy, maxx:e.maxx+dx, maxy:e.maxy+dy}, -1, 0);
		updateAfterEvent();
	}
	/**
	 * Cancel the panning and dragging speed interval
	 */
	function cancel() {
		//trace("CANCEL");
		if (panning) {
			panmap.update(delay);
			_parent.updateOther(panmap, delay);
			clearInterval(autopanid);
			clearInterval(velocityid);
			panning = false;
		}
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
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	
}