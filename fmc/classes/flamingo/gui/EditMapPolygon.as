// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import flamingo.geometrymodel.LinearRing;
import flamingo.geometrymodel.Point;
import flamingo.geometrymodel.Polygon;

class flamingo.gui.EditMapPolygon extends EditMapGeometry {
    
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
        var pixel:Pixel = point2Pixel(Point(points[0]));
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
            lineStyle(0, style.getStrokeColor(), style.getStrokeOpacity());
        } else {
            lineStyle(style.getStrokeWidth(), style.getStrokeColor(), style.getStrokeOpacity());
        }
        if (style.getFillOpacity() > 0) {
            beginFill(style.getFillColor(), style.getFillOpacity());
        }
        for (var i:Number = 1; i < points.length; i++) {
            pixel = point2Pixel(Point(points[i]));
            lineTo(pixel.getX(), pixel.getY());
        }
        if (style.getFillOpacity() > 0) {
            endFill();
        }
        
        if (type != ACTIVE) {
            moveTo(x, y);
            lineStyle(style.getStrokeWidth() * 2, 0, 0);
            for (var i:Number = 1; i < points.length; i++) {
                pixel = point2Pixel(Point(points[i]));
                lineTo(pixel.getX(), pixel.getY());
            }
        }
    }
    
}
