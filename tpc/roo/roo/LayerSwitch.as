/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
import mx.controls.RadioButton;
import mx.utils.Delegate;

import core.AbstractComponent;
import roo.LayerOGWMSLayerSwitchAdapter;

class roo.LayerSwitch extends AbstractComponent {
    
    private var layerOGWMSLayerSwitchAdapter:LayerOGWMSLayerSwitchAdapter = null;
    private var radioButton0:RadioButton = null;
    private var radioButton1:RadioButton = null;
    
    function onLoad():Void {
        super.onLoad();
        
        layerOGWMSLayerSwitchAdapter = new LayerOGWMSLayerSwitchAdapter(this);
        _global.flamingo.addListener(layerOGWMSLayerSwitchAdapter, listento[0], this);
        _global.flamingo.addListener(layerOGWMSLayerSwitchAdapter, listento[1], this);
        _global.flamingo.addListener(this, "flamingo", this);
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "titles") {
            addRadioButtons(value.split(","));
        }
    }
    
    function addRadioButtons(titles:Array):Void {
        var initObject:Object = new Object();
        initObject["groupName"] = "yoyo";
        initObject["selected"] = true;
        initObject["label"] = titles[0];
        radioButton0 = RadioButton(attachMovie("RadioButton", "mRadioButton0", 0, initObject));
        radioButton0.addEventListener("click", Delegate.create(this, onClickRadioButton));
        radioButton0.setStyle("fontSize", 11);
        initObject["_y"] = 15;
        initObject["selected"] = false;
        initObject["label"] = titles[1];
        radioButton1 = RadioButton(attachMovie("RadioButton", "mRadioButton1", 1, initObject));
        radioButton1.addEventListener("click", Delegate.create(this, onClickRadioButton));
        radioButton1.setStyle("fontSize", 11);
    }
    
    function onClickRadioButton(eventObject:Object):Void {
        var layer0:MovieClip = _global.flamingo.getComponent(listento[0]);
        var layer1:MovieClip = _global.flamingo.getComponent(listento[1]);
        
        if (eventObject.target == radioButton0) {
            radioButton1.selected = false;
        } else { // radioButton1
            radioButton0.selected = false;
        }
        swizch();
    }
    
    function onResize(o:Object) {
        _global.flamingo.position(this);
    }
    
    function swizch():Void {
        var layer0:MovieClip = _global.flamingo.getComponent(listento[0]);
        var layer1:MovieClip = _global.flamingo.getComponent(listento[1]);

        //set visibility according to radio buttons
        var layer0Visible:Number = layer0.getVisible();
        var layer1Visible:Number = layer1.getVisible();
        if (radioButton0.selected) {
            if (layer0Visible == -1) {
                layer0.setVisible(true);
            }
            if (layer1Visible == 1) {
                layer1.setVisible(false);
            }
        } else {
            if (layer1Visible == -1) {
                layer1.setVisible(true);
            }
            if (layer0Visible == 1) {
                layer0.setVisible(false);
            }
        }

        //switch visibility when out-of-scale
        var layer0Visible:Number = layer0.getVisible();
        var layer1Visible:Number = layer1.getVisible();
        if (Math.abs(layer0Visible) == 2) {
            if (layer1Visible == -1) {
                layer1.setVisible(true);
            }
        } else if (Math.abs(layer1Visible) == 2) {
            if (layer0Visible == -1) {
                layer0.setVisible(true);
            }
        }
        
        //enable radio buttons when both layers are within scale range, otherwise disable
        var layer0Visible:Number = layer0.getVisible();
        var layer1Visible:Number = layer1.getVisible();
        if ((Math.abs(layer0Visible) == 2) || (Math.abs(layer1Visible) == 2)) {
            radioButton0.enabled = false;
            radioButton1.enabled = false;
        } else if ((Math.abs(layer0Visible) == 1) && (Math.abs(layer1Visible) == 1)) {
            radioButton0.enabled = true;
            radioButton1.enabled = true;
        }
    }
    
}
