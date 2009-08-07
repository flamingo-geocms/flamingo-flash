// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder, B3partners bv.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.IconPicker extends MovieClip implements ActionEventListener {
    
    private var gis:GIS = null;
	private var enabled:Boolean = true;
	private var tabIndex:Number= 1;
	private var tabEnabled:Boolean = false;
	private var propertyName:String = null;
	private var propertyPropertyType:String = null;
	
	private var availableIcons:Array = null;
	private var defaultvalue:String = null;
	private var iconTiles:Array = null;
	private var pickIconUrl:String = null;
	private var pickIconTitle:String = null;
	
	private var mContainer:MovieClip = null;
	private var mPickWindow:MovieClip = null;
	private var pickWindowVisible:Boolean = false;
	private var tileWidthPr:Number = 20;	//tile on property window
	private var tileHeightPr:Number = 20;
	private var tileWidth:Number = 25;		//tile on pick window
	private var tileHeight:Number = 25;
	private var nrTilesHor:Number = 4;
	private var nrTilesVer:Number = 3;
	private var tilesSpacing:Number = 2;
	private var tileBgColor:Number = 0xeeeeee;
	private var pickWindowBgColor:Number = 0xcccccc;
	
	private var defaultIconUrl:String = "assets/icons/icon1.png";
	
    function init():Void {
		if (availableIcons.length <= 0 || availableIcons == undefined) {
			_global.flamingo.tracer("Exception in gui.IconPicker.init() \npropertyPropertyType = "+propertyPropertyType+"\navailableIcons is undefined or length = 0.\navailableIcons.length = "+availableIcons.length);
            return;
        }
		tabEnabled = false;
		
		var feature:Feature = gis.getActiveFeature();
		var val:String = feature.getValueWithPropType(propertyPropertyType);
		//look the pickIconUrl up in the availableIcons list and return the value
		for (var i:Number = 0; i<availableIcons.length; i++) {
			if (availableIcons[i].getValue() == val) {
				pickIconUrl = availableIcons[i].getPickIconUrl();
			}
		}
		//pickIconUrl = String(feature.getValue(propertyName));
		
		if (pickIconUrl == null || pickIconUrl == NaN || pickIconUrl == undefined){
			pickIconUrl = defaultIconUrl;
			pickIconTitle = "default";
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
	
	function setAvailableIcons(availableIcons:Array):Void{
		this.availableIcons = availableIcons;
	}
	
	function setDefaultvalue(defaultvalue:String):Void{
		this.defaultvalue = defaultvalue;
		
		for (var i:Number = 0; i<availableIcons.length; i++) {
			if (availableIcons[i].getValue() == this.defaultvalue) {
				defaultIconUrl = availableIcons[i].getPickIconUrl();
				return;
			}
		}
		
		//alert in case the defaultpickColor can not be found in the list.
		_global.flamingo.tracer("Exception in gui.IconPicker.setDefaultvalue() \npropertyPropertyType = "+propertyPropertyType+"\nThe defaultvalue = "+defaultvalue+" can not find a matching value in the availableIcons. \navailableIcons.length = "+availableIcons.length);
		
		
		//trace("Exception in gui.IconPicker.setDefaultvalue() \npropertyPropertyType = "+propertyPropertyType+"\nThe defaultvalue = "+defaultvalue+" can not find a matching value in the availableIcons. \navailableIcons.length = "+availableIcons.length);
		
		//defaultIconUrl = String(defaultvalue);		
	}
	
	function getDefaultvalue():String{
		return this.defaultvalue;
	}
	
	function getValue():String {
		//look the pickIconUrl up in the availableIcons list and return the value
		for (var i:Number = 0; i<availableIcons.length; i++) {
			if (availableIcons[i].getPickIconUrl() == pickIconUrl) {
				return availableIcons[i].getValue();
			}
		}

		return String(pickIconUrl); 
    }
	
	function drawGui():Void{
		var thisObj:Object = this;
		updateIconTitle();
		
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
				if (thisObj.pickIconUrl == null || thisObj.pickIconUrl == "null"){
					//draw red cross to indicate null value
					lineStyle(2,0xff0000,100);
					moveTo(2, 2);
					lineTo(thisObj.tileWidthPr - 2, thisObj.tileHeightPr - 2);
					moveTo(thisObj.tileWidthPr - 2, 2);
					lineTo(2, thisObj.tileHeightPr - 2);
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
		
		if (pickIconUrl != null && pickIconUrl != "null"){
			//create and load icon pic on tile
			var mIconTilePic:MovieClip = mContainer.attachMovie("ColorTile", "mIconTilePic", 20);
					
			var loadListener:Object = new Object();
			loadListener.onLoadInit = function(mc:MovieClip) {
				mc._width = thisObj.tileWidthPr;
				mc._height = thisObj.tileHeightPr;
				mc.onPress = function(){
					thisObj._parent._parent.onComponentSetFocus(thisObj);
					if (!thisObj.pickWindowVisible) {
						thisObj.popUpPickWindow();
					} else {
						thisObj.closePickWindow();
					}
				}
			}

			var mcLoader:MovieClipLoader = new MovieClipLoader();
			mcLoader.addListener(loadListener);
			mcLoader.loadClip(pickIconUrl, mIconTilePic);
		}
		
		//draw textfield containing friendly color name
		var mTF:Object = createTextField("mPointText", 15, 0, 0, 100, 100); //limited to one line
		mTF.multiline = false;
		mTF.autoSize = "left";
		mTF.wordWrap = false;
		var tfmt:TextFormat = new TextFormat();
		tfmt.color = 0x000000;
		tfmt.align = "left";
		if (pickIconTitle != null){
			mTF.text  = String(pickIconTitle);
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
		
		mPickWindow = mContainer.createEmptyMovieClip("mPickWindow", 20 );
		drawIconTiles(mPickWindow);
		pickWindowVisible = true;
	}
	
	private function closePickWindow():Void {
		//close IconPickerWindow
		mPickWindow.removeMovieClip();
		mPickWindow = null;
		
		mContainer.mIconTileBg.removeMovieClip();
		mContainer.mIconTilePic.removeMovieClip();
		
		pickWindowVisible = false;
		drawGui();
	}
	
	private function updateIconTitle():Void{
		//update friendly color name
		for (var i:Number = 0; i < availableIcons.length; i++) {
			if (availableIcons[i].getPickIconUrl() == pickIconUrl){
				pickIconTitle = availableIcons[i].getTitle();
			}
		}
		if (pickIconUrl == "null" || pickIconUrl == null){
			pickIconTitle = "";
		}
	}
	
	private function drawIconTiles(parentMc:MovieClip):Void{
		var tileIconUrl:String = defaultIconUrl;	//tile color
		var tileIconName:String = "default";		//friendly name of the tile color. Default in case there is no availableColor.
		var thisObj:Object = this;
		
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
		parentMc._y = 20;
		
		
		iconTiles = new Array();
		
		var xPos:Number = 0;
		var yPos:Number = 0;
		var startTileDepth:Number = parentMc.getNextHighestDepth();

		var thisObj2:Object = this;

		//determine number of tiles to be drawn
		var nrTilesToDraw:Number = nrTilesHor*nrTilesVer;
		if (availableIcons.length < nrTilesHor*nrTilesVer) {
			nrTilesToDraw = availableIcons.length;
		}
		
		//check for exception
		if (nrTilesToDraw <= 0) {
			parentMc.mPickWindowBg.onPress = function(){
				parentMc._parent.closePickWindow();
			}
            _global.flamingo.tracer("Exception in gui.IconPicker.drawColorTiles() \navailableIcons.length = "+availableIcons.length+"\nnrTilesHor*nrTilesVer = "+nrTilesHor*nrTilesVer);
            return;
        }
		
		//add 1 tile for the "draw no icon" option
		nrTilesToDraw++;
		
		for (var i:Number = 0; i <nrTilesToDraw; i++) {
			//draw iconTile
			xPos = 0 + (i   % nrTilesHor) * (tileWidth + tilesSpacing) + tileWidth/2;
			yPos = 0 + ( Math.floor(i  / nrTilesHor) ) * (tileHeight + tilesSpacing) + tileHeight/2;
	
			var initObject = new Object();
            initObject["_x"] = xPos;
			initObject["_y"] = yPos;
			initObject["nr"] = i;
			
			var loadIcon:Boolean = true;
			
			if (i == 0){
				loadIcon = false; //"draw no icon" tile. A red cross.
				tileIconUrl = "null";
				tileIconName = "";
			} else if (i < availableIcons.length + 1) {
				tileIconUrl = availableIcons[i - 1].getPickIconUrl();
				tileIconName = availableIcons[i - 1].getName();	//friendly name of the icon
			} else {
				loadIcon = false; //draw background tile instead.
				tileIconUrl = "null";
				tileIconName = "";
			}
			initObject["tileIconUrl"] = tileIconUrl;
			initObject["tileIconName"] = tileIconName;
			
			
			
			var depth:Number= startTileDepth + i;
			iconTiles.push(parentMc.attachMovie("ColorTile", "mIconTile" + i, depth, initObject));
			
			with (iconTiles[i]) {
				if (loadIcon) {
					//create and load icon pic on tile
					var mIconTilePic:MovieClip = attachMovie("ColorTile", "mIconTilePic", 20);
							
					var loadListener:Object = new Object();
					loadListener.onLoadInit = function(mc:MovieClip) {
						mc._width = thisObj.tileWidth;
						mc._height = thisObj.tileHeight;
						mc.onPress = function(){
							thisObj2.pickIconUrl = this._parent.tileIconUrl;
							thisObj2.closePickWindow();
						}
					}
					loadListener.onLoadError  = function(target_mc:MovieClip, errorCode:String, httpStatus:Number) {
						thisObj2._global.flamingo.showError("Exception in gui.IconPicker.as.", "Can not load icon with url = "+target_mc._parent.tileIconUrl+" \nErrorCode = "+errorCode+"\nhttpStatus = "+httpStatus,3000);
						//trace("IconPicker.as load error. can not load icon: with url = "+target_mc._parent.tileIconUrl+"  errorCode = "+errorCode+"\nhttpStatus = "+httpStatus);
					}
					var mcLoader:MovieClipLoader = new MovieClipLoader();
					mcLoader.addListener(loadListener);
					
					mcLoader.loadClip(tileIconUrl, mIconTilePic);
				} else {
					//create and draw tile background and click surface
					var mIconTileBg:MovieClip = attachMovie("ColorTile", "mIconTileBg", 10);
					with (mIconTileBg) {
						createEmptyMovieClip("mIconTileBgGraphicNormal", 1);
						with (mIconTileBgGraphicNormal) {
							beginFill(thisObj2.tileBgColor, 100);
							moveTo(0, 0);
							lineTo(thisObj2.tileWidth, 0);
							lineTo(thisObj2.tileWidth, thisObj2.tileHeight);
							lineTo(thisObj2.tileWidth, thisObj2.tileHeight);
							lineTo(0, thisObj2.tileHeight);
							lineTo(0, 0);
							endFill();
							
							//draw red cross to indicate null value
							lineStyle(2,0xff0000,100);
							moveTo(2, 2);
							lineTo(thisObj2.tileWidth - 2, thisObj2.tileHeight - 2);
							moveTo(thisObj2.tileWidth - 2, 2);
							lineTo(2, thisObj2.tileHeight - 2);
						}
					}
					mIconTileBg.onPress = function(){
						thisObj2.pickIconUrl = this._parent.tileIconUrl;
						thisObj2.closePickWindow();
					}
				}
			}
		}	
	}
}
