/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

class gui.GradientFill {
	private var color1 : Number = 0x000000;
	private var color2 : Number = 0xffffff;
	private var roundedCorners : String;
	private var gradientDirection : String = "hor";
	private var cSize : Number = 15;
	private var outline : Boolean = false;
	private var alpha1 : Number;
	private var alpha2 : Number;
	private var linecolor : Number;

	function GradientFill(color1:Number,color2:Number, alpha1:Number, alpha2:Number, 
							roundedCorners:String, gradientDirection:String,cSize:Number, 
							outline:Boolean,linecolor:Number){
		this.color1 = color1;
		this.color2 = color2;
		this.alpha1 = alpha1;
		this.alpha2 = alpha2;
		this.roundedCorners = roundedCorners;
		this.gradientDirection = gradientDirection;
		this.cSize = cSize;
		this.outline = outline;
		this.linecolor = linecolor;
	}
	
	function draw(parent:MovieClip):Void{
		var color:Color = null;
        color = new Color(this["color1"]);
        color.setRGB(color1);
        color = new Color(this["color2"]);
        color.setRGB(color2);
        var colors:Array = [color1, color2];
        var alphas:Array = [alpha1, alpha2];
        var ratios:Array = [0, 0xFF];
        var rotation:Number = 0;
        if(gradientDirection=="ver"){
        	rotation = Math.PI/2;
        }
        var wdth:Number = parent.__width;
        var hght:Number = parent.__height;
        if (wdth==undefined){
        	wdth = parent._width;
        }
        if (hght == undefined){
        	hght = parent._height;
        }	       
        
        var matrix:Object = {matrixType: "box", x: 0, y: 0, w:wdth, h:hght, r: rotation};
		
        parent.clear();
        if(outline){
        	parent.lineStyle(0, linecolor, 100, true);
        }
        parent.beginGradientFill("linear", colors, alphas, ratios, matrix);
        parent.moveTo(0,0);
        if(roundedCorners.indexOf("ul")!=-1){
        	parent.moveTo(0, cSize);
        	parent.curveTo(0,0,cSize,0);
        }
        if(roundedCorners.indexOf("ur")!=-1){
        	parent.lineTo(wdth - cSize, 0);
        	parent.curveTo(wdth, 0,wdth,cSize);
        } else {	
        	parent.lineTo(wdth, 0);
        }
       	if(roundedCorners.indexOf("lr")!=-1){	
        	parent.lineTo(wdth,hght -cSize);
        	parent.curveTo(wdth, hght, wdth -cSize, hght);
        } else {
        	parent.lineTo(wdth,hght);
        } 
        if(roundedCorners.indexOf("ll")!=-1){
        	parent.lineTo(cSize, hght);
        	parent.curveTo(0,hght,0,hght - cSize);	
        } else {	
        	parent.lineTo(0, hght);
        } 
        if(roundedCorners.indexOf("ul")!=-1){
        	parent.lineTo(0, cSize);
        } else {	
        	parent.lineTo(0, 0);
        }	
        parent.endFill();
	}
	
	
	
}
