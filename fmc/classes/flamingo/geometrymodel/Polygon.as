// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

class flamingo.geometrymodel.Polygon extends Geometry {
    
    private var exteriorRing:LinearRing = null;
    
    function Polygon(exteriorRing:LinearRing) {
        if (exteriorRing == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Polygon.<<init>>(null)");
            return;
        }
        
        this.exteriorRing = exteriorRing;
        exteriorRing.setParent(this);
    }
    
    function addChild(child:Geometry):Void {
        if (isChild(child)) {
            // Child already exists. This is a non-exceptional precondition.
            return;
        }
        if (!(child instanceof Point)) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Polygon.addChild(" + child.toString() + ")");
            return;
        }
        
        exteriorRing.addChild(child);
    }
    
    function removeChild(child:Geometry):Void {
        if (!isChild(child)) {
            // Child does not exist. This is a non-exceptional precondition.
            return;
        }
        if (!(child instanceof Point)) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Polygon.removeChild(" + child.toString() + ")");
            return;
        }
        
        exteriorRing.removeChild(child);
    }
    
    function getChildGeometries():Array {
        return new Array(exteriorRing);
    }
    
    function getPoints():Array {
        return exteriorRing.getPoints();
    }
    
    function getEndPoint():Point {
        return exteriorRing.getEndPoint(); 
    }
    
    function getCenterPoint():Point {
        return exteriorRing.getCenterPoint();
    }
    
    function getEnvelope():Envelope {
        return exteriorRing.getEnvelope();
    }
    
    function clone():Geometry {
        return new Polygon(LinearRing(exteriorRing.clone()));
    }
    
    function getExteriorRing():LinearRing {
        return exteriorRing;
    }
    
    function toGMLString():String {
        var points:Array = exteriorRing.getPoints();
        var point:Point = null;
        
        var gmlString:String = "";
        gmlString += "<gml:Polygon srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        gmlString += "  <gml:outerBoundaryIs>\n";
        gmlString += "    <gml:LinearRing>\n";
        gmlString += "      <gml:coordinates cs=\",\" decimal=\".\" ts=\" \">";
        
        for (var i:Number = 0; i < points.length; i++) {
            point = Point(points[i]);
            
            gmlString += (point.getX() + "," + point.getY());
            
            if (i < points.length - 1) {
                gmlString += " ";
            }
        }
        
        gmlString += "</gml:coordinates>\n";
        gmlString += "    </gml:LinearRing>\n";
        gmlString += "  </gml:outerBoundaryIs>\n";
        gmlString += "</gml:Polygon>\n";
        
        return gmlString;
    }
    
    function toString():String {
        return ("Polygon (" + exteriorRing.toString() + ")");
    }
    
}
