/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import coregui.*;

class coregui.ButtonBar extends MovieClip {
    
    static var HORIZONTAL:Number = 0;
    static var VERTICAL:Number = 1;
    
    private var buttonWidth:Number = 10; // Set by init object.
    private var buttonHeight:Number = 10; // Set by init object.
    private var orientation:Number = HORIZONTAL; // Set by init object.
    private var spacing:Number = 5; // Set by init object.
    private var expandable:Boolean = false; // Set by init object.
    private var buttonConfigs:Array = null; // Set by init object.
    private var buttons:Array = null;
    
    function onLoad():Void {
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
            addButtons();
        }
    }
    
    private function addBackground():Void {
        var background:MovieClip = createEmptyMovieClip("mBackground", 0);
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
    }
    
    private function addButton(buttonConfig:ButtonConfig, i:Number):Void {
        var symbolID:String = buttonConfig.getGraphicURL();
        var initObject:Object = new Object();
		initObject["_width"] = buttonWidth;
		initObject["_height"] = buttonHeight;
        if (orientation == HORIZONTAL) {
            initObject["_x"] = i * (buttonWidth + spacing);
        } else { // VERTICAL
            initObject["_y"] = i * (buttonHeight + spacing);
        }
		initObject["id"] = i;
        initObject["tooltipText"] = buttonConfig.getToolTipText();
		initObject["actionEventListener"] = buttonConfig.getActionEventListener();
        initObject["url"] = buttonConfig.getURL();
        initObject["windowName"] = buttonConfig.getWindowName();
        buttons.push(attachMovie(symbolID, "m" + symbolID + i, i + 1, initObject));
    }
    
    private function removeButtons():Void {
        for (var i:String in buttons) {
            buttons[i].removeMovieClip();
        }
        buttons = new Array();
    }
    
    function onMouseMove():Void {
        if (!expandable) {
            return;
        }
        
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
