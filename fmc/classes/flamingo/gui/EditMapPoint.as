/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

import flamingo.geometrymodel.Point;

class flamingo.gui.EditMapPoint extends EditMapGeometry {
    private var pixel:Pixel = null;
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
      	super.onLoad();        
    }
    
   function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function resetPixels():Void{
    	var point:Point = Point(_geometry);
        pixel=point2Pixel(point);
    }
    
    function doDraw():Void {
    	if(pixel==null){
    		resetPixels();
    	} 	
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
        clear();
        moveTo(x, y);
        if (type == ACTIVE) {
        	if(isChild){
            	lineStyle(strokeWidth * 4, strokeColor, strokeOpacity);
        	} else {
        		lineStyle(strokeWidth * 5, strokeColor, strokeOpacity);
        	}	
        } else {
        	if(isChild){
        		lineStyle(0,0,0);
        	} else {	
            	lineStyle(strokeWidth * 3, strokeColor, strokeOpacity);
        	}
        }
        lineTo(x + 0.15, y + 0.45);
    }
    
    private function addChildGeometries():Void {
    	//do nothing for point
    }
    
}
