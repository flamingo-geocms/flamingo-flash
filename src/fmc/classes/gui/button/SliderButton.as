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
import gui.ZoomerV;
import tools.Logger;
import display.spriteloader.SpriteSettings;

/**
 * Slider button that is used in the ZoomerV
 * @author Meine Toonen
 */
class gui.button.SliderButton extends AbstractButton
{
	private var zoomerV:ZoomerV;
	var center:Object;
	var bSlide:Boolean = false;
	var p:Number;
	/**
	 * Constructor for SliderButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the sliderHor where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function SliderButton(id:String, container:MovieClip, zoomerV:ZoomerV)
	{
		super(id, container);
		toolOverSettings = new SpriteSettings(3*SpriteSettings.buttonSize, 3*SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolDownSettings  = new SpriteSettings(3*SpriteSettings.buttonSize+SpriteSettings.sliderSize, 3*SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(3*SpriteSettings.buttonSize+2*SpriteSettings.sliderSize, 3*SpriteSettings.sliderSize, SpriteSettings.sliderSize, SpriteSettings.sliderSize , 0, 0, true, 100);
		this.zoomerV = zoomerV;
		this.parent = zoomerV;
	}
	/************* event handlers **************/
	function onPress()	{
		zoomerV.cancelUpdate();
		var l = this.container._x;
		var t = zoomerV.sliderBar._y-(this.height/2);
		var r = this.container._x;
		var b = zoomerV.sliderBar._y + zoomerV.sliderBar._height-(this.height/2);
		
		this.container.startDrag(false, l, t, r, b);
		var thisObj = this;
		center = map.getCenter();
		this.container.onMouseMove = function()
		{
			thisObj.bSlide = true;
			thisObj.zoomSlider();
		};
	}
	
	function onRelease()
	{
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		zoomerV.updateMaps();
	}
	
	function onDragOut()	{
		bSlide = true;
		zoomSlider();
	}
	
	function onDragOver()	{
		bSlide = true;
		zoomSlider();
	}
	
	function onReleaseOutside()	{
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		zoomerV.updateMaps();
	}
	
	function onRollOver()	{
		flamingo.showTooltip(flamingo.getString(zoomerV, "tooltip_slider"), this);
	}
	/**
	 * is used when the button is dragged
	 */
	function zoomSlider()	{
		var max = map.getMaxScale();
		var min = map.getMinScale();
		if(min == undefined)
		{
			min = 0.001;
		}
		
		p = (this.container._y-zoomerV.sliderBar._y)/zoomerV.sliderBar._height*100;
		p = p/21.544347;
		p = p*p*p;
		p = Math.min(100, p);
		p = Math.max(0, p);
		var scale = min + ((max - min) * p / 100);
		map.moveToScale(scale, center, -1, 0);
	}
	
	function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	/*********************** Getters and Setters ***********************/
	public function get map():Object
	{
		return flamingo.getComponent(this.zoomerV.listento[0]);
	}
}