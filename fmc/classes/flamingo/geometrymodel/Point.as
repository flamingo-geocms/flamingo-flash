/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.*;

import flamingo.event.StateEvent;
import flamingo.gui.Pixel;
import flamingo.event.GeometryListener;

class flamingo.geometrymodel.Point extends Geometry implements GeometryListener {
    
    private var x:Number = null;
    private var y:Number = null;
    
    function Point(x:Number, y:Number) {
        if (x == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Point.<<init>>(" + x + ", " + y + ")");
            return;
        }
        if (y == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Point.<<init>>(" + x + ", " + y + ")");
            return;
        }
        
        this.x = x;
        this.y = y;
    }
    
    function getPoints():Array {
        return new Array(this);
    }
    
    function getEndPoint():Point {
        return this;
    }
    
    function getCenterPoint():Point {
        return new Point(x, y);
    }
    
     function getEnvelope():Envelope {
        return new Envelope(x, y, x, y);
    }
    
    function clone():Point {
    	var newPoint = new Point(x, y);
        return newPoint;
    }
    
    function setXY(x:Number, y:Number, pixel:Pixel):Void {
        this.x = x;
        this.y = y;
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
    
    function toGMLString():String {
        var gmlString:String = "";
        gmlString += "<gml:Point srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        gmlString += "  <gml:coordinates cs=\",\" decimal=\".\" ts=\" \">";
        gmlString += (x + "," + y);
        gmlString += "</gml:coordinates>\n";
        gmlString += "</gml:Point>\n";
        
        return gmlString;
    }
    
    function toString():String {
        return("Point (" + x + ", " + y + ")");
    }
    
    function onChangeGeometry(geometry:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
    
    function onAddChild(geometry:Geometry,child:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
    
    
    
}
