/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.geometrymodel.*;

class flamingo.geometrymodel.Polygon extends Geometry {
    
    private var exteriorRing:LinearRing = null;
    
    function Polygon(exteriorRing:LinearRing) {
        if (exteriorRing == null) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Polygon.<<init>>(null)");
            return;
        }
        
        this.exteriorRing = exteriorRing;
        addGeometryListener(exteriorRing);
        geometryEventDispatcher.addChild(this,exteriorRing);
    }
    
    function addPoint(point:Point):Void {        
        exteriorRing.addPoint(point);
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
