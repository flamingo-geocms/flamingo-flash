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
import display.spriteloader.Sprite;
import gui.button.SliderButton;
import gui.button.ZoomInButton;
import gui.button.ZoomOutButton;
import gui.tools.ToolGroup;
import gui.tools.ToolZoomin;
import tools.Logger;
import display.spriteloader.SpriteSettings;
import display.spriteloader.event.SpriteMapEvent;
import display.spriteloader.SpriteMap;
import core.AbstractPositionable;

/** @component ZoomerV
 * A vertical zoombar.
 * @file ZoomerV.fla (sourcefile)
 * @file ZoomerV.swf (compiled component, needed for publication on internet)
 * @file ZoomerV.xml (configurationfile, needed for publication on internet)
 * @configstring tooltip_zoomin Tooltip of zoomin button.
 * @configstring tooltip_zoomout Tooltip of zoomout button.
 * @configstring tooltip_slider Tooltip of slider button.
 */

/** @tag <fmc:ZoomerV>  
 * This tag defines a vertical zoombar. It listens to 1 or more maps.
 * @example
 * <fmc:Window top="100" left="100" width="300" bottom="bottom" canresize="true" canclose="true" title="Identify results">
 * @example
 * <fmc:ZoomerV left="10" top="10" height="300" listento="map">
 *    <string id="tooltip_zoomin" en="zoomin" nl="inzoomen"/>
 *    <string id="tooltip_zoomout" en="zoomout" nl="uitzoomen"/>
 *    <string id="tooltip_slider" en="..." nl="..."/>
 * </fmc:ZoomerV>
 * @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
 * @attr updatedelay (defaultvalue="500") Amount of time in milliseconds(1000 = 1 second) between releasing the zoomin/out and slider buttons and the update of a map.
 * @attr skin (defaultvalue="") Available skins: "", "f2" 
 */
/**
 * A vertical zoombar.
 */
class gui.ZoomerV  extends AbstractPositionable{

	var _zoomid:Number;
	var center:Object;
	var updatedelay:Number = 500;
	//listeners
	//zoomin button
	var _zoomIn:ZoomInButton;
	//zoomout button
	var _zoomOut:ZoomOutButton;
	//the slider bar
	var _sliderBar:MovieClip;
	//the slider button
	var _sliderButton:SliderButton;
	//a reference to the map
	var _lMap:Object = new Object();
	//a reference to the spriteMap 
	var _spriteMap:SpriteMap;
	
	/**
	 * Constructor for creating a ZoomerV
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @see core.AbstractPositionable
	 */
	public function ZoomerV(id:String,  container:MovieClip)
	{
		super(id, container);
		spriteMap = flamingo.spriteMap;
		defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" + "<ZoomerV>" + "<string id='tooltip_zoomin' en='zoom in' nl='inzoomen'/>" + "<string id='tooltip_zoomout' en='zoom out' nl='uitzoomen'/>" + "</ZoomerV>";
	
		//listeners
		//---------------------------------------
		//---------------------------------------
		
		var thisObj:ZoomerV = this;
		lMap.onInit = function(map:MovieClip)
		{
			thisObj.refresh();
		}
		lMap.onChangeExtent = function(map:MovieClip)
		{
			thisObj.refresh();
		}
		lMap.onUpdate = function(map:MovieClip)
		{
			thisObj.refresh();
		}
		
		//---------------------------------------
		sliderBar = this.container.createEmptyMovieClip("sliderBar", this.container.getNextHighestDepth());
		spriteMap.attachSpriteTo(sliderBar, new SpriteSettings(0, 1089, 2, 50, 0, 0, true, 100) );
		zoomIn = new ZoomInButton(this.id + "_zoomInButton", this.container.createEmptyMovieClip("zoomInButton", this.container.getNextHighestDepth()), this);
		zoomOut = new ZoomOutButton(this.id + "_zoomOutButton", this.container.createEmptyMovieClip("zoomOutButton", this.container.getNextHighestDepth()), this);
		sliderButton = new SliderButton(this.id + "_sliderButton", this.container.createEmptyMovieClip("sliderButton", this.container.getNextHighestDepth()), this);
			
		init();
	}
	
	/**
	 * Init the component with the defaults and already loaded configs
	 */
	function init() {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true
			t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ZoomerV "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
			return;
		}
		this._visible = false
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
	
			case "updatedelay" :
				updatedelay = Number(val);
				break;
			}
		}
		flamingo.addListener(lMap, listento[0], this);
		
		resize();
		refresh();
	}
	/**
	 * Refresh the slider to the correct position and length.
	 */
	function refresh() {
		if (sliderButton.bSlide) {
			return;
		}
		var map = flamingo.getComponent(listento[0]);
		var max = map.getMaxScale();
		var min = map.getMinScale();
		if (min == undefined) {
			min = 0;
		}
		var p;
		var scale = map.getScale();
		if (scale == min) {
			p = 0;
		} else if (scale == max) {

			p = 100;
		} else {
			
			p = (scale-min)/(max-min)*100;
			p = Math.pow(p, (1/3))*21.544347;
			p = Math.min(100, p);
			p = Math.max(0, p);
			if (isNaN(p)) {
				p = 0;
			}
		}
		sliderButton.move(flamingo.getPosition(sliderButton)._x, sliderBar._y+(sliderBar._height*p/100));
	}
	/**
	 * Resize the component according the set values and parent
	 */
	function resize() {
		var r = flamingo.getPosition(this);
		zoomIn.move(r.x, (r.y ));
		zoomOut.move(r.x, (r.y + r.height ));
		sliderBar._x = r.x+zoomIn.width/2-sliderBar._width/2;
		sliderBar._y = r.y+zoomIn.height+sliderButton.height/2;
		sliderBar._height = r.height - zoomOut.height - zoomIn.height;// -sliderButton.height;
		sliderButton.move(sliderBar._x - (sliderButton.width / 2), sliderBar._y+ (sliderButton.height/2));
		refresh()
	}
	
	/**
	 * Do the zoom 
	 * @param	map the map which must zoom
	 * @param	perc percentage of zooming.
	 * @see 	gui.Map#moveToPercentage
	 */
	function _zoom(map:MovieClip, perc:Number) {
		if (map.getScale() == 0) {
			if (perc>100) {
				clearInterval(_zoomid);
				//zoomin
			} else {
				map.moveToScale(0.001, undefined, -1, 0);
				//zoomout
			}
		}
		map.moveToPercentage(perc, undefined, -1, 0);
	}
	
	/**
	 * Update the maps that are referenced with the listento
	 */
	function updateMaps()
	{
		var map = flamingo.getComponent(listento[0]);
		map.update(updatedelay);
		for(var i:Number = 1; i < listento.length; i++)
		{
			var mc = flamingo.getComponent(listento[i]);
			mc.moveToExtent(map.getMapExtent(), updatedelay);
		}
	}
	/**
	 * Cancel the update
	 */
	function cancelUpdate()
	{
		for(var i:Number = 0; i < listento.length; i++)
		{
			var mc = flamingo.getComponent(listento[i]);
			mc.cancelUpdate();
		}
	}
	/****** Getters and setters ****/
	public function get zoomIn():ZoomInButton
	{
		return _zoomIn;
	}
	
	public function set zoomIn(value:ZoomInButton):Void
	{
		_zoomIn = value;
	}
	
	public function get zoomOut():ZoomOutButton
	{
		return _zoomOut;
	}
	
	public function set zoomOut(value:ZoomOutButton):Void
	{
		_zoomOut = value;
	}
	
	public function get sliderBar():MovieClip
	{
		return _sliderBar;
	}
	
	public function set sliderBar(value:MovieClip):Void
	{
		_sliderBar = value;
	}
	
	public function get sliderButton():SliderButton
	{
		return _sliderButton;
	}
	
	public function set sliderButton(value:SliderButton):Void
	{
		_sliderButton = value;
	}
	
	public function get lMap():Object 
	{
		return _lMap;
	}
	
	public function set lMap(value:Object):Void 
	{
		_lMap = value;
	}
	
	public function get spriteMap():SpriteMap 
	{
		return _spriteMap;
	}
	
	public function set spriteMap(value:SpriteMap):Void 
	{
		_spriteMap = value;
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
}