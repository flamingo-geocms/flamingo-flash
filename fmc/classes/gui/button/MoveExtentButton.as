/*-----------------------------------------------------------------------------
Copyright (C) 2011 Roy Braam

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
import gui.BorderNavigation;
import gui.button.AbstractButton;
import tools.Logger;
/**
 * Button is a part of the BorderNavigation component
 * @author Roy Braam
 */
class gui.button.MoveExtentButton extends AbstractButton {
	private var _moveId:Number;
	
	private var _xDirection:Number;
	private var _yDirection:Number;
	private var _borderNavigation:BorderNavigation = null;
	
	/**
	 * Constructor for MoveExtentButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @param	the bordernavigation component where this button is in
	 * @see 	gui.button.AbstractButton
	 */	
	public function MoveExtentButton(id:String, container:MovieClip, borderNavigation:BorderNavigation) {
		super(id, container);
		this.borderNavigation = borderNavigation;		
		this.parent = borderNavigation;		
	}
	/**
	 * Set the direction (vector) of the map if clicked on this button
	 * @param	x x direction
	 * @param	y y direction
	 */
	public function setDirectionMatrix(x, y) {
		this.xDirection = x;
		this.yDirection = y;
	}
	/************* event handlers **************/
	public function onPress() {
		this.startMove();
	}
	public function onRelease() {
		this.stopMove();
	}
	public function onReleaseOutside() {
		this.stopMove();		
	}	
	/**
	 * Start moving
	 */	
	public function startMove() {		
		var dx = 0;
		var dy = 0;
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.__width;
		var msy = (e.maxy - e.miny) / map.__height;
		dy = this.yDirection * map.__height / 40 * msy;
		dx = this.xDirection * map.__width / 40 * msx;
		
		var obj:Object = new Object();
		obj.map = map;
		obj.dx = dx;
		obj.dy = dy;
		_moveId = setInterval(this, "_move", 10, obj);
		
	}
	/**
	 * Stop moving
	 */
	public function stopMove() {
		clearInterval(_moveId);
		this.borderNavigation.updateMaps();
	}
	/**
	 * Do the move
	 * @param	obj the direction for moving the map
	 */
	function _move(obj:Object) {
		var e = obj.map.getCurrentExtent();
		e.minx = e.minx+obj.dx;
		e.miny = e.miny+obj.dy;
		e.maxx = e.maxx+obj.dx;
		e.maxy = e.maxy+obj.dy;
		obj.map.moveToExtent(e, -1, 0);
	}
	
	function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	
	/**
	 * Gets the real parent object 
	 * @return the real parent. In this case its always the borderNavigation
	 */
	public function getParent():Object {
		return this._borderNavigation;
	}
	/*********************** Getters and Setters ***********************/
	public function get map():Object {
		return flamingo.getComponent(this.borderNavigation.listento[0]);
	}
	public function get xDirection():Number {
		return _xDirection;
	}
	
	public function set xDirection(value:Number):Void {
		_xDirection = value;
	}
	
	public function get yDirection():Number {
		return _yDirection;
	}
	
	public function set yDirection(value:Number):Void {
		_yDirection = value;
	}
	
	public function get borderNavigation():BorderNavigation {
		return _borderNavigation;
	}
	
	public function set borderNavigation(value:BorderNavigation):Void {
		_borderNavigation = value;
	}
}