/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

import event.StateEventListener;
import event.StateEvent;

import geometrymodel.Geometry;

import mx.controls.Label;

import event.AddRemoveEvent;
import event.GeometryListener;

class gui.EditMapGeometry extends GeometryPane implements GeometryListener {
	
	
    static var NORMAL:Number = 0;
    static var ACTIVE:Number = 1;
    
    private var strokeColor:Number = -1;
    private var strokeOpacity:Number = -1;
    private var strokeWidth:Number = 2;
    private var fillColor:Number = -1;
    private var fillOpacity:Number = -1
    
    private var _geometry:Geometry = null; // Set by init object.
    private var type:Number = -1; // Set by init object.
    private var labelText:String = null; // Set by init object.
    private var isChild:Boolean = false; // Set by init object.
    private var labelDepth:Number = 1000;
    private var label:Label = null;
    
    function onLoad():Void {
        super.onLoad();
        _geometry.addGeometryListener(this);
    	strokeOpacity = style.getStrokeColor();
    	strokeWidth = style.getStrokeWidth();
    	strokeColor= style.getStrokeColor();
		fillColor = style.getFillColor();
		fillOpacity = style.getFillOpacity();
        _global.flamingo.addListener(this,map,this);
        addChildGeometries();
        draw();
    }
    
   function remove():Void { 
        this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    
    function setSize(width:Number, height:Number):Void {
        super.setSize(width, height);
        draw();
    }
    
    function onChangeGeometry(geometry:Geometry):Void {
    	draw();
 	}
 	
 	 function onAddChild(geometry:Geometry,child:Geometry):Void {
        addEditMapGeometry(child, type, null, this.getNextHighestDepth(),true);
		draw();
 	}
	
    function setType(type:Number):Void {
        if (this.type == type) {
            return;
        }
        
        this.type = type;
        setTypeChildren(type);
        
        draw();
    }
    
    function setLabelText(labelText:String):Void {
        if (this.labelText == labelText) {
            return;
        }
        
        this.labelText = labelText;
        
        setLabel();
    }
    
    function onChangeExtent():Void {
		if(this instanceof EditMapPoint){
        	EditMapPoint(this).resetPixels();
		}	
    	draw();
	}
    
    private function draw():Void {
        clear();
         doDraw();
        setLabel();
    }
    
    private function doDraw():Void { }
    
    private function setLabel():Void {
        if (labelText == null) {
            if (label != null) {
                label.removeMovieClip();
                label = null;
            }
            return;
        }

        if (label == null) {
            label = Label(attachMovie("Label", "mLabel", labelDepth, {autoSize: "center"}));
        }
        
        if (type == ACTIVE) {
            label.setStyle("fontWeight", "bold");
        } else {
            label.setStyle("fontWeight", "none");
        }
        label.text = labelText;
        
		var pixel:Pixel = point2Pixel(_geometry.getCenterPoint());
		label._x = pixel.getX() - (label.width / 2);
        label._y = pixel.getY();

    }
    
    private function addChildGeometries():Void {
        var childGeometries:Array = _geometry.getChildGeometries();
        for (var i:Number = 0; i < childGeometries.length; i++) {
            addEditMapGeometry(Geometry(childGeometries[i]), type, null, i, true);
        }
    }
    

    private function point2Pixel(_point:geometrymodel.Point):Pixel {
	        var extent:Object = map.getMapExtent();
	        
			var minX:Number = extent.minx;
	        var minY:Number = extent.miny;
	        var maxX:Number = extent.maxx;
	        var maxY:Number = extent.maxy;
	        
	        var pixelX:Number = width * (_point.getX() - minX) / (maxX - minX);
	        var pixelY:Number = height * (maxY - _point.getY()) / (maxY - minY);
	        return new Pixel(pixelX, pixelY);
    }
    
}
