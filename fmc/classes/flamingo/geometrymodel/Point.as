// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

import flamingo.event.StateEvent;

class flamingo.geometrymodel.Point extends Geometry {
    
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
    
    function isWithin(envelope:Envelope):Boolean {
        if ((x >= envelope.getMinX()) && (x <= envelope.getMaxX())
                                      && (y >= envelope.getMinY()) && (y <= envelope.getMaxY())) {
            return true;
        }
        return false;
    }
    
    function move(dx:Number, dy:Number):Void {
        x += dx;
        y += dy;
        
        dispatchEvent(new StateEvent(this, "Geometry", StateEvent.CHANGE, null));
    }
    
    function equals(geometry:Geometry):Boolean {
        if (!(geometry instanceof Point)) {
            return false;
        }
        if ((x == Point(geometry).getX()) && (y == Point(geometry).getY())) {
            return true;
        }
        return false;
    }
    
    function clone():Geometry {
        return new Point(x, y);
    }
    
    function setXY(x:Number, y:Number):Void {
        this.x = x;
        this.y = y;
        
        dispatchEvent(new StateEvent(this, "Geometry", StateEvent.CHANGE, null));
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
    
    function getDistance(point:Point):Number {
        var dx:Number = x - point.getX();
        var dy:Number = y - point.getY();
        var distance:Number = Math.sqrt((dx * dx) + (dy * dy));
        
        return distance;
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
    
}
