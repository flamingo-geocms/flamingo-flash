// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

// *** ***
//This class provides the user a pick window in which he/she can select a line type. The line types are drawn on the map by the gui.EditMapLineString class.
//The available line types need to be implemented in this class for selection and in the corresponding gui.EditMapLineString class.
//In this version only the "solid", "arrow", and "arrow_closed" types are implemented.
//The "dashed" type needs some debugging before it can be used. 
// *** ***	
	
import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.LineTypePicker extends MovieClip implements ActionEventListener {
    
    private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	
	private var lineType:String = null;
	private var defaultvalue:String = null;
	private var iconTiles:Array = null;

	private var mContainer:MovieClip = null;
	private var mPickWindow:MovieClip = null;
	private var pickWindowVisible:Boolean = false;
	
	private var tileWidthPr:Number = 40;	//tile on property window
	private var tileHeightPr:Number = 20;
	private var tileWidth:Number = 50;		//tile on pick window
	private var tileHeight:Number = 25;
	private var nrTilesHor:Number = 1;		//not set by init because this depends on the number of supported line types.
	private var nrTilesVer:Number = 3;		//not set by init because this depends on the number of supported line types.
	private var tilesSpacing:Number = 2;
	private var tileBgColor:Number = 0xeeeeee;
	private var tileFgColor:Number = 0xffffff;
	private var pickWindowBgColor:Number = 0xcccccc;
		
    function init():Void {
		tabEnabled = false;
		
		var feature:Feature = gis.getActiveFeature();
		lineType = String(feature.getValue(propertyName));
		
		if (lineType == null || lineType == NaN || lineType == undefined){
			lineType = defaultvalue;
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
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
	}
	
	function getDefaultvalue():String{
		return this.defaultvalue;
	}
	
	function getValue():String {
		return lineType; 
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
				
				if (thisObj.lineType == "solid"){
					//draw solid line to indicate solid value
					lineStyle(2,0x000000,100);
					moveTo(2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr/2);
				} else if (thisObj.lineType == "arrow"){
					//draw line with arrow to indicate arrow value
					lineStyle(2,0x000000,100);
					moveTo(2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2 - 10, thisObj.tileHeightPr/2 - 10);
					moveTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2 - 10, thisObj.tileHeightPr/2 + 10);
				} else if (thisObj.lineType == "arrow_closed"){
					//draw line with closed arrow to indicate arrow value
					lineStyle(2,0x000000,100);
					moveTo(2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr/2);
					
					beginFill(0x000000,100);
					moveTo(thisObj.tileWidthPr - 2 - 10, thisObj.tileHeightPr/2 - 10);
					lineTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr/2);
					lineTo(thisObj.tileWidthPr - 2 - 10, thisObj.tileHeightPr/2 + 10);
					lineTo(thisObj.tileWidthPr - 2 - 10, thisObj.tileHeightPr/2 - 10);
					endFill();
				} else if (thisObj.lineType == "dashed"){
					//draw dashed line to indicate dashed value
					lineStyle(2,0x000000,100);
					var penOnLength:Number = 6;
					var penOffLength:Number = 4;
					var dlseg:Number = penOnLength;
					var penOn:Boolean = true;
					var pen:flash.geom.Point = new flash.geom.Point(2, thisObj.tileHeightPr/2);
					moveTo(pen.x, pen.y);
					for (var dl:Number=dlseg; dl < thisObj.tileWidthPr - 2; dl += dlseg){
						if (penOn) {
							//draw: pen on
							pen.x += penOnLength;
							lineTo(pen.x, pen.y);
							dlseg = penOffLength;
						} else {
							//move: pen off
							pen.x += penOffLength;
							moveTo(pen.x, pen.y);
							dlseg = penOnLength;
						}
						penOn = !penOn;
					}
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
	
	private function drawLineTypeTiles(parentMc:MovieClip):Void{
		var thisObj:Object = this;
		var tileLineType:String = "solid";
		
		//draw backGound of pickWindow
		var w:Number = (nrTilesHor + 1) * (tileWidth + tilesSpacing) - tilesSpacing;
		var h:Number = (nrTilesVer + 1) * (tileHeight + tilesSpacing) - tilesSpacing;
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
				
		for (var i:Number = 0; i < nrTilesHor*nrTilesVer; i++) {
			//draw iconTile
			xPos = 0 + (i   % nrTilesHor) * (tileWidth + tilesSpacing) + 10;				// + tileWidth/2;
			yPos = 0 + ( Math.floor(i  / nrTilesHor) ) * (tileHeight + tilesSpacing) + 10;	//+ tileHeight/2;
			
			var initObject = new Object();
            initObject["_x"] = xPos;
			initObject["_y"] = yPos;
			initObject["nr"] = i;
		
			if (i == 0){
				thisObj.tileLineType = "solid";
			} else if (i == 1) {
				thisObj.tileLineType = "arrow";
			} else if (i == 2) {
				thisObj.tileLineType = "arrow_closed";
			} else if (i == 3) {
				thisObj.tileLineType = "dashed";
			} else {
				thisObj.tileLineType = defaultvalue;
			}	
			
			initObject["tileLineType"] = thisObj.tileLineType;
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
				
				mIconTileBg.onPress = function(){
					thisObj.lineType = this._parent.tileLineType;
					thisObj.closePickWindow();
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
										
					if (thisObj.tileLineType == "solid"){
						//draw solid line to indicate solid value
						lineStyle(2,0x000000,100);
						moveTo(2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2, thisObj.tileHeight/2);
					} else if (thisObj.tileLineType == "arrow"){
						//draw line with arrow to indicate arrow value
						lineStyle(2,0x000000,100);
						moveTo(2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2 - 10, thisObj.tileHeight/2 - 10);
						moveTo(thisObj.tileWidth - 2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2 - 10, thisObj.tileHeight/2 + 10);
					} else if (thisObj.tileLineType == "arrow_closed"){
						//draw line with closed arrow to indicate arrow value
						lineStyle(2,0x000000,100);
						moveTo(2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2, thisObj.tileHeight/2);
						
						beginFill(0x000000,100);
						moveTo(thisObj.tileWidth - 2 - 10, thisObj.tileHeight/2 - 10);
						lineTo(thisObj.tileWidth - 2, thisObj.tileHeight/2);
						lineTo(thisObj.tileWidth - 2 - 10, thisObj.tileHeight/2 + 10);
						lineTo(thisObj.tileWidth - 2 - 10, thisObj.tileHeight/2 - 10);
						endFill();
					} else if (thisObj.tileLineType == "dashed"){
						//draw dashed line to indicate dashed value
						lineStyle(2,0x000000,100);
						var penOnLength:Number = 6;
						var penOffLength:Number = 4;
						var dlseg:Number = penOnLength;
						var penOn:Boolean = true;
						var pen:flash.geom.Point = new flash.geom.Point(2, thisObj.tileHeight/2);
						moveTo(pen.x, pen.y);
						for (var dl:Number=dlseg; dl < thisObj.tileWidth - 2; dl += dlseg){
							if (penOn) {
								//draw: pen on
								pen.x += penOnLength;
								lineTo(pen.x, pen.y);
								dlseg = penOffLength;
							} else {
								//move: pen off
								pen.x += penOffLength;
								moveTo(pen.x, pen.y);
								dlseg = penOnLength;
							}
							penOn = !penOn;
						}
					}
				}
				
				mIconTileFg.onPress = function(){
					thisObj.lineType = this._parent.tileLineType;
					thisObj.closePickWindow();
				}	
			}
		}	
	}
}
