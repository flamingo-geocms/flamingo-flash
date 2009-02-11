// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

class flamingo.gui.MapPrintAdapter {
    
    private var print:Print = null;
    
    function MapPrintAdapter(print:Print) {
        this.print = print;
    }
    
    function onChangeExtent(map:MovieClip):Void {
        print.setScale(map.getCurrentScale());
    }
    
}
