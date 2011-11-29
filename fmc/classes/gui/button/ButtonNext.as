/**
 * ...
 * @author Meine Toonen
 */
import core.ComponentInterface;
import gui.button.AbstractButton;
import tools.Logger;
/** @component ButtonNext
* A button to zoom the map to the next extent.
* @file ButtonNext.fla (sourcefile)
* @file ButtonNext.swf (compiled component, needed for publication on internet)
* @file ButtonNext.xml (configurationfile, needed for publication on internet)
* @configstring tooltip tooltiptext of the button
*/
/** @tag <fmc:ButtonNext>  
* This tag defines a button for zooming the map to the next extent. It listens to 1 or more maps
* Beware! To make this button work properly, it is necessary that the "nrprevextents" of the map is set!
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:ButtonNext  right="50% 170" top="71" listento="map"/>
* @attr skin (defaultvalue = "") Skin of the button.  Available skins: default ("") and "f2".
*/
class gui.button.ButtonNext extends AbstractButton implements ComponentInterface {
	
	var skin:String = "";
	//---------------------------------
	var lParent:Object = new Object();
	var lMap:Object = new Object();
	
	/**
	 * Constructor
	 * @param	id
	 * @param	container
	 * @see AbstractButton#Constructor(id:String,container:MovieClip);
	 */
	public function ButtonNext(id:String, container:MovieClip) 
	{
		super(id, container);
		this.toolDownLink = "assets/img/ButtonNext_down.png";
		this.toolUpLink = "assets/img/ButtonNext_up.png";
		this.toolOverLink = "assets/img/ButtonNext_over.png";		
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" + 
						"<ButtonNext>" + 
						"<string id='tooltip' en='next extent' nl='volgende stap'/>" +
						"</ButtonNext>"
							
		flamingo.addListener(lParent, flamingo.getParent(this), this);

		
		init();
	
	}
	
	function init():Void {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ButtonNext "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		var thisObj:ButtonNext = this;
		lMap.onUpdate = function(map:MovieClip) {
			if (map.getNextExtents().length>0) {
				thisObj.setEnabled(true);
			} else {
				thisObj.setEnabled(false);
			}
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
		//load default attributes, strings, styles and cursors  
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "skin" :
				skin = val;
				break;
			}
		}
		flamingo.addListener(lMap, listento[0], this);
		this.resize()
	}

	function press() {
		for (var i = 0; i<listento.length; i++) {
			var map = flamingo.getComponent(listento[i]);
			if (map.getHoldOnUpdate() and map.isUpdating()) {
				return;
			}
		}
		for (var i = 0; i<listento.length; i++) {
			flamingo.getComponent(listento[i]).moveToNextExtent();
		}
	}
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}