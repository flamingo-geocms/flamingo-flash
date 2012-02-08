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
import display.spriteloader.SpriteSettings;
import tools.Logger;
/** @component ButtonFull
* A button to zoom the map to the intial or full extent.
* @file flamingo/fmc/classes/gui/button/ButtonFull.as (sourcefile)
* @file flamingo/fmc/classes/gui/button/AbstractButton.as (extends)
* @file flamingo/classes/core/AbstractPositionable.as
* @file ButtonFull.xml (configurationfile, needed for publication on internet)
* @change	2009-03-04 NEW attribute extent
* @configstring tooltip tooltiptext of the button
*/
/** @tag <fmc:ButtonFull>  
* This tag defines a button for zooming the map to the fullextent. It listens to 1 or more maps
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:ButtonFull   right="50% 200" top="71" listento="map"/>
* @attr extent (no defaultvalue) If value is 'initial' the ButtonFull zooms to the (for the Map configured) 
* (initial) extent instead of the fullextent.
*/
/**
 * A button to zoom the map to the intial or full extent.
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.button.ButtonFull extends AbstractButton{	
	var extent:String;
	var skin:String = "";
	//---------------------------------
	
	/**
	 * Constructor for ButtonPrev. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @see 	gui.button.AbstractButton
	 */
	public function ButtonFull(id:String, container:MovieClip) {		
		super(id, container);
		toolDownSettings = new SpriteSettings(0, 8*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(SpriteSettings.buttonSize, 8*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 8*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100);
		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ButtonFull>" +
							"<string id='tooltip' en='full extent' nl='zoom naar volledige uitsnede'/>" + 
							"</ButtonFull>";
		init();
	}
	
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	function init():Void {		
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ButtonFull "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
		//load defaults
		//var xml:XML = new XML()
		//xml.ignoreWhite = true;
		//xml.load(getNocacheName(url+".xml", this.nocache))
		
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
	/************* event handlers **************/
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
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}