/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/

class tools.Arrays {
	
	/**
	 * Invokes the given callback on each element of the list that is passed as the first argument.
	 * 
	 */
	public static function each (list: Array, callback: Function): Void {
		for (var i: Number = 0; i < list.length; ++ i) {
			callback (list[i], i);
		}
	}
	
	public static function eachAsync (list: Array, callback: Function, blockSize: Number, delay: Number, continuation: Function): Void {
		var i: Number = 0,
            worker: Function;
            
        if (!blockSize || blockSize < 0) {
        	blockSize = 1;
        }
        if (!delay || delay < 0) {
        	delay = 100;
        }
        
        worker = function (): Void {
        	for (var j: Number = 0; j < blockSize && i < list.length; ++ j, ++ i) {
        		callback (list[i], i);
        	}
        	
        	if (i < list.length) {
        		_global.setTimeout (worker, delay);
        	} else if (continuation) {
        		continuation ();
        	}
        };
        
        if (list.length > 0) {
            _global.setTimeout (worker, delay);
        }
	}
	
	public static function map (list: Array, callback: Function): Array {
		var result: Array = [ ];
		for (var i: Number = 0; i < list.length; ++ i) {
			result.push (callback (list[i], i));
		}
		return result;
	}
	
	public static function filter (list: Array, callback: Function): Array {
		var result: Array = [ ],
            i: Number;
            
		if (callback) {
    		for (i = 0; i < list.length; ++ i) {
    			if (callback (list[i], i)) {
    				result.push (list[i]);
    			}
    		}
		} else {
			for (i = 0; i < list.length; ++ i) {
				if (list[i]) {
					result.push (list[i]);
				}
			}
		}
		
		return result;
	}
}
