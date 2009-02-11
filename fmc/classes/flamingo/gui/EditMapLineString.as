// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import flamingo.geometrymodel.Envelope;
import flamingo.geometrymodel.LineString;
import flamingo.geometrymodel.Point;

class flamingo.gui.EditMapLineString extends EditMapGeometry {
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
		super.setSize(width, height);
    }
    
    function doDraw():Void {
		
        //var lineString:LineString = LineString(LineString(_geometry).clip(new Envelope(115000, 440000, 170000, 478000)));
        var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
        var pixel:Pixel = point2Pixel(Point(points[0]));
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
            lineStyle(style.getStrokeWidth() * 2, style.getStrokeColor(), style.getStrokeOpacity());
        } else {
            lineStyle(style.getStrokeWidth(), style.getStrokeColor(), style.getStrokeOpacity());
        }
        for (var i:Number = 1; i < points.length; i++) {
            pixel = point2Pixel(Point(points[i]));
            lineTo(pixel.getX(), pixel.getY());
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
