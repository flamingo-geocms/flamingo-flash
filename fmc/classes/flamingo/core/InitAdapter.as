import flamingo.core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
class flamingo.core.InitAdapter {

	private var listener:AbstractComponent = null;
    
    function InitAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    
    function onInit():Void {
        listener.removeInitAdapter(this);
    }
    
}
