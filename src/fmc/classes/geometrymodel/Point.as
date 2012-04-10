/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

import event.StateEvent;
import gui.Pixel;
import event.GeometryListener;
/**
 * geometrymodel.Point
 */
class geometrymodel.Point extends Geometry implements GeometryListener {
    
    private var x:Number = null;
    private var y:Number = null;
    /**
     * constructor
     * @param	x
     * @param	y
     */
    function Point(x:Number, y:Number) {
        if (x == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Point.<<init>>(" + x + ", " + y + ")");
            return;
        }
        if (y == null) {
            _global.flamingo.tracer("Exception in geometrymodel.Point.<<init>>(" + x + ", " + y + ")");
            return;
        }
        
        this.x = x;
        this.y = y;
    }
    /**
     * getPoints
     * @return
     */
    function getPoints():Array {
        return new Array(this);
    }
    /**
     * getEndPoint
     * @return
     */
    function getEndPoint():Point {
        return this;
    }
    /**
     * getCenterPoint
     * @return
     */
    function getCenterPoint():Point {
        return this;
    }
    /**
     * getEnvelope
     * @return
     */
     function getEnvelope():Envelope {
        return new Envelope(x, y, x, y);
    }
    /**
     * clone
     * @return
     */
    function clone():Point {
    	var newPoint = new Point(x, y);
        return newPoint;
    }
    /**
     * setXY
     * @param	x
     * @param	y
     * @param	pixel
     */
    function setXY(x:Number, y:Number, pixel:Pixel):Void {
        this.x = x;
        this.y = y;
    }
	/**
	 * setX
	 * @param	x
	 */
	function setX(x:Number):Void {
        this.x = x;
    }
	/**
	 * setY
	 * @param	y
	 */
	function setY(y:Number):Void {
        this.y = y;
    }
    /**
     * getX
     * @return
     */
    function getX():Number {
        return x;
    }
    /**
     * getY
     * @return
     */
    function getY():Number {
        return y;
    }
	/**
	 * changeGeometry
	 */
	function changeGeometry():Void {
		geometryEventDispatcher.changeGeometry(this);
	}
    /**
     * toGMLString
     * @param	srsName
     * @return
     */
    function toGMLString(srsName:String):String {
        var gmlString:String = "";
        
        if (srsName == undefined) {
			gmlString += "<gml:Point srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        } else {
		    gmlString += "<gml:Point srsName=\""+srsName+"\">\n";
		}
		gmlString += "  <gml:coordinates cs=\",\" decimal=\".\" ts=\" \">";
        gmlString += (x + "," + y);
        gmlString += "</gml:coordinates>\n";
        gmlString += "</gml:Point>\n";
        
        return gmlString;
    }
	/**
	 * toWKT
	 * @return
	 */
	function toWKT():String{		
		var wktGeom:String="";
		wktGeom+="POINT(";
		wktGeom+=(this.getX()+" "+this.getY());
		wktGeom+=")";		
		return wktGeom;
	} 
    /**
     * toString
     * @return
     */
    function toString():String {
        return("Point (" + x + ", " + y + ")");
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
	
}
