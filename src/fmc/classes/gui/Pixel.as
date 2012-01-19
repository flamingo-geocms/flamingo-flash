/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

class gui.Pixel {
    
    private var x:Number = -1;
    private var y:Number = -1;
    
    function Pixel(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
		
	function setX(x:Number):Void {
        this.x = x;
    }
	
	function setY(y:Number):Void {
        this.y = y;
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
	
	function clone():Pixel {
        return new Pixel(x, y);
    }
	
	function getDistance(pixel:Pixel):Number {
        var dx:Number = x - pixel.getX();
        var dy:Number = y - pixel.getY();
        var distance:Number = Math.sqrt((dx * dx) + (dy * dy));
        
        return distance;
    }
    
    function toString():String {
        return "Pixel(" + x + ", " + y + ")";
    }
    
}
