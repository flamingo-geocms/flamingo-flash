/**
 * @author Meine Toonen

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
	/** @component SliderHor
	* A horizontal slider.
	* @file SliderHor.fla (sourcefile)
	* @file SliderHor.swf (compiled component, needed for publication on internet)
	* @file SliderHor.xml (configurationfile, needed for publication on internet)
	* @configstring minimum Minimum value.
	* @configstring maximum Maximum value.
	* @configstring initial Initial value.
	* @configstring slidestep Value to increase or decrease current setting with every click.
	* @configstring setter name of method on listeners to apply new value.
	* @configstring tooltip_increase Tooltip of plus button.
	* @configstring tooltip_decrease Tooltip of min button.
	* @configstring tooltip_slider Tooltip of slider button.
	*/
	/** @tag <fmc:SliderHor>  
	* This tag defines a horizontal slider. Another component may listen to change events.
	* @example
	* <fmc:SliderHor left="10" top="10" width="300" minimum="0" maximum="100" initial="100" setter="setAlpha" slidestep="5">
	*		    <string id="tooltip_increase" en="opaque" nl="ondoorzichtig"/>
	*		    <string id="tooltip_decrease" en="transparent" nl="transparant"/>
	*		    <string id="tooltip_slider" en="drag to change transparency" nl="schuif voor transparantie"/>
	* </fmc:SliderHor>
	* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
	* @attr skin (defaultvalue="") Available skins: "", "f2" 
	*/
import core.AbstractPositionable;
import gui.button.DecreaseButton;
import gui.button.HorSliderButton;
import gui.button.IncreaseButton;
import display.spriteloader.SpriteSettings;
import display.spriteloader.SpriteMap;
import TextField.StyleSheet;
import tools.Logger;

class gui.SliderHor extends AbstractPositionable{
	
	/*-----------------------------------------------------------------------------*/

	var initial:Number = 100;
	var updatedelay:Number = 500;
	var setter:String = "";
	var currentValue:Number = 0;
	var minimum:Number = 0;
	var maximum:Number = 100;
	var slidestep:Number = (maximum - minimum) / 20;
	
	var _sliderButton:HorSliderButton;
	var _increaseButton:IncreaseButton;
	var _decreaseButton:DecreaseButton;
	var _sliderBar:MovieClip;
	var _spriteMap:SpriteMap;
	var _mLabel:TextField;
	
	public function SliderHor(id:String, container:MovieClip) 
	{
		super(id, container);
		//---------------------------------------
		var thisObj:SliderHor = this;
		var lParent:Object = new Object();
		lParent.onResize = function(mc:MovieClip) {
			thisObj.resize();
		};
		flamingo.addListener(lParent, flamingo.getParent(this), this);
		

		
		//---------------------------------------
		init();
		
				//build buttons
		spriteMap = flamingo.spriteMapFactory.obtainSpriteMap(flamingo.correctUrl( "assets/img/sprite.png"));
		
		sliderBar = this.container.createEmptyMovieClip("sliderBar", this.container.getNextHighestDepth());
		spriteMap.attachSpriteTo(sliderBar, new SpriteSettings(0, 762, 50, 2, 0, 0, true, 100) );
		sliderButton = new HorSliderButton("sliderButton", this.container.createEmptyMovieClip("sliderButton_container", this.container.getNextHighestDepth()), this);
		increaseButton = new IncreaseButton("increaseButton", this.container.createEmptyMovieClip("increaseButton_container", this.container.getNextHighestDepth()), this);
		decreaseButton = new DecreaseButton("decreaseButton", this.container.createEmptyMovieClip("decreaseButton _container", this.container.getNextHighestDepth()), this);

		
		if (flamingo.getString(this, "label") != undefined && flamingo.getString(this, "label") != "") {
			mLabel = this.container.createTextField("mLabel", this.container.getNextHighestDepth(), 0, 0, 100, 25);
			mLabel.multiline = false;
			mLabel.wordWrap = false;
			mLabel.html = true;
			mLabel.selectable = false;
			mLabel.styleSheet = StyleSheet(flamingo.getStyleSheet(this));
			mLabel.text = "<p class='text'>" + flamingo.getString(this, "label") + "</p>";
			mLabel._width = mLabel.textWidth+5;
			mLabel._height = mLabel.textHeight+5;
		}
	}
	
	function init() {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true
			t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>SliderHor "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
			return;
		}
		this._visible = false

		//defaults
		var xml:XML = flamingo.getDefaultXML(this);
		this.setConfig(xml);
		delete xml;

		//custom
		var xmls:Array= flamingo.getXMLs(this);
		for (var i = 0; i < xmls.length; i++){
			this.setConfig(xmls[i]);
		}
		delete xmls;
		//remove xml from repository
		flamingo.deleteXML(this);
		
		var eventHandler:Object = new Object();
		var thisObj:SliderHor = this;
		eventHandler.onSetValue = function (sourceSetter:String, newValue:Number, layer:Object) {
			  if (sourceSetter == thisObj.setter) {
				thisObj.currentValue = newValue;
				thisObj.refresh();
			  }
		}
		flamingo.addListener(eventHandler, listento, this);
		
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
			xml=xml.firstChild;
		}
		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
				case "minimum" :
					minimum = Number(val);
					break;
				case "maximum" :
					maximum = Number(val);
					break;
				case "initial" :
					initial = Number(val);
					break;
				case "slidestep" :
					slidestep = Number(val);
					break;
				case "setter" :
					setter = val;
					break;
			}
		}

		currentValue = initial;
		resize();
		refresh();
	}

	function stepSlider(increase:Boolean) {
		if (increase) {
		  currentValue += slidestep;
		}
		else {
		  currentValue += -slidestep;
		}

		if (minimum < maximum) {
			if (currentValue < minimum) {
			  currentValue = minimum;
			}
			if (currentValue > maximum) {
			  currentValue = maximum;
			}
		  }
		  else {
			if (currentValue > minimum) {
			  currentValue = minimum;
			}
			if (currentValue < maximum) {
			  currentValue = maximum;
			}
		  }

		  updateListeners();    
	}


	function refresh() {
		if (sliderButton.bSlide) {
			return;
		}
		sliderButton.container._x = sliderBar._x + (sliderBar._width * Math.abs(minimum - currentValue) / Math.abs(maximum - minimum));
	}

	function resize() {
		var r = flamingo.getPosition(this);
		//increaseButton.container._x = r.x + r.width - mIncrease._width / 2;
		increaseButton.move(r.x + r.width + increaseButton.width / 2, r.y);
	//	mIncrease._y = r.y;
		decreaseButton.move( r.x + decreaseButton.width / 2, r.y);
		//mDecrease._y = r.y;
		sliderBar._x = r.x + (decreaseButton.width *2) + (sliderButton.width/2);
		sliderBar._y = r.y + decreaseButton.height / 2;
		sliderBar._width = r.width - decreaseButton.width - increaseButton.width  - sliderButton.width;
		sliderButton.container._x = sliderBar._x;
		sliderButton.container._y = sliderBar._y - (sliderButton.height/2);
		if (mLabel != undefined) {
			mLabel._x = r.x + decreaseButton.width;
			mLabel._y = r.y + 5;
		}
		refresh();
	}

	function updateListeners() {
		for (var i:Number = 0; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			if (mc[setter]) {
			  mc[setter](currentValue);
			}
			else {
			  flamingo.tracer("Error: method with name '" + setter + "' not found on listener '" + listento[i] + "'");
			}
		}
		refresh();
	}
	
	function cancelUpdate()
	{
		for(var i:Number = 0; i < listento.length; i++)
		{
			var mc = flamingo.getComponent(listento[i]);
			mc.cancelUpdate();
		}
	}
	
	public function get sliderButton():HorSliderButton 
	{
		return _sliderButton;
	}
	
	public function set sliderButton(value:HorSliderButton):Void 
	{
		_sliderButton = value;
	}
	
	public function get increaseButton():IncreaseButton 
	{
		return _increaseButton;
	}
	
	public function set increaseButton(value:IncreaseButton):Void 
	{
		_increaseButton = value;
	}
	
	public function get decreaseButton():DecreaseButton 
	{
		return _decreaseButton;
	}
	
	public function set decreaseButton(value:DecreaseButton):Void 
	{
		_decreaseButton = value;
	}
	
	public function get sliderBar():MovieClip 
	{
		return _sliderBar;
	}
	
	public function set sliderBar(value:MovieClip):Void 
	{
		_sliderBar = value;
	}
	
	public function get spriteMap():SpriteMap 
	{
		return _spriteMap;
	}
	
	public function set spriteMap(value:SpriteMap):Void 
	{
		_spriteMap = value;
	}
	
	public function get mLabel():TextField 
	{
		return _mLabel;
	}
	
	public function set mLabel(value:TextField):Void 
	{
		_mLabel = value;
	}

	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
}