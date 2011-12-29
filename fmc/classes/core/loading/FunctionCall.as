/**
 * ...
 * @author Roy Braam
 */
/**
 *Class that holds the function call for LoadComponentQueue 
 */
class core.loading.FunctionCall{
	private var _func:Function;
	private var _arg:FunctionArguments;
	private var _funcOwner:Object;
	/**
	 * Constructor 
	 * @param	funcOwner the owner of the function
	 * @param	func the function
	 * @param	arg extra arguments given to the function
	 */
	public function FunctionCall(funcOwner:Object,func:Function, arg:FunctionArguments) {
		this.func = func;
		this.arg = arg;
		this.funcOwner = funcOwner;
	}
	/*Getters and setters*/
	public function get func():Function {
		return _func;
	}
	
	public function set func(value:Function):Void {
		_func = value;
	}
	
	public function get arg():FunctionArguments {
		return _arg;
	}
	
	public function set arg(value:FunctionArguments):Void {
		_arg = value;
	}
	
	public function get funcOwner():Object {
		return _funcOwner;
	}
	
	public function set funcOwner(value:Object):Void {
		_funcOwner = value;
	}
	
}