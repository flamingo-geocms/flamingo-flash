import core.AbstractComposite;
import mx.data.encoders.Num;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class core.AbstractPositionable
{	
	private var _loaded:Boolean = true;
    private var _type:String = null;
	
	private var _id:String;
	private var _container:MovieClip;
	
	private var _visible:Boolean = true;
	
	private var _strings:Object = new Object();
	
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
		
	/**
	 * todo implement movieclip interface en toepassen op container
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
		Logger.console("*** AbstractPositionable.getVisible");
		return _visible;
	}
	
	public function set visible(value:Boolean):Void{
		Logger.console("*** AbstractPositionable.setVisible");
		_visible = value;
	}
	
	public function get strings():Object 
	{
		Logger.console("*** AbstractPositionable.getStrings");
		return _strings;
	}
	
	public function set strings(value:Object):Void 
	{
		Logger.console("*** AbstractPositionable.setStrings");
		_strings = value;
	}
	/*
	public function get widht():Number {
		Logger.console("**** get width");
		return this.container._width;
	}
	public function set width(width:Number) {
		Logger.console("**** set width");
		this.container._width = width;
	}
	public function get height():Number {
		Logger.console("**** get height");
		return this.container._height;
	}
	public function set height(height:Number) {
		Logger.console("**** set height");
		this._container._height = height;
	}*/
	
	
}