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
		toolDownSettings = new SpriteSettings(269, 1093, 20, 20, -4, -9, true, 100);
		toolOverSettings = new SpriteSettings(311, 1093, 20, 20, -4, -9, true, 100);
		toolUpSettings = new SpriteSettings(353, 1094, 16, 17, -4, -9, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	/************* event handlers **************/
	function onPress() {
		sliderHor.cancelUpdate();
	}
	
	function onRelease() {
		sliderHor.stepSlider(false);
	}
	
	function onReleaseOutside() {
		sliderHor.stepSlider(false);
	}
	
	function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_decrease"), this);
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