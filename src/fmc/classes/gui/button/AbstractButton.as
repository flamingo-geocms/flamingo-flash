/*-----------------------------------------------------------------------------
Copyright (C) 2011  Roy Braam / Meine Toonen B3partners BV

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
import display.spriteloader.SpriteMap;
import display.spriteloader.SpriteSettings;
import display.spriteloader.event.SpriteMapEvent;
import tools.Logger;
/**
 * A abstract button object, extend this to implement a button
 * @author Roy Braam
 * @author Meine Toonen
 */
class gui.button.AbstractButton extends AbstractPositionable{
	//the movieclip that holds the visible part.
	private var _holder:MovieClip;
	
	//Is the button available to use?
	private var _enabled:Boolean;
	
	//is the button pressed
	private var _pressed:Boolean;
	//the id of the tooltip (default: 'tooltip');
	private var _tooltipId:String;
	
	//the movieclip loader
	private var _mcloader:MovieClipLoader;
	
	//the movieclips that are shown.
	private var _mcUp:MovieClip;
	private var _mcOver:MovieClip;
	private var _mcDown:MovieClip;	
	//the links to the images.
	private var _toolDownLink:String;
	private var _toolUpLink:String;
	private var _toolOverLink:String;
	
	private var _toolDownSettings:SpriteSettings;
	private var _toolUpSettings:SpriteSettings;
	private var _toolOverSettings:SpriteSettings;
	
	private var _spriteMap:SpriteMap;
	
	/**
	 * Constructor for abstractButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 * @see 	core.AbstractPositionable
	 */
	public function AbstractButton(id:String, container:MovieClip) {			
		super(id, container);
		spriteMap = flamingo.spriteMap;
		
		//make the holder for the movieclip
		this.holder = this.container.createEmptyMovieClip("tool_" + id + "_holder", this.container.getNextHighestDepth());
		
		//set init vars
		this.enabled = true;		
		this.tooltipId = "tooltip";				
		
		//load the button images.
		this.mcDown = this.holder.createEmptyMovieClip("tool_" + id+"_down", this.holder.getNextHighestDepth());
		this.mcOver = this.holder.createEmptyMovieClip("tool" + id + "_over", this.holder.getNextHighestDepth());
		this.mcUp = this.holder.createEmptyMovieClip("tool" + id+"_up", this.holder.getNextHighestDepth());
								
		this.mcloader = new MovieClipLoader();			
				
		this.mcDown._visible = false;
		this.mcOver._visible = false;
		this.mcUp._visible = true;
		
		if (flamingo.spriteMap.loaded) {
			this.resize();
		}else {
			var thisObj = this;
			flamingo.spriteMap.addEventListener(SpriteMapEvent.LOAD_COMPLETE, function() {
				thisObj.resize();
			});
		}
		
		this.setEvents();	
	}
	/**
	 * Set the events of this button.
	 */
	public function setEvents():Void {		
		var thisObj:AbstractButton = this;
		this.holder.onRollOver = function() {	
			var s:String = thisObj.flamingo.getString(thisObj, thisObj.tooltipId);
			thisObj.flamingo.showTooltip(s, thisObj);
			if (thisObj.isClickable()){
				//var id = thisObj.flamingo.getId(thisObj);
				thisObj.mcOver._visible = true;
				thisObj.mcUp._visible = false;	
				thisObj.onRollOver();
			}
		}
		this.holder.onRollOut = function() {
			if (thisObj.isClickable()) {
				thisObj.mcOver._visible = false;				
				thisObj.mcDown._visible = false;
				thisObj.mcUp._visible = true;
				thisObj.onRollOut();
			}
		}
		this.holder.onPress = function() {
			if (thisObj.isClickable()) {				
				thisObj.pressed = true;
				thisObj.mcOver._visible = false;
				thisObj.mcUp._visible = false;
				thisObj.mcDown._visible = true;
				thisObj.onPress();		
			}
		}
		this.holder.onRelease = function() {
			if (thisObj.isClickable()) {	
				thisObj.pressed = false;
				thisObj.mcDown._visible = false;
				thisObj.mcUp._visible = false;
				thisObj.mcOver._visible = true;
				thisObj.onRelease();
			}
		}
		this.holder.onReleaseOutside = function() {
			if (thisObj.isClickable()) {
				thisObj.pressed = false;
				thisObj.onReleaseOutside();
			}
		};
		
		this.holder.onDragOver = function() {
			if (thisObj.isClickable()) {
				if (thisObj.pressed) {				
					thisObj.mcOver._visible = false;	
					thisObj.mcUp._visible = false;			
					thisObj.mcDown._visible = true;	
					thisObj.onDragOver();
				}
			}
		};
		
		this.holder.onDragOut = function() {
			if (thisObj.isClickable()) {						
				thisObj.mcOver._visible = false;		
				thisObj.mcDown._visible = false;		
				thisObj.mcUp._visible = true;	
				
			}
		};
	}
	/**
	 * Enable/disable (grayout) the tool
	 * @param	b true(enable) or false(disable
	 */
	public function setEnabled(b:Boolean):Void{
		if (b) {
			this.container._alpha = 100;
		} else {
			this.mcOver._visible = false;			
			this.mcDown._visible = false;			
			this.mcUp._visible = true;
			this.container._alpha = 20;
		}
		this._enabled = b;
	}	
	/**
	 * Returns true if this button is clickable
	 */
	public function isClickable():Boolean {
		return this.enabled;
	}
	/*****************************************************
	 * Old functions that need to be supported.
	 */
	public function click() {
		this.onPress();
	}
	/*******************************************************
	 * Functions that can be used to handle events on the button.
	 */
	
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onRelease() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onPress() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onRollOut() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onRollOver() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onReleaseOutside() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onDragOver() { }
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onDragOut() { }
	
	/**
	 * needs to be overwritten
	 * @param	xml
	 */
	public function setConfig(xml:Object) {
		Logger.console("!!!Function setConfig() needs to be overwritten in: "+this.id);
	}
	/*********************** Getters and Setters ***********************/
	public function get holder():MovieClip 
	{
		return _holder;
	}
	/**
	 * set holder
	 */
	public function set holder(value:MovieClip):Void 
	{
		_holder = value;
	}
	/**
	 * get enabled
	 */
	public function get enabled():Boolean{
		return _enabled;
	}
	/**
	 * set enabled
	 */
	public function set enabled(value:Boolean) {
		this._enabled = value;
	}
	/**
	 * get toolDownLink
	 */
	public function get toolDownLink():String{
		return _toolDownLink;
	}
	/**
	 * set toolDownLink
	 */
	public function set toolDownLink(value:String):Void {
		_toolDownLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolDownLink), this.mcDown.createEmptyMovieClip("container",0));		
	}
	/**
	 * get toolUpLink
	 */
	public function get toolUpLink():String 
	{
		return _toolUpLink;
	}
	/**
	 * set toolUpLink
	 */
	public function set toolUpLink(value:String):Void{
		_toolUpLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolUpLink), this.mcUp.createEmptyMovieClip("container",0));		
	}
	/**
	 * get toolOverLink
	 */
	public function get toolOverLink():String 
	{
		return _toolOverLink;
	}
	/**
	 * set toolOverLink
	 */
	public function set toolOverLink(value:String):Void {
		_toolOverLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolOverLink), this.mcOver.createEmptyMovieClip("container",0));		
	}
	/**
	 * get tooltipId
	 */
	public function get tooltipId():String 
	{
		return _tooltipId;
	}
	/**
	 * set tooltipId
	 */
	public function set tooltipId(value:String):Void 
	{
		_tooltipId = value;
	}
	/**
	 * get mcUp
	 */
	public function get mcUp():MovieClip 
	{
		return _mcUp;
	}
	/**
	 * set mcUp
	 */
	public function set mcUp(value:MovieClip):Void 
	{
		_mcUp = value;
	}
	/**
	 * get mcOver
	 */
	public function get mcOver():MovieClip 
	{
		return _mcOver;
	}
	/**
	 * set mcOver
	 */
	public function set mcOver(value:MovieClip):Void 
	{
		_mcOver = value;
	}
	/**
	 * get mcDown
	 */
	public function get mcDown():MovieClip 
	{
		return _mcDown;
	}
	/**
	 * set mcDown
	 */
	public function set mcDown(value:MovieClip):Void 
	{
		_mcDown = value;
	}
	/**
	 * get mcloader
	 */
	public function get mcloader():MovieClipLoader {
		return _mcloader;
	}
	/**
	 * set mcloader
	 */
	public function set mcloader(value:MovieClipLoader):Void {
		_mcloader = value;
	}
	/**
	 * get pressed
	 */
	public function get pressed():Boolean {
		return _pressed;
	}
	/**
	 * set pressed
	 */
	public function set pressed(value:Boolean):Void {
		_pressed = value;
	}
	/**
	 * get toolDownSettings
	 */
	public function get toolDownSettings():SpriteSettings 
	{
		return _toolDownSettings;
	}
	/**
	 * set toolDownSettings
	 */
	public function set toolDownSettings(value:SpriteSettings):Void 
	{
		_toolDownSettings = value;
		spriteMap.attachSpriteTo(this.mcDown.createEmptyMovieClip("container", this.mcDown.getNextHighestDepth()),value);
	}
	/**
	 * get toolUpSettings
	 */
	public function get toolUpSettings():SpriteSettings 
	{
		return _toolUpSettings;
	}
	/**
	 * set toolUpSettings
	 */
	public function set toolUpSettings(value:SpriteSettings):Void 
	{
		_toolUpSettings = value;
		spriteMap.attachSpriteTo(this.mcUp.createEmptyMovieClip("container", this.mcUp.getNextHighestDepth()),value);
	}
	/**
	 * get toolOverSettings
	 */
	public function get toolOverSettings():SpriteSettings 
	{
		return _toolOverSettings;
	}
	/**
	 * set toolOverSettings
	 */
	public function set toolOverSettings(value:SpriteSettings):Void 
	{
		_toolOverSettings = value;
		spriteMap.attachSpriteTo(this.mcOver.createEmptyMovieClip("container", this.mcOver.getNextHighestDepth()),value);
	}
	/**
	 * get spriteMap
	 */
	public function get spriteMap():SpriteMap 
	{
		return _spriteMap;
	}
	/**
	 * set spriteMap
	 */
	public function set spriteMap(value:SpriteMap):Void 
	{
		_spriteMap = value;
	}
	/**
	 * set width
	 */
	public function set width(value:Number) {
		mcUp._width = value;
		mcDown._width = value;
		mcOver._width = value;	
	}
	/**
	 * set height
	 */
	public function set height(value:Number) {
		mcUp._height = value;
		mcDown._height = value;
		mcOver._height = value;
	}
	/**
	 * get width
	 */
	public function get width():Number {
		return mcUp._width;
	}
	/**
	 * get height
	 */
	public function get height():Number {
		return mcUp._height;
	}
}