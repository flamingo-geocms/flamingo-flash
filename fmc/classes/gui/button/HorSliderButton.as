/*-----------------------------------------------------------------------------
Copyright (C) 2011 Meine Toonen

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
import gui.SliderHor;
/**
 * Horizontal slider button in sliderhor
 * @author Meine Toonen
 */
class gui.button.HorSliderButton extends AbstractButton
{
	var _sliderHor:SliderHor;	
	var bSlide:Boolean = false;
	/**
	 * Constructor for HorSliderButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the sliderHor where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function HorSliderButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolOverSettings = new SpriteSettings(102, 762, 13, 20,-5, -5, true, 100);
		toolDownSettings  = new SpriteSettings(69, 762, 13, 20, -5, -5, true, 100);
		toolUpSettings = new SpriteSettings(136, 764, 9, 16, -5, -5, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	
	function slide() {
		sliderHor.currentValue = sliderHor.minimum + ((this.container._x-sliderHor.sliderBar._x) / sliderHor.sliderBar._width) * (sliderHor.maximum - sliderHor.minimum);
		sliderHor.updateListeners();
	}
	
	/************* event handlers **************/
	function onPress() {
		sliderHor.cancelUpdate();
		/*
		 * var l = mSliderbar._x;
		var t = mSlider._y;
		var r = mSliderbar._x+mSliderbar._width;
		var b = mSlider._y;*/
		var l = sliderHor.sliderBar._x;
		var t = this.container._y;
		var r = sliderHor.sliderBar._width + sliderHor.sliderBar._x;
		var b = this.container._y;
		this.container.startDrag( false, l, t, r, b);
		var thisObj:HorSliderButton = this;
		this.container.onMouseMove = function() {
			thisObj.bSlide = true;
			thisObj.slide();
		};
	}
	
	function onRelease () {
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		slide();
	}	
	
	function onReleaseOutside() {
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		slide();
	}
	
	function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_slider"), this);
	}
	
	function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	/*********************** Getters and Setters ***********************/
	public function get sliderHor():SliderHor 
	{
		return _sliderHor;
	}
	
	public function set sliderHor(value:SliderHor):Void 
	{
		_sliderHor = value;
	}
}