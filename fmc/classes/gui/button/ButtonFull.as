/**
 * ...
 * @author Roy Braam
 */
import core.ComponentInterface;
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
import display.spriteloader.Sprite;
import display.spriteloader.SpriteMap;
import display.spriteloader.event.SpriteMapEvent;
import display.spriteloader.SpriteMapFactory;

/** @component ButtonFull
* A button to zoom the map to the intial or full extent.
* @file ButtonFull.fla (sourcefile)
* @file ButtonFull.swf (compiled component, needed for publication on internet)
* @file ButtonFull.xml (configurationfile, needed for publication on internet)
* @change	2009-03-04 NEW attribute extent
* @configstring tooltip tooltiptext of the button
*/
/** @tag <fmc:ButtonFull>  
* This tag defines a button for zooming the map to the fullextent. It listens to 1 or more maps
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:ButtonFull   right="50% 200" top="71" listento="map"/>
* @attr skin (defaultvalue = "") Skin of the button. No skins available at this moment.
* @attr extent (no defaultvalue) If value is 'initial' the ButtonFull zooms to the (for the Map configured) 
* (initial) extent instead of the fullextent.
*/
class gui.button.ButtonFull extends AbstractButton implements ComponentInterface{	
	var extent:String;
	var skin:String = "";
	var spriteMap:SpriteMap;
	//---------------------------------
	
	/**
	 * Constructor
	 * @param	id
	 * @param	container
	 * @see AbstractButton#Constructor(id:String,container:MovieClip);
	 */
	public function ButtonFull(id:String, container:MovieClip) {		
		super(id, container);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ButtonFull>" +
							"<string id='tooltip' en='full extent' nl='zoom naar volledige uitsnede'/>" + 
							"</ButtonFull>";	
		init();
	}
	
	function init():Void {		
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ButtonFull "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		
		var spriteMap:SpriteMap = flamingo.spriteMapFactory.obtainSpriteMap("sprite.png");			
		spriteMap.attachSpriteTo(this.mcOver.createEmptyMovieClip("container", this.mcOver.getNextHighestDepth()), new SpriteSettings(3, 359 , 22, 31, 0, 0, true, 100));
		spriteMap.attachSpriteTo(this.mcDown.createEmptyMovieClip("container", this.mcDown.getNextHighestDepth()), new SpriteSettings(50, 359 , 22, 31, 0, 0, true, 100));
		spriteMap.attachSpriteTo(this.mcUp.createEmptyMovieClip("container", this.mcUp.getNextHighestDepth()), new SpriteSettings(97, 359 , 22, 31, 0, 0, true, 100));
		
		
		this._visible = false;
		
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
			xml=xml.firstChild;
		}

		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		//parse custom attributes

		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "skin" :
				skin = val;
				break;
			case "extent" :
				extent = val;
				break;
			}
		}	
			
		resize();		
	}
		
	public function onRelease() {		
		for (var i = 0; i<listento.length; i++) {
			var map = flamingo.getComponent(listento[i]);
			if (map.getHoldOnUpdate() && map.isUpdating()) {
				Logger.console("Error, is still updating....");
				return;
			}
		}		
		for (var i = 0; i<listento.length; i++) {
			var map = flamingo.getComponent(listento[i]);
			if (extent == "initial") {
				map.moveToExtent(map.getInitialExtent(),0);
			} else {
				map.moveToExtent(map.getFullExtent(),0);
			}
		}
	}
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}