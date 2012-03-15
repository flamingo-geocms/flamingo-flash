/**
 * AS2 Event mimicking AS3 style
 * @author Stijn De Ryck 
 */
class display.spriteloader.event.Event
{
 
	private var _type:String;
	private var _target:Object;
	/**
	 * constructor
	 * @param	type
	 * @param	target
	 */
	public function Event(type:String,target:Object){
		_type=type;
		_target=target;
    }
	/**
	 * toString
	 * @return
	 */
    public function toString():String{
        return "[Event]{_type:"+_type+"_target:"+_target+"}";
    }
    /**
     * setter type
     */
	public function set type(t:String):Void{}
    /**
     * getter type
     */
    public function get type():String { return _type; }
	/**
	 * setter target
	 */
    public function set target(t:Object):Void{_target=t;}
	/**
	 * getter target
	 */
    public function get target():Object{return _target;}
	
	
}
