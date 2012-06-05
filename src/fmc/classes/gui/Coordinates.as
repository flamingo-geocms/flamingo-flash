/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

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
import TextField.StyleSheet;
import tools.Logger;
/** @component fmc:Coordinates
* Shows coordinates when the mouse is moved over the map.
* @file flamingo/classes/gui/Coordinates.as (sourcefile)
* @file flamingo/classes/core/AbstractPositionable.as
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
/**
 * Shows coordinates when the mouse is moved over the map.
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.Coordinates  extends AbstractPositionable{	
	var decimals:Number = 0;
	var xy:String;
	var resized:Boolean = false;
	var _tCoord:TextField;
	var _lMap:Object;
	
	/**
	 * Constructor for creating this component
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @see core.AbstractPositionable
	 */
	public function Coordinates(id:String,  container:MovieClip) {
		super(id, container);
		defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<Coordinates>" +
							"<string id='xy' nl='[x] [y]' en='[x] [y]'/>" +
							"<style id='.xy' font-family='verdana' font-size='12px' color='#333333' display='block' font-weight='normal'/>"+
							"</Coordinates>";		
		init();
	}
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	private function init():Void {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true
			t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Coordinates "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
			return;
		}
		this._visible = false
		
		
		tCoord = this.container.createTextField("tCoord", 0, 0, 0, 0, 0);
		tCoord.htmlText = "";
		tCoord.multiline = true;
		tCoord.wordWrap = false;
		tCoord.html = true;
		tCoord.selectable = false;

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
		
		this._visible = this.visible
		
		var thisObj:Coordinates = this;
		var lFlamingo:Object = new Object();
		lFlamingo.onSetLanguage = function(lang:String) {
			thisObj.setString();
		};
		flamingo.addListener(lFlamingo, "flamingo", this);
		
		//---------------------------------------
		var lParent:Object = new Object();
		lParent.onResize = function(c:MovieClip) {
			thisObj.resize();
		};
		flamingo.addListener(lParent, flamingo.getParent(this), this);
		
		lMap = new Object();
		lMap.onRollOut = function(map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {
			thisObj.tCoord.htmlText = "";
		};
		lMap.onMouseMove = function(map:MovieClip, xpos:Number, ypos:Number, coord:Object):Void  {
			var x = coord.x;
			var y = coord.y;
			if (isNaN(x) || isNaN(y)){
				thisObj.tCoord.htmlText = "";
				return;
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
			if (! thisObj.resized) {
				thisObj.resize();
				thisObj.resized = true;
			}
		};
		
		flamingo.raiseEvent(this, "onInit", this);
	}
	/**
	* Configurates a component by setting a xml.
	* @param xml:Object Xml or string representation of a xml.
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
		flamingo.addListener(lMap, listento, this);
		this.setString();
		flamingo.position(this);
		tCoord.styleSheet = StyleSheet(flamingo.getStyleSheet(this));
	}
	/**
	 * Set the xy string for this component, get it from flamingo
	 */
	function setString(){
		this.xy = flamingo.getString(this, "xy", "[x] [y]");
	}
	
	/*********************** Getters and Setters *****************/
	/**
	 * getter tCoord
	 */
	public function get tCoord():TextField 
	{
		return _tCoord;
	}
	/**
	 * setter tCoord
	 */
	public function set tCoord(value:TextField):Void 
	{
		_tCoord = value;
	}
	/**
	 * getter lMap
	 */
	public function get lMap():Object 
	{
		return _lMap;
	}
	/**
	 * setter lMap
	 */
	public function set lMap(value:Object):Void 
	{
		_lMap = value;
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}	
}

