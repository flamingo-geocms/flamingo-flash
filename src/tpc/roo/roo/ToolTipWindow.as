import core.AbstractComponent;
import roo.GradientFill;
import mx.controls.CheckBox;
import mx.utils.Delegate;
import mx.core.UIObject;

/**
 * @author velsll
 */
class roo.ToolTipWindow extends AbstractComponent {
	
	private var color1 : Number = 0x000000;
	private var color2 : Number = 0xffffff;
	private var alpha1 : Number = 100;
	private var alpha2 : Number = 100;
	private var roundedCorners : String = "ul,ur,ll,lr";
	private var gradientDirection : String = "ver";
	private var cSize : Number = 15;
	private var outline : Boolean = false;
	private var linecolor : Number = 0x000000;
	private var gradientFill:GradientFill = null;

	private var toolText : String;
	private var toolTextField : TextField;
	private var checkBox : CheckBox;
	private var tool : Object;

	private var thisObj: Object;
	private var initVisible : String = "true";
	private var closeButton : MovieClip;

	private var cookieElapsePeriod : Number = 604800000;
	private var cookieElapsed:Boolean = false; 
	
	function onLoad():Void {
        	super.onLoad();	
	}
	
	function setTool(tool:Object){
		setCookieElapsed();
		if(initVisible == "true" && cookieElapsed){
			draw(tool);
		} 
	}
	
	private function setCookieElapsed():Void{
		var curDate:Date = new Date();
		if(_global.flamingo.getCookie("toolTipIdentifyDate")!=undefined){
			var dateString:String = _global.flamingo.getCookie("toolTipIdentifyDate");
			var dateArray:Array = dateString.split("/");
			var curUTC:Number = Date.UTC(curDate.getYear(),curDate.getMonth(),curDate.getDate(), curDate.getHours(),curDate.getMinutes(),curDate.getSeconds());
			var cookieUTC:Number = Date.UTC(dateArray[0],dateArray[1],dateArray[2],dateArray[3],dateArray[4],dateArray[5]);
			if((curUTC - cookieUTC) > cookieElapsePeriod){
				cookieElapsed = true;
			} else {
				cookieElapsed = false;
			}
		} else {
			cookieElapsed = true;
		}
	}
	
	function setAttribute(name:String, value:String):Void {
		if (name == "gradientcolor1") {
            color1 = Number(value);
        } else if (name == "gradientcolor2") {
            color2 = Number(value);
		} else if (name == "initVisible") {
            initVisible = value;  
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
	 	} else if (name == "cookieelapsedays") {
	 		cookieElapsePeriod = Number(value) * 86400000;
		}	 		
	}
	
	function getCookieElapsed():Boolean{
		return cookieElapsed;
	}
	
	function draw(tool:Object){
		remove();
		this.tool = tool;
		var toolPos:Object = _global.flamingo.getPosition(tool);

		var point:Object = new Object();
		point.x=0;
		point.y=0;	
		this.localToGlobal(point);
		//cannot use localToGlobal for tool in init fase not yet positioned
		var dx:Number =  getAbsX(tool) + toolPos.width/2 - point.x;// getAbsX(tool)+ toolPos.width/2 - getAbsX(this);
		var dy:Number = 0;
		//buttonbar above the tooltipwindow 
		//TODO buttonbar below the tooltipwindow
		//if(getAbsY(tool) < point.y){
			dy = point.y - getAbsY(tool) - toolPos.height + 3;
		//}
		//else {
			//dy = getAbsY(tool)- point.y + toolPos.height + 3;
		//}
		gradientFill = new GradientFill(color1,color2,alpha1,alpha2,roundedCorners,
								gradientDirection, cSize, outline,linecolor);				
		gradientFill.draw(this);
		if(outline){
        	lineStyle(0, linecolor, 100,true);
        }
        moveTo(dx,-dy);
        beginFill(color1, alpha1);
        lineTo(this.__width/2-10,0);
        lineTo(this.__width/2+10,0);
        lineTo(dx,-dy);
        endFill();
        closeButton = this.createEmptyMovieClip("mCloseButton", this.getNextHighestDepth());
		closeButton._x = this.__width -20;
		closeButton._y = 8;
		closeButton.beginFill(0xffffff, 100);
        closeButton.lineStyle(1,0x000000,40);
        closeButton.moveTo(0,0);
        closeButton.lineTo(10,0);
        closeButton.lineTo(10,10);
        closeButton.lineTo(0,10);
        closeButton.lineTo(0,0);
        closeButton.lineTo(10,10);
        closeButton.moveTo(0,10);
        closeButton.lineTo(10,0);
        closeButton.useHandCursor = false;
        closeButton["thisObj"] = this;
        closeButton.onPress = function (){
        	thisObj.remove();
        }; 
        closeButton.addEventListener("press", Delegate.create(this, onClickClosebutton));
        
        toolTextField = this.createTextField("mToolText", this.getNextHighestDepth(),10,20 ,this.__width -15, this.__height -40);
		var textFormat:TextFormat = new TextFormat();
    	textFormat.font = "_sans";
    	textFormat.size = 11;
		toolTextField.setNewTextFormat(textFormat);
		toolTextField.multiline = true;
		toolTextField.wordWrap = true;
		toolTextField.html = true;
		toolTextField.selectable = false;
		toolTextField.htmlText = _global.flamingo.getString(this,"tooltiptext");
		checkBox = CheckBox(attachMovie("CheckBox", "mCheckBox" , this.getNextHighestDepth(), {_x:10,_y:this.__height-30, _width:this.__width -10}));
        checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
        checkBox.textIndent = 5;
        checkBox.setStyle("fontFamily", "_sans");
        checkBox.setStyle("fontSize", 11);
        checkBox.label = _global.flamingo.getString(this,"checktext");
	}
	
	private function getAbsX(comp:Object):Number{
		var x:Number = 0;
		while (comp != _root){
			var parPos:Object = _global.flamingo.getPosition(comp);
			x += parPos.x;
			comp = comp._parent;
		}
		return x;
	}
	
	private function getAbsY(comp:Object):Number{
		var y:Number = 0; 
		while (comp != _root){
			var parPos:Object = _global.flamingo.getPosition(comp);
			y+=parPos.y;
			comp = comp._parent;
		}
		return y;
	}
	
	
	
	
	private function onClickClosebutton() : Void {
		remove();
	}

	function remove(){
		clear();
		toolTextField.removeTextField();
		closeButton.removeMovieClip();
		checkBox.removeMovieClip();
	}
		

	private function onClickCheckBox() : Void {
		var curDate = new Date();
		_global.flamingo.setCookie("toolTipIdentifyDate",curDate.getYear()+ "/" + curDate.getMonth() + "/" + curDate.getDate() + "/"  + curDate.getHours() + "/" + curDate.getMinutes()+ "/" + curDate.getSeconds());
		this.setVisible(false);
	}
}
