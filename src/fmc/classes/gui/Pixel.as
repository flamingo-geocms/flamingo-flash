/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

/**
 * Pixel
 */
class gui.Pixel {
    
    private var x:Number = -1;
    private var y:Number = -1;
    /**
     * constructor Pixel
     * @param	x
     * @param	y
     */
    function Pixel(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
	/**
	 * setter X
	 * @param	x
	 */	
	function setX(x:Number):Void {
        this.x = x;
    }
	/**
	 * setter Y
	 * @param	y
	 */
	function setY(y:Number):Void {
        this.y = y;
    }
    /**
     * getter X
     * @return
     */
    function getX():Number {
        return x;
    }
    /**
     * gettter Y
     * @return
     */
    function getY():Number {
        return y;
    }
	/**
	 * clone
	 * @return
	 */
	function clone():Pixel {
        return new Pixel(x, y);
    }
	/**
	 * getter Distance
	 * @param	pixel
	 * @return
	 */
	function getDistance(pixel:Pixel):Number {
        var dx:Number = x - pixel.getX();
        var dy:Number = y - pixel.getY();
        var distance:Number = Math.sqrt((dx * dx) + (dy * dy));
        
        return distance;
    }
    /**
     * to String
     * @return
     */
    function toString():String {
        return "Pixel(" + x + ", " + y + ")";
    }
    
}
