import core.AbstractComposite;
import mx.data.encoders.Num;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class core.AbstractPositionable
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
	//
	private var _defaultXML:String;
	
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
		
		//if the parent is resized then resize this.
		var lParent:Object = new Object();
		var thisObj:AbstractPositionable = this;
		lParent.onResize = function(mc:MovieClip ) {
			thisObj.resize();
		};
		thisObj.flamingo.addListener(lParent, flamingo.getParent(this), this);
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
	public function get _parent():MovieClip {
		return this.container._parent;
	}
	public function get parent():MovieClip {
		return this.container._parent;
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
	
	
}