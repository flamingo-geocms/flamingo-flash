/**
 * AS2 Event mimicking AS3 style
 * @author Stijn De Ryck 
 */
class display.spriteloader.event.Event
{
 
	private var _type:String;
	private var _target:Object;
	
	public function Event(type:String,target:Object){
		_type=type;
		_target=target;
    }
	
    public function toString():String{
        return "[Event]{_type:"+_type+"_target:"+_target+"}";
    }
    
	public function set type(t:String):Void{}
    public function get type():String{return _type;}
    public function set target(t:Object):Void{_target=t;}
    public function get target():Object{return _target;}
	
	
}
