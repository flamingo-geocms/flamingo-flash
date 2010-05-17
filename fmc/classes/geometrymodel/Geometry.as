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

class geometrymodel.Geometry {
    
    var geometryEventDispatcher:GeometryEventDispatcher = null;
    private var eventComp:AbstractComponent = null;
	private var parent:Geometry = null;
    
    function Geometry() {
        geometryEventDispatcher = new GeometryEventDispatcher();
    }
	   
   	function addGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.addGeometryListener(geometryListener);
	}
	
	function removeGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.removeGeometryListener(geometryListener);
	}
     
	function getGeometryEventDispatcher():GeometryEventDispatcher{
		return geometryEventDispatcher;
	}
	function setParent(parent:Geometry):Void {
        if (this.parent != parent) {
            if (parent != null) {
                this.parent = parent;
            }
        }
    }
    
    function getParent():Geometry {
        return parent;
    }
    
    function getFirstAncestor():Geometry {
        if (parent == null) {
            return this;
        } else {
            return parent.getFirstAncestor();
        }
    }
	
    function addPoint(point:Point):Void { }
    
    function getChildGeometries():Array { return null; }
    
    function getPoints():Array { return null; }
    
    private function getEndPoint():Point { return null; }
    
    function getCenterPoint():Point { return null; }
    
	function getEnvelope():Envelope { return null; }
	
    function clone():Geometry { return null; }
    
    function toGML():XML {
        return new XML(toGMLString());
    }
    
    function toGMLString():String { return null; }
	
	public function setEventComp(gis : GIS) : Void {
		this.eventComp = gis;
	}
	
	function toWKT():String{return null;}
	
	public function setXYEndPoint(mousePoint : Point, pixel) : Void {
			var endPoint = this.getEndPoint();
			endPoint.setXY(mousePoint.getX(), mousePoint.getY(), pixel);
			geometryEventDispatcher.changeGeometry(this);
	}
}
