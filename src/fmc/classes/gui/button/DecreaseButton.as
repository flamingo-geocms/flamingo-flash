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
 * Decrease button in sliderhor
 * @author Meine Toonen
 */
class gui.button.DecreaseButton extends AbstractButton
{	
	var _sliderHor:SliderHor;
	/**
	 * Constructor for DecreaseButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the sliderHor where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function DecreaseButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(3*SpriteSettings.buttonSize, 0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(3*SpriteSettings.buttonSize +SpriteSettings.sliderSize,0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(3*SpriteSettings.buttonSize +2*SpriteSettings.sliderSize, 0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	/**
	 * event handler
	 */
	function onPress() {
		sliderHor.cancelUpdate();
	}
	/**
	 * event handler
	 */
	function onRelease() {
		sliderHor.stepSlider(false);
	}
	/**
	 * event handler
	 */
	function onReleaseOutside() {
		sliderHor.stepSlider(false);
	}
	/**
	 * event handler
	 */
	function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_decrease"), this);
	}
	/**
	 * don't do anything on resize. The parent is positioning this object
	 */
	function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	/*********************** Getters and Setters ***********************/
	/**
	 * get sliderHor
	 */
	public function get sliderHor():SliderHor 
	{
		return _sliderHor;
	}
	/**
	 * set sliderHor
	 */
	public function set sliderHor(value:SliderHor):Void 
	{
		_sliderHor = value;
	}
	
}