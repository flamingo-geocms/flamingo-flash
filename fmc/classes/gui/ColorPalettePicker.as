// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.ActionEvent;
import event.ActionEventListener;

import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.ColorPalettePicker extends MovieClip implements ActionEventListener {
    
	private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	
	private var availableColors:Array = null;
	private var colorTiles:Array = null;
	private var pickColor:Number = null;
	private var pickColorTitle:String = null;	//title of the AvailableColor representing a friendly color name.
	private var defaultvalue:String = null;
	private var defaultpickColor:Number = null;
	private var defaultpickColorTitle:String = null;
	private var mContainer:MovieClip = null;
	private var mPickWindow:MovieClip = null;
	private var pickWindowVisible:Boolean = false;
	private var tileWidthPr:Number = 15;	//tile on property window
	private var tileHeightPr:Number = 15;
	private var tileWidth:Number = 20;		//tile on pick window
	private var tileHeight:Number = 20;
	private var nrTilesHor:Number = 2;
	private var nrTilesVer:Number = 4;
	private var tilesSpacing:Number = 2;	
		
    
    function init():Void {
		if (availableColors.length <= 0 || availableColors == undefined) {
			_global.flamingo.tracer("Exception in gui.ColorPalettePicker.init() \npropertyName = "+propertyName+"\navailableColors is undefined or length = 0.\navailableColors.length = "+availableColors.length);
            return;
        }
		
		tabEnabled = false;
		var feature:Feature = gis.getActiveFeature();
		pickColor = Number(feature.getValue(propertyName));
		
		if (pickColor == null || pickColor == NaN || pickColor == undefined){
			pickColor = Number(defaultvalue);
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

	
	function setAvailableColors(availableColors:Array):Void{
		this.availableColors = availableColors;
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
		defaultpickColor = Number(defaultvalue);
	}
	
	function getValue():String {
		return String(pickColor); 
    }
	
		
	function drawGui():Void{	
		var thisObj:Object = this;
		updateColorTitle();	
		mContainer = createEmptyMovieClip("mContainer", getNextHighestDepth());
		
		var mColorTile:MovieClip = mContainer.attachMovie("ColorTile", "mColorTile", 10);
		with (mColorTile) {
			createEmptyMovieClip("mColorTileGraphicNormal", 1);
			with (mColorTileGraphicNormal) {
				beginFill(thisObj.pickColor, 100);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
				endFill();
				
				lineStyle(1, 0x808080, 100);
				moveTo(0, 0);
				lineTo(thisObj.tileWidthPr, 0);
				lineTo(thisObj.tileWidthPr, thisObj.tileHeightPr);
				lineTo(0, thisObj.tileHeightPr);
				lineTo(0, 0);
			}
		}
		
		mColorTile.mColorTileGraphicNormal.onPress = function(){
		
			if (!thisObj.pickWindowVisible) {
				thisObj.popUpPickWindow();
			} else {
				thisObj.closePickWindow();
			}
			thisObj._parent._parent.onComponentSetFocus(thisObj);
		}
		
		//draw textfield containing friendly color name
		var mTF:Object = createTextField("mPointText", 15, 0, 0, 100, 100); //limited to one line
		mTF.multiline = false;
		mTF.autoSize = "left";
		mTF.wordWrap = false;
		var tfmt:TextFormat = new TextFormat();
		tfmt.color = 0x000000;
		tfmt.align = "left";
		if (pickColorTitle != null){
			mTF.text  = String(pickColorTitle);
		} else {
		mTF.text  = "";
		}
		mTF.setTextFormat(tfmt);
		mTF._x = tileWidthPr + 10;
		mTF._y = 0;
    }
	
	
	private function popUpPickWindow():Void {
		//close popupwindows from other properties
		_parent._parent.closeOtherComponentWindows(this);
		
		//popup ColorPalettePickerWindow
		mPickWindow = mContainer.createEmptyMovieClip("mPickWindow", 20 );

		drawColorTiles(mPickWindow);
		pickWindowVisible = true;
    }
	private function closePickWindow():Void {
		//popup ColorPalettePickerWindow
		mPickWindow.removeMovieClip();
		mPickWindow = null;
		mContainer.mColorTile.removeMovieClip();

		pickWindowVisible = false;
		drawGui();
    }
	
	private function updateColorTitle():Void{
		//update friendly color name
		for (var i:Number = 0; i < availableColors.length; i++) {
			if (availableColors[i].getPickColor() == pickColor){
				pickColorTitle = availableColors[i].getTitle();
			}
		}
	}
	
	private function drawColorTiles(parentMc:MovieClip):Void{
		var tileColor:String = "0xFF808080";	//tile color
		var tileColorName:String = "grijs";		//friendly name of the tile color. Default in case there is no availableColor.
		var tileColorDefault:String = "0xFF808080";	//default tile color in case there is no availableColor.
		var tileColorNameDefault:String = "grijs";		//Default in case there is no availableColor.
		
		var thisObj:Object = this;
		
		//draw backGound of pickWindow
		var w:Number = (nrTilesHor + 1) * (tileWidth + tilesSpacing) - tilesSpacing;
		var h:Number = (nrTilesVer + 1) * (tileHeight + tilesSpacing) - tilesSpacing;
		with (parentMc) {
			
			createEmptyMovieClip("mPickWindowBg", 1);
			with (mPickWindowBg) {
				_x = 0;
				_y = 0;
				beginFill("0xCCCCCC", 100);
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
		
		colorTiles = new Array();
		var xPos:Number = 0;
		var yPos:Number = 0;
		var startTileDepth:Number = parentMc.getNextHighestDepth();
		
		//determine number of tiles to be drawn
		var nrTilesToDraw:Number = nrTilesHor*nrTilesVer;
		if (availableColors.length < nrTilesHor*nrTilesVer) {
			nrTilesToDraw = availableColors.length;
		}
				
		//check for exception
		//trace("ColorPalettePicker.as drawColorTiles() nrTilesToDraw = "+nrTilesToDraw+"  availableColors = "+availableColors);
		if (nrTilesToDraw <= 0 || availableColors == undefined) {
			parentMc.mPickWindowBg.onPress = function(){
				parentMc._parent.closePickWindow();
			}
            _global.flamingo.tracer("Exception in gui.ColorPalettePicker.drawColorTiles() \navailableColors.length = "+availableColors.length+"\nnrTilesHor*nrTilesVer = "+nrTilesHor*nrTilesVer);
            return;
        }
		
		for (var i:Number = 0; i < nrTilesToDraw; i++) {
			//draw colorTile
			xPos = 0 + (i   % nrTilesHor) * (thisObj.tileWidth + tilesSpacing) + thisObj.tileWidth/2;
			yPos = 0 + ( Math.floor(i  / nrTilesHor) ) * (thisObj.tileHeight + tilesSpacing) + thisObj.tileHeight/2;
	
			var initObject = new Object();
            initObject["_x"] = xPos;
			initObject["_y"] = yPos;
			initObject["nr"] = i;
			if (i < availableColors.length) {
				tileColor = availableColors[i].getPickColor();
				tileColorName = availableColors[i].getName();	//friendly name of the color
			}
			else{
				tileColor = tileColorDefault;
				tileColorName = tileColorNameDefault;
			}
			initObject["tileColor"] = tileColor;
			initObject["tileColorName"] = tileColorName;
			
			var thisObj:Object = this;

			var depth:Number= startTileDepth + i;
			colorTiles.push(parentMc.attachMovie("ColorTile", "mColorTile" + i, depth, initObject));
			with (colorTiles[i]) {
				//_x = xPos;
				//_y = yPos;
				gotoAndStop(1);
				createEmptyMovieClip("mColorTileGraphicNormal", 0 );
				var thisObj2:Object = this;
				with (mColorTileGraphicNormal) {
					beginFill(tileColor, 100);
					moveTo(0, 0);
					lineTo(thisObj.tileWidth, 0);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(thisObj.tileWidth, thisObj.tileHeight);
					lineTo(0, thisObj.tileHeight);
					lineTo(0, 0);
					endFill();
				}
			}
			
			colorTiles[i].onPress = function(){
				thisObj.pickColor = this.tileColor;
				thisObj.pickColorTitle = this.tileColorName;
				
				//remove onPress listeners
				for (var j:Number = 0; j < thisObj.colorTiles.length; j++) {
					//trace("delete thisObj.colorTiles[j].onPress");
					delete thisObj.colorTiles[j].onPress;
				}
				
				parentMc._parent._parent.closePickWindow();
			}
		}
	}
}
