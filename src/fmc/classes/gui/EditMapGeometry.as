/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gismodel.*;
import gui.*;

import event.StateEventListener;
import event.StateEvent;

import geometrymodel.Geometry;
import geometrymodel.Point;
import geometrymodel.LineString;
import geometrymodel.LinearRing;
import geometrymodel.Polygon;
import geometrymodel.Circle;

import mx.controls.Label;

import event.AddRemoveEvent;
import event.GeometryListener;
import tools.Logger;

/**
 * EditMapGeometry
 */
class gui.EditMapGeometry extends GeometryPane implements GeometryListener {
	
	
    static var NORMAL:Number = 0;
    static var ACTIVE:Number = 1;
    
    private var strokeColor:Number = -1;
    private var strokeOpacity:Number = -1;
    private var strokeWidth:Number = 2;
	private var lineStringStyle:String = null;
	private var lineDashStyle:String = null;
    private var fillColor:Number = -1;
    private var fillOpacity:Number = -1;
	private var fillPatternUrl:String = null;
    
    private var _geometry:Geometry = null; // Set by init object.
    private var type:Number = -1; // Set by init object.
    private var labelText:String = null; // Set by init object.
    private var isChild:Boolean = false; // Set by init object.
	private var alwaysDrawPoints:Boolean = false; // Set by init object.
	private var labelDepth:Number = 11000;
    private var label:Label = null;
    
    private var showMeasures:Boolean = false; // Set by init object.
	private var measureUnit:String = null;// Set by init object.
	private var measureDecimals:Number = null;// Set by init object.
	private var measureMagicnumber:Number = null;// Set by init object.
	private var measureDs:String = null;// Set by init object.
	
    private var measureLabel:Label = null;
    
    /**
     * on Load
     */
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
    /**
     * remove
     */
    function remove():Void { 
		this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    /**
     * set Size
     * @param	width
     * @param	height
     */
    function setSize(width:Number, height:Number):Void {
        super.setSize(width, height);
        draw();
    }
    /**
     * on Change Geometry
     * @param	geometry
     */
    function onChangeGeometry(geometry:Geometry):Void {
		draw();
 	}
 	
	/**
	 * on Add Child
	 * @param	geometry
	 * @param	child
	 */
 	 function onAddChild(geometry:Geometry, child:Geometry):Void {
		var childGeometries:Array = geometry.getChildGeometries();
		var i:Number = childGeometries.length - 1;
		if (childGeometries.length == undefined) {
			i = 0;
		}
		var depth:Number;
		if (child instanceof Point) {
			depth = 10000 + i;
		} else if (child instanceof LineString) {
			depth = 5000 + i;
		} else if (child instanceof LinearRing) {
			depth = 4000 + i;
		} else if (child instanceof Polygon) {
			depth = 3000 + i;
		} else if (child instanceof Circle) {
			depth = 2000 + i;
		}
		else {
			depth = 1000 + i;
		}

        addEditMapGeometry(child, type, null, depth, true);
		draw();
 	}
	/**
	 * on Remove Child
	 * @param	geometry
	 * @param	child
	 */
	function onRemoveChild(geometry:Geometry,child:Geometry) : Void {
        removeEditMapGeometry(geometry, child);
		draw();	
	}
	/**
	 * set Type
	 * @param	type
	 */
    function setType(type:Number):Void {
        if (this.type == type) {
            return;
        }
        
        this.type = type;
        setTypeChildren(type);
        
        draw();
    }
    /**
     * set LabelText
     * @param	labelText
     */
    function setLabelText(labelText:String):Void {		
        if (this.labelText == labelText) {
            return;
        }
        
        this.labelText = labelText;
        
        setLabel();
    }
    /**
     * on Change Extent
     */
    function onChangeExtent():Void {
		if(this instanceof EditMapPoint){
        	EditMapPoint(this).resetPixels();
		}	
    	draw();
	}
	/**
	 * get First Ancestor
	 * @return
	 */
	function getFirstAncestor():EditMapGeometry {
        if (this.isChild == null) {
            return this;
        } else {
			if (this._parent.getFirstAncestor() instanceof EditMapGeometry) {
				return this._parent.getFirstAncestor();
			} else {
				return this;
			}
        }
    }
    
    private function draw():Void {
        clear();
        doDraw();
        setLabel();
        if(this.type == ACTIVE && showMeasures){
       		setMeasureLabel();
        } else {
        	measureLabel.text = "";
        }
		if (this.type == ACTIVE && _geometry.getFirstAncestor() == _geometry) { //surpress updating for child geometries. Saves cpu resources.
			//raise event onGeometryDrawDragUpdate via editMap through gis
			gis.geometryDragUpdate();
		}
		
    }
	
	private function reDraw():Void {
		//remove all existing editMap children of the geometry from visible layer
		var firstAncestor:Geometry = _geometry.getFirstAncestor();
		
		//brute force cleaning?
		for (_name in this) {
				if (this[_name] instanceof MovieClip) {
					this[_name].removeMovieClip();
				}
		}
		
		//add child geometries
		addChildGeometries();
		
		clear();
        doDraw();
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
    
     private function setMeasureLabel():Void {
		var isArea:Boolean = null;			
        var measureString:String = "";
		
		if (_geometry instanceof Polygon || _geometry instanceof Circle) {
			isArea = true;
		}else if (_geometry instanceof LineString && _geometry.getParent() == null) {
			isArea = false;
		}
		if (isArea!=null){
			var value:Number;
			if (isArea) {
				if (_geometry instanceof Polygon){
					value = Math.abs(Polygon(_geometry).getArea());
				} else {
					value = Math.abs(Circle(_geometry).getArea());
				}
			}else {
				value = LineString(_geometry).getLength();
			}
			//make measureString with configured values
			if (measureUnit != null || measureMagicnumber != null  || measureDecimals !=null) {
				if (measureDecimals == null) {
					measureDecimals = 2;
				}if (measureUnit == null) {
					measureUnit = "m"; 
				}if (measureMagicnumber == null) {
					measureMagicnumber = 1;
				}
				if (isArea) {
					value = value / (measureMagicnumber*measureMagicnumber);
				}else{
					value = value / measureMagicnumber;
				}
				var dec:Number = Math.pow(10, measureDecimals);
				value = Math.round(value * dec) / dec;
				
				measureString = "" + value;
				if (measureDs != null) {
					measureString = measureString.split(".").join(measureDs);
				}
				measureString +=" " + measureUnit;
				if (isArea) {
					measureString + "2"; 
				}
			//choose the measureString
			}else {
				if (isArea) {
					if (value > 1000000){
						measureString = Math.round(value/10000)/100 + " km2";
					}
					//else if (area > 10000 && area <= 10000000){
						//measureString = Math.round(area/100)/100 + " ha";	
					//} 
					else {
						measureString = Math.round(value) + " m2";
					}
				}else {
					if (value > 1000){
						measureString = Math.round(value/10)/100 + " km";
					} else {
						measureString = Math.round(value) + " m";
					}
				}
			}
		}
		measureLabel.text = "";
  		if(measureString != ""  ){
  			if (measureLabel == null) {
            	measureLabel = Label(attachMovie("Label", "mLabel2", 12000, {autoSize: "center", html: true}));
        	}
  			measureLabel.text = measureString;
			var pixel:Pixel = point2Pixel(_geometry.getCenterPoint());
			measureLabel._x = pixel.getX() - (measureLabel.width / 2);
        	measureLabel._y = pixel.getY() - 15;
  		}

    }
    
    private function addChildGeometries():Void {
        var childGeometries:Array = _geometry.getChildGeometries();
		if (childGeometries.length >0) {
			for (var i:Number = 0; i < childGeometries.length; i++) {
				
				var depth:Number;
				var geometry:Geometry = Geometry(childGeometries[i]);
				if (geometry instanceof Point) {
					depth = 10000 + i;
				} else if (geometry instanceof LineString) {
					depth = 5000 + i;
				} else if (geometry instanceof LinearRing) {
					depth = 4000 + i;
				} else if (geometry instanceof Polygon) {
					depth = 3000 + i;
				} else if (geometry instanceof Circle) {
					depth = 2000 + i;
				}
				
				addEditMapGeometry(Geometry(childGeometries[i]), type, null, depth, true);
			}
		}
    }
    

    private function point2Pixel(_point:geometrymodel.Point):Pixel {
	        var extent:Object = map.getCurrentExtent();
	        var minX:Number = extent.minx;
	        var minY:Number = extent.miny;
	        var maxX:Number = extent.maxx;
	        var maxY:Number = extent.maxy;
	        
	        var pixelX:Number = width * (_point.getX() - minX) / (maxX - minX);
	        var pixelY:Number = height * (maxY - _point.getY()) / (maxY - minY);
	        return new Pixel(pixelX, pixelY);
    }
    
}
