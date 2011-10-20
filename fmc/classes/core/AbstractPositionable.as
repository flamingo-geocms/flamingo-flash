import core.AbstractComposite;
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
	
	public function AbstractPositionable (id:String, container:MovieClip) {
		Logger.console("Positionable with id: " , id);
		this.id = id;
		this.container = container;
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
	
}