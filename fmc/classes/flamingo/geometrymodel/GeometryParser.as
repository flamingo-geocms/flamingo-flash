// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

import flamingo.tools.XMLTools;

class flamingo.geometrymodel.GeometryParser {
    
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
            linearRingNode = XMLTools.getChild("gml:LinearRing", outerBoundaryNode);
            geometry = new Polygon(LinearRing(parseGeometry(linearRingNode)));
        } else if (geometryNode.nodeName == "gml:PolygonPatch") {
            outerBoundaryNode = XMLTools.getChild("gml:exterior", geometryNode);
            linearRingNode = XMLTools.getChild("gml:LinearRing", outerBoundaryNode);
            geometry = new Polygon(LinearRing(parseGeometry(linearRingNode)));
        }
        return geometry;
    }
    
}
