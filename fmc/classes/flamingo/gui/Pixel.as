// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

class flamingo.gui.Pixel {
    
    private var x:Number = -1;
    private var y:Number = -1;
    
    function Pixel(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
    
    function toString():String {
        return "Pixel(" + x + ", " + y + ")";
    }
    
}
