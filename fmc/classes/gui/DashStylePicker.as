// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

// *** ***
//This class provides the user a pick window in which he/she can select a dash style type for a line. The line types are drawn on the map by the gui.EditMapLineString class.
//The available dash styles (AvailableDashStyle objects) are configurable by the xml config file. See GIS.as for further documentation.
// *** ***	
	
import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.DashStylePicker extends MovieClip implements ActionEventListener {
    
    private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	private var propertyPropertyType:String = null;
	
	private var availableDashStyles:Array = null;
	private var defaultvalue:String = null;
	private var defaultpickDashStyle:String = null;
	private var pickDashStyle:String = null;
	private var pickDashStyleTitle:String = null;
	private var iconTiles:Array = null;

	private var mContainer:MovieClip = null;
	private var mPickWindow:MovieClip = null;
	private var pickWindowVisible:Boolean = false;
	
	private var lineWidth = 2.0;				//lineWidth of the dashed line drawn in this picker.
	private var tileWidthPr:Number = 40;	//tile on property window
	private var tileHeightPr:Number = 20;
	private var tileWidth:Number = 80;		//tile on pick window
	private var tileHeight:Number = 25;
	private var nrTilesHor:Number = 1;		//not set by init because this depends on the number of supported line types.
	private var nrTilesVer:Number = 4;		//not set by init because this depends on the number of supported line types.
	private var tilesSpacing:Number = 2;
	private var tileBgColor:Number = 0xeeeeee;
	private var tileFgColor:Number = 0xffffff;
	private var pickWindowBgColor:Number = 0xcccccc;
		
    function init():Void {
		if (availableDashStyles.length <= 0 || availableDashStyles == undefined) {
			_global.flamingo.tracer("Exception in gui.DashStylePicker.init() \propertyPropertyType = "+propertyPropertyType+"\navailableDashStyles is undefined or length = 0.\availableDashStyles.length = "+availableDashStyles.length);
            return;
        }
		
		tabEnabled = false;
		var feature:Feature = gis.getActiveFeature();
		
		var val:String = feature.getValueWithPropType(propertyPropertyType);
		//look the pickDashStyle up in the availableDashStyles list and return the value
		for (var i:Number = 0; i<availableDashStyles.length; i++) {
			if (availableDashStyles[i].getValue() == val) {
				pickDashStyle = availableDashStyles[i].getPickDashStyle()
			}
		}	
		
		if (pickDashStyle == null || pickDashStyle == NaN || pickDashStyle == undefined){
			pickDashStyle = String(defaultvalue);
		}	
		
		//set listener
		_parent._parent.setActionEventListener(this);
		
		drawGui();
    }
	
	function onActionEvent(actionEvent:ActionEvent):Void {
		var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "PropWindow_" + ActionEvent.OPEN) {
			closePickWindow();
		}
	}
	
	function setAvailableDashStyles(availableDashStyles:Array):Void{
		this.availableDashStyles = availableDashStyles;
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
		
		for (var i:Number = 0; i<availableDashStyles.length; i++) {
			if (availableDashStyles[i].getValue() == this.defaultvalue) {
				this.defaultpickDashStyle = availableDashStyles[i].getPickDashStyle();
				return;
			}
		}
		
		//alert in case the defaultpickColor can not be found in the list.
		_global.flamingo.tracer("Exception in gui.DashStylePicker.setDefaultvalue() \npropertyPropertyType = "+propertyPropertyType+"\nThe defaultvalue = "+defaultvalue+" can not find a matching value in the availableDashStyles. \availableDashStyles.length = "+availableDashStyles.length);
	}
	
	function getValue():String {
		//look the pickDashStyle up in the availableDashStyles list and return the value
		for (var i:Number = 0; i<availableDashStyles.length; i++) {
			if (availableDashStyles[i].getPickDashStyle() == pickDashStyle) {
				return availableDashStyles[i].getValue();
			}
		}
		return null; 
    }
	
	function drawGui():Void{
		var thisObj:Object = this;
		
		if(mContainer != null) {
			mContainer.removeMovieClip();
		}
		mContainer = createEmptyMovieClip("mContainer", getNextHighestDepth());
		
		//create and draw tile background and click surface
		var mIconTileBg:MovieClip = mContainer.attachMovie("ColorTile", "mIconTileBg", 10);
		with (mIconTileBg) {
			createEmptyMovieClip("mIconTileBgGraphicNormal", 1);
			with (mIconTileBgGraphicNormal) {
				clear();
				beginFill(thisObj.tileBgColor, 100);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
				endFill();
				
				if (thisObj.pickDashStyle != null && thisObj.pickDashStyle.split(" ").length > 1) {
					//draw dashed line to indicate dashed pick value
					var dashStyleArray:Array = thisObj.dashStyleStringToArray(thisObj.pickDashStyle);
					
					//draw dashed line to indicate dashed value
					lineStyle(thisObj.lineWidth,0x000000,100,false,"normal","none","bevel");
					var firstpenOnLength:Number = Number(dashStyleArray[0]);
					if (firstpenOnLength < thisObj.lineWidth && dashStyleArray.length <= 1) {
						firstpenOnLength = thisObj.lineWidth;
					}
					var dlseg:Number = firstpenOnLength;
					var penOn:Boolean = true;
					var pen:flash.geom.Point = new flash.geom.Point(2, thisObj.tileHeightPr/2);
					moveTo(pen.x, pen.y);
					var counter:Number = 0;
					var cycleIndexOffset:Number = 0;
					for (var dl:Number=dlseg; dl <= thisObj.tileWidthPr - thisObj.lineWidth; dl += dlseg){
						if (penOn) {
							//draw: pen on
							pen.x += dlseg;
							lineTo(pen.x, pen.y);
						} else {
							//move: pen off
							pen.x += dlseg;
							moveTo(pen.x, pen.y);
						}
						penOn = !penOn;
						
						cycleIndexOffset++;
						if (cycleIndexOffset >= dashStyleArray.length) {
							cycleIndexOffset = 0;
							penOn = true;
						}
						dlseg = Number(dashStyleArray[cycleIndexOffset]);
						if (dl + dlseg >= thisObj.tileWidthPr - thisObj.lineWidth) {
							//draw last segment up to boundary if applicable
							lineTo(thisObj.tileWidthPr - thisObj.lineWidth, pen.y);
							break;
						}
					}
					
				} else {
					//draw solid line to indicate solid value
					lineStyle(thisObj.lineWidth,0x000000,100);
					moveTo(thisObj.lineWidth, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - thisObj.lineWidth, thisObj.tileHeightPr/2);
				}
				
			}
		}
		mIconTileBg.onPress = function(){
			thisObj._parent._parent.onComponentSetFocus(thisObj);
			if (!thisObj.pickWindowVisible) {
				thisObj.popUpPickWindow();
			} else {
				thisObj.closePickWindow();
			}
		}
	}
	
	private function popUpPickWindow():Void {
		//close popupwindows from other properties
		_parent._parent.closeOtherComponentWindows(this);
		
		mPickWindow = mContainer.createEmptyMovieClip("mPickWindow", 20 );
		drawLineTypeTiles(mPickWindow);
		pickWindowVisible = true;
	}
	
	private function closePickWindow():Void {
		//close IconPickerWindow
		mPickWindow.removeMovieClip();
		mPickWindow = null;
		
		mContainer.mIconTileBg.removeMovieClip();
				
		pickWindowVisible = false;
		drawGui();
	}
	
	private function dashStyleStringToArray(dashStyle:String):Array{
		var dashStyleArray:Array = new Array(1.0);		//default solid line
		if (dashStyle != null) {
			dashStyleArray = dashStyle.split(" ");
		}
		return dashStyleArray;
	}
	
	private function drawLineTypeTiles(parentMc:MovieClip):Void{
		var tileDashStyle:String = "1.0";	//tile dashStyle
		var dashStyleArray:Array;
		var tileDashStyleName:String = "solid";		//friendly name of the tile dashStyle. Default in case there is no availableDashStyle.
		var tileDashStyleDefault:String = "1.0";	//default tile dashStyle in case there is no availableColor.
		var tileDashStyleNameDefault:String = "solid";		//Default in case there is no availableColor.
		
		
		var thisObj:Object = this;
		var tileLineType:String = "solid";
		
		//draw backGound of pickWindow
		var w:Number = (nrTilesHor) * (tileWidth + tilesSpacing) - tilesSpacing + 20;
		var h:Number = (nrTilesVer) * (tileHeight + tilesSpacing) - tilesSpacing + 20;
		with (parentMc) {
			createEmptyMovieClip("mPickWindowBg", 1);
			with (mPickWindowBg) {
				_x = 0;
				_y = 0;
				beginFill(thisObj.pickWindowBgColor, 100);
				moveTo(0, 0);
				lineTo(w, 0);
				lineTo(w, h);
				lineTo(w, h);
				lineTo(0, h);
				lineTo(0, 0);
				endFill();
			}
		}
		parentMc._x = 30;
		parentMc._y = 0;

		iconTiles = new Array();
		
		var xPos:Number = 0;
		var yPos:Number = 0;
		var startTileDepth:Number = parentMc.getNextHighestDepth();
		
		//determine number of tiles to be drawn
		var nrTilesToDraw:Number = nrTilesHor*nrTilesVer;
		if (availableDashStyles.length < nrTilesHor*nrTilesVer) {
			nrTilesToDraw = availableDashStyles.length;
		}
		
		//check for exception
		if (nrTilesToDraw <= 0 || availableDashStyles == undefined) {
			parentMc.mPickWindowBg.onPress = function(){
				parentMc._parent.closePickWindow();
			}
            _global.flamingo.tracer("Exception in gui.DashStylePicker.drawLineTypeTiles() \availableDashStyles.length = "+availableDashStyles.length+"\nnrTilesHor*nrTilesVer = "+nrTilesHor*nrTilesVer);
            return;
        }
		
		for (var i:Number = 0; i < nrTilesToDraw; i++) {
			dashStyleArray = dashStyleStringToArray(availableDashStyles[i].getPickDashStyle());
			
			//draw dashStyle Tile
			xPos = 0 + (i   % nrTilesHor) * (tileWidth + tilesSpacing) + 10;				// + tileWidth/2;
			yPos = 0 + ( Math.floor(i  / nrTilesHor) ) * (tileHeight + tilesSpacing) + 10;	//+ tileHeight/2;
			
			var initObject = new Object();
            initObject["_x"] = xPos;
			initObject["_y"] = yPos;
			initObject["nr"] = i;
			
			initObject["tileLineType"] = thisObj.tileLineType;
			if (i < availableDashStyles.length) {
				tileDashStyle = availableDashStyles[i].getPickDashStyle();
				tileDashStyleName = availableDashStyles[i].getName();	//friendly name of the dashStyle
			}
			else{
				tileDashStyle = tileDashStyleNameDefault;
				tileDashStyleName = tileDashStyleNameDefault;
			}
			initObject["tileDashStyle"] = tileDashStyle;
			initObject["tileDashStyleName"] = tileDashStyleName;
			
			var depth:Number= startTileDepth + i;
			
			iconTiles.push(parentMc.attachMovie("ColorTile", "mIconTile" + i, depth, initObject));
			
			with (iconTiles[i]) {
				//create and draw tile background and click surface
				var mIconTileBg:MovieClip = attachMovie("ColorTile", "mIconTileBg", 10);
				with (mIconTileBg) {
					createEmptyMovieClip("mIconTileBgGraphicNormal", 1);
					with (mIconTileBgGraphicNormal) {
						beginFill(thisObj.tileBgColor, 100);
						moveTo(0, 0);
						lineTo(thisObj.tileWidth, 0);
						lineTo(thisObj.tileWidth, thisObj.tileHeight);
						lineTo(thisObj.tileWidth, thisObj.tileHeight);
						lineTo(0, thisObj.tileHeight);
						lineTo(0, 0);
						endFill();
					}
				}
				
				//create and draw tile foreground (showing opacity) and click surface
				var mIconTileFg:MovieClip = attachMovie("ColorTile", "mIconTileFg", 20);

				with (mIconTileFg) {
					beginFill(thisObj.tileFgColor, 100);
					moveTo(0, 0);
					lineTo(thisObj.tileWidth, 0);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(0, thisObj.tileHeight);
					lineTo(0, 0);
					endFill();
					
					if (thisObj.availableDashStyles[i].getPickDashStyle() != null && thisObj.availableDashStyles[i].getPickDashStyle().split(" ").length > 1) {
						//draw dashed line to indicate dashed value
						//lineStyle(thickness:Number, rgb:Number, alpha:Number, pixelHinting:Boolean, noScale:String, capsStyle:String, jointStyle:String, miterLimit:Number);
						lineStyle(thisObj.lineWidth,0x000000,100,false,"normal","none","bevel");
						var firstpenOnLength:Number = Number(dashStyleArray[0]);
						if (firstpenOnLength < 1.0 && dashStyleArray.length <= 1) {
							firstpenOnLength = 1.0;
						}
						var dlseg:Number = firstpenOnLength;
						var penOn:Boolean = true;
						var pen:flash.geom.Point = new flash.geom.Point(2, thisObj.tileHeight/2);
						moveTo(pen.x, pen.y);
						var counter:Number = 0;
						var cycleIndexOffset:Number = 0;
						for (var dl:Number=dlseg; dl <= thisObj.tileWidth - thisObj.lineWidth; dl += dlseg){
							if (penOn) {
								//draw: pen on
								pen.x += dlseg;
								lineTo(pen.x, pen.y);
							} else {
								//move: pen off
								pen.x += dlseg;
								moveTo(pen.x, pen.y);
							}
							penOn = !penOn;
							
							cycleIndexOffset++;
							if (cycleIndexOffset >= dashStyleArray.length) {
								cycleIndexOffset = 0;
								penOn = true;
							}
							dlseg = Number(dashStyleArray[cycleIndexOffset]);
							if (dl + dlseg >= thisObj.tileWidth - thisObj.lineWidth) {
								//draw last segment up to boundary if applicable
								lineTo(thisObj.tileWidth - thisObj.lineWidth, pen.y);
								break;
							}
						}
					} else {
						//draw solid line
						lineStyle(thisObj.lineWidth,0x000000,100);
						moveTo(thisObj.lineWidth, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - thisObj.lineWidth, thisObj.tileHeight/2);
					}
				}
				
				mIconTileFg.onPress = function(){
					thisObj.pickDashStyle = this._parent.tileDashStyle;
					thisObj.pickDashStyleTitle = this._parent.tileDashStyleName;
					thisObj.closePickWindow();
				}
			}
		}	
	}
}
