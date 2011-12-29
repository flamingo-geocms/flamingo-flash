/**
 * ...
 * @author Roy Braam
 */
import tools.Logger;
import core.loading.FunctionCall;
 /**
  * Class that is used to hold a queue of Function calls that will be executed when the object is loaded.
  */
class core.loading.LoadComponentQueue{
	
	var queue:Object = null;
	/**
	 * 
	 * @param	flamingo
	 */
	public function LoadComponentQueue() {
	}
	/**
	 * Use this function to add functions that are called when a onLoadComplete occured for the object (id)
	 * @param	id the id of the object on which we want to wait
	 * @param	funcOwner the owner of the function that needs to be called
	 * @param	func the function
	 * Add all arguments that need to be used as functionarguments for the given function after these arguments.
	 */
	public function executeAfterLoad(id:String, funcOwner:Object,func:Function) {
		if (queue == null) {
			queue = new Object();
		}
		if (queue[id] == undefined) {
			queue[id] = new Array();
		}		
		//remove first 3 arguments.
		arguments.splice(0, 3);				
		queue[id].push(new FunctionCall(funcOwner,func, arguments));
	}
	/**
	 * The function that is called after 'onLoadComponent'
	 */
	public function onLoadComponent(mc):Void {	
		var tokens:Array = mc._name.split(".");
		var mcId = tokens[tokens.length - 1];		
		if (queue[mcId] != undefined) {
			var execArray:Array = queue[mcId];
			while (execArray.length > 0) {
				
				var fc:FunctionCall = FunctionCall(execArray.shift());
				//Logger.console("Let "+fc.funcOwner+" execute "+fc.func+" with "+fc.arg);
				fc.func.apply(fc.funcOwner, fc.arg);
			}
			delete queue[mcId];
		}
		
    }
	
}