/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.*

import gismodel.GIS;
import gismodel.Style;
import geometrymodel.Geometry;
import geometrymodel.Point;
import geometrymodel.LineString;
import geometrymodel.Polygon;
import geometrymodel.Circle;

class gui.GeometryPane extends MovieClip {
    
    private var gis:GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var style:Style = null; // Set by init object.
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var editMapGeometries:Array = null;
    
    function onLoad():Void {
        editMapGeometries = new Array();
    }
    
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
        initObject["_geometry"] = geometry;
        initObject["type"] = type;
        initObject["labelText"] = labelText;
        initObject["style"] = style;
        initObject["width"] = width;
        initObject["height"] = height;
        initObject["isChild"] = isChild;
        if (geometry instanceof Point) {
            editMapGeometries.push(attachMovie("EditMapPoint", "mEditMapPoint" + depth, depth, initObject));
        } else if (geometry instanceof LineString) {
            editMapGeometries.push(attachMovie("EditMapLineString", "mEditMapLineString" + depth, depth, initObject));
        } else if (geometry instanceof Polygon) {
            editMapGeometries.push(attachMovie("EditMapPolygon", "mEditMapPolygon" + depth, depth, initObject));
        } else if (geometry instanceof Circle) {
            editMapGeometries.push(attachMovie("EditMapCircle", "mEditMapCircle" + depth, depth, initObject));
        }
    }
    
    private function setTypeChildren(type:Number):Void {
        for (var i:String in editMapGeometries) {
            EditMapGeometry(editMapGeometries[i]).setType(type);
        }
    }
    
}
