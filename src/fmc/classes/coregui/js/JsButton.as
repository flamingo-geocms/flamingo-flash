/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/

/** @component JsButton
* A component for a button with javascript API, and xml configurable behaviour and styling.
* @file flamingo/fmc/classes/flamingo/coregui/js/JsButton.as  (sourcefile)
* @file flamingo/fmc/JsButton.fla  (sourcefile)
* @file flamingo/fmc/JsButton.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:JsButton>
* This tag defines an JsButton instance.
* If toggle is true the buttons toggles its selected state. 
* If enabled is false the disabled image is shown which can be made to show graphically a greyed out state.
* URL's of button state images can be set to configure the styling. If no url is provided the default graphics are shown.
* @class coregui.js.JsButton extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component.
* @example
	<FLAMINGO>
		...
		<fmc:JsButton id="knop1" left="2" top="2" width="50" height="25" iconurl_up="assets/skin/knop1_skin_up.png" iconurl_over="assets/skin/knop1_skin_over.png" iconurl_sel="assets/skin/knop1_skin_sel.png" iconurl_dis="assets/skin/knop1_skin_dis.png" toggle="true" visible="true" enabled="true" selected="false">
			<string id="tooltip" en="Lasso tool" nl="Lasso tool"/>
		</fmc:JsButton>
		...
	</FLAMINGO>
* @attr toggle (true, false, default value: false) Sets the toggle state.
* @attr visible (true, false, default value: true) Sets the visible state.
* @attr enabled (true, false, default value: true) Sets the enabled state.
* @attr selected (true, false, default value: false) Sets the selected state.
* @attr iconurl_up (String) URL of the "up" state image (jpg or png) of the button.
* @attr iconurl_over (String) URL of the "over" state image (jpg or png) of the button.
* @attr iconurl_sel (String) URL of the selected state image (jpg or png) of the button.
* @attr iconurl_dis (String) URL of the disabled state image (jpg or png) of the button, i.e. when enabled = false.
*/

import coregui.*;
import core.AbstractComponent;

/**
 *  A component for a button with javascript API, and xml configurable behaviour and styling.
 */
class coregui.js.JsButton extends AbstractComponent {
    
    private var id:String = ""; 			// Set by xml config file
	private var tooltipText:String = null; 	// Set by init object.
	
	private var bSelected:Boolean = false;	//
	private var bToggle:Boolean = false;	//
	private var bEnabled:Boolean = true;	//
	private var bVisible:Boolean = true;	//
	private var bRollOver:Boolean = false;	//
	private var bDown:Boolean = false;		//
	
	private var iconurl_up:String = "";
	private var iconurl_over:String = "";
	private var iconurl_dis:String = "";
	private var iconurl_sel:String = "";
	
	private var loadList:Array;
	
	private var mIcon_up:MovieClip;
	private var mIcon_over:MovieClip;
	private var mIcon_dis:MovieClip;
	private var mIcon_sel:MovieClip;
    
	/**
	 * setAttribute
	 * @param	name
	 * @param	value
	 */
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
	/**
	 * init
	 */
    function init():Void {
		super.init();
		//make the button invisible untill all images are loaded
		this._visible = false; 
        useHandCursor = false;
		
		//if value not set by init object overrule it
		if (tooltipText == null) {
			tooltipText = _global.flamingo.getString(this, "tooltip");
		}
		
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
			target_mc._x = 0;
			target_mc._y = 0;
			target_mc._width = thisObj.width;
			target_mc._height = thisObj.height;
		};
		
		mclListener.onLoadComplete = function(target_mc:MovieClip) {
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
		image_mcl.loadClip(iconurl, mcGraph);
		loadList.push(mcGraph);
	}
	
	
	private function checkAllLoaded(target_mc:MovieClip):Void {
		var allLoaded:Boolean = true;
		for (var i:Number=0; i<loadList.length; i++) {
			if (target_mc._name == loadList[i]._name) {
				loadList.splice(i,1);
			} else {
				allLoaded = false;
			}
		}
		if (allLoaded) {
			onAllSkinsLoaded();
			if (this.visible)
				this._visible = true;
		}
	}
	
	private function onAllSkinsLoaded():Void {
		drawButton();
	}
		
	/**
	 * process event onPress
	 */
    function onPress():Void {
		if (bToggle) {
			bSelected = !bSelected;
		}
		bRollOver = false;
		bDown = true;
				
		drawButton();
		onDispatchJsButtonEvent();
    }
    
	/**
	 * process event onRollOver
	 */
    function onRollOver():Void {
		bRollOver = true;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
		_global.flamingo.showTooltip(tooltipText, this);
    }
    
	/**
	 * process event onRollOut
	 */
    function onRollOut():Void {
		bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
    
	/**
	 * process event onRelease
	 */
    function onRelease():Void {
		bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
    
	/**
	 * process event onReleaseOutside
	 */
    function onReleaseOutside():Void {
		bRollOver = false;
		bDown = false;
		
		drawButton();
		onDispatchJsButtonEvent();
    }
	
	/**
	 * drawButton
	 */
	function drawButton():Void{
		//trace("drawButton() id = "+id+" bVisible = "+bVisible+" bEnabled = "+bEnabled+" bRollOver = "+bRollOver+" bToggle = "+bToggle+" bSelected = "+bSelected);
		if (!bVisible) {
			hideIconGraphs();
		} else if (!bEnabled) {
			hideIconGraphs();
			mIcon_dis._visible = true;
		} else if (bRollOver) {
			hideIconGraphs();
			mIcon_over._visible = true;
		} else if (bToggle && bSelected) {
			hideIconGraphs();
			mIcon_sel._visible = true;
		} else {
			hideIconGraphs();
			mIcon_up._visible = true;
		}
		return;
	}

	private function hideIconGraphs():Void{
		mIcon_up._visible = false;
		mIcon_over._visible = false;
		mIcon_dis._visible = false;
		mIcon_sel._visible = false;
	}
	
	//API getters and setters
	
	/**
	Returns the id of the button: String.
	*/
	function getID():String {
        return id;
    }
    /**
	 * Sets the toggle state of the button. If false the selected state will also be set to false.
	 * @param toggle Boolean, toggle state of the button.
	*/
	function setToggleState(toggle:Boolean):Void {
		this.bToggle = toggle;
		if (!bToggle) {
			bSelected = false;
		}
		
		drawButton();
	}
    /**
	 * @return the toggle state of the button: Boolean.
	*/
	function getToggleState():Boolean {
		return bToggle;
	}
	/**
	 * Sets the selected state of the button
	 * @param selected Boolean, selected state of the button.
	*/
	function setSelectedState(selected:Boolean):Void {
		this.bSelected = selected;
		
		drawButton();
	}
    /**
	 * @return the selected state of the button: Boolean.
	*/
	function getSelectedState():Boolean {
		return bSelected;
	}
	/**
	 * Sets the enabled state of the button
	 * @param enabled Boolean, enabled state of the button.
	*/
	function setEnabledState(bEnabled:Boolean):Void {
		this.bEnabled = bEnabled;
		
		drawButton();
	}
    /**
	 * @return the enabled state of the button: Boolean.
	*/
	function getEnabledState():Boolean {
		return bEnabled;
	}
	/**
	 * onDispatchJsButtonEvent
	 */
	function onDispatchJsButtonEvent():Void {
		var jsButtonEvent:Object = new Object;
		jsButtonEvent["id"] = id;
		jsButtonEvent["down"] = bDown;
		jsButtonEvent["rollover"] = bRollOver;
		jsButtonEvent["enabled"] = bEnabled;
		jsButtonEvent["toggle"] = bToggle;
		jsButtonEvent["selected"] = bSelected;
	
		//API event onEvent();
		_global.flamingo.raiseEvent(this,"onEvent",id,jsButtonEvent);
	}

	
	//API events

	/**
	* Dispatched when the button state is changed.
	* @param id:String the id of the jsButton.
	* @param jsButtonEvent:Object the jsButtonEvent as object with properties: id:String, down:Boolean, rollover:Boolean, enabled:Boolean, toggle:Boolean, selected:Boolean.
	*/
	public function onEvent(id:String, jsButtonEvent:Object):Void {}
}
