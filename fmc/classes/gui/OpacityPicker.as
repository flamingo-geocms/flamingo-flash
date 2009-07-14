// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.OpacityPicker extends MovieClip implements ActionEventListener {
    
    private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	
	private var opacity:Number = null;
	private var defaultvalue:String = null;
	private var minvalue:Number = 0;
	private var maxvalue:Number = 100;
		
	private var mContainer:MovieClip = null;
	private var iconTiles:Array = null;
	private var tileWidthPr:Number = 15;	//tile on property window
	private var tileHeightPr:Number = 15;
	private var tileWidth:Number = 20;		//tile on pick window
	private var tileHeight:Number = 20;
	private var nrTilesHor:Number = 2;
	private var nrTilesVer:Number = 2;
	private var tilesSpacing:Number = 2;
	private var tileBgColor:Number = 0xffffff;
	private var tileFgColor:Number = 0x000000;
	private var pickWindowBgColor:Number = 0xcccccc;
	private var mPickWindow:MovieClip = null;
	private var pickWindowVisible:Boolean = false;
			
    function init():Void {
		tabEnabled = false;
		var thisObj:Object = this;
		
		var feature:Feature = thisObj.gis.getActiveFeature();
		opacity = Number(feature.getValue(thisObj.propertyName));
		if (opacity == null || opacity == NaN || opacity == undefined){
			opacity = Number(defaultvalue);
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
	
	function getValue():Number {
		return opacity; 
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
				beginFill(thisObj.tileBgColor, 100);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
				endFill();
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
		
		if (opacity >= 0 && opacity <= 100 ){
			//create and draw tile foreground (showing opacity) and click surface
			var mIconTileFg:MovieClip = mContainer.attachMovie("ColorTile", "mIconTileFg", 20);
			with (mIconTileFg) {
				beginFill(thisObj.tileFgColor, thisObj.opacity);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
				endFill();
				
				//draw border
				lineStyle(1, 0x808080, 100);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
				
			}
			
			mIconTileFg.onPress = function(){
				thisObj._parent._parent.onComponentSetFocus(thisObj);
				if (!thisObj.pickWindowVisible) {
					thisObj.popUpPickWindow();
				} else {
					thisObj.closePickWindow();
				}
			}
		}
				
		//draw textfield containing opacity value
		var mTF:Object = createTextField("mPointText", 15, 0, 0, 100, 100); //limited to one line
		mTF.multiline = false;
		mTF.autoSize = "left";
		mTF.wordWrap = false;
		var tfmt:TextFormat = new TextFormat();
		tfmt.color = 0x000000;
		tfmt.align = "left";
		mTF.text  = String(opacity) + " %";
		mTF.setTextFormat(tfmt);
		mTF._x = tileWidthPr + 10;
		mTF._y = 0; 
		
	}
	
	private function popUpPickWindow():Void {
		//close popupwindows from other properties
		_parent._parent.closeOtherComponentWindows(this);
	
		mPickWindow = mContainer.createEmptyMovieClip("mPickWindow", 20 );
		drawIconTiles(mPickWindow);
		pickWindowVisible = true;
	}
	
	private function closePickWindow():Void {
		//close OpacityPickerWindow
		mPickWindow.removeMovieClip();
		mPickWindow = null;
		
		mContainer.mIconTileBg.removeMovieClip();
		mContainer.mIconTileFg.removeMovieClip();
		
		pickWindowVisible = false;
		drawGui();
	}
	
	
	
	private function drawIconTiles(parentMc:MovieClip):Void{
		var thisObj:Object = this;
		var tileIconOpacity:Number = 0;
		
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
			xPos = 0 + (i   % nrTilesHor) * (tileWidth + tilesSpacing) + tileWidth/2;
			yPos = 0 + ( Math.floor(i  / nrTilesHor) ) * (tileHeight + tilesSpacing) + tileHeight/2;
			
			var thisObj3:Object = this;
			var initObject = new Object();
            initObject["_x"] = xPos;
			initObject["_y"] = yPos;
			initObject["nr"] = i;
			
			//distribute opacity evenly over total nr tiles between minvalue and maxvalue
			thisObj.tileIconOpacity = Math.round(minvalue + (maxvalue - minvalue) * (nrTilesHor*nrTilesVer - 1 - i) / (nrTilesHor*nrTilesVer - 1));
			
			initObject["tileIconOpacity"] = thisObj.tileIconOpacity;
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
					thisObj.closePickWindow();
				}
				
				//create and draw tile foreground (showing opacity) and click surface
				var mIconTileFg:MovieClip = attachMovie("ColorTile", "mIconTileFg", 20);
				with (mIconTileFg) {
					beginFill(thisObj.tileFgColor, thisObj.tileIconOpacity);
					moveTo(0, 0);
					lineTo(thisObj.tileWidth, 0);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(0, thisObj.tileHeight);
					lineTo(0, 0);
					endFill();
				}
				
				mIconTileFg.onPress = function(){
					thisObj.opacity = this._parent.tileIconOpacity;
					thisObj.closePickWindow();
				}	
			}
		}	
	}
}

