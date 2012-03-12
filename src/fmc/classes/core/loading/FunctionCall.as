/**
 * Class that holds the function call for LoadComponentQueue 
 * @author Roy Braam
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
	/**
	 * func
	 */
	public function get func():Function {
		return _func;
	}
	
	/**
	 * func
	 */
	public function set func(value:Function):Void {
		_func = value;
	}
	
	/**
	 * arg
	 */
	public function get arg():FunctionArguments {
		return _arg;
	}
	
	/**
	 * arg
	 */
	public function set arg(value:FunctionArguments):Void {
		_arg = value;
	}
	
	/**
	 * funcOwner
	 */
	public function get funcOwner():Object {
		return _funcOwner;
	}
	
	/**
	 * funcOwner
	 */
	public function set funcOwner(value:Object):Void {
		_funcOwner = value;
	}
	
}