import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek(IDgis bv)
*         Roy Braam (B3Parnters bv)
 -----------------------------------------------------------------------------*/
/**
 * core.InitAdapter
 */
 class core.InitAdapter {

	private var listener:AbstractComponent = null;
	private var waitFor:String = null;
    /**
     * InitAdapter
     * @param	listener
     */
    function InitAdapter(listener:AbstractComponent,waitFor:String) {
        this.listener = listener;
		this.waitFor = waitFor;
    }
    /**
     * onInit
     */
    function onInit():Void {
        listener.removeInitAdapter(this);
    }
	
	function toString():String {
		return "" + this.listener.id + " waiting for: " + this.waitFor;
	}
	
	function getWaitFor():String {
		return this.waitFor;
	}
    
}
