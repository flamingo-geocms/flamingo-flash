/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;
import event.GeometryListener;
/**
 * geometrymodel.Polygon
 */
class geometrymodel.Polygon extends Geometry implements GeometryListener{
    
    private var exteriorRing:LinearRing = null;
    private var interiorRings:Array = null;
	/**
	 * constructor
	 * @param	exteriorRing
	 */
    function Polygon(exteriorRing:LinearRing) {
        if (exteriorRing == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Polygon.<<init>>(null)");
            return;
        }
        interiorRings=new Array();
		exteriorRing.removeConsecutiveDoubles();
        this.exteriorRing = exteriorRing;
        exteriorRing.setParent(this);
        addGeometryListener(exteriorRing);
        geometryEventDispatcher.addChild(this,exteriorRing);		
    }
	/**
	 * addInteriorRing
	 * @param	interiorRing
	 */
    function addInteriorRing(interiorRing:LinearRing){
        interiorRing.setParent(this);
		interiorRings.push(interiorRing);		
		addGeometryListener(interiorRing);
		geometryEventDispatcher.addChild(this,interiorRing);
	}
	/**
	 * getInteriorRings
	 * @return
	 */
	function getInteriorRings():Array{
		return interiorRings;
	}
	/**
	 * addPoint
	 * @param	point
	 */
    function addPoint(point:Point):Void {        
        exteriorRing.addPoint(point);
    }
	/**
	 * insertPoint
	 * @param	point
	 * @param	insertIndex
	 */
	function insertPoint(point:Point, insertIndex:Number):Void {
        exteriorRing.insertPoint(point, insertIndex);
    }
	/**
	 * getChildGeometries
	 * @return
	 */
    function getChildGeometries():Array {
        var rings:Array= new Array();
		rings.push(exteriorRing);
		for (var i=0; i < interiorRings.length; i++){
			rings.push(interiorRings[i]);
		}
		return rings;
    }
    /**
     * getPoints
     * @return
     */
    function getPoints():Array {
        return exteriorRing.getPoints();
    }
    /**
     * getEndPoint
     * @return
     */
    function getEndPoint():Point {
        return exteriorRing.getEndPoint(); 
    }
    /**
     * getCenterPoint
     * @return
     */
    function getCenterPoint():Point {
        return exteriorRing.getCenterPoint();
    }
    /**
     * getExteriorRing
     * @return
     */
    function getExteriorRing():LinearRing {
        return exteriorRing;
    }
    /**
     * getEnvelope
     * @return
     */
    function getEnvelope():Envelope{
    	return getExteriorRing().getEnvelope();
    }
    
    /**
     * getArea
     * @param	performSimpleTest
     * @return
     */
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
	/**
	 * polygonIsSimpleTest
	 * @return
	 */
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
    /**
     * selfIntersectionTest
     * @return
     */
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
	
    /**
     * lineSegmentIntersectionTest
     * @param	p1
     * @param	p2
     * @param	p3
     * @param	p4
     * @return
     */
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
	
	/**
	 * toGMLString
	 * @param	srsName
	 * @return
	 */
	function toGMLString(srsName:String):String {
        var points:Array = exteriorRing.getPoints();
        var point:Point = null;
        
        var gmlString:String = "";
		if (srsName == undefined) {
			gmlString += "<gml:Polygon srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        } else if(srsName==null){
			gmlString+= "<gml:Polygon>\n";
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
	/**
	 * toWKT
	 * @return
	 */
	function toWKT():String{
		var wktGeom:String="";
		wktGeom+="POLYGON(";		
		wktGeom+=toWKTPart();
		wktGeom+=")";
		return wktGeom;
	}
	/**
	 * toWKTPart
	 * @return
	 */
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
		for (var b:Number=0; b < interiorRings.length; b++){
			points=interiorRings[b].getPoints();
			wktGeom+=",(";
			for (var i:Number = 0; i < points.length; i++) {
				if (i!=0){
					wktGeom+=",";
				}
				point = Point(points[i]);            
				wktGeom += (point.getX() + " " + point.getY());
			}
			wktGeom+=")";
		}
		
		return wktGeom;
	}
	/**
	 * toString
	 * @return
	 */
	function toString():String {
        return ("Polygon (" + exteriorRing.toString() + ")");
    }
	/**
	 * onChangeGeometry
	 * @param	geometry
	 */
	function onChangeGeometry(geometry:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
    /**
     * onAddChild
     * @param	geometry
     * @param	child
     */
    function onAddChild(geometry:Geometry,child:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
	/**
	 * onRemoveChild
	 * @param	geometry
	 * @param	child
	 */
	public function onRemoveChild(geometry:Geometry,child:Geometry) : Void {
		//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
    
	public function translatePos(x:Number, y:Number):Void {
		var polygon:Polygon = this;
		var exteriorRing:LinearRing = polygon.getExteriorRing();
		var interiorRings:Array = polygon.getInteriorRings();
		var points:Array = exteriorRing.getPoints();
		
		exteriorRing.translatePos(x, y);
		//walk over the interior rings
		for (var i:Number =0; i <  interiorRings.length; i++){			
			var interiorRing:LinearRing = LinearRing(interiorRings[i]);
			interiorRing.translatePos(x, y);
		}
	}
}
