/*-----------------------------------------------------------------------------
Copyright (C) 2011  Roy Braam / Meine Toonen B3partners BV

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
import core.AbstractPositionable;
import tools.Logger;
/**
 * Make a implementation of this class to handle the parsing of the xml.
 * It implements the setConfig() function and uses the addComposite and addAttribute
 * functions of the implementations (both need to be implemented in the implementations) to set
 * the values from the XML
 * @author Roy Braam
 */
class core.AbstractConfigurable extends AbstractPositionable{
	/**
	 * AbstractConfigurable
	 * @param	id
	 * @param	container
	 */
	public function AbstractConfigurable(id:String, container:MovieClip) {
		super(id, container);	
		init();
	}
	/**
	 * Called as last statement in constructor.
	 * Initializes the object. It sets the defaults and gets the already set custom XML's from flamingo
	 */
	public function init():Void {
		//set visible false while configuring
		this._visible = false;
		//set defaults defaults
		var xmlNode:XMLNode = this.stringToXMLNode(defaultXML);
		if (xmlNode!=undefined){
			this.setConfig(xmlNode);
			delete xmlNode;
		}
		//get the custom xml's
		var xmls:Array = flamingo.getXMLs(this);
		for (var i = 0; i < xmls.length; i++) {		
			if (xmls[i]!=undefined)
				this.setConfig(stringToXMLNode(xmls[i]));
		}
		delete xmls;
		//remove xml from repository
		flamingo.deleteXML(this);
		this._visible = visible;
		flamingo.raiseEvent(this, "onInit", this);
	}
	/**
	 * Config this object with the given xml.
	 * @param	xml the configuration of this object.
	 */
	public function setConfig(xml:XMLNode) {
		//parse the default attributes.
		flamingo.parseXML(this, xml);
		//set the custom attributes
		for (var attributeName:String in xml.attributes) {
            var value:String = xml.attributes[attributeName];
            setAttribute(attributeName, value);
        }	
		//set the custom composites
		addComposites(xml);
		resize();
	}
	/**
	 * Set the composites (with the child xml nodes) for this object.
	 * @param	config a XMLNode configuration of the childs for this object.
	 */
	function addComposites(config:XMLNode) {
		for (var j:Number = 0; j < config.childNodes.length; j++) {
			var xmlNode:XMLNode = config.childNodes[j];
			var nodeName:String = xmlNode.nodeName;
			if (nodeName.indexOf(":") > -1) {
				nodeName = nodeName.substr(nodeName.indexOf(":") + 1);
			}
			if (nodeName.toLowerCase() == "string") {
				flamingo.setString(config, this.strings);
			}else {				
				addComposite(nodeName, xmlNode);
			}
		}
	}
	/*********************************************************
	 * Abstracts, need to be implemented
	 */ 
	/**
	 * Implement this function to reinit the configed settings.
	 */
	public function reinit():Void { };	
	/**
	 * Implement this function. It Passes a configured attribute for this component.
	 * @param name name of the attribute
	 * @param value value of the attribute
	 */
	function setAttribute(name:String, value:String):Void {
		Logger.console("!!!!!AbstractConfigurable.setAttribute(name:String, value:String) must be implemented in subclass");
	}	
	/**
	 * Implement this function. It Passes a name and child xml to the component.
	 * @param name the name of the tag
	 * @param config the xml child
	 */ 
	function addComposite(name:String, config:XMLNode):Void { 
		Logger.console("!!!!!AbstractConfigurable.addComposite(name:String, config:XMLNode) not implemented in component with id: "+id+ " can't set the composite for this object");
	}
	
	
	/***********************************************
	 * Helper functions
	 */
	/**
	 * From string to xmlnode
	 * @param	xmlString
	 */
	public function stringToXMLNode(xmlString:String) {
		var xml:XML = new XML(String(xmlString));
		return xml.firstChild;
	}
}