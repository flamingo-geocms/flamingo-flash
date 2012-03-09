
/**
 * @author Linda Vels
 */
import core.AbstractComponent;

import coregui.GradientFill;

import mx.controls.Label;

import gui.URL;

class coregui.GradientButton extends AbstractComponent{
	private var buttonLabel:Label;
	private var cSize:Number = 6;
    private var gradient1:GradientFill = null;
	private var gradient2:GradientFill = null;
	private var gradientDisabled:GradientFill = null; 
	private var disabled:Boolean = false;
	private var tooltipText:String = null;
	
	
	function init(){
		if (tooltipText == null) {
			tooltipText = _global.flamingo.getString(this, "tooltip");
		}
		gradient1 = new GradientFill(0xcccccc,0xffffff,100,100,"ll,ul,lr,ur","ver",cSize,true,0x666666);
		gradient2 = new GradientFill(0xffffff,0xcccccc,100,100,"ll,ul,lr,ur","ver",cSize,true,0x666666);
		gradientDisabled = new GradientFill(0xeeeeee,0xeeeeee,100,100,"ll,ul,lr,ur","ver",cSize,true,0xaaaaaa);
		this.useHandCursor = false;
        buttonLabel = Label(this.attachMovie("Label", "mLabel", this.getNextHighestDepth(),{_width:this.__width,_height:this.__height}));
        var style:Object = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        buttonLabel.setStyle("fontFamily", style["fontFamily"]);
        buttonLabel.setStyle("fontSize", style["fontSize"]);
        buttonLabel.setStyle("textAlign", "center");
    	draw();
	}
	
	function draw(){
		if(disabled){
			gradientDisabled.draw(this);
			buttonLabel.color = 0xbbbbbb;	
		} else {
			gradient1.draw(this);
			buttonLabel.text = getLabel();
			buttonLabel.color = 0x666666;	
		}
	}
	

	function getLabel():String {
        return _global.flamingo.getString(this,"label");
    }  
	

    
    function onReleaseOutside():Void {
    	if(!disabled){
	    	gradient1.draw(this);
    	}

    }
    
    function onRollOver():Void {
    	if(!disabled){
			gradient2.draw(this);
			_global.flamingo.showTooltip(tooltipText, this);
    	}
    }
    
    function onRollOut():Void {
    	if(!disabled){
			gradient1.draw(this);
    	}
    }
       
       
    function resize() {
        _global.flamingo.position(this);
    }
    
	
}
