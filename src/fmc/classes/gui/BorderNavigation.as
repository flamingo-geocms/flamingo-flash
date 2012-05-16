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
import gui.button.MoveExtentButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/** @component BorderNavigation
* Navigation buttons at the border of a map.
* @file flamingo/classes/gui/BorderNavigation.as (sourcefile)
* @file flamingo/classes/core/AbstractPositionable.as
* @file flamingo/classes/gui/Button/MoveExtentButton.as 
* @file BorderNavigation.xml (configurationfile, needed for publication on internet)
* @configstring tooltip_north tooltiptext of north button
* @configstring tooltip_south tooltiptext of south button
* @configstring tooltip_west tooltiptext of west button
* @configstring tooltip_east tooltiptext of east button
* @configstring tooltip_northwest tooltiptext of northwest button
* @configstring tooltip_southwest tooltiptext of southwest button
* @configstring tooltip_southeast tooltiptext of southeast button
* @configstring tooltip_northeast tooltiptext of northeast button
*/
/** @tag <fmc:BorderNavigation>  
* This tag defines navigation buttons at the border of a map. It listens to 1 or more map components
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example <fmc:BorderNavigation left="10" top="10" right="right -10" bottom="50%" buttons="N,S,W,E,NE,SE,NW,SW" listento="map,map1" offset="6"/>
* @attr buttons (defaultvalue = "W,S,N,E,NE,NW,SE,SW") Comma seperated list of buttons. W=West, S=South etc. Reconized values: W,S,N,E,NE,NW,SE,SW
* @attr updatedelay (defaultvalue = "500") Time in milliseconds (1000 = 1 sec.) in which the map will be updated.
* @attr offset (defaultvalue = "0") Offset in pixels applied to all buttons. For main positioning use the default positioning attributes (left, top etc.).
*/
/**
 * Navigation buttons at the border of a map. Arrows to move up,down,left,right etc.
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.BorderNavigation extends AbstractPositionable
{
	var buttons:Array = new Array("W", "S", "N", "E");
	
	///*, "NW", "NE", "SE", "SW"*/);
	
	var extentButtons:Object;
	var offset:Number = 0;
	var skin = "";
	var _moveid:Number;
	var updatedelay:Number = 500;
	
	//listeners
	
	/**
	 * Constructor for creating this component
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @see core.AbstractPositionable
	 */
	public function BorderNavigation(id:String, container:MovieClip)
	{
		super(id, container);
		extentButtons = new Object();		
		init();
	}
	
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	function init()
	{
		if(flamingo == undefined)
		{
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>BorderNavigation " + this.version + "</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
		
		//defaults
		//custom
		
		var xmls:Array = flamingo.getXMLs(this);
		for(var i = 0; i < xmls.length; i++)
		{
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
	function setConfig(xml:Object)
	{
		if(typeof(xml) == "string")
		{
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		
		if (this.type!=undefined && this.type.toLowerCase() != xml.localName.toLowerCase()) {
			return;
		}
		//load default attributes, strings, styles and cursors
		
		flamingo.parseXML(this, xml);
		
		//parse custom attributes
		
		for(var attr in xml.attributes)
		{
			var val:String = xml.attributes[attr];
			switch(attr.toLowerCase()){
				case "buttons":
					buttons =  val.toUpperCase().split(",");
					break;
				case "offset":
					offset = Number(val);
					break;
				case "updatedelay":
					updatedelay = Number(val);
					break;
				case "skin":
					skin = val;
					break;
			};
		}
		flamingo.position(this.container);
		refresh();
	}
	/**
	 * Refresh the component
	 */
	function refresh()
	{
		for(var i = 0; i < buttons.length; i++)
		{
			var pos = buttons[i];
			var map = flamingo.getComponent(listento[0]);
			var moveExtentButton:MoveExtentButton = new MoveExtentButton(this.id + pos, this.container.createEmptyMovieClip("m" + pos, i), this,map);
			var offsetx = SpriteSettings.buttonSize/2;
			var offsety = SpriteSettings.buttonSize/2; 
			switch(pos){
				case "W":
					moveExtentButton.setDirectionMatrix(- 1, 0);
					moveExtentButton.tooltipId = "tooltip_west";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 7*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 7*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 7*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					break;
				case "E":
					moveExtentButton.setDirectionMatrix(1, 0);
					moveExtentButton.tooltipId = "tooltip_east";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 0, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 0, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 0, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offsety, true, 100);
					break;
				case "N":
					moveExtentButton.setDirectionMatrix(0, 1);
					moveExtentButton.tooltipId = "tooltip_north";
					moveExtentButton.toolDownSettings = new SpriteSettings(0,SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					break;
				case "S":
					moveExtentButton.setDirectionMatrix(0, - 1);
					moveExtentButton.tooltipId = "tooltip_south";
					moveExtentButton.toolDownSettings = new SpriteSettings(0,4*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 4*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 4*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, 0, true, 100);
					break;
				case "NE":
					moveExtentButton.setDirectionMatrix(1, 1);
					moveExtentButton.tooltipId = "tooltip_northeast";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 2*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 2*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 2*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					break;
				case "SE":
					moveExtentButton.setDirectionMatrix(1, - 1);
					moveExtentButton.tooltipId = "tooltip_southeast";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 5*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 5*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 5*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					break;
				case "SW":
					moveExtentButton.setDirectionMatrix(- 1, - 1);
					moveExtentButton.tooltipId = "tooltip_southwest";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 6*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 6*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 6*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					break;
				case "NW":
					moveExtentButton.setDirectionMatrix(- 1, 1);
					moveExtentButton.tooltipId = "tooltip_northwest";
					moveExtentButton.toolDownSettings = new SpriteSettings(0, 3*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 3*SpriteSettings.buttonSize,SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					moveExtentButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 3*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offsetx, offsety, true, 100);
					break;
			};
			moveExtentButton.strings = this.strings;
			this.extentButtons[pos] = moveExtentButton;
		}
			resize();
	}
	/**
	 * Resize the component according the set values and parent
	 */
	function resize()
	{		
		super.resize();
		var r = flamingo.getPosition(this);
		/*r.x = 0;
		 r.y = 0;*/
		
		/*var left = r.x - offset;
		var top = r.y - offset;*/
		var left = 0;
		var top = 0;
		var right = left + r.width - SpriteSettings.buttonSize + offset;
		var bottom = top + r.height - SpriteSettings.buttonSize + offset;
		var xcenter = (r.width/ 2) - SpriteSettings.buttonSize;
		var ycenter = (r.height/ 2) - SpriteSettings.buttonSize;
		//var offset = SpriteSettings.buttonSize / 2;
		for(var pos in extentButtons)
		{			
			//Logger.console("Resize pos: "+pos);			
			switch(pos){
				case "W":
					extentButtons[pos].move(left, ycenter);
					break;
				case "E":
					extentButtons[pos].move(right, ycenter);
					break;
				case "N":
					extentButtons[pos].move(xcenter, top);
					break;
				case "S":
					extentButtons[pos].move(xcenter, bottom);
					break;
				case "NE":
					extentButtons[pos].move(right, top);
					break;
				case "SE":
					extentButtons[pos].move(right, bottom);
					break;
				case "SW":
					extentButtons[pos].move(left, bottom);
					break;
				case "NW":
					extentButtons[pos].move(left, top);
					break;
			};
		}
	}
	/**
	 * Update the maps in the listento
	 */
	public function updateMaps(){
		var map = flamingo.getComponent(listento[0]);
		map.update(updatedelay);
		for(var i:Number = 1; i < listento.length; i++)
		{
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
}