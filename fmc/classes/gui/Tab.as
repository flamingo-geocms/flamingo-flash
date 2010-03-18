 /*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component Tab
* A Tab defines a Tab page in the TabControler.
* @file flamingo/tpc/classes/flamingo/gui/Tab.as  (sourcefile)
* @file flamingo/fmc/Tab.fla (sourcefile)
* @file flamingo/fmc/Tab.swf (compiled component, needed for publication on internet)
* @configstring buttonlabel Label text used for Tab title.
*/

/** @tag <fmc:Tab> 
* This tag defines a tab instance. 
* @class gui.Tab 
* @hierarchy child node of TabControler 
* @example
*  <fmc:TabControler left="left" width="300" top="top" bottom="bottom">
  		<fmc:Tab width="100%" height="100%">
   			<string id="buttonlabel" nl="Kaartlagen"/>
   			<fmc:Legend id="kaartlagen" left="20" top="20"  right="right -5" bottom="bottom" listento="map" visible="false"/>
  		</fmc:Tab>
   		<fmc:Tab  width="100%" height="100%">
   			<string id="buttonlabel" nl="Legenda"/>
    		<fmc:Legend id="legenda"  left="20" top="20"  right="right -5" bottom="bottom" listento="map" visible="false"/>
   		</fmc:Tab>
   		<fmc:Tab  width="100%" height="100%">
    		<string id="buttonlabel" nl="Resultaten"/>
    		<fmc:IdentifyResultsHTML id="identifyResults" left = "5" top="5"  right="right -5" bottom="bottom -5" listento="map" borderalpha="0" wordwrap="false">
				...
    		</fmc:IdentifyResultsHTML>
   		</fmc:Tab>
 	</fmc:TabControler>
* @attr buttonwidth defines the width of the Tab button. By default the width is defined 
* by the width of the TabControler and the number of Tab's within the TabControler. Default
* width = width of TabControler / number of Tab's. If not for all Tab's a buttonwidth is configured. 
* The remaining width will be devided over the reamining buttons. 
*/
import core.AbstractContainer;

import coregui.GradientFill;

import gui.ScalableContainer;


class gui.Tab extends AbstractContainer {
	private var componentID:String = "Tab 1.0";
	private var label : String;
	private var button : MovieClip;
	private var buttonWidth:Number;
	private var gradientVisible:GradientFill=null;
	private var gradientInvisible:GradientFill=null;

	function onLoad(){
		super.onLoad();
		this.setVisible(false);
	}	
   	function init(){
		label = _global.flamingo.getString(this,"buttonlabel");
		gradientVisible = new GradientFill(0xffffff,0xffffff,100,100,"ur","ver",10,true,bordercolor);
		gradientInvisible = new GradientFill(0xffffff,0xcccccc,100,100,"ur","ver",10,true,bordercolor);
	}

    function setAttribute(name:String, value:String):Void {
        if (name == "buttonwidth") {
            buttonWidth = Number(value);
        }
    }

	function setButton(button:MovieClip){
		this.button = button;
	}
	
	function getButton():MovieClip {
		return button;
	}
	
	function getButtonWidth():Number {
		return buttonWidth;
	}
    
	
	function getLabel():String {
		return label;
	}

	function setVisible(visible:Boolean){
		super.setVisible(visible);
		if (visible){
			gradientVisible.draw(this.button); 
			button.moveTo(2,30);
			button.lineStyle(2,0xffffff);
			button.lineTo(button.__width,30);
			button["mLabel"].setStyle("fontWeight","bold");
		} else {
			gradientInvisible.draw(this.button);
			button["mLabel"].setStyle("fontWeight","normal");
		}		

		for (var i:String in listento) {
           var comp:Object = _global.flamingo.getComponent(listento[i]);   
			if(comp.setVisible instanceof Function){
				comp.setVisible(visible);
       		} else if (comp.show instanceof Function && visible){
       			comp.show();
			} else if(comp.hide instanceof Function && !visible){
       			comp.hide();
			} else {
				comp._visible = visible;
       		}
		}
	}
	
}
