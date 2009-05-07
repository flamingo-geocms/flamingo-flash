/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

import geometrymodel.Envelope;
import geometrymodel.LineString;
import geometrymodel.Point;

class gui.EditMapLineString extends EditMapGeometry {
    
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
		super.setSize(width, height);
    }
    
    function doDraw():Void {
        var lineString:LineString = LineString(_geometry);
        var points:Array = lineString.getPoints();
        var pixel:Pixel = point2Pixel(points[0]);
        
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
        	if(isChild){
            	lineStyle(strokeWidth * 2, strokeColor, strokeOpacity);
        	} else {
        		lineStyle(strokeWidth * 2, strokeColor, strokeOpacity);
        	}
        } else {
        	if(isChild){
        		lineStyle(0, 0, 0);
        	} else {	
            	lineStyle(strokeWidth, strokeColor, strokeOpacity);
        	}	
        }
        for (var i:Number = 1; i < points.length; i++) {
            pixel = point2Pixel(points[i]);
            lineTo(pixel.getX(), pixel.getY());
        }
    }
    
}
