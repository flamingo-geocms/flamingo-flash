import flamingo.core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

class flamingo.core.VisibleAdapter {

	private var listener:AbstractComponent = null;
    
    function VisibleAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    
    function onHide():Void {
        listener.setVisible(false);
    }
    
}
