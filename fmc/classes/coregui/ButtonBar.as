/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import coregui.*;
import tools.Logger;
import event.ActionEvent;
import event.ActionEventListener;

class coregui.ButtonBar extends MovieClip implements ActionEventListener{
    
    static var HORIZONTAL:Number = 0;
    static var VERTICAL:Number = 1;
    
    private var buttonWidth:Number = 10; // Set by init object.
    private var buttonHeight:Number = 10; // Set by init object.
    private var orientation:Number = HORIZONTAL; // Set by init object.
    private var spacing:Number = 15; // Set by init object.
    private var expandable:Boolean = false; // Set by init object.
	private var popwindow:Boolean = false; // Set by init object.
    private var buttonConfigs:Array = null; // Set by init object.
    private var buttons:Array = null;
	
	private var backgroundpadding:Number = 10; // Set by init object.
	private var backgroundfillcolor:Number = 0x666666; // Set by init object.
	private var backgroundfillopacity:Number = 50; // Set by init object.
	private var backgroundborderwidth:Number = 2; // Set by init object.
	private var backgroundborderspacing:Number = 2; // Set by init object.
	private var backgroundbordercolor:Number = 0xcccccc; // Set by init object.
	private var backgroundborderopacity:Number = 50; // Set by init object.	
	
	private var barbackground:MovieClip = null;
	private var default_xpos:Number = 0;
	private var default_ypos:Number = 0;
	private var popUpWindowDX:Number = 15; // Set by init object.
	private var popUpWindowDY:Number = 22; // Set by init object.
	private var intervalId:Number;
	private var popUpWindowHideDelay:Number = 1000; // Set by init object.
	private var popUpWindowVisible:Boolean = false;
	
	private var setXIntervalId;
	
    function onLoad():Void {
		default_xpos = _x;
		default_ypos = _y;
	
        if ((orientation != HORIZONTAL) && (orientation != VERTICAL)) {
            _global.flamingo.tracer("Exception in coregui.ButtonBar.<<init>>(" + orientation + ")");
        }
        if (buttonConfigs == null) {
            _global.flamingo.tracer("Exception in coregui.ButtonBar.<<init>>()");
        }
        
        buttons = new Array();
        
        if (expandable) {
            addBackground();
        } else {
			if (popwindow){
				showPopUpWindowBar();
			}else{
	            addButtons();
			}
        }

		
    }
	
	function onActionEvent(actionEvent:ActionEvent):Void {
        var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
		if (sourceClassName + "_" + actionType == "Button_" + ActionEvent.CLICK) {
			if (expandable) {
				if (popwindow) {
					removePopUpWindow(true);
				} else {
					removeButtons();
				}
			}
        }
    }
    
    
    private function addBackground():Void {
        var background:MovieClip = createEmptyMovieClip("mBackground", 1);
        background.moveTo(0, 0);
        background.lineStyle(1, 0x404040, 100);
        background.beginFill(0x000000, 0);
        background.lineTo(buttonWidth - 1, 0);
        background.lineTo(buttonWidth - 1, buttonHeight - 1);
        background.lineTo(0, buttonHeight - 1);
        background.endFill();
    }
    
    private function addButtons():Void {
        for (var i:Number = 0; i < buttonConfigs.length; i++) {
            addButton(ButtonConfig(buttonConfigs[i]), i);
        }
		setXIntervalId = setInterval(this,"setMovieclipX",10);
		
    }
    
    private function addButton(buttonConfig:ButtonConfig, i:Number):Void {
        var symbolID:String = buttonConfig.getGraphicURL();
        var initObject:Object = new Object();
		initObject["_width"] = buttonWidth;
		initObject["_x"] = 123;
		initObject["_height"] = buttonHeight;
        if (orientation == HORIZONTAL) {
            initObject["_x"] = i * (buttonWidth + spacing);
        } else { // VERTICAL
            initObject["_y"] = i * (buttonHeight + spacing) + 20;
        }
		initObject["id"] = i;
        initObject["tooltipText"] = buttonConfig.getToolTipText();
		initObject["actionEventListener"] = buttonConfig.getActionEventListener();
        initObject["url"] = buttonConfig.getURL();
        initObject["windowName"] = buttonConfig.getWindowName();
		var b:MovieClip = attachMovie(symbolID , "m" + symbolID + i, getNextHighestDepth(),initObject);
		
        buttons.push(b);
		buttons[i].addActionEventListener(this);
	}

	private function setMovieclipX(){
		for (var i:Number = 0; i < buttons.length; i++) {
            buttons[i]._x = i * (buttonWidth + spacing);
		}		
		clearInterval(setXIntervalId);
	}
    
    private function removeButtons():Void {
		for (var i:Number = 0; i < buttons.length; i++) {
            buttons[i].onPress = null;
		}
        for (var j:String in buttons) {
            buttons[j].removeMovieClip();
        }
        buttons = new Array();
    }
    
	private function addBarBackground():Void {
		var w = buttonWidth;
		var h = buttonHeight;
		if (orientation == HORIZONTAL) {
            w = buttonConfigs.length * (buttonWidth + spacing) - spacing;
        } else { // VERTICAL
            h = buttonConfigs.length * (buttonHeight + spacing) - spacing;
        }
		
		barbackground = createEmptyMovieClip("mBarBackground", 0);
		
		barbackground.moveTo(-backgroundpadding, -backgroundpadding);
		barbackground.beginFill(backgroundfillcolor, backgroundfillopacity);
		barbackground.lineTo(w + backgroundpadding, -backgroundpadding);
		barbackground.lineTo(w + backgroundpadding, h + backgroundpadding);
		barbackground.lineTo(-backgroundpadding, h + backgroundpadding);
		barbackground.lineTo(-backgroundpadding, -backgroundpadding);
		barbackground.endFill();
		
		barbackground.lineStyle(backgroundborderwidth, backgroundbordercolor, backgroundborderopacity);
		barbackground.moveTo(-backgroundpadding + backgroundborderspacing, -backgroundpadding + backgroundborderspacing);
		barbackground.lineTo(w + backgroundpadding - backgroundborderspacing, -backgroundpadding + backgroundborderspacing);
		barbackground.lineTo(w + backgroundpadding - backgroundborderspacing, h + backgroundpadding - backgroundborderspacing);
		barbackground.lineTo(-backgroundpadding + backgroundborderspacing, h + backgroundpadding - backgroundborderspacing);
		barbackground.lineTo(-backgroundpadding + backgroundborderspacing, -backgroundpadding + backgroundborderspacing);
    }
	
	private function removeBarBackground():Void {
		barbackground.removeMovieClip();
	}
	
    function onMouseMove():Void {
		if (!expandable) {
			return;
        } else {
			if (popwindow) {
				if (hitTest(_root._xmouse, _root._ymouse)) {
					if (buttons.length > 0) {
						return;
					}
					if (!popUpWindowVisible){
						showPopUpWindowBar();
					}
				} else {
					if (buttons.length == 0) {
						_x = default_xpos;
						_y = default_ypos;
						removeBarBackground();
						popUpWindowVisible = false;
						return;
					}
					if (popUpWindowVisible) {
						if (intervalId!=null){
							clearInterval(intervalId);
						}
						intervalId = setInterval(this,"removePopUpWindow", popUpWindowHideDelay);
					}
					
				}
				
			
			} else {
				if (hitTest(_root._xmouse, _root._ymouse)) {
					if (buttons.length > 0) {
						return;
					}
					addButtons();
				} else {
					if (buttons.length == 0) {
						return;
					}
					removeButtons();
				}
			}
		}
	
    }
	function showPopUpWindowBar():Void{
		_x = default_xpos + popUpWindowDX;
		_y = default_ypos + popUpWindowDY;
		addBackground();
		addBarBackground();
		addButtons();
		popUpWindowVisible = true;
		if (intervalId!=null){
			clearInterval(intervalId);
		}
	}
	
	function removePopUpWindow(afterMouseDown:Boolean):Void{
		if (afterMouseDown==null) {
			afterMouseDown = false;
		}
		clearInterval(intervalId);
		if (!hitTest(_root._xmouse, _root._ymouse) || afterMouseDown) {
			_x = default_xpos;
			_y = default_ypos;
			removeBarBackground();
			removeButtons();
			popUpWindowVisible = false;
		}
	}
    
}
