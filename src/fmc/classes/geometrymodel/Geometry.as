/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
import gismodel.GIS;

import event.StateEvent;
import event.StateEventListener;
import event.StateEventDispatcher;
import core.AbstractComponent;
import event.GeometryEventDispatcher;
import event.GeometryListener;
/**
 * geometrymodel.Geometry
 */
class geometrymodel.Geometry {
    
    var geometryEventDispatcher:GeometryEventDispatcher = null;
    private var eventComp:AbstractComponent = null;
	private var parent:Geometry = null;
    /**
     * constructor
     */
    function Geometry() {
        geometryEventDispatcher = new GeometryEventDispatcher();
    }
	/**
	 * addGeometryListener
	 * @param	geometryListener
	 */
   	function addGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.addGeometryListener(geometryListener);
	}
	/**
	 * removeGeometryListener
	 * @param	geometryListener
	 */
	function removeGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.removeGeometryListener(geometryListener);
	}
    /**
     * getGeometryEventDispatcher
     * @return
     */
	function getGeometryEventDispatcher():GeometryEventDispatcher{
		return geometryEventDispatcher;
	}
	/**
	 * setParent
	 * @param	parent
	 */
	function setParent(parent:Geometry):Void {
        if (this.parent != parent) {
            if (parent != null) {
                this.parent = parent;
            }
        }
    }
    /**
     * getParent
     * @return
     */
    function getParent():Geometry {
        return parent;
    }
    /**
     * getFirstAncestor
     * @return
     */
    function getFirstAncestor():Geometry {
        if (parent == null) {
            return this;
        } else {
            return parent.getFirstAncestor();
        }
    }
	/**
	 * stub
	 * @param	point
	 */
    function addPoint(point:Point):Void { }
    /**
     * stub
     * @return
     */
    function getChildGeometries():Array { return null; }
    /**
     * stub
     * @return
     */
    function getPoints():Array { return null; }
    
    private function getEndPoint():Point { return null; }
    /**
     * stub
     * @return
     */
    function getCenterPoint():Point { return null; }
    /**
     * stub
     * @return
     */
	function getEnvelope():Envelope { return null; }
	/**
	 * stub
	 * @return
	 */
    function clone():Geometry { return null; }
    /**
     * toGML
     * @return
     */
    function toGML():XML {
        return new XML(toGMLString());
    }
    /**
     * stub
     * @return
     */
    function toGMLString():String { return null; }
	/**
	 * setEventComp
	 * @param	gis
	 */
	public function setEventComp(gis : GIS) : Void {
		this.eventComp = gis;
	}
	/**
	 * stub
	 * @return
	 */
	function toWKT():String{return null;}
	/**
	 * setXYEndPoint
	 * @param	mousePoint
	 * @param	pixel
	 */
	public function setXYEndPoint(mousePoint : Point, pixel) : Void {
			var endPoint = this.getEndPoint();
			endPoint.setXY(mousePoint.getX(), mousePoint.getY(), pixel);
			geometryEventDispatcher.changeGeometry(this);
	}
}
