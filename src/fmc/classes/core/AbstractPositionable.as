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
import core.AbstractComposite;
import core.AbstractListenerRegister;
import mx.data.encoders.Num;
import tools.Logger;
/**
 * A abstractpositionable object. Extend this object if you want to create a component that 
 * is placeable somewhere in the movie. It has some backward compatible things so it works with the older parts
 * of flamingo
 * @author Roy Braam 
 * @author Meine Toonen
 */
class core.AbstractPositionable extends AbstractListenerRegister
{	
	/*Defaults set by flamingo*/
	private var _name:String;
	private var _widthSetting:String;
	private var _heightSetting:String;
	private var _left:String;
	private var _right:String;
	private var _top:String;
	private var _bottom:String;
	private var _xcenter:String;
	private var _ycenter:String;
	private var _maxwidth:Number;
	private var _minwidth:Number;
	private var _maxheight:Number;
	private var _minheight:Number;
	
	//loaded ??
	private var _loaded:Boolean;
	//type of object
    private var _type:String;
	//the id of this object
	private var _id:String;
	//the movieclip that contains the visible part of the component.
	private var _container:MovieClip;
	//version of component.
	private var _version:String;	
	//visible
	private var configVisible:Boolean;
	//The strings that are used in this component
	private var _strings:Object;
	//The cursors for the object
	private var _cursors:Object;
	//Styles for the object
	private var _styles:TextField.StyleSheet;
	//guides of object
	private var _guides:Object = null;
	//the id of the cursor (default: 'cursor');
	private var _cursorId:String;
	//a array of id's to listen to
	private var _listento:Array;
	//The default xml with init config
	private var _defaultXML:String;
	//the name of the parent. It's only used by old flamingo code. Implemented to be backwards compatible
	private var _parentName:String;
	//if the parent is a AbstractPositionable:
	private var _parentObject:AbstractPositionable;
	//Border movieclip
	private var _mBorder:MovieClip;
	//Border settings:	
	private var _bordercolor:Number;
	private var _borderwidth:Number;
	private var _borderalpha:Number;
	//__width and __height settings.
	private var _width2;
	private var _height2;
	/**
	 * Constructor 
	 * @param	id the id
	 * @param	container the visible container.
	 */
	public function AbstractPositionable (id:String, container:MovieClip) {
		this.id = id;
		this.container = container;
		
		//init vars
		this.cursorId = "cursor";
		
		this.visible = true;
		this.strings = new Object();
		this.cursors = new Object();
		this.styles = new TextField.StyleSheet();	
		this.borderalpha = 100;
		this.version = "2.0";
		//this.height = "10";
		this._loaded = true;
		reassignListeners();		
	}
	/**
	 * overwrite in implementation
	 * @param	xml
	 */
	public function setConfig(xml:XML) { }
	
	/**
	 * Pass the hittest to the movieclip so the function call is backwards compatible
	 * @param	x xcoord 
	 * @param	y ycoord
	 * @param	shapeFlag
	 * @return	true if hit
	 */
	public function hitTest(x:Number, y:Number, shapeFlag:Boolean):Boolean {
		return this.container.hitTest(x, y, shapeFlag);
	}
	/**
	 * create a border around this component. It uses the border settings set for this component.
	 */
	public function createBorder():Void {
		if (this._mBorder == undefined)
			this._mBorder = this.container.createEmptyMovieClip("mBorder", 2);		
		mBorder.clear();
		mBorder.lineStyle(borderwidth, bordercolor, borderalpha);
		mBorder.moveTo(0, 0);
		mBorder.lineTo(this.__width, 0);
		mBorder.lineTo(this.__width, this.__height);
		mBorder.lineTo(0, this.__height);
		mBorder.lineTo(0, 0);
		
		mBorder._width = __width;
		mBorder._height = __height;
		
	}
	/**
	 * Function to resize this component
	 */
	public function resize() {		
		this.flamingo.position(this);
		if (this.mBorder != undefined) {
			flamingo.position(this.mBorder);
		}
		flamingo.raiseEvent(this, "onResize", this);
		
	}
	/**
	 * Moves the movieclip to the given x and y
	 * @param	x
	 * @param	y
	 */
	function move(x:Number, y:Number) {
		if (!(isNaN(x))) {
			this.container._x = x;
		}
		if (!(isNaN(y))) {
			this.container._y = y;
		}
	}
	/**
	 * Use this function to reassing Listeners that are set on a dummy object in flamingo.
	 * If the listento in a object references an object that is not set yet, a dummy object wil be made
	 * to store the listeners. In the 'old' way the rest of the information is set on that object when the 
	 * object is loaded. The new way creates a new object with a constructor, so the old object with listeners
	 * is only a dummy. There for it must be reassigned.
	 */ 
	public function reassignListeners() {
		/* A Component is added before, and had a listener to this object.
		 * Therefor a temp listener object is made. Now add the listener to the real thing.*/
		var oldComponent = flamingo.getRawComponent(id);
		if (oldComponent != undefined) {
			//There is a listener added. Now add it on the newly created object
			if (oldComponent._listeners != undefined) {
				//enable broadcasting
				AsBroadcaster.initialize(flamingo.getComponent[id]);
				for (var i = 0; i < oldComponent._listeners.length; i++) {
					flamingo.addListener(oldComponent._listeners[i], this,oldComponent.callers[i]);
				}
			}
		}
	}
	
	/**
	* Shows or hides the component.
	* This will raise the onSetVisible event.
	* @param vis:Boolean True or false.
	*/
	function setVisible(vis:Boolean):Void {
		this._visible = vis;
		this.visible = vis;
		flamingo.raiseEvent(this, "onSetVisible", this, vis);
	}
	
	/***********************************************************************
	*functions that are needed to work with old (not OO) flamingo code
	*/
	/**
	 * getter target
	 */
	public function get target():String {
		return this.container._target;
	}
	/**
	 * getter _target
	 */
	public function get _target():String {
		return this.container._target;
	}
	/**
	 * Function to support old flamingo code that calls _parent on the MovieClip. 
	 * Returns the .parent function
	 * @see AbstractPositionable#parent
	 * @deprecated 
	 */
	public function get _parent():Object {
		return this.parent;
	}
	/**
	 * Returns the parent object. Default it's the MovieClip container._parent. 
	 * If the parentObject is set that is returned, it's the real parent.
	 * If .parent is set by old flamingo code (a mc name is set and is stored in _parentName)
	 * the _parentName is returned.
	 * If not the parentObject nor the parentName is set, the getParent function is called. Implementations
	 * can overwrite this function.
	 */
	public function get parent():Object {	
		//if a old flamingo object is set as parent the _parentName is returned (the old way)
		if (_parentObject != undefined) {
			return _parentObject;
		}else if (_parentName != undefined ) {
			return flamingo.getComponent(_parentName);
		}else{
			return this.getParent();
		}
	}
	/**
	 * Gets the real parent object
	 * Needs to be implemented if the parent is not set as parent, but needs to return something else.
	 * Is only called when there is no parent set.
	 * @return the real parent.
	 */
	public function getParent():Object {
		return this.container._parent;
	}
	/**
	 * Sets the parent for flamingo. Also compatible with old flamingo code.
	 * If the name of a parent movieclip is set it is stored in the _parentName.
	 * @param value A AbstractPositionable object that is the parent. Can also be a string (old flamingo code)
	 * that name is stored in the _parentName.
	 */
	public function set parent(value:Object) {
		var lParent:Object = new Object();		
		var thisObj:AbstractPositionable = this;
		lParent.onResize = function(mc:MovieClip ) {
			//if the parent is resized then resize this.			
			thisObj.resize();
		};
		//resize after the parent is init
		lParent.onInit = function(mc:MovieClip) {
			thisObj.resize();
		}
		if (value instanceof AbstractPositionable) {
			//the parent is a new component.
			this._parentObject = AbstractPositionable(value);
			this.flamingo.addListener(lParent, value, this);
		}else if (value instanceof String || typeof(value) == "string") {			
			//The parent is a movieclip / old flamingo object.
			this._parentName = String(value);	
			this.flamingo.addListener(lParent, value, this);
		}else {
			Logger.console("!!!!!!!! Can't set the parent for: "+id+" because the given value is not of "+
			"type AbstractPositionable (new code) or String (Old code): "+value);
		}
	}
	/**
	 * Returnes Flamingo as set in the _global
	 */
	public function get flamingo():Object {
		return _global.flamingo;
	}
	
	/**
	 * Both _visible (getter and setter) are forwarded to the container _visible(getter and setter)
	 */	
	public function set _visible(value:Boolean) {
		this.container._visible = value;
	}
	/**
	 * Both _visible (getter and setter) are forwarded to the container _visible(getter and setter)
	 */	
	public function get _visible():Boolean {
		return this.container._visible;
	}
	/**
	 * setter _alpha
	 */
	public function set _alpha(value:Number) {
		this.container._alpha=value;
	}
	/**
	 * getter _alpha
	 */
	public function get _alpha():Number {
		return this.container._alpha;
	}	
	/**
	 * getter __width
	 */
	public function get __width():Number {
		return this._width2;
	}
	/**
	 * setter __width
	 */
	public function set __width(value:Number):Void {
		this._width2 = value;
	}
	/**
	 * getter __height
	 */
	public function get __height():Number {
		return this._height2;
	}
	/**
	 * setter __height
	 */
	public function set __height(value:Number):Void {
		this._height2=value;
	}
	/***********************************************************************/	
	/***********************************************************************
	 * Getters and Setters.
	 */
	/**
	 * getter _height
	 */
	public function get _height():Number {
		return this.container._height;
	}
	/**
	 * getter _width
	 */
	public function get _width():Number {
		return this.container._width;
	}
	/**
	 * setter _height
	 */
	public function set _height(value:Number) {
		this.container._height=value;
	}
	/**
	 * setter _width
	 */
	public function set _width(value:Number) {
		this.container._width=value;
	}
	
	/**
	 * getter id
	 */	
	public function get id():String 
	{		
		return _id;
	}
	/**
	 * setter id
	 */
	public function set id(value:String):Void 
	{
		_id = value;
	}
	/**
	 * getter container
	 * the movieclip that contains the visible part of the component.
	 */
	public function get container():MovieClip 
	{
		return _container;
	}
	/**
	 * setter container
	 */
	public function set container(value:MovieClip):Void 
	{
		_container = value;
	}
	/**
	 * getter loaded
	 */
	public function get loaded():Boolean 
	{
		return _loaded;
	}
	
	public function set loaded(value:Boolean):Void 
	{
		_loaded = value;
	}
	/**
	 * getter type
	 */
	public function get type():String 
	{
		return _type;
	}
	
	/**
	 * setter type
	 */
	public function set type(value:String):Void 
	{
		_type = value;
	}
	
	/**
	 * getter visible
	 */
	public function get visible():Boolean { 		
		return configVisible;
	}
	
	/**
	 * setter visible
	 */
	public function set visible(value:Boolean):Void {
		this.configVisible = value;
	}
		
	/**
	 * getter strings
	 * The strings that are used in this component
	 */
	public function get strings():Object 
	{
		return _strings;
	}
	
	/**
	 * setter strings
	 * The strings that are used in this component
	 */
	public function set strings(value:Object):Void 
	{
		_strings = value;
	}
	
	/**
	 * getter version
	 */
	public function get version():String {
		return _version;
	}
	
	/**
	 * setter version
	 */
	public function set version(value:String):Void {
		_version = value;
	}
	
	/**
	 * getter cursors
	 */
	public function get cursors():Object {
		return _cursors;
	}
	
	/**
	 * setter cursors
	 */
	public function set cursors(value:Object):Void {
		_cursors = value;
	}
	
	/**
	 * getter styles
	 */
	public function get styles():TextField.StyleSheet {
		return _styles;
	}
	
	/**
	 * setter styles
	 */
	public function set styles(value:TextField.StyleSheet):Void {
		_styles = value;
	}
		
	/**
	 * getter cursorId
	 * the id of the cursor (default: 'cursor');
	 */
	public function get cursorId():String {
		return _cursorId;
	}
	
	/**
	 * setter cursorId
	 * the id of the cursor (default: 'cursor');
	 */
	public function set cursorId(value:String):Void {
		_cursorId = value;
	}
	
	/**
	 * getter listento
	 */
	public function get listento():Array 
	{
		return _listento;
	}
	
	/**
	 * setter listento
	 */
	public function set listento(value:Array):Void 
	{
		_listento = value;
	}
	
	/**
	 * getter defaultXML
	 */
	public function get defaultXML():String {
		return _defaultXML;
	}
	
	/**
	 * setter defaultXML
	 */
	public function set defaultXML(value:String):Void {
		_defaultXML = value;
	}
	
	/**
	 * getter minheight
	 */
	public function get minheight():Number {
		return _minheight;
	}
	
	/**
	 * setter minheight
	 */
	public function set minheight(value:Number):Void {
		_minheight = value;
	}
	
	/**
	 * getter maxheight
	 */
	public function get maxheight():Number {
		return _maxheight;
	}
	
	/**
	 * setter maxheight
	 */
	public function set maxheight(value:Number):Void {
		_maxheight = value;
	}
	
	/**
	 * getter minwidth
	 */
	public function get minwidth():Number {
		return _minwidth;
	}
	
	/**
	 * setter minwidth
	 */
	public function set minwidth(value:Number):Void {
		_minwidth = value;
	}
	
	/**
	 * getter maxwidth
	 */
	public function get maxwidth():Number {
		return _maxwidth;
	}
	
	/**
	 * setter maxwidth
	 */
	public function set maxwidth(value:Number):Void {
		_maxwidth = value;
	}
	
	/**
	 * getter ycenter
	 */
	public function get ycenter():String {
		return _ycenter;
	}
	
	/**
	 * setter ycenter
	 */
	public function set ycenter(value:String):Void {
		_ycenter = value;
	}
	
	/**
	 * getter xcenter
	 */
	public function get xcenter():String {
		return _xcenter;
	}
	
	/**
	 * setter xcenter
	 */
	public function set xcenter(value:String):Void {
		_xcenter = value;
	}
	
	/**
	 * getter bottom
	 */
	public function get bottom():String {
		return _bottom;
	}
	
	/**
	 * setter bottom
	 */
	public function set bottom(value:String):Void {
		_bottom = value;
	}
	
	/**
	 * getter top
	 */
	public function get top():String {
		return _top;
	}
	
	/**
	 * setter top
	 */
	public function set top(value:String):Void {
		_top = value;
	}
	
	/**
	 * getter right
	 */
	public function get right():String {
		return _right;
	}
	
	/**
	 * setter right
	 */
	public function set right(value:String):Void {
		_right = value;
	}
	
	/**
	 * getter left
	 */
	public function get left():String {
		return _left;
	}
	
	/**
	 * setter left
	 */
	public function set left(value:String):Void {
		_left = value;
	}
	
	/**
	 * getter height
	 */
	public function get height():String {
		return _heightSetting;
	}
	
	/**
	 * setter height
	 */
	public function set height(value:String):Void {
		_heightSetting = value;
	}
	
	/**
	 * getter width
	 */
	public function get width():String {
		return _widthSetting;
	}
	
	/**
	 * setter width
	 */
	public function set width(value:String):Void {
		_widthSetting = value;
	}
	
	/**
	 * getter name
	 */
	public function get name():String {
		return _name;
	}
	
	/**
	 * setter name
	 */
	public function set name(value:String):Void {
		_name = value;
	}
	
	/**
	 * getter mBorder
	 * Border movieclip
	 */
	public function get mBorder():MovieClip {
		return _mBorder;
	}
	
	/**
	 * setter mBorder
	 * Border movieclip
	 */
	public function set mBorder(value:MovieClip):Void {
		_mBorder = value;
	}
	
	/**
	 * getter bordercolor setting
	 */
	public function get bordercolor():Number {
		return _bordercolor;
	}
	
	/**
	 * setter bordercolor setting
	 */
	public function set bordercolor(value:Number):Void {
		_bordercolor = value;
	}
	
	/**
	 * getter borderwidth setting
	 */
	public function get borderwidth():Number {
		return _borderwidth;
	}
	
	/**
	 * setter borderwidth setting
	 */
	public function set borderwidth(value:Number):Void {
		_borderwidth = value;
	}
	
	/**
	 * getter borderalpha setting
	 */
	public function get borderalpha():Number {
		return _borderalpha;
	}
	
	/**
	 * setter borderalpha setting
	 */
	public function set borderalpha(value:Number):Void {
		_borderalpha = value;
	}
	
	/**
	 * getter guides 
	 */
	public function get guides():Object {
		return _guides;
	}
	/**
	 * setter guides 
	 */
	public function set guides(value:Object):Void {
		_guides = value;
	}
	
	/**
	 * getter parentObject
	 * if the parent is a AbstractPositionable
	 */
	public function get parentObject():AbstractPositionable {
		return _parentObject;
	}
	
	/**
	 * setter parentObject
	 * if the parent is a AbstractPositionable
	 */
	public function set parentObject(value:AbstractPositionable):Void {
		_parentObject = value;
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when the component is resized
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onResize(comp:AbstractPositionable):Void {
	//}
	/**
	 * Raised when this component is set visible
	 * @param	comp the component
	 * @param	visible true/false. Visible or not visible
	 */
	//public function onSetVisible(comp:AbstractPositionable,visible:Boolean){}
}