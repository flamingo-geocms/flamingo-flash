import tools.Logger;
import core.loading.FunctionCall;
import core.AbstractComponent;
/**
 * Class that is used to hold a queue of Function calls that will be executed when the object is loaded.
 * @author Roy Braam
 */
class core.loading.LoadComponentQueue{
	
	var queue:Object = null;
	/**
	 * 
	 * @param	flamingo
	 */
	public function LoadComponentQueue() {
		//setInterval(this, "logQueue", 10000);
	}
	/**
	 * Use this function to add functions that are called when a onLoadComplete occured for the object (id)
	 * @param	id the id of the object on which we want to wait
	 * @param	funcOwner the owner of the function that needs to be called
	 * @param	func the function
	 * Add all arguments that need to be used as functionarguments for the given function after these arguments.
	 */
	public function executeAfterLoad(id:String, funcOwner:Object,func:Function) {
		if (id == null || id ==  undefined) {
			Logger.console("!!!!!! can not execute after load! No id given. \n FuncOwner: " +funcOwner);
			return;
		}
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
		if (mcId == undefined)
			mcId = mc.id;		
		if (queue[mcId] != undefined) {
			var execArray:Array = queue[mcId];
			while (execArray.length > 0) {				
				var fc:FunctionCall = FunctionCall(execArray.shift());
				fc.func.apply(fc.funcOwner, fc.arg);
			}
			delete queue[mcId];
		}
		
    }
	
	/**
	 * logQueue
	 */
	public function logQueue():Void {
		var noc:Number = 0;
		var log:String = "";
		for (var s in queue) {
			noc++;
			log += "Component: " + s + " has " + queue[s].length + " calls waiting.";
			for (var i = 0; i < queue[s].length; i++) {
				var fc:FunctionCall = FunctionCall(queue[s][i]);
				log += "\n   call " + i + " has arguments: " + fc.funcOwner;
			}
		}
		Logger.console("Waiting for " + noc + " components.\n"+log);
		
	}
	
}