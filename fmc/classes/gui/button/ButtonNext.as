/*-----------------------------------------------------------------------------
Copyright (C) 2006 Menko Kroese

This file is part of Flamingo MapComponents.

Flamingo MapComponents is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------*/
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
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
/**
 * Button to zoom to next extent
 * @author Meine Toonen
 */
class gui.button.ButtonNext extends AbstractButton{
	
	var skin:String = "";
	//---------------------------------
	var lParent:Object = new Object();
	var lMap:Object = new Object();
	
	/**
	 * Constructor for ButtonPrev. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @see 	gui.button.AbstractButton
	 */
	public function ButtonNext(id:String, container:MovieClip) 
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(4, 405, 22, 22, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(50, 405, 22, 22, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(99, 405, 22, 22, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" + 
						"<ButtonNext>" + 
						"<string id='tooltip' en='next extent' nl='volgende stap'/>" +
						"</ButtonNext>"
							
		flamingo.addListener(lParent, flamingo.getParent(this), this);
		init();	
	}	
	/**
	 * Init the component with the defaults and already loaded configs
	 */
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
		thisObj.setEnabled(false);
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
	/************* event handlers **************/
	function onRelease() {
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
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}