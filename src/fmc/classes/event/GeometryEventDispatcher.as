/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
import event.GeometryListener;
/**
 * event.GeometryEventDispatcher
 */
class event.GeometryEventDispatcher {

	private var geometryListeners:Array = null;
	/**
	 * constructor
	 */
    function GeometryEventDispatcher() {
        geometryListeners = new Array();
    }
	/**
	 * addGeometryListener
	 * @param	geometryListener
	 */
    function addGeometryListener(geometryListener:GeometryListener):Void {
        geometryListeners.push(geometryListener);
    }
	/**
	 * removeGeometryListener
	 * @param	geometryListener
	 */
    function removeGeometryListener(geometryListener:GeometryListener):Void {
        for (var i:Number = 0; i < geometryListeners.length; i++) {
            if (geometryListener == geometryListeners[i]) {
                geometryListeners.splice(i, 1);
            }
        }
    }
	/**
	 * changeGeometry
	 * @param	geometry
	 */
    function changeGeometry(geometry:Geometry):Void {
        updateListeners(geometryListeners);
        for (var i:Number = 0; i < geometryListeners.length; i++) {
            GeometryListener(geometryListeners[i]).onChangeGeometry(geometry);
        }
    }
	/**
	 * addChild
	 * @param	geometry
	 * @param	child
	 */
    public function addChild(geometry:Geometry,child:Geometry) : Void {
		updateListeners(geometryListeners);
        for (var i:Number = 0; i < geometryListeners.length; i++) {
            GeometryListener(geometryListeners[i]).onAddChild(geometry,child);
        }
	}
	/**
	 * removeChild
	 * @param	geometry
	 * @param	child
	 */
	public function removeChild(geometry:Geometry,child:Geometry) : Void {
		updateListeners(geometryListeners);
        for (var i:Number = 0; i < geometryListeners.length; i++) {
            GeometryListener(geometryListeners[i]).onRemoveChild(geometry,child);
        }
	}

    private function updateListeners(listeners:Array):Void {
        for (var i:Number = 0; i < listeners.length; i++) {
			
            if (listeners[i].toString() == null) { // toString() is necessary as movieclips will never  become null.
               
			   listeners.splice(i--, 1); // i-- because the array that is being looped is also being spliced.
            } else {
				
                for (var j:Number = 0; j < listeners.length; j++) {
                    if ((listeners[i] == listeners[j]) && (i != j)) {
                        listeners.splice(j--, 1); // j-- because the array that is being looped is also being spliced. i is not affected because j is always greater than i here.
                    }
                }
            }
        }
    }

}
