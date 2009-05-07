/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import geometrymodel.dde.*;

class geometrymodel.dde.Geometry {

    private var superGeometry:Geometry = null;
 
    var geometryEventDispatcher:GeometryEventDispatcher = null;

    function Geometry() {
        geometryEventDispatcher = new GeometryEventDispatcher();
    }
	
	function getGeometryEventDispatcher():GeometryEventDispatcher{
		return geometryEventDispatcher;
	}
	function setGeometryEventDispatcher(geometryEventDispatcher):Void{
		this.geometryEventDispatcher = geometryEventDispatcher;
	}
	

    function setSuperGeometry(superGeometry:Geometry):Void {
        this.superGeometry = superGeometry;
    }

    function getSuperGeometry():Geometry {
        return superGeometry;
    }

    function getMostSuperGeometry():Geometry {
        var mostSuperGeometry:Geometry = this;
        while (mostSuperGeometry.getSuperGeometry() != null) {
            mostSuperGeometry = mostSuperGeometry.getSuperGeometry();
        }
        return mostSuperGeometry;
    }
	
	function addGeometryListener(geometryListener:GeometryListener){
		geometryEventDispatcher.addGeometryListener(geometryListener);
	}

    function getGeometries():Array {return null;}

    function addPoint(point:Point):Void { }

    function addPointN(point:Point, number:Number):Void { }

    function removeGeometry(geometry:Geometry):Void { }

    function removePoint(point:Point):Void { }

    function setPointXY(x:Number, y:Number):Void { }

    function move(dx:Number,dy:Number):Void { }

    function getCoords():Array {return null;}

    function getCenterPoint():Point {return null;}

    function getNearestPoint(point:Point):Point {return null;}

    function getEnvelope():Envelope {return null;}

    function clip(envelope:Envelope):Geometry {return null;}

    function clone():Geometry {return null;}

    function toString():String {return null;}

}
