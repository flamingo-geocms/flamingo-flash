/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

import gismodel.CreateGeometry;
import geometrymodel.Geometry;
import geometrymodel.Point;

class gui.EditMapCreateGeometry extends MovieClip {
    
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var gis:gismodel.GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var createGeometry:CreateGeometry = null; // Set by init object.
    
    private var numMouseDowns:Number = 0;
    private var intervalID:Number = null;
    private var geometry:Geometry = null;
    private var deltaTime:Number = 0;
    private var pressTime:Number = 0;
    private var previousPressTime:Number = 0;
    
    function onLoad():Void {
        draw();
    }
    
    function remove():Void {
        this.removeMovieClip();
    }
    
    function setSize(width:Number, height:Number):Void {
        this.width = width;
        this.height = height;
        
        draw();
    }
    
    private function draw():Void {
        clear();
        moveTo(0, 0);
        lineStyle(0, 0x000000, 100);
        beginFill(0xAA6600, 30);
        lineTo(width, 0);
        lineTo(width, height);
        lineTo(0, height);
        endFill();
    }
    
    function onPress():Void {
    	var double:Boolean = false;	
    	if (previousPressTime==0){
    		previousPressTime = getTimer();
    		//first click
    	} else { 	 
    		pressTime = getTimer();
    		deltaTime =  pressTime - previousPressTime;
    		if(deltaTime<300){
    			double = true;
    		} else {
    			double = false;
    		}
    		previousPressTime = getTimer();
    	}        
        if (double) {
            gis.setCreateGeometry(null);
        } else {	
            var pixel:Pixel = new Pixel(_xmouse, _ymouse);
            var point:geometrymodel.Point = pixel2Point(pixel);
            if (geometry == null) {
                geometry = createGeometry.getGeometryFactory().createGeometry(point);
                geometry.setEventComp(gis);
                createGeometry.getLayer().addFeature(geometry);
                if (geometry instanceof geometrymodel.Point) {
                    gis.setCreateGeometry(null);
                }
            } else {
                geometry.addPoint(point);
            }
        }
    }
    
    function onMouseMove():Void {
        if (geometry != null) {
        	var pixel = new Pixel(_xmouse, _ymouse);
        	var mousePoint:Point = pixel2Point(pixel);
        	geometry.setXYEndPoint(mousePoint , pixel);
        }
    }
    
    
    private function pixel2Point(pixel:Pixel):geometrymodel.Point {
    	
        var extent:Object = map.getMapExtent();
		var minX:Number = extent.minx;
        var minY:Number = extent.miny;
        var maxX:Number = extent.maxx;
        var maxY:Number = extent.maxy;
        var pointX:Number = pixel.getX() * (maxX - minX) / width + minX;
        var pointY:Number = -pixel.getY() * (maxY - minY) / height + maxY;
        
        return new geometrymodel.Point(pointX, pointY);
    }
    
}
