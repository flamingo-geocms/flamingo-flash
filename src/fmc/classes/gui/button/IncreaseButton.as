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
import gui.SliderHor;
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/**
 * IncreaseButton for SliderHor
 * @author Meine Toonen
 */
class gui.button.IncreaseButton extends AbstractButton
{	
	var _sliderHor:SliderHor;
	/**
	 * Constructor for IncreaseButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the sliderHor where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function IncreaseButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(3*SpriteSettings.buttonSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(3*SpriteSettings.buttonSize+SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(3*SpriteSettings.buttonSize+2*SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	/************* event handlers **************/
	public function onPress () {
		sliderHor.cancelUpdate();
	}
	
	public function onRelease () {
		sliderHor.stepSlider(true);
	}
	
	public function onReleaseOutside () {
		sliderHor.stepSlider(true);
	}
	
	public function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_increase"), this);
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