/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.Polygon extends Geometry {
    
    private var exteriorRing:LinearRing = null;
    
    function Polygon(exteriorRing:LinearRing) {
        if (exteriorRing == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Polygon.<<init>>(null)");
            return;
        }
        
		exteriorRing.removeConsecutiveDoubles();
        this.exteriorRing = exteriorRing;
        exteriorRing.setParent(this);
        addGeometryListener(exteriorRing);
        geometryEventDispatcher.addChild(this,exteriorRing);
    }
    
    function addPoint(point:Point):Void {        
        exteriorRing.addPoint(point);
    }
	
	function insertPoint(point:Point, insertIndex:Number):Void {
        exteriorRing.insertPoint(point, insertIndex);
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
    
    function getEnvelope():Envelope{
    	return getExteriorRing().getEnvelope();
    }
    
    
	function getArea(performSimpleTest:Boolean):Number {
		var points:Array = exteriorRing.getPoints();
		var area:Number = 0;
		
		if (points.length >=2) {
			if (performSimpleTest) {
				//test if polygon is simple
				if (!polygonIsSimpleTest()) {
					return null;
				}
			}
		}
		else { //polygon has 1 or 2 points, by definition in this case the polygon is always simple.
			return 0;
		}
				
		//*** calc area ***
		for (var i:Number = 0; i < points.length - 1; i++) {
			area += ( points[i].getX() * points[i+1].getY() - points[i+1].getX() * points[i].getY() );
		}
		area /= -2.0;
		return area;
	}
	
	function polygonIsSimpleTest():Boolean {
        var polygonSimple:Boolean = true;
		var points:Array = exteriorRing.getPoints();
		
		//in principle the exteriorRing is always closed. But while drawing we can not always be sure.
		var isClosed:Number = 0;
		if (points.length >=2) {
			if (Point(points[0]) == Point(points[points.length - 1])){
				isClosed = 1;
			}
		}
		else {
			//polygon has 1 or 2 points, by definition in this case the polygon is always simple.
			return true;
		}
	
		//test on line segment length != 0 and test if connected line segments are parallel
		for (var i:Number = 0; i < points.length - isClosed - 1; i++) {
			//test on line segment length != 0
			if (points[i].getDistance(points[i+1] == 0)) {
				polygonSimple = false;
				break;
			}
			else {	
				//test if connected line segments are parallel
				if ( i < points.length - isClosed - 1) {
					if (lineSegmentIntersectionTest(points[i], points[i+1], points[i+1], points[i+2]) == "PARALLEL") {
						polygonSimple = false;
						break;
					}
				}
			}
		
		}
		
		//test if polygon selfintersects
		if (polygonSimple) {
			if (selfIntersectionTest()){
				polygonSimple = false;
			}
		}
		return polygonSimple;
	}
    
	function selfIntersectionTest():Boolean {
		var intersection:Boolean = false;
		
		var points:Array = exteriorRing.getPoints();
		
		var isClosed:Number = 0;
		if (points.length >=2) {
			if (Point(points[0]) == Point(points[points.length - 1])){
				isClosed = 1;
			}
		}
		
		//test selfintersection 
		for (var i:Number = 0; i < points.length - isClosed; i++) {
			for (var j:Number = i + 2; j < points.length - isClosed - 1; j++) {
				if (!points[i].equals(points[i+1]) && !points[j].equals(points[j+1]) 
					&& !points[i].equals(points[j+1]) && !points[j].equals(points[i+1]) ) {
					if (lineSegmentIntersectionTest(points[i], points[i+1], points[j], points[j+1]) == "INTERSECTING") {
						//check if line segments have non zero length.
						intersection = true;
						break;
					}
				}
			}
		}
		return intersection;
	}
	
    
	function lineSegmentIntersectionTest(p1:Point, p2:Point, p3:Point, p4:Point):String {
		//Line Segment A: point p1 & p2
		//Line Segment B: point p3 & p4
		var denom:Number = 	((p4.getY() - p3.getY())*(p2.getX() - p1.getX())) - ((p4.getX() - p3.getX())*(p2.getY() - p1.getY()));
		var nume_a:Number = ((p4.getX() - p3.getX())*(p1.getY() - p3.getY())) - ((p4.getY() - p3.getY())*(p1.getX() - p3.getX()));
		var nume_b:Number = ((p2.getX() - p1.getX())*(p1.getY() - p3.getY())) - ((p2.getY() - p1.getY())*(p1.getX() - p3.getX()));

		
		if (denom == 0) {
            if(nume_a == 0.0 && nume_b == 0.0) {
                return "COINCIDENT";
            }
            return "PARALLEL";
        }

        var ua:Number = nume_a / denom;
        var ub:Number = nume_b / denom;

        if(ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0) {
            // Get the intersection point.
            //intersectionPoint.setX(p1.getX() + ua*(p2.getX() - p1.getX()));
            //intersectionPoint.setY(p1.getY() + ua*(p2.getY() - p1.getY()));

            return "INTERSECTING";
        }

		return "NOT_INTERSECTING";
	
	}
	
	
	function toGMLString(srsName:String):String {
        var points:Array = exteriorRing.getPoints();
        var point:Point = null;
        
        var gmlString:String = "";
		if (srsName == undefined) {
			gmlString += "<gml:Polygon srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        } else {
		    gmlString += "<gml:Polygon srsName=\""+srsName+"\">\n";
		}
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
	
	function toWKT():String{
		var wktGeom:String="";
		wktGeom+="POLYGON(";		
		wktGeom+=toWKTPart();
		wktGeom+=")";
		return wktGeom;
	}
	
	function toWKTPart():String{
		var wktGeom:String="";
		var points:Array = this.getPoints();
        var point:Point = null;
		wktGeom+="(";	
		for (var i:Number = 0; i < points.length; i++) {
			if (i!=0){
				wktGeom+=",";
			}
            point = Point(points[i]);            
            wktGeom += (point.getX() + " " + point.getY());
		}
		wktGeom+=")";
		return wktGeom;
	}
	
	function toString():String {
        return ("Polygon (" + exteriorRing.toString() + ")");
    }
    
}
