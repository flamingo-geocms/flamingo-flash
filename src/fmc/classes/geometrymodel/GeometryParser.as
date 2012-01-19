/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

import tools.XMLTools;
import tools.Logger;

class geometrymodel.GeometryParser {
    
	private static var log:Logger= new Logger("gui.EditMapPolygon",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
	
    static function parseGeometry(geometryNode:XMLNode):Geometry {		
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")
                                                   && (geometryNode.nodeName != "gml:Envelope")) {
            geometryNode = geometryNode.firstChild;
        }		
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")
													&& (geometryNode.nodeName != "gml:Envelope")) {
            geometryNode = geometryNode.firstChild;
        }
        if ((geometryNode.nodeName != "gml:Point") && (geometryNode.nodeName != "gml:LinearRing")
                                                   && (geometryNode.nodeName != "gml:LineString")
                                                   && (geometryNode.nodeName != "gml:LineStringSegment")
                                                   && (geometryNode.nodeName != "gml:Polygon")
                                                   && (geometryNode.nodeName != "gml:PolygonPatch")
												   && (geometryNode.nodeName != "gml:Envelope")) {
            _global.flamingo.tracer("Exception in GeometryParser.parseGeometry()");
            return null;
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
        } else if (geometryNode.nodeName == "gml:Envelope") {
        	var lowerCorner:Array = XMLTools.getStringValue("gml:lowerCorner", geometryNode).split(" ");
        	var upperCorner:Array = XMLTools.getStringValue("gml:upperCorner", geometryNode).split(" ");
			geometry = new Envelope(lowerCorner[0],lowerCorner[1],upperCorner[0],upperCorner[1]);
        }
        return geometry;
    }
	
	static function parseGeometryFromWkt(wktGeom:String):Geometry {
		
		log.debug("GeometryParser.as parseGeometryFromWkt() wktGeom = "+wktGeom);
		
		var geometry:Geometry = null;
		
		//parse wktGeom
		var points:Array = null;
		var x:Number = 0;
		var y:Number = 0;
		var coordinatePairs:Array;
		
		//handle the multi's
		if (wktGeom.indexOf("MULTI") != -1) {
			//intercept Multi Polygon
			if (wktGeom.indexOf("MULTIPOLYGON") != -1){
				//MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))
				var wktMultiPolygon:String=""+wktGeom;
				wktMultiPolygon=wktMultiPolygon.substring("MULTIPOLYGON".length,wktMultiPolygon.length);				
				geometry=parseWktMultiPolygon(wktMultiPolygon);				
			}else{
				_global.flamingo.tracer("Exception in GeometryParser.parseGeometryFromWkt()\nUnable to parse MULTI geometry. \nwktGeom = "+wktGeom);
				return null;
			}
		}//create geometry according to geometryType 
		else if (wktGeom.indexOf("POINT") != -1) {
			var wktPoints:String = wktGeom.slice(wktGeom.indexOf("(") + 1,wktGeom.indexOf(")"));
			//if existing remove first " " (space character).
			if (wktPoints.charAt(0) == " ") {
				wktPoints = wktPoints.substr(1);
			}
			
			coordinatePairs = wktPoints.split(" ");
			x = Number(coordinatePairs[0]);
            y = Number(coordinatePairs[1]);
			geometry = new Point(x, y);
		
		} else if (wktGeom.indexOf("LINESTRING") != -1) {
			var wktPoints:String = wktGeom.slice(wktGeom.lastIndexOf("(") + 1,wktGeom.indexOf(")"));
			coordinatePairs = wktPoints.split(",");
					
			points = createPoints(coordinatePairs);
			
			if (points!=null){
				geometry = new LineString(points);				
			}
		} else if (wktGeom.indexOf("POLYGON") != -1){
			geometry=parseWktPolygon(wktGeom);
		}else {
			//unidentified geometry type
			_global.flamingo.tracer("Exception in GeometryParser.parseGeometryFromWkt() \nUnidentified geometry type.\nwktGeom = "+wktGeom);
		}
		
		return geometry;
	}
	
	static function createPoints(coordinatePairs:Array):Array{
		var x:Number = 0;
		var y:Number = 0;
		var points = new Array();
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
		return points;
	}
	
	static function parseWktLinearRing(wktGeom):LinearRing{
		log.debug("parseWktLinearRing: "+wktGeom);
		var wktLinearRing=""+wktGeom;
		//remove first and last ()
		wktLinearRing=wktLinearRing.substring(wktLinearRing.indexOf("(")+1,wktLinearRing.indexOf(")"));				
		var coordinatePairs = wktLinearRing.split(",");					
		var points:Array = createPoints(coordinatePairs);
		if (points==null){
			return null;
		}
		//make first == last;
		points[points.length-1]=points[0];
		return new LinearRing(points);
	}
    
	static function parseWktPolygon(wktGeom:String):Polygon{
		log.debug("parseWktPolygon: "+wktGeom);
		var wktPolygon:String=""+wktGeom;
		if (wktPolygon.indexOf("POLYGON")!=-1){			
			wktPolygon=wktPolygon.substring("POLYGON".length,wktPolygon.length);
		}
		//remove the first( and last ) so only the polygons stay
		wktPolygon=wktPolygon.substring(wktPolygon.indexOf("(")+1,wktPolygon.lastIndexOf(")"));
		var geometry:Polygon=null;
		while (wktPolygon!=null && wktPolygon.length > 0){
			var beginIndex:Number=wktPolygon.indexOf("(");
			var endIndex:Number=wktPolygon.indexOf(")");			
			if (endIndex > 0){
				endIndex+=1;
			}
			var wktLinearRing:String = wktPolygon.substring(beginIndex,endIndex);
			var linearRing:LinearRing = parseWktLinearRing(wktLinearRing);			
			if (geometry==null){
				geometry = new Polygon(linearRing);
			}else{
				Polygon(geometry).addInteriorRing(linearRing);
			}
			//check if there is next polygon
			if (wktPolygon.indexOf("(",endIndex)<0){
				wktPolygon=null;
			}else{
				wktPolygon= wktPolygon.substring(endIndex,wktPolygon.length);
			}
		}
		return geometry;
	}
	
	static function parseWktMultiPolygon(wktGeom:String):MultiPolygon{
		log.debug("parseWktMultiPolygon: "+wktGeom);
		var wktMultiPolygon:String=""+wktGeom;
		if (wktMultiPolygon.indexOf("MULTIPOLYGON")!=-1){			
			wktMultiPolygon=wktMultiPolygon.substring("MULTIPOLYGON".length,wktMultiPolygon.length);
		}
		//remove the first( and last ) so only the polygons stay
		wktMultiPolygon=wktMultiPolygon.substring(wktMultiPolygon.indexOf("(")+1,wktMultiPolygon.lastIndexOf(")"));
		var geometry:MultiPolygon=null;
		while (wktMultiPolygon!=null && wktMultiPolygon.length > 0){
			var beginIndex:Number=wktMultiPolygon.indexOf("((");
			var endIndex:Number=wktMultiPolygon.indexOf("))");
			if (endIndex > 0){
				endIndex+=2;
			}
			var wktPolygonPart=wktMultiPolygon.substring(beginIndex,endIndex);
			var polygon:Polygon= parseWktPolygon(wktPolygonPart);
			if (geometry==null){
				geometry = new MultiPolygon(polygon);
			}else{
				MultiPolygon(geometry).addPolygon(polygon);
			}
			//check if there is next polygon
			if (wktMultiPolygon.indexOf("((",endIndex)<0){
				wktMultiPolygon=null;
			}else{
				wktMultiPolygon= wktMultiPolygon.substring(endIndex,wktMultiPolygon.length);
			}
		}				
		return geometry;
	}
}

