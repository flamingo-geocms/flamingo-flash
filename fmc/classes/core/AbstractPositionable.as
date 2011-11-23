import core.AbstractComposite;
import mx.data.encoders.Num;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class core.AbstractPositionable
{	
	//loaded ??
	private var _loaded:Boolean = true;
	//type of object
    private var _type:String = null;
	//the id of this object
	private var _id:String;
	//the movieclip that contains the visible part of the component.
	private var _container:MovieClip;
	//version of component.
	private var _version:String;	
	//visible
	private var _visible:Boolean = true;
	//The strings that are used in this component
	private var _strings:Object = new Object();
	//The cursors for the object
	private var _cursors:Object = new Object();
	//Styles for the object
	private var _styles:TextField.StyleSheet= new TextField.StyleSheet();
	/**
	 * Constructor 
	 * @param	id the id
	 * @param	container the visible container.
	 */
	public function AbstractPositionable (id:String, container:MovieClip) {
		Logger.console("Positionable with id: " , id);
		this.id = id;
		this.container = container;
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
	
	public function get flamingo():Flamingo {
		return _global.flamingo;
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
	
	
}