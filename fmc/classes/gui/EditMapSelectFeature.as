// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.
// Changes by author: Maurits Kelder, B3partners bv

import gui.*;

import gismodel.CreateGeometry;

import geometrymodel.Geometry;
import geometrymodel.Point;
import geometrymodel.Polygon;
import geometrymodel.LineString;

class gui.EditMapSelectFeature extends MovieClip {
    
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var gis:gismodel.GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var createGeometry:CreateGeometry = null; // Set by init object.
    
    private var numMouseDowns:Number = 0;
    private var intervalID:Number = null;
	private var ctrlKeyDown:Boolean = false;
    private var geometry:geometrymodel.Geometry = null;
    
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
        //draw full transparent colored layer to inform user we are in "Create new geometry" mode
		clear();
        moveTo(0, 0);
        lineStyle(0, 0x000000, 100);
        beginFill(0x333333, 30);
		lineTo(width, 0);
        lineTo(width, height);
        lineTo(0, height);
        endFill();
    }
	
    function onPress():Void {
		var pixel = new Pixel(_xmouse, _ymouse);
       	var mousePoint:Point = pixel2Point(pixel);
		
		var pointMin:geometrymodel.Point = pixel2Point(new Pixel(_xmouse-5, _ymouse-5));
		var pointMax:geometrymodel.Point = pixel2Point(new Pixel(_xmouse+5, _ymouse+5));
		
		var env:geometrymodel.Envelope = new geometrymodel.Envelope(pointMin.getX(), pointMin.getY(), pointMax.getX(), pointMax.getY());
		gis.doGetFeatures(env);
		gis.setSelectedEditTool(null);
    }            
    
    private function pixel2Point(pixel:Pixel):geometrymodel.Point {
    	
        var extent:Object = map.getCurrentExtent();
		var minX:Number = extent.minx;
        var minY:Number = extent.miny;
        var maxX:Number = extent.maxx;
        var maxY:Number = extent.maxy;
        var pointX:Number = pixel.getX() * (maxX - minX) / width + minX;
        var pointY:Number = -pixel.getY() * (maxY - minY) / height + maxY;
        
        return new geometrymodel.Point(pointX, pointY);
    }
    
}
