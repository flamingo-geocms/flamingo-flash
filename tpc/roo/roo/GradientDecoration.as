/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
import roo.GradientFill; 

import core.AbstractComponent;

import flash.geom.Matrix;

import mx.utils.Delegate; 

class roo.GradientDecoration extends AbstractComponent {

	
	private var color1 : Number = 0x000000;
	private var color2 : Number = 0xffffff;
	private var alpha1 : Number = 100;
	private var alpha2 : Number = 100;
	private var roundedCorners : String;
	private var gradientDirection : String = "hor";
	private var cSize : Number = 15;
	private var outline : Boolean = false;
	private var linecolor : Number = 0x000000;
	private var gradientFill:GradientFill = null;


	function onLoad():Void {
        super.onLoad();
        var lParent:Object = new Object();
        var thisObj:Object = this;
        lParent.onResize = function(mc:MovieClip) {
				thisObj.resize();
		};
		_global.flamingo.addListener(lParent, _global.flamingo.getParent(this), this);
		gradientFill = new GradientFill(color1,color2,alpha1,alpha2,roundedCorners,
								gradientDirection, cSize, outline,linecolor);
  		gradientFill.draw(this);
	}
	

	function setAttribute(name:String, value:String):Void {
	 	if (name == "gradientcolor1") {
            color1 = Number(value);
        } else if (name == "gradientcolor2") {
            color2 = Number(value);
        } else if (name == "cornersize") {
            cSize = Number(value);    
        } else if (name == "roundedcorners") {
            roundedCorners = value;
        } else if (name == "gradientdirection") {
            gradientDirection = value;
	 	} else if (name == "outline") {
	 		if(value=="true"){
	 			outline = true;
	 		} else {
	 			outline = false;
	 		} 	
	 	} else if (name == "linecolor") {
	 		linecolor = Number(value);
	 	} 
	}
	
	
	function resize() {
		gradientFill.draw(this);		
    }
	
}
