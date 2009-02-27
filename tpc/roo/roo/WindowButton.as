import roo.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.WindowButton extends AbstractComponent {
    
    private var window:Object;
    
    function onLoad():Void {
        super.onLoad();
        
        this.useHandCursor = false;
    }
    
    function onPress():Void {
        this.gotoAndStop(3);
        
        window = _global.flamingo.getComponent(listento[0]);
        if (window._visible) {
            window.setVisible(false);
        } else {
            window.setVisible(true);
        }
    }
    
    function onRelease():Void {
        this.gotoAndStop(2);
    }
    
    function onReleaseOutside():Void {
        this.gotoAndStop(1);
    }
    
    function onRollOver():Void {
        this.gotoAndStop(2);
        
        _global.flamingo.showTooltip("legenda openen/sluiten", this);
    }
    
    function onRollOut():Void {
        this.gotoAndStop(1);
    }
    
    function resize() {
        _global.flamingo.position(this);
    }
    
}
