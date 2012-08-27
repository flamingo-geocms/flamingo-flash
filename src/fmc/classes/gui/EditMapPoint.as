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
import geometrymodel.MultiPolygon;
import geometrymodel.LineString;

import gismodel.Feature;
import gismodel.Layer;
import gismodel.GeometryProperty;
import tools.Logger;
import mx.controls.Label;

/**
 * EditMapPoint
 */
class gui.EditMapPoint extends EditMapGeometry {
    private var m_pixel:Pixel = null;
	private var mPointGraphic:MovieClip = null;
	private var mIconTilePic:MovieClip = null;
	private var mPointText:TextField = null;
	private var drawPointTextCross:Boolean = false;
	private var mPointTextCross:MovieClip = null;
	private var pointNr:Number = -1;
	
	private var pointColor:Number = -1;
	private var pointOpacity:Number = -1;
	private var pointIconUrl:String = null;
	private var pointText:String = null;
	
	public var log:Logger=null;
	/**
	 * This method is a stub. It is necessary though, because of the "super" bug in Flash.
	 */    
    function onLoad():Void { 
      	super.onLoad();    
		this.log = new Logger("gui.EditMapPoint",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
    }
    /**
     * set Size
     * @param	width
     * @param	height
     */
   function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    /**
     * reset Pixels
     */
    function resetPixels():Void{
    	var point:Point = Point(_geometry);
        m_pixel=point2Pixel(point);
    }
    
    private function addChildGeometries():Void {
    	//do nothing for point
    }
	/**
	 * do Draw Clean
	 */
	function doDrawClean():Void {
		if (mPointGraphic != null) {
			with (this.mPointGraphic) {
				_x = 0;
				_y = 0;
				clear();
			}
		}
	}
	
	private function getFlashValue(feature:Feature, layer:Layer, propType:String):String {
		var geometryProperty:GeometryProperty = layer.getPropertyWithType(propType);
		var val:String = feature.getValueWithPropType(propType);
		
		var flashValue:String = geometryProperty.getFlashValue(val);
		//trace("EditMapPoint.as getFlashValue() geometryProperty.getPropertyType() = "+geometryProperty.getPropertyType());
		//trace("EditMapPoint.as getFlashValue() propType = "+propType+"  geometryProperty = "+geometryProperty+"  val = "+val+"   flashValue = "+flashValue);
		
		return flashValue;
		//return geometryProperty.getFlashValue(val);
	}
	/**
	 * do Draw
	 */
	function doDraw():Void {
		if (editable) {
			//*** strokeColor, strokeOpacity and fillColor are set by:
			// 1. the initial value in the code in gui.EditMapGeometry.as These are values like -1, 2, etc.
			// 2. (overwritten by) the corresponding <style attribute=".." in the xml config
			// 3. (overwritten by) the corresponding GeometryProperty attribute <fmc:GeometryProperty name="fillopacity" etc.
			// 
			// pointColor and pointOpacity refer to the disc shape graphical presentation of a point. The are set by the strokeColor and strokeOpacity.
			// strokeColor and strokeOpacity are used as rendering colors for the point text and for other geometries like lines in linestrings, circle, polygons, etc.
			
			
			var feature:Feature = this.getFirstAncestor()._parent.getFeature();
			var layer:Layer = feature.getLayer();
			var flashValue:String;
			
			flashValue = getFlashValue(feature, layer, "strokecolor");
			if (flashValue != null){
				strokeColor = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "strokeopacity");
			if (flashValue != null){
				strokeOpacity = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "fillcolor");
			if (flashValue != null){
				fillColor = Number(flashValue);
			}
			
			pointColor = strokeColor;
			pointOpacity = strokeOpacity;
			flashValue = getFlashValue(feature, layer, "pointcolor");
			if (flashValue != null){
				pointColor = Number(flashValue);
			}
			flashValue = getFlashValue(feature, layer, "pointopacity");
			if (flashValue != null){
				pointOpacity = Number(flashValue);
			}
			
			if(!isChild) {
				pointIconUrl = getFlashValue(feature, layer, "pointicon");	//allow null value
				pointText = getFlashValue(feature, layer, "pointtext");	//allow null value
			} else {		//ensure that for linestring, polygon, circle no icon or text is drawn.
				pointIconUrl = "";
				pointText = "";
			}
			
			/* //debug traces
			trace("EditMapPoint.as doDraw() feature = "+feature);
			trace("EditMapPoint.as doDraw() pointcolor value = "+feature.getValueWithPropType("pointcolor"));
			trace("EditMapPoint.as doDraw() pointopacity value = "+feature.getValueWithPropType("pointopacity"));
			trace("EditMapPoint.as doDraw() strokecolor value = "+feature.getValueWithPropType("strokecolor"));
			trace("EditMapPoint.as doDraw() strokeopacity value = "+feature.getValueWithPropType("strokeopacity"));
			trace("EditMapPoint.as doDraw() fillcolor value = "+feature.getValueWithPropType("fillcolor"));
			trace("EditMapPoint.as doDraw() pointicon value = "+feature.getValueWithPropType("pointicon"));
			trace("EditMapPoint.as doDraw() pointtext value = "+feature.getValueWithPropType("pointtext"));
			*/
			
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
			//label._x -=(label.width / 2);
        }
        if (type == ACTIVE) {
            label.setStyle("fontWeight", "bold");
        } else {
            label.setStyle("fontWeight", "none");
        }
        label.text = labelText;
		
		var point:Point = Point(_geometry);
		var pixel:Pixel = point2Pixel(point);
		label._x = 0 - (label.width / 2);
        label._y = 0;
    }
    
    private function doDrawEditable():Void {
        var point:Point = Point(_geometry);
        var pixel:Pixel = point2Pixel(point);
        var x:Number = pixel.getX();
        var y:Number = pixel.getY();
		
		var thisObj:Object = this;
		var drawIconGraph:Boolean = !(pointIconUrl == null || pointIconUrl == "null" || pointIconUrl == "" || pointIconUrl == undefined);
		var drawPointText:Boolean = !(pointText == null || pointText == "" || pointText == "null" || pointText == undefined);
		//trace("EditMapPoint.as: drawIconGraph = "+drawIconGraph); 
		//trace("EditMapPoint.as: drawPointText = "+drawPointText); 
		
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
			mPointGraphic = createEmptyMovieClip("mPointGraphic", 20);	 //the icon is at depth 10, text at depth 30.
		}
		if (mIconTilePic != null) {
			mIconTilePic.removeMovieClip();
		}
		if (mPointText != null) {
			mPointText.removeTextField();
		}
		if (mPointTextCross != null) {
			mPointTextCross.removeMovieClip();
		}
				
		if (type == ACTIVE) {	
			with (mPointGraphic) {
				_x = 0;
				_y = 0;
				
				clear();
				moveTo(0, 0);
				//lineStyle(thisObj.style.getStrokeWidth() * 4, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				if (drawIconGraph || drawPointText) {
					lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF8000, 100); //orange
				} else {
					if (isChild) {
						//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.strokeColor, thisObj.strokeOpacity);
						lineStyle(thisObj.style.getStrokeWidth() * 6, 0xff0000, thisObj.strokeOpacity);
					} else {
						//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.pointColor, thisObj.pointOpacity);
						lineStyle(thisObj.style.getStrokeWidth() * 6, 0xff0000, thisObj.pointOpacity);
					}
				}
				
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
					//if geometry's first ancestor is a point, do not delete the point.
					var geom:Geometry = thisObj._geometry.getFirstAncestor();
					if (geom instanceof Point) {
						//do nothing
					}else{						
						thisObj._geometry.getParent().removePoint(Point(thisObj._geometry));						
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
					
					if ((thisObj._geometry.getFirstAncestor() instanceof Polygon) || (thisObj._geometry.getFirstAncestor() instanceof MultiPolygon)) {
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
						//if (thisObj._geometry.getFirstAncestor() instanceof Polygon) {
							thisObj._geometry.getFirstAncestor().getGeometryEventDispatcher().changeGeometry(this);
						//}
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
						thisObj._geometry.getFirstAncestor().getGeometryEventDispatcher().changeGeometry(this);
						//raise event onGeometryDrawUpdate via editMap through gis
						thisObj.gis.geometryUpdate();
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
				//this.lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF0000, 100);
				if (thisObj.isChild) {
					//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.strokeColor, thisObj.strokeOpacity);
					lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF0000, 100);
				} else {
					//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.pointColor, thisObj.pointOpacity);
					lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF0000, 100);
				}
				this.lineTo(0.45, 0.45);
				
			}
			mPointGraphic.onRollOutHandler = function(){
				// onRollOut
				this.clear();
				this.moveTo(0,0);
				//this.lineStyle(thisObj.style.getStrokeWidth() * 4, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				//this.lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.style.getStrokeColor(), thisObj.style.getStrokeOpacity());
				//this.lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.strokeColor, thisObj.strokeOpacity);
				if (thisObj.drawIconGraph || thisObj.drawPointText) {
					lineStyle(thisObj.style.getStrokeWidth() * 6, 0xFF8000, 100); //orange
				} else {
					//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.strokeColor, thisObj.strokeOpacity);
					if (isChild) {
						//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.strokeColor, thisObj.strokeOpacity);
						lineStyle(thisObj.style.getStrokeWidth() * 6, 0xff0000, thisObj.strokeOpacity);
					} else {
						//lineStyle(thisObj.style.getStrokeWidth() * 6, thisObj.pointColor, thisObj.pointOpacity);
						lineStyle(thisObj.style.getStrokeWidth() * 6, 0xff0000, thisObj.pointOpacity);
					}
				}
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
			if (drawIconGraph || drawPointText) {
				this.mPointGraphic.clear();
			} else {
				with (this.mPointGraphic) {
					_x = 0;
					_y = 0;
					clear();
					if(thisObj.alwaysDrawPoints){
						//lineStyle(thisObj.strokeWidth * 4, thisObj.strokeColor, thisObj.strokeOpacity);
						lineStyle(thisObj.strokeWidth * 4, thisObj.pointColor, thisObj.pointOpacity);
					}
					else{
						if(thisObj.isChild){
							lineStyle(0, 0, 0);
						} else {
							//lineStyle(thisObj.strokeWidth * 5, thisObj.strokeColor, thisObj.strokeOpacity);
							lineStyle(thisObj.strokeWidth * 5, thisObj.pointColor, thisObj.pointOpacity);
						}
					}
					moveTo(0, 0);
					lineTo(0+0.45,0+0.45);
				}
			}
			
			disablePseudoButtonEvents(mPointGraphic);
		}
		if (drawPointText) {
			mPointText = createTextField("mPointText", 15, 0, 0, 100, 100); //limited to one line
			mPointText.multiline = false;
			mPointText.autoSize = "left";
			mPointText.wordWrap = false;
			var tfmt:TextFormat = new TextFormat();
			tfmt.color = thisObj.pointColor;
			tfmt.align = "left";
			mPointText.text = pointText;
			mPointText.setTextFormat(tfmt);
			mPointText._x = 0;
			mPointText._y = 0; //-mPointText._height;
			
			if (!drawIconGraph && drawPointTextCross) {
				mPointTextCross = createEmptyMovieClip("mPointTextCross", 14);
				with (mPointTextCross) {
					_x=0;
					_y=0;
					clear();
					lineStyle(0,thisObj.pointColor,thisObj.pointOpacity);
					moveTo(-5,0);
					lineTo(5,0);
					moveTo(0,-5);
					lineTo(0,5);
				}
			}
		}
		if (drawIconGraph) {
			//trace("EditMapPoint.as: try to load a icon and draw it on the map.  thisObj.pointIconUrl = "+thisObj.pointIconUrl);
			//try to load an icon and draw it on the map
							
			//create and load icon pic on tile
			mIconTilePic = createEmptyMovieClip("mIconTilePic", 10);
			
			var thisObj3:Object = this;
			var loadListener:Object = new Object();
			loadListener.onLoadInit = function(mc:MovieClip) {
				//size the loaded tile according to the tile size
				mc._x = -mc._width/2;
				mc._y = -mc._height/2;
				
				//reposition the point text right from the icon (width 0 px spacing)
				thisObj3.mPointText._x = mc._width/2 + 0;
			}
			loadListener.onLoadError  = function(target_mc:MovieClip, errorCode:String, httpStatus:Number) {
				thisObj3._global.flamingo.showError("Exception in gui.EditMapPoint.as", "Can not load icon with url = "+target_mc._parent.tileIconUrl+" \nErrorCode = "+errorCode+"\nhttpStatus = "+httpStatus,3000);
				//trace("EditMapPoint.as load error. can not load icon: with url = "+target_mc._parent.tileIconUrl+"  errorCode = "+errorCode+"\nhttpStatus = "+httpStatus);
			}

			var mcLoader:MovieClipLoader = new MovieClipLoader();
			mcLoader.addListener(loadListener);
			mcLoader.loadClip(thisObj.pointIconUrl, mIconTilePic);
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

	
	private function enablePseudoButtonEvents(target){
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
	
	private function disablePseudoButtonEvents(target){
		delete target.onMouseDown; 
		delete target.onMouseUp;
		delete target.onMouseMove;
	}
}
