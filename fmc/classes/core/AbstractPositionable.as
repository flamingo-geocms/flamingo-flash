import core.AbstractComposite;
import core.AbstractListenerRegister;
import mx.data.encoders.Num;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class core.AbstractPositionable extends AbstractListenerRegister
{	
	/*Defaults set by flamingo shit*/
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
	private var _visible:Boolean;
	//The strings that are used in this component
	private var _strings:Object;
	//The cursors for the object
	private var _cursors:Object;
	//Styles for the object
	private var _styles:TextField.StyleSheet;
	
	//the id of the cursor (default: 'cursor');
	private var _cursorId:String;
	//a array of id's to listen to
	private var _listento:Array;
	//The default xml with init config
	private var _defaultXML:String;
	//the name of the parent. It's only used by old flamingo code. Implemented to be backwards compatible
	private var _parentName:String;
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
		this.loaded = true;
		this.visible = true;
		this.strings = new Object();
		this.cursors = new Object();
		this.styles = new TextField.StyleSheet();		
	}
	/**
	 * Pass the hittest to the movieclip
	 * @param	x xcoord
	 * @param	y ycoord
	 * @param	shapeFlag
	 * @return	true if hit
	 */
	public function hitTest(x:Number, y:Number, shapeFlag:Boolean):Boolean {
		return this.container.hitTest(x, y, shapeFlag);
	}
	
	public function resize() {		
		this.flamingo.position(this);
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
	
	/*public function setCursor(cursor:String):Void {			
		flamingo.showCursor(cursor);		
	}*/
	
	/***********************************************************************
	*functions that are needed to work with old (not OO) flamingo code
	*/
	public function get target():String {
		return this.container._target;
	}
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
	 * If .parent is set by old flamingo code (a mc name is set then and is stored in _parentName)
	 * the _parentName is returned.
	 */
	public function get parent():Object {	
		//if a old flamingo object is set as parent the _parentName is returned (the old way)
		if (_parentName != undefined ) {
			return this._parentName;
		}else{
			return this.getParent();
		}
	}
	/**
	 * Gets the real parent object
	 * Needs to be overwritten in subclasses if its something else, the return of the parentName must not be implemented!
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
		if (value instanceof AbstractPositionable) {
			//the parent is a new component.
			this.flamingo.addListener(lParent, value, this);
		}else if (value instanceof String || typeof(value) == "string") {
			//The parent is a movieclip / old flamingo object.
			this._parentName = String(value);	
			this.flamingo.addListener(lParent, value, this);
		}else {
			Logger.console("!!!!!!!! Can't set the parent because the given value is not of "+
			"type AbstractPositionable (new code) or String (Old code): "+value);
		}
	}
	public function get flamingo():Flamingo {
		return _global.flamingo;
	}
	/*public function get _x():Number {
		return this.container._x;
	}
	public function set _x(value:Number):Void {
		this.container._x = value;
	}
	public function get _y():Number {
		return this.container._y;
	}
	public function set _y(value:Number):Void {
		this.container._y=value;
	}
	public function get _width():Number {
		return this.container._width;
	}
	public function set _width(value:Number):Void {
		this.container._width = value;
	}
	public function get _height():Number {
		return this.container._height;
	}
	public function set _height(value:Number):Void {
		this.container._height=value;
	}*/
	/***********************************************************************/	
	/***********************************************************************
	 * Getters and Setters.
	 */
	
		
	public function get id():String 
	{		
		return _id;
	}
	
	public function set id(value:String):Void 
	{
		_id = value;
	}
	
	public function get container():MovieClip 
	{
		return _container;
	}
	
	public function set container(value:MovieClip):Void 
	{
		_container = value;
	}
	
	public function get loaded():Boolean 
	{
		return _loaded;
	}
	
	public function set loaded(value:Boolean):Void 
	{
		//_loaded = value;
	}
	public function get type():String 
	{
		return _type;
	}
	
	public function set type(value:String):Void 
	{
		_type = value;
	}
		
	public function get visible():Boolean { 		
		return _visible;
	}
	
	public function set visible(value:Boolean):Void{
		_visible = value;
	}
		
	public function get strings():Object 
	{
		return _strings;
	}
	
	public function set strings(value:Object):Void 
	{
		_strings = value;
	}
	
	public function get version():String {
		return _version;
	}
	
	public function set version(value:String):Void {
		_version = value;
	}
	
	public function get cursors():Object {
		return _cursors;
	}
	
	public function set cursors(value:Object):Void {
		_cursors = value;
	}
	
	public function get styles():TextField.StyleSheet {
		return _styles;
	}
	
	public function set styles(value:TextField.StyleSheet):Void {
		_styles = value;
	}
		
	public function get cursorId():String {
		return _cursorId;
	}
	
	public function set cursorId(value:String):Void {
		_cursorId = value;
	}
	
	
	public function get listento():Array 
	{
		return _listento;
	}
	
	public function set listento(value:Array):Void 
	{
		_listento = value;
	}
	
	public function get defaultXML():String {
		return _defaultXML;
	}
	
	public function set defaultXML(value:String):Void {
		_defaultXML = value;
	}
	
	public function get minheight():Number {
		return _minheight;
	}
	
	public function set minheight(value:Number):Void {
		_minheight = value;
	}
	
	public function get maxheight():Number {
		return _maxheight;
	}
	
	public function set maxheight(value:Number):Void {
		_maxheight = value;
	}
	
	public function get minwidth():Number {
		return _minwidth;
	}
	
	public function set minwidth(value:Number):Void {
		_minwidth = value;
	}
	
	public function get maxwidth():Number {
		return _maxwidth;
	}
	
	public function set maxwidth(value:Number):Void {
		_maxwidth = value;
	}
	
	public function get ycenter():String {
		return _ycenter;
	}
	
	public function set ycenter(value:String):Void {
		_ycenter = value;
	}
	
	public function get xcenter():String {
		return _xcenter;
	}
	
	public function set xcenter(value:String):Void {
		_xcenter = value;
	}
	
	public function get bottom():String {
		return _bottom;
	}
	
	public function set bottom(value:String):Void {
		_bottom = value;
	}
	
	public function get top():String {
		return _top;
	}
	
	public function set top(value:String):Void {
		_top = value;
	}
	
	public function get right():String {
		return _right;
	}
	
	public function set right(value:String):Void {
		_right = value;
	}
	
	public function get left():String {
		return _left;
	}
	
	public function set left(value:String):Void {
		_left = value;
	}
	
	public function get height():String {
		return _heightSetting;
	}
	
	public function set height(value:String):Void {
		_heightSetting = value;
	}
	
	public function get width():String {
		return _widthSetting;
	}
	
	public function set width(value:String):Void {
		_widthSetting = value;
	}
	
	public function get name():String {
		return _name;
	}
	
	public function set name(value:String):Void {
		_name = value;
	}
	
	
	/** 
	 * Dispatched when the component is resized
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onResize(comp:MovieClip):Void {
	//}
}