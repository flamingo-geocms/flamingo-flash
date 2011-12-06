import core.AbstractPositionable;
import TextField.StyleSheet;
import tools.Logger;
/**
 * @author Meine Toonen
 */
/** @component Coordinates
* Shows coordinates when the mouse is moved over the map.
* @file Coordinates.fla (sourcefile)
* @file Coordinates.swf (compiled component, needed for publication on internet)
* @file Coordinates.xml (configurationfile, needed for publication on internet)
* @configstring xy (default = "[x] [y]") textstring to define coordinates. The values "[x]" and "[y]" are replaced by the actually coordinates.
* @configstyle .xy fontstyle of coordinates(xy) string
*/
/** @tag <fmc:Coordinates>  
* This tag defines coordinates. It listens to 1 or more mapcomponents.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example 
* <fmc:Coordinates  listento="map,map1"  left="x10" top="bottom -40" decimals="6">
*    <string id="xy" en="lat [y] &lt;br&gt;lon [x] "  nl="breedtegraad [y]  lengtegraad [x]"/>
* </fmc:Coordinates/>
* @attr decimals Number of decimals
*/
class gui.Coordinates extends AbstractPositionable
{
	var decimals:Number = 0;
	var xy:String;
	var resized:Boolean = false;
	var lMap:Object = new Object();
	var _tCoord:TextField = null;
	
	public function Coordinates(id:String, container:MovieClip) 
	{
		super(id, container);
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
									"<Coordinates>" +
										"<string id='xy' nl='asdf[x] wer[y]' en='asdf[x] [y]'/>" +
										"<style id='.xy' font-family='verdana' font-size='12px' color='#333333' display='block' font-weight='normal'/>" +
									"</Coordinates>";
		init();
	}
	
	private function init() {	
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true
			t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Coordinates "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
			return;
		}
		this._visible = false
		
		tCoord = this.container.createTextField("tCoord", 0, 0, 0, 0, 0);
		tCoord.multiline = true;
		tCoord.wordWrap = false;
		tCoord.html = true;
		tCoord.selectable = false;
		tCoord.htmlText = "";
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
		
		this._visible = this.visible;
		
		var lFlamingo:Object = new Object();
		lFlamingo.onSetLanguage = function(lang:String) {
			this.setString();
		};
		
		flamingo.addListener(lFlamingo, "flamingo", this);
		
		var thisObj = this;
		lMap.onRollOut = function (map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {
			thisObj.tCoord.htmlText = "";
		};
		
		lMap.onMouseMove = function (map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {
			var x = coord.x;
			var y = coord.y;
			if (isNaN(x) || isNaN(y)){
				thisObj.tCoord.htmlText = "";
				return
			}
			if (thisObj.decimals>0) {
				x = Math.round(x*thisObj.decimals)/thisObj.decimals;
				y = Math.round(y*thisObj.decimals)/thisObj.decimals;
			}
			var s = thisObj.xy;
			s = s.split("[x]").join(x);
			s = s.split("[y]").join(y);
			thisObj.tCoord.htmlText = "<span class='xy'>"+s+"</span>";
			thisObj.tCoord._width = thisObj.tCoord.textWidth+5;
			thisObj.tCoord._height = thisObj.tCoord.textHeight+5;
		};
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
		resized = false
		//load default attributes, strings, styles and cursors    
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "decimals" :
				decimals = Math.pow(10, Number(val));
				break;
			}
		}
		tCoord.styleSheet = StyleSheet(flamingo.getStyleSheet(this));
		setString();
		flamingo.position(this);
		flamingo.addListener(lMap, listento, this);
	}

	function setString() {
		this.xy = flamingo.getString(this, "xy", "[x] [y]");
	}
	
	public function get tCoord():TextField {
		return _tCoord;
	}
	
	public function set tCoord(value:TextField):Void {
		_tCoord = value;
	}
	

	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}