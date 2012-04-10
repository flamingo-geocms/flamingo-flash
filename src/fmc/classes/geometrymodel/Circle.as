/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import geometrymodel.*;
/**
 * geometrymodel.Circle
 */
class geometrymodel.Circle extends Geometry {
    
    private var centerPoint:Point = null;
    private var circlePoint:Point = null;
	private var numberOfSegments:Number=48;
    /**
     * constructor
     * @param	centerPoint
     * @param	circlePoint
     */
    function Circle(centerPoint:Point, circlePoint:Point) {
        if (centerPoint == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Circle.<<init>>()");
        }
        if (circlePoint == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Circle.<<init>>()");
        }
        
        this.centerPoint = centerPoint;
        this.circlePoint = circlePoint;
    }
    /**
     * getChildGeometries
     * @return
     */
    function getChildGeometries():Array {
        return new Array(centerPoint, circlePoint);
    }
    /**
     * getPoints
     * @return
     */
    function getPoints():Array {
        return new Array(centerPoint, circlePoint);
    }
    /**
     * getEndPoint
     * @return
     */
    function getEndPoint():Point {
        return circlePoint;
    }
    /**
     * getCenterPoint
     * @return
     */
    function getCenterPoint():Point {
        return centerPoint;
    }
    /**
     * getEnvelope
     * @return
     */
    function getEnvelope():Envelope {
        var centerX:Number = centerPoint.getX();
        var centerY:Number = centerPoint.getY();
        var radius:Number = getRadius();
        var minX:Number = centerX - radius;
        var minY:Number = centerY - radius;
        var maxX:Number = centerX + radius;
        var maxY:Number = centerY + radius;
        
        return new Envelope(minX, minY, maxX, maxY);
    }
    /**
     * clone
     * @return
     */
    function clone():Geometry {
        return new Circle(Point(centerPoint.clone()), Point(circlePoint.clone()));
    }
    /**
     * getRadius
     * @return
     */
    function getRadius():Number {
        var dx:Number = circlePoint.getX() - centerPoint.getX();
        var dy:Number = circlePoint.getY() - centerPoint.getY();
        
        return Math.sqrt((dx * dx) + (dy * dy));
    }
    /**
     * getArea
     * @return
     */
    function getArea():Number {
    	return Math.PI * (getRadius()* getRadius());
	}
    /**
     * toGMLString
     * @param	srsName
     * @return
     */
    function toGMLString(srsName:String):String {
        var gmlString:String = "";
        gmlString += "<gml:Circle>\n";
        gmlString += "  <gml:coordinates>9000,5000 9500,5500 8500,5000</gml:coordinates>\n";
        gmlString += "</gml:Circle>\n";
        
        return gmlString;
    }
    /**
     * toWKT
     * @return
     */
	function toWKT():String{
		var wktGeom:String="";
		wktGeom+="POLYGON(";		
		wktGeom+=this.toWKTPart();
		wktGeom+=")";
		return wktGeom;
	}
	/**
	 * toWKTPart
	 * @return
	 */
	function toWKTPart():String{
		var wktString:String="(";
	    var startAngle:Number = 0;
        var endAngle:Number = 2 * Math.PI;
        var segAngle:Number = 2 * Math.PI / numberOfSegments;
        var angle:Number = startAngle;
		var radius=getRadius();
		for (;;) {
            var xcoord = centerPoint.getX() + radius * Math.cos(angle);
            var ycoord = centerPoint.getY() + radius * Math.sin(angle);
            if (angle!=0){
				wktString+=",";
			}
			wktString+=xcoord+" "+ycoord; 
            if (angle >= endAngle) {
                break;
            }
            angle += segAngle;
            if (angle > endAngle) {
                angle = endAngle;
            }
        }
		wktString+=")";
		return wktString;
	}
	/**
	 * toString
	 * @return
	 */
    function toString():String {
        return "Circle(" + centerPoint.toString() + ", " + circlePoint.toString() + ")"; 
    }
    
}
