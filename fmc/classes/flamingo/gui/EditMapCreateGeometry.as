/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

import flamingo.gismodel.CreateGeometry;

class flamingo.gui.EditMapCreateGeometry extends MovieClip {
    
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var gis:flamingo.gismodel.GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var createGeometry:CreateGeometry = null; // Set by init object.
    
    private var numMouseDowns:Number = 0;
    private var intervalID:Number = null;
    private var geometry:flamingo.geometrymodel.Geometry = null;
    
    function onLoad():Void {
        draw();
    }
    
    function remove():Void {
        if (geometry != null) {
            geometry.removeChild(geometry.getEndPoint());
        }
        
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
        if (numMouseDowns == 0) {
            intervalID = setInterval(this, "resetNumMouseDowns", 300);
        }
        numMouseDowns++;
        var double:Boolean = false;
        if (numMouseDowns == 2) {
            double = true;
            resetNumMouseDowns();
        }
        
        if (double) {
            gis.setCreateGeometry(null);
        } else {
            var point:flamingo.geometrymodel.Point = pixel2Point(new Pixel(_xmouse, _ymouse));
            if (geometry == null) {
                geometry = createGeometry.getGeometryFactory().createGeometry(point);
                geometry.setEventComp(gis);
                createGeometry.getLayer().addFeature(geometry, true);
                if (geometry instanceof flamingo.geometrymodel.Point) {
                    gis.setCreateGeometry(null);
                }
            } else {
                geometry.addChild(point);
            }
        }
    }
    
    function onMouseMove():Void {
        if (geometry != null) {
            var endPoint:flamingo.geometrymodel.Point = geometry.getEndPoint();
            var mousePoint:flamingo.geometrymodel.Point = pixel2Point(new Pixel(_xmouse, _ymouse));
            endPoint.setXY(mousePoint.getX(), mousePoint.getY());
        }
    }
    
    private function resetNumMouseDowns():Void {
        if (numMouseDowns >= 1) {
            numMouseDowns = 0;
            clearInterval(intervalID);
        }
    }
    
    private function pixel2Point(pixel:Pixel):flamingo.geometrymodel.Point {

        var extent:Object = map.getMapExtent();
		var minX:Number = extent.minx;
        var minY:Number = extent.miny;
        var maxX:Number = extent.maxx;
        var maxY:Number = extent.maxy;
        var pointX:Number = pixel.getX() * (maxX - minX) / width + minX;
        var pointY:Number = -pixel.getY() * (maxY - minY) / height + maxY;
        
        return new flamingo.geometrymodel.Point(pointX, pointY);
    }
    
}
