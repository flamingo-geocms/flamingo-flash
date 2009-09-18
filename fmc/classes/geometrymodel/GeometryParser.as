/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

import tools.XMLTools;

class geometrymodel.GeometryParser {
    
    static function parseGeometry(geometryNode:XMLNode):Geometry {		
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")) {
            geometryNode = geometryNode.firstChild;
        }		
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")) {
            geometryNode = geometryNode.firstChild;
        }
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")) {
            _global.flamingo.tracer("Exception in GeometryParser.parseGeometry()");
            return;
        }	

        var outerBoundaryNode:XMLNode = null;
        var linearRingNode:XMLNode = null;
        var coordinatePairsString:String = null;
        var coordinatesNode:XMLNode = null;
        var cs:String = null;
        var ts:String = null;
        var coordinatePairs:Array = null;
        var coordinates:Array = null;
        var x:Number = 0;
        var y:Number = 0;
        var points:Array = null;
        var geometry:Geometry = null;
        
        if (geometryNode.nodeName == "gml:Point") {
            coordinatePairsString = XMLTools.getStringValue("gml:coordinates", geometryNode);
            if (coordinatePairsString != null) {
                coordinatesNode = XMLTools.getChild("gml:coordinates", geometryNode);
                cs = XMLTools.getStringValue("cs", coordinatesNode);
				if (cs==undefined)
					cs=",";
				if (ts==undefined)
					ts=" ";
                coordinates = coordinatePairsString.split(cs);
            } else {
                coordinatePairsString = XMLTools.getStringValue("gml:pos", geometryNode);
                coordinates = coordinatePairsString.split(" ");
            }
            x = Number(coordinates[0]);
            y = Number(coordinates[1]);
            geometry = new Point(x, y);
        } else if (geometryNode.nodeName == "gml:LinearRing") {
            coordinatePairsString = XMLTools.getStringValue("gml:coordinates", geometryNode);
            if (coordinatePairsString != null) {
                coordinatesNode = XMLTools.getChild("gml:coordinates", geometryNode);
                cs = XMLTools.getStringValue("cs", coordinatesNode);
                ts = XMLTools.getStringValue("ts", coordinatesNode);
				if (cs==undefined)
					cs=",";
				if (ts==undefined)
					ts=" ";
                coordinatePairs = coordinatePairsString.split(ts);
                points = new Array();
                for (var j:Number = 0; j < coordinatePairs.length; j++) {
                    if (j < coordinatePairs.length - 1) {
                        coordinates = coordinatePairs[j].split(cs);
                        x = Number(coordinates[0]);
                        y = Number(coordinates[1]);
                        points.push(new Point(x, y));
                    } else {
                        points.push(points[0]);
                    }
                }
            } else {
                coordinatePairsString = XMLTools.getStringValue("gml:posList", geometryNode);
                coordinates = coordinatePairsString.split(" ");
                points = new Array();
                for (var j:Number = 0; j < coordinates.length; j += 2) {
                    if (j < coordinates.length - 2) {
                        x = Number(coordinates[j]);
                        y = Number(coordinates[j + 1]);
                        points.push(new Point(x, y));
                    } else {
                        points.push(points[0]);
                    }
                }
            }
            geometry = new LinearRing(points);
        } else if (geometryNode.nodeName == "gml:LineString") {
            coordinatePairsString = XMLTools.getStringValue("gml:coordinates", geometryNode);
            coordinatesNode = XMLTools.getChild("gml:coordinates", geometryNode);
            cs = XMLTools.getStringValue("cs", coordinatesNode);
            ts = XMLTools.getStringValue("ts", coordinatesNode);
			if (cs==undefined)
				cs=",";
			if (ts==undefined)
				ts=" ";
            coordinatePairs = coordinatePairsString.split(ts);
            points = new Array();
            for (var j:Number = 0; j < coordinatePairs.length; j++) {
                coordinates = coordinatePairs[j].split(cs);
                x = Number(coordinates[0]);
                y = Number(coordinates[1]);
                points.push(new Point(x, y));
            }
            geometry = new LineString(points);
        } else if (geometryNode.nodeName == "gml:LineStringSegment") {
            coordinatePairsString = XMLTools.getStringValue("gml:posList", geometryNode);
            coordinates = coordinatePairsString.split(" ");
            points = new Array();
            for (var j:Number = 0; j < coordinates.length; j += 2) {
                x = Number(coordinates[j]);
                y = Number(coordinates[j + 1]);
                points.push(new Point(x, y));
            }
            geometry = new LineString(points);
        } else if (geometryNode.nodeName == "gml:Polygon") {
            outerBoundaryNode = XMLTools.getChild("gml:outerBoundaryIs", geometryNode);
			if (outerBoundaryNode==undefined || outerBoundaryNode==null){
				outerBoundaryNode= XMLTools.getChild("gml:exterior", geometryNode);
			}
            linearRingNode = XMLTools.getChild("gml:LinearRing", outerBoundaryNode);
            geometry = new Polygon(LinearRing(parseGeometry(linearRingNode)));
        } else if (geometryNode.nodeName == "gml:PolygonPatch") {
            outerBoundaryNode = XMLTools.getChild("gml:exterior", geometryNode);
            linearRingNode = XMLTools.getChild("gml:LinearRing", outerBoundaryNode);
            geometry = new Polygon(LinearRing(parseGeometry(linearRingNode)));
        }
        return geometry;
    }
	
	static function parseGeometryFromWkt(wktGeom:String):Geometry {
		
		trace("GeometryParser.as parseGeometryFromWkt() wktGeom = "+wktGeom);
		
		var geometry:Geometry = null;
		
		//parse wktGeom
		var points:Array = null;
		var x:Number = 0;
		var y:Number = 0;
		var coordinatePairs:Array;
		
		
		if (wktGeom.indexOf("MULTI") != -1) {
			//intercept Multi Polygon
			_global.flamingo.tracer("Exception in GeometryParser.parseGeometryFromWkt()\nUnable to parse MULTI POLYGON geometry. \nwktGeom = "+wktGeom);
			return null;
		}
		
		//create geometry according to geometryType 
		if (wktGeom.indexOf("POINT") != -1) {
			var wktPoints:String = wktGeom.slice(wktGeom.indexOf("(") + 1,wktGeom.indexOf(")"));
			//if existing remove first " " (space character).
			if (wktPoints.charAt(0) == " ") {
				wktPoints = wktPoints.substr(1);
			}
			
			coordinatePairs = wktPoints.split(" ");
			x = Number(coordinatePairs[0]);
            y = Number(coordinatePairs[1]);
			geometry = new Point(x, y);
		
		} else if ( (wktGeom.indexOf("LINESTRING") != -1) || (wktGeom.indexOf("POLYGON") != -1) ) {
			var wktPoints:String = wktGeom.slice(wktGeom.lastIndexOf("(") + 1,wktGeom.indexOf(")"));
			coordinatePairs = wktPoints.split(",");
					
			//_global.flamingo.tracer("TRACE in GeometryParser.parseGeometryFromWkt() coordinatePairs = "+coordinatePairs);
			
			points = new Array();
			for (var j:Number = 0; j < coordinatePairs.length; j++) {
				//if existing remove first " " (space character).
				if (coordinatePairs[j].charAt(0) == " ") {
					coordinatePairs[j] = coordinatePairs[j].substr(1);
				}
                var coordinatePair:Array = coordinatePairs[j].split(" ");
				x = Number(coordinatePair[0]);
                y = Number(coordinatePair[1]);
				points.push(new geometrymodel.Point(x, y));
				
			}
			if (points!=null){
				if (wktGeom.indexOf("LINESTRING") != -1) {
					geometry = new LineString(points);
				} else if (wktGeom.indexOf("POLYGON") != -1) {
					//We assume a correct wkt geometry. 
					//Because the LinearRing class only tests if objects are equal,
					//we ensure that the last point equals the first point to close the ring and avoid an error message. 
					 
					points[points.length - 1] = points[0];
					
					var polygon:Polygon = new Polygon(new LinearRing(points));
					geometry = polygon;
				}
			}
		} else {
			//unidentified geometry type
			_global.flamingo.tracer("Exception in GeometryParser.parseGeometryFromWkt() \nUnidentified geometry type.\nwktGeom = "+wktGeom);
		}
		
		return geometry;
	}
    
}

