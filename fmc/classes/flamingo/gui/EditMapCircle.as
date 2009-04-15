/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import flamingo.gui.*;

import flamingo.geometrymodel.Circle;
import flamingo.geometrymodel.Envelope;
import flamingo.geometrymodel.Point;

import mx.controls.Label;

class flamingo.gui.EditMapCircle extends EditMapGeometry {
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
	}
	


	function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function doDraw():Void {
    	
        var circle:Circle = Circle(_geometry);
       	var centrePixel:Pixel = point2Pixel(circle.getCenterPoint());
        var circlePixel:Pixel = point2Pixel(circle.getEndPoint());
        
        var radiusText:Label = null; 

        var x:Number = centrePixel.getX();
        var y:Number = centrePixel.getY();
        var circleX:Number = circlePixel.getX();
        var circleY:Number = circlePixel.getY();
        var dx:Number = circleX - x;
        var dy:Number = circleY - y;
        var r:Number = Math.sqrt((dx * dx) + (dy * dy));
        var p4r:Number = Math.sin(Math.PI/4) * r;
        var p8r:Number = Math.tan(Math.PI/8) * r;
        
        clear();
        
        if(radiusText==null){
        	radiusText= Label(this.attachMovie("Label", "mLabel", 1));
        }
        radiusText.move(x-20,y - 20);
        radiusText.text = Math.round(circle.getRadius()).toString() +  " m";

        	
        moveTo(x, y - r);
        if (type == ACTIVE) {
            lineStyle(strokeWidth * 2, strokeColor, strokeOpacity);
            radiusText.visible = true;
        } else {
            lineStyle(strokeWidth, strokeColor, strokeOpacity);
            radiusText.visible = false;
        }
        if (style.getFillOpacity() > 0) {
            beginFill(fillColor, fillOpacity);
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
            lineStyle(strokeWidth, strokeColor, strokeOpacity);
            lineTo(circleX, circleY);            
        } 

        if (fillOpacity > 0) {
            endFill();
        }
    }
    
}
