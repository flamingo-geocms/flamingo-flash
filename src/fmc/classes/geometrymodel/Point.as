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

class geometrymodel.Point extends Geometry implements GeometryListener {
    
    private var x:Number = null;
    private var y:Number = null;
    
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
    
    function clone():Point {
    	var newPoint = new Point(x, y);
        return newPoint;
    }
    
    function setXY(x:Number, y:Number, pixel:Pixel):Void {
        this.x = x;
        this.y = y;
    }
	
	function setX(x:Number):Void {
        this.x = x;
    }
	
	function setY(y:Number):Void {
        this.y = y;
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
	
	function changeGeometry():Void {
		geometryEventDispatcher.changeGeometry(this);
	}
    
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
	
	function toWKT():String{		
		var wktGeom:String="";
		wktGeom+="POINT(";
		wktGeom+=(this.getX()+" "+this.getY());
		wktGeom+=")";		
		return wktGeom;
	} 
    
    function toString():String {
        return("Point (" + x + ", " + y + ")");
    }
    
	function onChangeGeometry(geometry:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
    
    function onAddChild(geometry:Geometry,child:Geometry):Void{
    	//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
	
	public function onRemoveChild(geometry:Geometry,child:Geometry) : Void {
		//parent changed
    	geometryEventDispatcher.changeGeometry(this);
    }
	
}
