// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import flamingo.geometrymodel.Point;

class flamingo.gui.EditMapPoint extends EditMapGeometry {
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function doDraw():Void {
        var point:Point = Point(_geometry);
        var pixel:Pixel = point2Pixel(point);
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
            lineStyle(style.getStrokeWidth() * 4, style.getStrokeColor(), style.getStrokeOpacity());
        } else {
            lineStyle(style.getStrokeWidth() * 2, style.getStrokeColor(), style.getStrokeOpacity());
        }
        lineTo(x + 0.15, y + 0.45);
        
        if (type != ACTIVE) {
            moveTo(x, y);
            lineStyle(style.getStrokeWidth() * 4, 0, 0);
            lineTo(x + 0.15, y + 0.45);
        }
    }
    
}
