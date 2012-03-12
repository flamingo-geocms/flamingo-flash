import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

 /**
  * core.VisibleAdapter 
  */
class core.VisibleAdapter {

	private var listener:AbstractComponent = null;
    /**
     * VisibleAdapter
     * @param	listener
     */
    function VisibleAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    /**
     * onHide
     */
    function onHide():Void {
        listener.setVisible(false);
    }
    
}
