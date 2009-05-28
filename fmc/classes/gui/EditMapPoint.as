/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import gui.*;

import geometrymodel.Geometry;
import geometrymodel.Point;
import geometrymodel.Polygon;
import geometrymodel.LineString;

class gui.EditMapPoint extends EditMapGeometry {
    private var m_pixel:Pixel = null;
	private var mPointGraphic:MovieClip = null;
	private var pointNr:Number = -1;
    
    function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
      	super.onLoad();        
    }
    
   function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function resetPixels():Void{
    	var point:Point = Point(_geometry);
        m_pixel=point2Pixel(point);
    }
    
    private function addChildGeometries():Void {
    	//do nothing for point
    }
	
	function doDrawClean():Void {
		if (mPointGraphic != null) {
			with (this.mPointGraphic) {
				_x = 0;
				_y = 0;
				clear();
			}
		}
	}
	
	
	
	function doDraw():Void {
		if (editMapEditable) {
			doDrawEditable();
		}
		else {
			if(m_pixel==null){
				resetPixels();
			} 	
			var x:Number = m_pixel.getX();
			var y:Number = m_pixel.getY();
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
	}
    
    private function doDrawEditable():Void {
        var point:Point = Point(_geometry);
        var pixel:Pixel = point2Pixel(point);
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
		var thisObj:Object = this;
		
		_x = x;
		_y = y;
		this.pointNr = Number(thisObj.getDepth()) - 10000;	
		
		//clear current graphic
		this.clear();
		
		//Depth of mPointGraphic
		//We want our graphical points on top of other graphics like mEditMapLineGraphic. But because the
		//geometry draw mechanism first draws point than linestrings, polygons, etc. the getNextHighestDepth 
		//will not suffice. The depth swapping is done at the linestring (and higher) level.
		
		if (mPointGraphic == null) {
			//trace("EditMapPoint.as: mPointGraphic == null, new mPointGraphic will be created");
			//mPointGraphic = createEmptyMovieClip("mPointGraphic", this.getNextHighestDepth() );
			mPointGraphic = createEmptyMovieClip("mPointGraphic", 1);

		}
		
		if (type == ACTIVE) {	
			with (mPointGraphic) {
				_x = 0;
				_y = 0;
				
				clear();
				moveTo(0, 0);
				//lineStyle(thisObj.style.getStrokeWidth() * 4, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				lineTo(0.15, 0.45);
				
				moveTo(0, 0);
				lineStyle(thisObj.style.getStrokeWidth() * 4, 0, 0);
				lineTo(0.15, 0.45);
				
			}
			
			mPointGraphic.cacheAsBitmap = true;
			
			//assign rollover, rollout, pressed and released listeners.
			enablePseudoButtonEvents(mPointGraphic);
					
			//assign pseudo button event handlers
			mPointGraphic.onPressHandler = function(){
				// onPress
				if (!thisObj.gis.getEditRemoveVertex()) {
					if (thisObj.type == ACTIVE){
						this.startDrag(false);
					}
				}
				else {
					//User requested to delete this point.
					//1. if geometry's first ancestor is a point, do not delete the point.
					//2. if geometry's first ancestor is a linestring:
					//		- delete the point if the nr of points >= 3. Otherwise do not delete the point.
					//3. if geometry's first ancestor is a polygon. Delete the point if:
					// 		- the nr of points >= 5. Remember that a polygon has a closed linestring ring so one point extra
					// 		- after deletion the polygon does not selfintersect. FOR NOW WE SKIP THIS TEST
					
					var geom:Geometry = thisObj._geometry.getFirstAncestor();
					if (geom instanceof Point) {
						//do nothing
					}
					else if (geom instanceof LineString) {
						if (geom.getPoints().length >= 3) {
							//delete the point
							thisObj._geometry.getParent().removePoint(Point(thisObj._geometry));
							
							//redraw geometry
							thisObj._parent.draw();
						}
					}
					else if (geom instanceof Polygon) {
						if (geom.getPoints().length >= 5) {
							//delete the point
							thisObj._geometry.getParent().removePoint(Point(thisObj._geometry));
							
							//redraw geometry, especially the fill of the polygon
							thisObj._parent._parent.draw();
							thisObj._parent.draw();
							
						}
					}
					//remove this editMapPoint and it's graphic !!!
					if (mPointGraphic != null) {
						with (this.mPointGraphic) {
							_x = 0;
							_y = 0;
							clear();
						}
					}
					mPointGraphic = null;
				}
			}
			
			mPointGraphic.onReleaseHandler = function(){
				// onRelease
				if (!thisObj.gis.getEditRemoveVertex()) {
					this.stopDrag();
					
					var intersectionTestResult:Boolean = false;
					
					if (thisObj._geometry.getFirstAncestor() instanceof Polygon) {
						
						var pixel:Pixel = new Pixel(this._x + this._parent._x, this._y + this._parent._y);
						var testPoint:Point = _parent.pixel2Point(pixel);
						intersectionTestResult = thisObj._parent.selfIntersectionTestDragPoint(thisObj.pointNr, testPoint);
					}
					if (intersectionTestResult) {
						//animate point back to original location
						var pixel:Pixel = new Pixel(this._parent._x, this._parent._y);
						var p:Point = _parent.pixel2Point(pixel);
						this._x = 0;
						this._y = 0;
						thisObj._geometry.setXY(p.getX(),p.getY());
						if (thisObj._geometry.getFirstAncestor() instanceof Polygon) {
							//redraw geometry, especially the fill of the polygon
							thisObj._parent._parent.draw();
							thisObj._parent.draw();
						}
					}
					else {
						var pixel:Pixel = new Pixel(this._x + this._parent._x, this._y + this._parent._y);
						var tmpPointX:Number=  _parent.pixel2Point(pixel).getX();
						var p:Point = _parent.pixel2Point(pixel);
						thisObj._geometry.setXY(p.getX(),p.getY());
						
						//update x,y of parent editMappoint
						this._parent._x += this._x;
						this._parent._y += this._y;
						this._x = 0;
						this._y = 0;
						
						if (thisObj._geometry.getFirstAncestor() instanceof Polygon) {
							//redraw geometry, especially the fill of the polygon
							thisObj._parent._parent.draw();
							thisObj._parent.draw();
						}
						else if (thisObj._geometry.getFirstAncestor() instanceof LineString) {
							//redraw geometry
							thisObj._parent.draw();
						}
						
					}
				}
			}
			
			mPointGraphic.onReleaseOutsideHandler = function(){
				// onReleaseOutside
				this.onReleaseHandler();
			}
			mPointGraphic.onRollOverHandler = function(){
				// onRollOver
				this.clear();
				this.moveTo(0,0);
				//this.lineStyle(thisObj.style.getStrokeWidth() * 4, 0xFF0000, thisObj.style.getStrokeOpacity());
				this.lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF0000, thisObj.style.getStrokeOpacity());
				this.lineTo(0.45, 0.45);
				
			}
			mPointGraphic.onRollOutHandler = function(){
				// onRollOut
				this.clear();
				this.moveTo(0,0);
				//this.lineStyle(thisObj.style.getStrokeWidth() * 4, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				this.lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				this.lineTo(0.45, 0.45);
			}
			
			mPointGraphic.onDragOutHandler = function(){
				// onDragOut
			}
			mPointGraphic.onDragOverHandler = function(){
				// onDragOver
			}
			
			
			mPointGraphic.onDragHandler = function(){
				// onDrag
				if (thisObj._geometry.getParent() instanceof LineString) {	
					var pixel:Pixel = new Pixel(this._x + this._parent._x, this._y + this._parent._y);
					var p:Point = _parent.pixel2Point(pixel);
					thisObj._parent.doDrawPointDrag(thisObj.pointNr, pixel);
				}
			}
			
		}
		else { //point is not active
			with (this.mPointGraphic) {
				_x = 0;
				_y = 0;

				clear();
				lineStyle(6, 0x0000ff, 50);
				moveTo(0, 0);
				lineTo(0+0.45,0+0.45);
			}
			disablePseudoButtonEvents(mPointGraphic);
		}
    }
	
	private function addChildGeometries():Void {
    	//do nothing for point
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
	
	function enablePseudoButtonEvents(target){
		target.isPressed = false; // flag
		target.isMouseOver = false; // flag
		
		target.onMouseDown = function(){
			if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
				this.isPressed = true;
				// onPress
				this.onPressHandler();
			}else{
				this.isPressed = false;
			}
		}
		
		target.onMouseUp = function(){
			if (this.isPressed){
				if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
					// onRelease
					this.onReleaseHandler();
				}else{
					// onReleaseOutside
					this.onReleaseOutsideHandler();
				}
			}
			this.isPressed = false;
		}
		
		target.onMouseMove = function(){
			var lastIsOver = this.isMouseOver;
			if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
				this.isMouseOver = true;
				if (this.isMouseOver != lastIsOver){
					if (this.isPressed){
						// onDragOver
						this.onDragHandler();
						//this.onDragOverHandler();
					}else{
						// onRollOver
						this.onRollOverHandler();
					}
				}
			}else{
				this.isMouseOver = false;
				if (this.isMouseOver != lastIsOver){
					if (this.isPressed){
						// onDragOut
						//this.onDragOutHandler();
						this.onDragHandler();
					}else{
						// onRollOut
						this.onRollOutHandler();
					}
				}
			}
		}
	
	}
	
	function disablePseudoButtonEvents(target){
				
		target.onMouseDown = function(){
			
		}
		
		target.onMouseUp = function(){
			
		}
		
		target.onMouseMove = function(){
			
		}
	
	}
	
	
    
}
