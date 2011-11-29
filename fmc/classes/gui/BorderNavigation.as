import core.AbstractPositionable;
import gui.button.MoveExtentButton;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class gui.BorderNavigation extends AbstractPositionable{
	
	var buttons:Array = new Array("W", "S", "N", "E"/*, "NW", "NE", "SE", "SW"*/);
	var extentButtons:Object;
	var offset:Number = 0;
	var skin = "";
	var _moveid:Number;
	var updatedelay:Number = 500;
	
	//listeners	
	public function BorderNavigation(id:String, container:MovieClip) {
		super(id, container);
			Logger.console("Constructor BorderNavigation");
		extentButtons = new Object();
		init();
	}
	
	function init() {
		Logger.console("BorderNavigation.init()");
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>BorderNavigation "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
		//defaults
		
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
		Logger.console("BorderNavigation.setConfig()");
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml=xml.firstChild;
		}
		//if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
			//return;
		//}
		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "buttons" :
				buttons = val.toUpperCase().split(",");
				break;
			case "offset" :
				offset = Number(val);
				break;
			case "updatedelay" :
				updatedelay = Number(val);
				break;
			case "skin" :
				skin = val;
				break;
			}
		}		
		flamingo.position(this.container);
		refresh();		
	}
	
	function refresh() {
		Logger.console("BorderNavigation Refresh button length: "+this.buttons.length);
		for (var i = 0; i<buttons.length; i++) {
			var pos = buttons[i];
			Logger.console("Direction: "+pos);
			var moveExtentButton:MoveExtentButton = new MoveExtentButton(this.id + pos, 
				this.container.createEmptyMovieClip("m" + pos, i));
				
			moveExtentButton.toolOverLink = "assets/img/borderNav_" + pos + "_over.png";
			moveExtentButton.toolUpLink ="assets/img/borderNav_"+pos+"_up.png";
			moveExtentButton.toolDownLink = "assets/img/borderNav_" + pos + "_down.png";
			
			Logger.console("New Button:"+moveExtentButton);
			switch (pos) {
				case "W" :
					moveExtentButton.setDirectionMatrix(-1,0);
					moveExtentButton.tooltipId = "";
					break;
				case "E" :
					moveExtentButton.setDirectionMatrix(1,0);
					moveExtentButton.tooltipId = "tooltip_east";				
					break;
				case "N" :
					moveExtentButton.setDirectionMatrix(0,1);
					moveExtentButton.tooltipId = "tooltip_north";
					break;
				case "S" :
					moveExtentButton.setDirectionMatrix(0,-1);
					moveExtentButton.tooltipId = "tooltip_south";
					break;
				case "NE" :
					moveExtentButton.setDirectionMatrix(1,1);
					moveExtentButton.tooltipId = "tooltip_northeast";				
					break;
				case "SE" :
					moveExtentButton.setDirectionMatrix(1,-1);
					moveExtentButton.tooltipId = "tooltip_southeast";
					break;
				case "SW" :
					moveExtentButton.setDirectionMatrix(-1,-1);
					moveExtentButton.tooltipId = "tooltip_southwest";
					break;
				case "NW" :
					moveExtentButton.setDirectionMatrix(-1,1);
					moveExtentButton.tooltipId = "tooltip_northwest";				
					break;
			}
			this.extentButtons[pos] = moveExtentButton;
		}
		resize();
	}
	function resize(map:MovieClip) {
		var r = flamingo.getPosition(this);
		Logger.console("rx: " + r.x);
		Logger.console("ry: " + r.y);
		/*r.x = 0;
		r.y = 0;*/
		var left = r.x - offset;		
		var top = r.y - offset;		
		var right = r.x+r.width+offset;
		var bottom = r.y+r.height+offset;
		var xcenter = (right+left)/2;
		var ycenter = (top + bottom) / 2;
		Logger.console("**************************************************");
		Logger.console("Left: " + left);
		Logger.console("right: " + right);
		Logger.console("ycenter: " + ycenter);
		Logger.console("xcenter: " + xcenter);
		Logger.console("top: " + top); 
		Logger.console("bottom: " + bottom);		
		for (var pos in extentButtons) {
			Logger.console("Resize pos: "+pos);
			switch (pos) {
			case "W" :
				extentButtons[pos].move(left, ycenter-33);
				break;
			case "E" :
				extentButtons[pos].move(right-31, ycenter-33);		
				break;
			case "N" :
				extentButtons[pos].move(xcenter-33, top);
				break;
			case "S" :
				extentButtons[pos].move(xcenter-33, bottom-31);
				break;
			case "NE" :
				extentButtons[pos].move(right, top);			
				break;
			case "SE" :
				extentButtons[pos].move(right, bottom);
				break;
			case "SW" :
				extentButtons[pos].move(left, bottom);
				break;
			case "NW" :
				extentButtons[pos].move(left, top);			
				break;
			}
		}
	}
	
	public function updateMaps() {
		var map = flamingo.getComponent(listento[0]);
		map.update(updatedelay);
		for (var i:Number = 1; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			mc.moveToExtent(map.getMapExtent(), updatedelay);
		}
	}
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
	public function get _parent():MovieClip {
		return this.container._parent;
	}
	
	
}