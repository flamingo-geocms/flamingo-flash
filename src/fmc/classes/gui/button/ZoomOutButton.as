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
import gui.ZoomerV;
import tools.Logger;
import gui.button.AbstractButton;
import display.spriteloader.SpriteSettings;

/**
 * Zoomout Button that is used in the ZoomerV component
 * @author Meine Toonen
 */
class gui.button.ZoomOutButton extends AbstractButton
{
	private var zoomerV:ZoomerV;
	private var _zoomid:Number;
	/**
	 * Constructor for ZoomOutButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the sliderHor where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function ZoomOutButton(id:String, container:MovieClip, zoomerV:ZoomerV){
		super(id, container);
		toolDownSettings = new SpriteSettings(3*SpriteSettings.buttonSize, 0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(3*SpriteSettings.buttonSize +SpriteSettings.sliderSize,0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(3*SpriteSettings.buttonSize +2*SpriteSettings.sliderSize, 0, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		this.zoomerV = zoomerV;
		this.parent = zoomerV;
	}
	
	/**
	 * Gets the real parent object 
	 * @return the real parent. In this case its always the zoomerV
	 */
	public function getParent():Object {
		return this.zoomerV;
	}
	/************* event handlers **************/
	public function onPress()
	{
		zoomerV.cancelUpdate();
		_zoomid = setInterval(zoomerV, "_zoom", 10, map, 95);
	}
	
	public function onRelease()
	{
		clearInterval(_zoomid);
		zoomerV.updateMaps();
	}
	
	public function onReleaseOutside()
	{
		clearInterval(_zoomid);
		zoomerV.updateMaps();
	}
	
	public function onRollOver()
	{
		flamingo.showTooltip(flamingo.getString(zoomerV, "tooltip_zoomout"), this);
	}
	
	public function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	/*********************** Getters and Setters ***********************/
	public function get map():Object
	{
		return flamingo.getComponent(this.zoomerV.listento[0]);
	}
}