/**
 * ...
 * @author Roy Braam
 */
import core.ComponentInterface;
import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
/** @component ToolIdentify
* Tool for identifying maps.
* @file ToolIdentify.fla (sourcefile)
* @file ToolIdentify.swf (compiled component, needed for publication on internet)
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
* @attr skin (defaultvalue="") Available skins: "", "f2" 
*/
class gui.tools.ToolIdentify extends AbstractTool implements ComponentInterface{
	var defaultXML:String;
	var skin = "_identify";
	var identifyall:Boolean = true;

	public function ToolIdentify(id:String, toolGroup:ToolGroup ,container:MovieClip) {		
		super(id, toolGroup, container);		
		this.toolDownLink = "assets/img/ToolIdentify_down.png";
		this.toolUpLink = "assets/img/ToolIdentify_up.png";
		this.toolOverLink = "assets/img/ToolIdentify_over.png";
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ToolIdentify>" +
							"<string id='tooltip' nl='informatie opvragen' en='identify'/>" +
							"<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='identify'/>" +
							"<cursor id='click'  url='fmc/CursorsMap.swf' linkageid='identify_click'/>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy' />" +
							"</ToolIdentify>";
		
		init();
	}
	
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
	function startUpdating() {
	}
	function stopUpdating() {
	}
	/****************************************
	 * Events
	 */
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	
}