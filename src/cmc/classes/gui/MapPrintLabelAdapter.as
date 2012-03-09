/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

class gui.MapPrintLabelAdapter {
    
    private var printLabel:PrintLabel = null;
    
    function MapPrintLabelAdapter(printLabel:PrintLabel) {
        this.printLabel = printLabel;
    }
    
    function onChangeExtent(map:MovieClip):Void {
        printLabel.setComponentsText();
    }
    
}
