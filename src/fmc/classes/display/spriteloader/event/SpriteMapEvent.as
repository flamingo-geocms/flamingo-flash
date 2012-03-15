import display.spriteloader.event.Event;

/**
 * display.spriteloader.event.SpriteMapEvent
 */
class display.spriteloader.event.SpriteMapEvent extends Event
{
	private var _data:Object;
	public static var LOAD_COMPLETE:String 	= 'SpriteMapEvent.LOAD_COMPLETE';
	public static var LOAD_ERROR:String 	= 'SpriteMapEvent.LOAD_ERROR';
	public static var LOAD_PROGRESS:String 	= 'SpriteMapEvent.LOAD_PROGRESS';
	
	/**
	 * constructor
	 * @param	type
	 * @param	target
	 * @param	data
	 */
	public function SpriteMapEvent(type:String,target:Object, data:Object) 
	{
		super(type, target)
		_data = data;;
	}
	/**
	 * getter data
	 */
	public function get data():Object 
	{
		return _data;
	}
	/**
	 * toString
	 * @return
	 */
	public function toString():String 
	{
		return "[SpriteMapEvent]{type: "+_type+", target: "+_target+", data:"+_data+"}";
	}
}