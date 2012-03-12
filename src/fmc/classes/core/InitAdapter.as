import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
/**
 * core.InitAdapter
 */
 class core.InitAdapter {

	private var listener:AbstractComponent = null;
    /**
     * InitAdapter
     * @param	listener
     */
    function InitAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    /**
     * onInit
     */
    function onInit():Void {
        listener.removeInitAdapter(this);
    }
    
}
