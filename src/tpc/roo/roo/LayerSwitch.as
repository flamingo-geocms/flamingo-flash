import mx.controls.RadioButton;
import mx.utils.Delegate;

import core.AbstractComponent;
import roo.LayerOGWMSLayerSwitchAdapter;

class roo.LayerSwitch extends AbstractComponent {
    
    private var layerOGWMSLayerSwitchAdapter:LayerOGWMSLayerSwitchAdapter = null;
    private var radioButton0:RadioButton = null;
    private var radioButton1:RadioButton = null;
    private var layers0:Array = null;
    private var layers1:Array = null;
    private var layerNames0:String = null;
    private var layerNames1:String = null;
	private var windowButton : String;

	function onLoad():Void {
        super.onLoad();
        
        layerOGWMSLayerSwitchAdapter = new LayerOGWMSLayerSwitchAdapter(this);
        for (var i:Number = 0; i < listento.length; i++) {
            _global.flamingo.addListener(layerOGWMSLayerSwitchAdapter, listento[i], this);
        }
        _global.flamingo.addListener(this, "flamingo", this);
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "titles") {
            addRadioButtons(value.split(","));
        }
        if (name == "layers1") {
        	layerNames0 = value;
        }
        if (name == "layers2") {
        	layerNames1 = value;
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

        if (layers0 == null) {
        	layers0 = getLayerComponents(layerNames0);
        }

        if (layers1 == null) {
        	layers1 = getLayerComponents(layerNames1);
        }

        for (var i:Number = 0; i < layers0.length; i++) {
        	setLayerVisibility(layers0[i], radioButton0.selected, isAllOutOfScale(layers1));
        }

        for (var j:Number = 0; j < layers1.length; j++) {
        	setLayerVisibility(layers1[j], radioButton1.selected, isAllOutOfScale(layers0));
        }

        
        //enable radio buttons when both layer sets are within scale range, otherwise disable
    
        if ((!isAllOutOfScale(layers0)) && (!isAllOutOfScale(layers1))) {
            radioButton0.enabled = true;
            radioButton1.enabled = true;
           } else {
            radioButton0.enabled = false;
            radioButton1.enabled = false;
        }
    }
    
    
    private function getLayerComponents(layerNames:String):Array {
    	var lyrs:Array = layerNames.split(",");
    	var lyrComp:Array = new Array();
    	for (var i:Number = 0; i < lyrs.length; i++) {
    		lyrComp.push(_global.flamingo.getComponent(lyrs[i]));
    	}
    	return lyrComp;
    }
    
    private function setLayerVisibility(layer:MovieClip, buttonSelected:Boolean, othersOutOfScale:Boolean):Void {
        if ((buttonSelected || othersOutOfScale) && layer.getVisible() < 0) {
          //_global.flamingo.tracer("layer = " + layer + " buttonSelected = " + buttonSelected + " othersOutOfScale = " + othersOutOfScale + " vis = " + layer.getVisible() );
        	layer.setVisible(true);
        }
        else if ((!buttonSelected && !othersOutOfScale) && layer.getVisible() > 0) {
          //_global.flamingo.tracer("layer = " + layer + " buttonSelected = " + buttonSelected + " othersOutOfScale = " + othersOutOfScale + " vis = " + layer.getVisible() );
        	layer.setVisible(false);
        }
    }
    
    private function isAllOutOfScale(layers:Array):Boolean {
    	var allOutOfScale:Boolean = true;
    	for (var i:Number = 0; i < layers.length; i++) {
    		if (Math.abs(layers[i].getVisible()) != 2) {
    			allOutOfScale = false;
    		}
    	}
    	return allOutOfScale;
    }
    
    
    function onUpdateComplete(layer:MovieClip, updateTime:Number):Void {
        swizch();
    }
    
}
