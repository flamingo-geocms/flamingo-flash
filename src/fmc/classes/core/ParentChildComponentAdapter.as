import core.AbstractComponent;
import tools.Logger;
/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

class core.ParentChildComponentAdapter {

	private var listener:AbstractComponent = null;
    
    function ParentChildComponentAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    
    function onInit():Void {
        listener.go();
    }
    
    function onResize():Void {
		//Logger.console("On resize "+listener.id);
        var bounds:Object = _global.flamingo.getPosition(listener);
        listener.setBounds(bounds.x, bounds.y, bounds.width, bounds.height);
    }
    
}
