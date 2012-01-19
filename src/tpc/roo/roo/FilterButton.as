import roo.GradientFill;

import mx.controls.Label;

import roo.WindowButton;

import core.AbstractComponent;

class roo.FilterButton extends WindowButton {
   
    
	function onLoad():Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.onLoad();
	}
	
    function draw(){
    	buttonLabel.setStyle("fontWeight","normal");
		gradientUp.draw(this);
    }
    
    function onPress():Void {
        buttonLabel.setStyle("fontWeight","bold");
        gradientDown.draw(this); 
        window_visible = !window_visible;
        if (window_visible) {
            _global.flamingo.raiseEvent(this, "onButtonPress", this, "FilterButton");
        }
    }
    
    function onCloseWindow():Void {
        window_visible = false;
		draw();
        _global.flamingo.raiseEvent(this, "onButtonRelease", this, "FilterButton");
    }
    
    
}
