/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels
* IDgis bv
 -----------------------------------------------------------------------------*/
 
 /** @component TabControler
* A component that can hold a number of Tab pages. This component replaces the old TabControl component
* This component had a limitation of maximal 2 Tabs. 
* @file flamingo/fmc/classes/flamingo/gui/TabControler.as  (sourcefile)
* @file flamingo/fmc/TabControler.fla (sourcefile)
* @file flamingo/fmc/TabControler.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:TabControler> 
* This tag defines a tabControler.
* @class gui.TabControler extends AbstractContainer
* @hierarchy child node of Flamingo 
* @example
* <fmc:TabControler left="left" width="300" top="top" bottom="bottom" borderalpha="0" startuptab="1">
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
 * @attr startuptab default:0 The tab number(0 is the first tab, 1 is the second tab etc.) of the tab that should be opened at startup 
 **/

import gui.Tab;

import mx.controls.Label;
import mx.utils.Delegate;

import core.AbstractContainer;

class gui.TabControler extends AbstractContainer {
	
	private var tabs : Array;
	private var numTabs : Number;
	private var startuptab: Number = 0;
	var buttons:MovieClip = null;
	
	function onLoad() {	
		//execute the rest when the movieclip is realy loaded and in the timeline
		if (!_global.flamingo.isLoaded(this)) {
			_global.flamingo.loadCompQueue.executeAfterLoad(id, this, onLoad);
			return;
		}
		super.onLoad();
		this.setVisible(false);
	}
	
	function setAttribute(name:String, value:String):Void {
        if (name == "startuptab") {
            startuptab = Number(value);
        }
    }
		
	function init():Void {		
	    var tabIDs:Array = getComponents();
        var tab:Tab = null;
        tabs = new Array();
		
        for (var tabId:String in tabIDs) {
            tab = _global.flamingo.getComponent(tabIDs[tabId]);
            if (tab.getComponentName() != "Tab") {
                continue;
            } 
            tab._y = 30;      
			tabs.push(tab); 
			numTabs++;  
			_global.flamingo.addListener(this, tab, this); 
        }
        if (tabs.length == 0) {
            _global.flamingo.tracer("Exception in gui.TabControler.<<init>>()\nNo tabs configured.");
            return;
        }
        drawTabButtons();
		_global.flamingo.addListener(this,"flamingo",this);	
		this.setVisible(true);
		tabs[startuptab].show();
	}

	private function drawTabButtons() : Void {
		if(buttons!=null){
			buttons.removeMovieClip();
		}
		buttons = this.createEmptyMovieClip("mc_buttons", this.getNextHighestDepth());
		var x:Number = 0
		for(var i:Number = 0; i< tabs.length;i++){
			var button:MovieClip = buttons.createEmptyMovieClip("mc_button" + i, i);
			
			var wdth:Number = tabs[i].getButtonWidth();
			if(wdth==undefined){
				wdth=(this.__width - x -4) / (tabs.length - i);
			}	
			var buttonLabel:Label = Label(button.attachMovie("Label", "mLabel", this.getNextHighestDepth(),{_width:wdth,_height:20,_y:5}));
        	var style:Object = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        	buttonLabel.setStyle("fontFamily", style["fontFamily"]);
        	buttonLabel.setStyle("fontSize", style["fontSize"]);
        	buttonLabel.setStyle("textAlign", "center");
        	buttonLabel.color = 0x666666;
        	buttonLabel.text = tabs[i].getLabel();
			button.__width = wdth;
			button.__height = 30;
			button._x = x;
			x+=wdth;
			button.addEventListener("onPress", Delegate.create(this, onClickButton));
			button.onPress = function() {
				this._parent._parent.onClickButton(this);
			};
			tabs[i].setButton(button);
			onClickButton(tabs[0].getButton());
		}	
	}
	
	function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
        var redraw:Boolean = false;
        if(this._x!=x ||this._y!=y||this.__width!=width){
        	redraw=true;
        }
        super.setBounds(x, y, width, height);
        if(redraw){
        	drawTabButtons();
        }
    }
	
	function onShow(tab:Tab){
		for(var i:Number = 0; i< tabs.length;i++){
			if(tabs[i] != tab){
				tabs[i].hide();
			}
		}
	}

	
    function onClickButton(button:MovieClip): Void {
		for(var i:Number = 0; i< tabs.length;i++){
			if(tabs[i].getButton() == button){
				tabs[i].show();
			} 
		}
	}

}
