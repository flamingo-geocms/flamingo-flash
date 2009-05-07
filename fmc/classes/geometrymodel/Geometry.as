/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
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
    
    function Geometry() {
        geometryEventDispatcher = new GeometryEventDispatcher();
    }
	   
   	function addGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.addGeometryListener(geometryListener);
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
	
	public function setXYEndPoint(mousePoint : Point, pixel) : Void {
			var endPoint = this.getEndPoint();
			endPoint.setXY(mousePoint.getX(), mousePoint.getY(), pixel);
			geometryEventDispatcher.changeGeometry(this);
	}
}
