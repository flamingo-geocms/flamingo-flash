/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

import flamingo.event.StateEventListener;
import flamingo.event.StateEvent;

import flamingo.geometrymodel.Geometry;

import mx.controls.Label;

class flamingo.gui.EditMapGeometry extends GeometryPane implements StateEventListener {
    
    static var NORMAL:Number = 0;
    static var ACTIVE:Number = 1;
    
    private var _geometry:Geometry = null; // Set by init object.
    private var type:Number = -1; // Set by init object.
    private var labelText:String = null; // Set by init object.
    private var labelDepth:Number = 1000;
    private var label:Label = null;
    
    function onLoad():Void {
        super.onLoad();

        _global.flamingo.addListener(this,map,this);
		_geometry.addEventListener(this, "Geometry", StateEvent.CHANGE, null);
        _geometry.addEventListener(this, "Geometry", StateEvent.ADD_REMOVE, "childGeometries");
        
        draw();
        if (type == ACTIVE) {
            addChildGeometries();
        }
    }
    
    function remove():Void { // This method is an alternative to the default MovieClip.removeMovieClip. Also unsubscribes as event listener. The event method MovieClip.onUnload cannot be used, because it works buggy.
        _geometry.removeEventListener(this, "Geometry", StateEvent.CHANGE, null);
        _geometry.removeEventListener(this, "Geometry", StateEvent.ADD_REMOVE, "childGeometries");
        
        removeEditMapGeometries();
        this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    
    function setSize(width:Number, height:Number):Void {
        super.setSize(width, height);
        
        draw();
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
		if (sourceClassName + "_" + actionType + "_" + propertyName == "Geometry_" + StateEvent.CHANGE + "_null") {
			draw();
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Geometry_" + StateEvent.ADD_REMOVE + "_childGeometries") {
            draw();
            if (stateEvent.getSource() == _geometry) {
                removeEditMapGeometries();
                addChildGeometries();
            }
        }
    }
    
	function onChangeExtent():Void {
		draw();
	}
	
    function setType(type:Number):Void {
        if (this.type == type) {
            return;
        }
        
        this.type = type;
        
        draw();
        if (type == ACTIVE) {
            addChildGeometries();
        } else {
            removeEditMapGeometries();
        }
    }
    
    function setLabelText(labelText:String):Void {
        if (this.labelText == labelText) {
            return;
        }
        
        this.labelText = labelText;
        
        setLabel();
    }
    
    private function draw():Void {
        clear();
        var envelope:flamingo.geometrymodel.Envelope = _geometry.getEnvelope();
        var geometryMinPixel:Pixel = point2Pixel(new flamingo.geometrymodel.Point(envelope.getMinX(), envelope.getMaxY())); // The min and max y values are reversed because
        var geometryMaxPixel:Pixel = point2Pixel(new flamingo.geometrymodel.Point(envelope.getMaxX(), envelope.getMinY())); // a point max is a pixel min and vice versa.
        
        if ((geometryMinPixel.getX() >= width) || (geometryMinPixel.getY() >= height)
                                               || (geometryMaxPixel.getX() < 0) || (geometryMaxPixel.getY() < 0)) {
            setLabel();
			// Geometry falls off the map; needs no drawing. This is a non-exceptional precondition.
            return;
        }
        
        localToGlobal(geometryMinPixel);
        localToGlobal(geometryMaxPixel);
        var centerPixel:Pixel = new Pixel(Stage.width / 2, Stage.height / 2);
        
        // An attempt to draw on a distance greater than 5760 pixels from the middle of the stage may result in pollution of the stage.
        if ((geometryMinPixel.getX() <= centerPixel.getX() - 5760) || (geometryMinPixel.getY() <= centerPixel.getY() - 5760)
                              || (geometryMaxPixel.getX() >= centerPixel.getX() + 5760) || (geometryMaxPixel.getY() >= centerPixel.getY() + 5760)) {
            trace("Exception in flamingo.gui.Geometry.draw()");
            return;
        }
        
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
        
        
		var envelope:flamingo.geometrymodel.Envelope = _geometry.getEnvelope();
	    var geometryMinPixel:Pixel = point2Pixel(new flamingo.geometrymodel.Point(envelope.getMinX(), envelope.getMaxY())); // The min and max y values are reversed because
        var geometryMaxPixel:Pixel = point2Pixel(new flamingo.geometrymodel.Point(envelope.getMaxX(), envelope.getMinY())); // a point max is a pixel min and vice versa.
        
        if ((geometryMinPixel.getX() >= width) || (geometryMinPixel.getY() >= height)
                                               || (geometryMaxPixel.getX() < 0) || (geometryMaxPixel.getY() < 0)) {
			label.removeMovieClip();
			label= null;
			return;
		}
		var pixel:Pixel = point2Pixel(_geometry.getCenterPoint());
		label._x = pixel.getX() - (label.width / 2);
        label._y = pixel.getY();

    }
    
    private function addChildGeometries():Void {
        var childGeometries:Array = _geometry.getChildGeometries();
        for (var i:Number = 0; i < childGeometries.length; i++) {
            addEditMapGeometry(Geometry(childGeometries[i]), type, null, i);
        }
    }
    
    private function point2Pixel(_point:flamingo.geometrymodel.Point):Pixel {
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
