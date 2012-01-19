/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

class gui.MapPrintAdapter {
    
    private var print:Print = null;
    
    function MapPrintAdapter(print:Print) {
        this.print = print;
    }
    
    function onChangeExtent(map:MovieClip):Void {
        print.setScale(map.getCurrentScale());
    }
    
}
