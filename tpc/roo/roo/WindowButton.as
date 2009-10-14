import mx.controls.Label;

import roo.GradientFill;

import core.AbstractComponent;

import mx.core.UIObject;

class roo.WindowButton extends AbstractComponent {
    
    private var window:Object;
    private var window_visible:Boolean;
 	private var sticky:Boolean = true;
 	private var down:Boolean = false;
    private var labelText:String = "labeltje";
    private var tooltipText:String = "";
    private var buttonLabel:Label;
    private var cSize:Number = 6;
    private var gradientDown:GradientFill = null;
	private var gradientUp : GradientFill;
	private var gradientOver : GradientFill;

	function onLoad():Void {
        super.onLoad();
        this.useHandCursor = false;
        buttonLabel = Label(this.attachMovie("Label", "mLabel", this.getNextHighestDepth(),{_width:this.__width,_height:this.__height}));
        var style:Object = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        buttonLabel.setStyle("fontFamily", style["fontFamily"]);
        buttonLabel.setStyle("fontSize", style["fontSize"]);
        buttonLabel.setStyle("textAlign", "center");
        buttonLabel.color = 0x666666;
        labelText = _global.flamingo.getString(this,"label");
        tooltipText = _global.flamingo.getString(this,"tooltip");
        buttonLabel.text = labelText;
		gradientDown = new GradientFill(0xffffff,0xffffff,100,100,"ll,ul,lr,ur","ver",cSize,true,0x666666);
		gradientUp = new GradientFill(0x000000,0x000000,0,0,"ll,ul,lr,ur","ver",cSize,true,0x666666);
		gradientOver = new GradientFill(0x000000,0x000000,0,0,"ll,ul,lr,ur","ver",cSize,true,0x666666);
		draw();
	}
	
	function draw(){
		window = _global.flamingo.getComponent(listento[0]);
		_global.flamingo.addListener( this,window, this);
		if(window._visible){
			window_visible = true;
			buttonLabel.setStyle("fontWeight","bold");
			gradientDown.draw(this);
		} else {
			window_visible = false;
			buttonLabel.setStyle("fontWeight","normal");
			gradientUp.draw(this);
		}	
	}

	function setAttribute(name:String, value:String):Void {
	   if (name == "cornersize") {
            cSize = Number(value);    
       } else if (name == "sticky") {
       		if(value=="false"){ 
       			sticky = false;
       		}
       		else {
       			sticky = true;
       		}
		} 	 		
	}
    
    
    function onHide(win:Object){
    	if(!down){
    		window_visible = false;
    		buttonLabel.setStyle("fontWeight","normal");
    		gradientUp.draw(this);
    	}
    }
    
    function onShow(win:Object){
    	if (sticky||down) {
    		window_visible = true;
    		buttonLabel.setStyle("fontWeight","bold");
        	gradientDown.draw(this);
    	}
    }

    function onPress():Void {
    	window_visible = !window_visible;
    	down = true;
    	buttonLabel.setStyle("fontWeight","bold");
        gradientDown.draw(this);
        if(window_visible){
        	window.show();
        } else {
        	window.hide();
        }
    }
    
    function onRelease():Void {
    	down = false;
    	if(!sticky||!window_visible){
    		buttonLabel.setStyle("fontWeight","bold");
    		gradientOver.draw(this);
    	}
    }
    
    function onReleaseOutside():Void {
    	down = false;
    	 if(!sticky||!window_visible){
    		buttonLabel.setStyle("fontWeight","normal");
    		gradientUp.draw(this);
    	}

    }
    
    function onRollOver():Void {
    	if(!sticky||!window_visible){
         	buttonLabel.setStyle("fontWeight","bold");
         	gradientOver.draw(this);   
    	}    
        _global.flamingo.showTooltip(tooltipText, this);
    }
    
    function onRollOut():Void {
    	if(!sticky||!window_visible){
    		gradientUp.draw(this);
        	buttonLabel.setStyle("fontWeight","normal");
    	}
    }
    
    function setEnabled(enabled:Boolean):Void{
    	this.enabled = enabled;
		if(enabled){
    		
			buttonLabel.color = 0x666666;
		} else {
    		buttonLabel.color = 0xcccccc;
    	}
    }
    
    function resize() {
        _global.flamingo.position(this);
    }
    
}
