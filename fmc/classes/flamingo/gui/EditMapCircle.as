// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import flamingo.geometrymodel.Circle;
import flamingo.geometrymodel.Envelope;
import flamingo.geometrymodel.Point;

class flamingo.gui.EditMapCircle extends EditMapGeometry {
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function doDraw():Void {
        var circle:Circle = Circle(_geometry);
        var pixel:Pixel = point2Pixel(circle.getCenterPoint());
        var circlePixel:Pixel = point2Pixel(circle.getEndPoint());
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        var circleX:Number = circlePixel.getX();
        var circleY:Number = circlePixel.getY();
        var dx:Number = circleX - x;
        var dy:Number = circleY - y;
        var r:Number = Math.sqrt((dx * dx) + (dy * dy));
        var p4r:Number = Math.sin(Math.PI/4) * r;
        var p8r:Number = Math.tan(Math.PI/8) * r;
        
        clear();
        moveTo(x, y - r);
        if (type == ACTIVE) {
            lineStyle(style.getStrokeWidth() * 2, style.getStrokeColor(), style.getStrokeOpacity());
        } else {
            lineStyle(style.getStrokeWidth(), style.getStrokeColor(), style.getStrokeOpacity());
        }
        curveTo(x + p8r, y - r, x + p4r, y - p4r);
        curveTo(x + r, y - p8r, x + r, y);
        curveTo(x + r, y + p8r, x + p4r, y + p4r);
        curveTo(x + p8r, y + r, x, y + r);
        curveTo(x - p8r, y + r, x - p4r, y + p4r);
        curveTo(x - r, y + p8r, x - r, y);
        curveTo(x - r, y - p8r, x - p4r,y - p4r);
        curveTo(x - p8r, y - r, x, y - r);
        
        if (type == ACTIVE) {
            moveTo(x, y);
            lineStyle(style.getStrokeWidth(), style.getStrokeColor(), style.getStrokeOpacity());
            lineTo(circleX, circleY);
        } else {
            moveTo(x, y - r);
            lineStyle(style.getStrokeWidth() * 2, 0, 0);
            curveTo(x + p8r, y - r, x + p4r, y - p4r);
            curveTo(x + r, y - p8r, x + r, y);
            curveTo(x + r, y + p8r, x + p4r, y + p4r);
            curveTo(x + p8r, y + r, x, y + r);
            curveTo(x - p8r, y + r, x - p4r, y + p4r);
            curveTo(x - r, y + p8r, x - r, y);
            curveTo(x - r, y - p8r, x - p4r,y - p4r);
            curveTo(x - p8r, y - r, x, y - r);
        }
    }
    
}
