/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

import geometrymodel.LinearRing;
import geometrymodel.Point;
import geometrymodel.Polygon;

class gui.EditMapPolygon extends EditMapGeometry {
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function doDraw():Void {
        var polygon:Polygon = Polygon(_geometry);
        var exteriorRing:LinearRing = polygon.getExteriorRing();
        var points:Array = exteriorRing.getPoints();
        var pixel:Pixel = point2Pixel(points[0]);
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
            lineStyle(0, strokeColor, strokeOpacity);
        } else {
            lineStyle(strokeWidth , strokeColor, strokeOpacity);
        }
        if (style.getFillOpacity() > 0) {
            beginFill(fillColor, fillOpacity);
        }
        for (var i:Number = 1; i < points.length; i++) {
            pixel =  point2Pixel(points[i]);
            lineTo(pixel.getX(), pixel.getY());
        }
        if (fillOpacity > 0) {
            endFill();
        }
        
        if (type != ACTIVE) {
            moveTo(x, y);
            lineStyle(strokeWidth * 2, 0, 0);
            for (var i:Number = 1; i < points.length; i++) {
                pixel =  point2Pixel(points[i]);
                lineTo(pixel.getX(), pixel.getY());
            }
        }
    }
    
}
