/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

import gismodel.CreateGeometry;
import gismodel.Feature;
import gismodel.Style;
import geometrymodel.Geometry;


import geometrymodel.Polygon;
import geometrymodel.LineString;
import geometrymodel.Point;
import geometrymodel.PointFactory;
import tools.Logger;

import gismodel.Layer;

class gui.EditMapCreateGeometry extends MovieClip {
    
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var gis:gismodel.GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var createGeometry:CreateGeometry = null; // Set by init object.
	private var style=null;
    
    private var numMouseDowns:Number = 0;
    private var intervalID:Number = null;
    private var geometry:Geometry = null;
    private var deltaTime:Number = 0;
    private var pressTime:Number = 0;
    private var previousPressTime:Number = 0;
	private var movePoint:Point = null;
    
    function onLoad():Void {
        draw();
    }
    
    function remove():Void {
        this.removeMovieClip();
    }
    
    function setSize(width:Number, height:Number):Void {
        this.width = width;
        this.height = height;
        
        draw();
    }
    
    private function draw():Void {
        clear();		
        moveTo(0, 0);
		if (style!=null){
			lineStyle(style.getStrokeWidth(),style.getStrokeColor(),style.getStrokeOpacity());
			beginFill(style.getFillColor(), style.getFillOpacity());
		}else{
			lineStyle(0, 0x000000, 100);
	        beginFill(0xDDAA50, 30);
		}
        lineTo(width, 0);
        lineTo(width, height);
        lineTo(0, height);
        endFill();
    }
    
	
    function onPress():Void {

    	var double:Boolean = false;	
    	if (previousPressTime==0){
    		previousPressTime = getTimer();
    		//first click
    	} else { 	 
    		pressTime = getTimer();
    		deltaTime =  pressTime - previousPressTime;
    		if(deltaTime<300){
    			double = true;
    		} else {
    			double = false;
    		}
    		previousPressTime = getTimer();
    	}        
        if (double) {
			if (geometry instanceof Polygon){
				Polygon(geometry).getExteriorRing().removePoint( Polygon(geometry).getEndPoint() );
			} else if (geometry instanceof LineString){
				LineString(geometry).removePoint(LineString(geometry).getEndPoint());
			}
			
			if (geometry instanceof LineString && gis.getCreatePointAtDistance()) {	
				//store path length for event
				var pathLength:Number = LineString(geometry).getLength();
				
				//remove the linestring
				createGeometry.getLayer().removeFeature(gis.getActiveFeature(), true);

				//create point geometry & add it as a feature to the layer
				var layer:Layer = createGeometry.getLayer();
				gis.setCreateGeometry(new CreateGeometry(layer, new PointFactory()));
				
				var point:geometrymodel.Point = pixel2Point(new Pixel(_xmouse, _ymouse));
				geometry = createGeometry.getGeometryFactory().createGeometry(point);
				createGeometry.getLayer().addFeature(geometry, true);				
				
				//raise event onCreatePointAtDistanceFinished
				//API event onCreatePointAtDistanceFinished();
				_global.flamingo.raiseEvent(this._parent._parent,"onCreatePointAtDistanceFinished",this._parent._parent,gis.getActiveFeature().getGeometry().toWKT(),pathLength);
			}
			
			//API event onGeometryDrawFinished();
			_global.flamingo.raiseEvent(this._parent,"onGeometryDrawFinished",this._parent,gis.getActiveFeature().getGeometry().toWKT());			
			gis.setCreateGeometry(null);
        } else {	
			var pixel:Pixel = new Pixel(_xmouse, _ymouse);
            var point:geometrymodel.Point = pixel2Point(pixel);
            if (geometry == null) {
                geometry = createGeometry.getGeometryFactory().createGeometry(point);
                geometry.setEventComp(gis);
                createGeometry.getLayer().addFeature(geometry);
                if (geometry instanceof geometrymodel.Point) {
					//API event onGeometryDrawFinished();
					_global.flamingo.raiseEvent(this._parent,"onGeometryDrawFinished",this._parent,gis.getActiveFeature().getGeometry().toWKT());
                    gis.setCreateGeometry(null);
                }
            } else {
                geometry.addPoint(point);
            }
			//raise event onGeometryDrawUpdate via editMap through gis
			gis.geometryUpdate();
        }
    }
    
    function onMouseMove():Void {
 		if (geometry != null) {
		   	var pixel = new Pixel(_xmouse, _ymouse);
        	var mousePoint:Point = pixel2Point(pixel);
        	geometry.setXYEndPoint(mousePoint , pixel);
			pixel = null;
			mousePoint = null;
			delete pixel;
			// remove the geometrylisteneer of the mousePoint?!
			delete mousePoint;
        }
    }
    
    
    private function pixel2Point(pixel:Pixel):geometrymodel.Point {
    	
        var extent:Object = map.getCurrentExtent();
		var minX:Number = extent.minx;
        var minY:Number = extent.miny;
        var maxX:Number = extent.maxx;
        var maxY:Number = extent.maxy;
        var pointX:Number = pixel.getX() * (maxX - minX) / width + minX;
        var pointY:Number = -pixel.getY() * (maxY - minY) / height + maxY;
        
        return new geometrymodel.Point(pointX, pointY);
    }
    
}
