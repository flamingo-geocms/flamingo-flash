import core.AbstractComponent;

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
        var bounds:Object = _global.flamingo.getPosition(listener);
        listener.setBounds(bounds.x, bounds.y, bounds.width, bounds.height);
    }
    
}
