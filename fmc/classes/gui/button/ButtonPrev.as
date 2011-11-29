/**
 * @author Meine Toonen
 */

/** @component ButtonPrev
* A button to zoom the map to the previous extent.
* @file ButtonPrev.fla (sourcefile)
* @file ButtonPrev.swf (compiled component, needed for publication on internet)
* @file ButtonPrev.xml (configurationfile, needed for publication on internet)
* @configstring tooltip tooltiptext of the button
*/
/** @tag <fmc:ButtonPrev>  
* This tag defines a button for zooming the map to the previous extent. It listens to 1 or more maps
* Beware! To make this button work properly, it is necessary that the "nrprevextents" of the map is set!
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:ButtonPrev  right="50% 140" top="71" listento="map"/>
* @attr skin (defaultvalue = "") Skin of the button. Available skins: default ("") and "f2".
*/
import core.ComponentInterface;
import gui.button.AbstractButton;
import tools.Logger;
class gui.button.ButtonPrev extends AbstractButton implements ComponentInterface
{
	var skin:String = "";
	var lParent:Object = new Object();
	var lMap:Object = new Object();

	public function ButtonPrev(id:String, container:MovieClip) 
	{
		super(id, container);
		this.toolDownLink = "assets/img/ButtonFull_down.png";
		this.toolUpLink = "assets/img/ButtonFull_up.png";
		this.toolOverLink = "assets/img/ButtonFull_over.png";		
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ButtonPrev>" +
						"<string id='tooltip'  en='previous extent' nl='stap terug'/>" + 
						"</ButtonPrev>";
		init();
	}
	
	private function init():Void {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ButtonPrev "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
		var thisObj:ButtonPrev = this;
		lMap.onUpdate = function(map:MovieClip) {
			if (map.getPrevExtents().length>0) {
				thisObj.setEnabled(true);
			} else {
				thisObj.setEnabled(false);
			}
		};
		flamingo.raiseEvent(this, "onInit", this);
	}
	/**
	* Configures a component by setting a xml.
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
		this.setEnabled(false);
		resize();
	}

	function press() {
		for (var i = 0; i<listento.length; i++) {
			var map = flamingo.getComponent(listento[i]);
			if (map.getHoldOnUpdate() and map.isUpdating()) {
				return;
			}
		}
		for (var i = 0; i<listento.length; i++) {
			flamingo.getComponent(listento[i]).moveToPrevExtent();
		}
	}
}