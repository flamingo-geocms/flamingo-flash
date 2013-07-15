/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import gui.*

import gismodel.GIS;
import gismodel.Style;
import geometrymodel.Geometry;
import geometrymodel.Point;
import geometrymodel.LineString;
import geometrymodel.Polygon;
import geometrymodel.MultiPolygon;
import geometrymodel.Circle;
import geometrymodel.LinearRing;
import tools.Logger;

/**
 * GeometryPane
 */
class gui.GeometryPane extends MovieClip {
    
    private var gis:GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var style:Style = null; // Set by init object.
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var editMapGeometries:Array = null;
	private var log:Logger=null;
	private var showMeasures:Boolean = false; // Set by init object.
	private var measureUnit:String = null;// Set by init object.
	private var measureDecimals:Number = null;// Set by init object.
	private var measureMagicnumber:Number = null;// Set by init object.
	private var measureDs:String = null;// Set by init object.
	
	private var editable:Boolean = true; //Set by init object.
	/**
	 * on Load
	 */
    function onLoad():Void {
		this.log = new Logger("gui.GeometryPane",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        editMapGeometries = new Array();
    }
    /**
     * set Size
     * @param	width
     * @param	height
     */
    function setSize(width:Number, height:Number):Void {
        this.width = width;
        this.height = height;
        
        for (var i:String in editMapGeometries) {
            EditMapGeometry(editMapGeometries[i]).setSize(width, height);
        }
    }
    
    private function addEditMapGeometry(geometry:Geometry, type:Number, labelText:String, 
    									depth:Number, isChild:Boolean):Void {
        var initObject:Object = new Object();
		initObject["map"] = map;
		initObject["gis"] = gis;
        initObject["_geometry"] = geometry;
        initObject["type"] = type;
        initObject["labelText"] = labelText;
        initObject["style"] = style;
        initObject["width"] = width;
        initObject["height"] = height;
        initObject["isChild"] = isChild;
		initObject["editable"] = editable;
		initObject["alwaysDrawPoints"] = gis.getAlwaysDrawPoints();
		initObject["showMeasures"] = showMeasures;
		initObject["measureUnit"] = measureUnit;
		initObject["measureDecimals"] = measureDecimals;
		initObject["measureMagicnumber"] = measureMagicnumber;
		initObject["measureDs"] = measureDs;
		
		if (geometry instanceof Point) {
            editMapGeometries.push(this.attachMovie("EditMapPoint", "mEditMapPoint" + depth, depth, initObject));
        } else if (geometry instanceof LineString) {
            editMapGeometries.push(this.attachMovie("EditMapLineString", "mEditMapLineString" + depth, depth, initObject));
        } else if (geometry instanceof LinearRing) {
            editMapGeometries.push(this.attachMovie("EditMapLineString", "mEditMapLinearRing" + depth, depth, initObject));
        } else if (geometry instanceof Polygon) {
            editMapGeometries.push(this.attachMovie("EditMapPolygon", "mEditMapPolygon" + depth, depth, initObject));
        } else if (geometry instanceof Circle) {
            editMapGeometries.push(this.attachMovie("EditMapCircle", "mEditMapCircle" + depth, depth, initObject));
        } else if (geometry instanceof MultiPolygon){
			editMapGeometries.push(this.attachMovie("EditMapMultiPolygon", "mEditMapMultiPolygon" + depth, depth, initObject));
		}
    }
    
    private function setTypeChildren(type:Number):Void {
        for (var i:String in editMapGeometries) {
            EditMapGeometry(editMapGeometries[i]).setType(type);
        }
    }
	
	private function  removeEditMapGeometry(geometry:Geometry, child:Geometry) {
	}
	
	private function removeEditMapGeometries():Void {
        for (var i:String in editMapGeometries) {
            EditMapGeometry(editMapGeometries[i]).remove();
        }
        editMapGeometries = new Array();
    }
    
}
