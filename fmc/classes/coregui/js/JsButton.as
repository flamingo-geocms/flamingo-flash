/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


/** @component JsButton
* A class for a javascript button with xml configurable behaviour and styling.
* @file flamingo/fmc/classes/flamingo/coregui/js/JsButton.as  (sourcefile)
* @file flamingo/fmc/JsButton.fla  (sourcefile)
* @file flamingo/fmc/JsButton.swf (compiled component, needed for publication on internet)
*/


import coregui.*;
import event.ActionEvent;
import event.ActionEventListener;
import core.AbstractComponent;

import mx.controls.Button;
import mx.core.*;

class coregui.js.JsButton extends AbstractComponent {
    
    private var id:String = ""; // Set by xml config file
	private var tooltipText:String = null; // Set by init object.
	
	private var bSelected:Boolean = false;	//
	private var bToggle:Boolean = false;	//
	private var bEnabled:Boolean = false;	//
	private var bVisible:Boolean = true;	//
	private var bRollOver:Boolean = false;	//
	private var bDown:Boolean = false;	//
	
	private var iconurl_up:String = "";
	private var iconurl_over:String = "";
	private var iconurl_dis:String = "";
	private var iconurl_sel:String = "";
	
	private var loadList:Array;
	
	private var mIcon_up:MovieClip;
	private var mIcon_over:MovieClip;
	private var mIcon_dis:MovieClip;
	private var mIcon_sel:MovieClip;
    
	function setAttribute(name:String, value:String):Void {
		if (name == "id") {
			if (value!=null){
            	this.id = String(value);
			}
		} else if (name == "selected") {
			if (value=="true"){
            	this.bSelected = true;
			}
		} else if (name == "toggle") {
			if (value=="true"){
            	this.bToggle = true;
			}
		} else if (name == "enabled") {
			if (value=="true"){
            	this.bEnabled = true;
			}
		} else if (name == "iconurl_up") {
			if (value!=null){
            	this.iconurl_up = String(value);
			}
		} else if (name == "iconurl_over") {
			if (value!=null){
            	this.iconurl_over = String(value);
			}
		} else if (name == "iconurl_dis") {
			if (value!=null){
            	this.iconurl_dis = String(value);
			}
		} else if (name == "iconurl_sel") {
			if (value!=null){
            	this.iconurl_sel = String(value);
			}
		}
	}
	
    function init():Void {
		super.init();
		
        useHandCursor = false;
		
		//if value not set by init object overrule it
		if (tooltipText == null) {
			tooltipText = _global.flamingo.getString(this, "tooltip");
		}
		
		//debug traces
		trace("JsButton.init() id = "+getID());
		trace("JsButton.init() iconurl_up = "+iconurl_up);
		trace("JsButton.init() iconurl_over = "+iconurl_over);
		trace("JsButton.init() iconurl_dis = "+iconurl_dis);
		trace("JsButton.init() iconurl_sel = "+iconurl_sel);
		
		//initialize loading of button graphics
		//if url is not provided than the default skin is used
		
		var initObj:Object = new Object();

		initObj["_width"] = this.width;
		initObj["_height"] = this.height;
		
		loadList = new Array();

		mIcon_up = this.createEmptyMovieClip("mIcon_up", this.getNextHighestDepth());
		mIcon_up.attachMovie("_up", "mIcon_default", mIcon_up.getNextHighestDepth(), initObj);
		mIcon_up.createEmptyMovieClip("mIcon_img", mIcon_up.getNextHighestDepth(), initObj);
		loadGraph(mIcon_up.mIcon_img, iconurl_up);
		
		mIcon_over = this.createEmptyMovieClip("mIcon_over", this.getNextHighestDepth());
		mIcon_over.attachMovie("_over", "mIcon_default", mIcon_over.getNextHighestDepth(), initObj);
		mIcon_over.createEmptyMovieClip("mIcon_img", mIcon_over.getNextHighestDepth(), initObj);
		loadGraph(mIcon_over.mIcon_img, iconurl_over);
		
		mIcon_sel = this.createEmptyMovieClip("mIcon_sel", this.getNextHighestDepth());
		mIcon_sel.attachMovie("_sel", "mIcon_default", mIcon_sel.getNextHighestDepth(), initObj);
		mIcon_sel.createEmptyMovieClip("mIcon_img", mIcon_sel.getNextHighestDepth(), initObj);
		loadGraph(mIcon_sel.mIcon_img, iconurl_sel);
		
		mIcon_dis = this.createEmptyMovieClip("mIcon_dis", this.getNextHighestDepth());
		mIcon_dis.attachMovie("_dis", "mIcon_default", mIcon_dis.getNextHighestDepth(), initObj);
		mIcon_dis.createEmptyMovieClip("mIcon_img", mIcon_dis.getNextHighestDepth(), initObj);
		loadGraph(mIcon_dis.mIcon_img, iconurl_dis);
    }
	
	private function loadGraph(mcGraph:MovieClip, iconurl:String):Void {
		if (iconurl == "") {
			return;
		}
		
		var thisObj:Object = this;
		var mclListener:Object = new Object();
		mclListener.onLoadInit = function(target_mc:MovieClip) {
			//trace("icon loaded target_mc = "+target_mc);
			target_mc._x = 0;
			target_mc._y = 0;
			target_mc._width = thisObj.width;
			target_mc._height = thisObj.height;
			
			//Voorbeeld code voor bitmapdata manipulatie
			/*
			import flash.display.BitmapData
			import flash.geom.Matrix

			var myBitmapData:BitmapData=new BitmapData(target_mc._width,target_mc._height);
			myBitmapData.draw(thisObj.mcGraph,new Matrix());

			var imageBmp:BitmapData = BitmapData.loadBitmap("myImage");
			// create movie clip and attach imageBmp
			this.createEmptyMovieClip("imageClip", 10);
			imageClip.attachBitmap(imageBmp, 2);
			*/
		};
		
		mclListener.onLoadComplete = function(target_mc:MovieClip) {
			trace("target_mc._parent.mIcon_default = "+target_mc._parent.mIcon_default);
			
			//remove mIcon_default
			if (target_mc._parent.mIcon_default != null) {
				target_mc._parent.mIcon_default.removeMovieClip();
			}
			
			target_mc.cacheAsBitmap = true;
			thisObj.checkAllLoaded(target_mc);
		}
		
		
		mclListener.onLoadError = function(target_mc:MovieClip) {
			trace("ERROR: can not load "+target_mc._name+"  of jsButton with id = "+thisObj.getID());
		};
		
		var image_mcl:MovieClipLoader = new MovieClipLoader();
		image_mcl.addListener(mclListener);
		
		trace("JsButton.loadGraph() iconurl = "+iconurl);
		image_mcl.loadClip(iconurl, mcGraph);
		loadList.push(mcGraph);
	}
	
	
	private function checkAllLoaded(target_mc:MovieClip):Void {
		//trace("loadList = "+loadList);
		//trace("checkAllLoaded called target_mc = "+target_mc);
		var allLoaded:Boolean = true;
		for (var i:Number=0; i<loadList.length; i++) {
			if (target_mc._name == loadList[i]._name) {
				//loaded
				trace("target_mc._name = "+target_mc._name+"  is loaded");
				loadList.splice(i,1);
			} else {
				allLoaded = false;
			}
		}
		if (allLoaded) {
			trace("All skins of id = "+id+" loaded");
			onAllSkinsLoaded();
		}
	}
	
	private function onAllSkinsLoaded():Void {
		trace("onAllSkinsLoaded() create the button object and initialize it with the loaded skins");
			
		drawButton();
	}
		
	//* getters and setters button state
	function getID():String {
        return id;
    }
    
	function setToggleState(toggle:Boolean):Void {
		this.bToggle = toggle;
		if (!bToggle) {
			bSelected = false;
		}
		
		drawButton();
	}
    
	function getToggleState():Boolean {
		return bToggle;
	}
	
	function setSelectedState(selected:Boolean):Void {
		this.bSelected = selected;
		
		drawButton();
	}
    
	function getSelectedState():Boolean {
		return bSelected;
	}
	
	function setEnabledState(bEnabled:Boolean):Void {
		this.bEnabled = bEnabled;
		
		drawButton();
	}
    
	function getEnabledState():Boolean {
		return bEnabled;
	}
	
	//* process events
    function onPress():Void {
		trace("JsButton.onPress() id = "+getID());
		if (bToggle) {
			bSelected = !bSelected;
		}
		bRollOver = false;
		bDown = true;
				
		drawButton();
		onDispatchJsButtonEvent();
    }
    
    function onRollOver():Void {
		trace("JsButton.onRollOver() id = "+getID());
		bRollOver = true;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
		_global.flamingo.showTooltip(tooltipText, this);
    }
    
    function onRollOut():Void {
		trace("JsButton.onRollOut() id = "+getID());
        bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
    
    function onRelease():Void {
		trace("JsButton.onRelease() id = "+getID());
        bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
    
    function onReleaseOutside():Void {
		trace("JsButton.onReleaseOutside() id = "+getID());
        bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
	
	function drawButton():Void{
		trace("drawButton() id = "+id+" bVisible = "+bVisible+" bEnabled = "+bEnabled+" bRollOver = "+bRollOver+" bToggle = "+bToggle+" bSelected = "+bSelected);
		if (!bVisible) {
			hideIconGraphs();
		} else if (!bEnabled) {
			hideIconGraphs();
			mIcon_dis._visible = true;
			trace("drawButton() id = "+id+" icon shown DISABLED");
		} else if (bRollOver) {
			hideIconGraphs();
			mIcon_over._visible = true;
			trace("drawButton() id = "+id+" icon shown OVER");
		} else if (bToggle && bSelected) {
			hideIconGraphs();
			mIcon_sel._visible = true;
			trace("drawButton() id = "+id+" icon shown SELECTED");
		} else {
			hideIconGraphs();
			mIcon_up._visible = true;
			trace("drawButton() id = "+id+" icon shown UP");
		}
		return;
	}

	private function hideIconGraphs():Void{
		mIcon_up._visible = false;
		mIcon_over._visible = false;
		mIcon_dis._visible = false;
		mIcon_sel._visible = false;
	}

	function onDispatchJsButtonEvent():Void {
		var jsButtonEvent:Object = new Object;
		jsButtonEvent["id"] = id;
		jsButtonEvent["down"] = bDown;
		jsButtonEvent["rollover"] = bRollOver;
		jsButtonEvent["enabled"] = bEnabled;
		jsButtonEvent["toggle"] = bToggle;
		jsButtonEvent["selected"] = bSelected;
	
		//call javascript method to dispatch 
		//API event onJsButtonChange();
		_global.flamingo.raiseEvent(this,"onJsButtonChange",this,jsButtonEvent);
		
		trace("onDispatchJsButtonEvent jsButtonEvent = "+jsButtonEvent);
	
	}

	
	//API events
	
	//
	/**
	* Dispatched when the button state is changed.
	* @param jsButton:MovieClip a reference to the jsButton.
	* @param jsButtonEvent:Object the jsButtonEvent as object.
	*/
	public function onJsButtonChange(jsButton:MovieClip, jsButtonEvent:Object):Void {}
}
