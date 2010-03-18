/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels
* IDgis bv
* Part of the LocationResultViewer component
 -----------------------------------------------------------------------------*/

import mx.utils.Delegate;
import gui.LocationResultViewer;
import roo.HighlightLayer;


class gui.LocationResult extends MovieClip {
	var location: Object; //set by initObject
	var viewer : Object;//set by initObject
	var index : Number; //set by initObject
	private var over : Boolean = false; 
	private var requestsent : Boolean = false;

	function onLoad(){
		var textField:TextField = this.createTextField("text",1,0,0, 600,20);			
		textField.html = true;
		var textFormat:TextFormat = new TextFormat();
		textFormat.font = "_sans";
		textFormat.underline = false;
		textFormat.color = 0x0000ff;
		textField.setNewTextFormat(textFormat);
    	textField.htmlText = location.str;
	}
	
	function onRollOver():Void{
		viewer.doClearInterval();
		this.over = true;
		TextField(this["text"]).textColor = 0x00ff00;
		viewer.doSetIntervalId(_global.setTimeout(Delegate.create({loc:this.location, thisObject: this},
					function (){	
						if(this.loc.locationdata.highlightLayer == null && this.loc.locationdata.hllayerid != null){
							this.loc.locationdata.highlightLayer =  _global.flamingo.getComponent(this.loc.locationdata.hllayerid);
						}
						this.loc.locationdata.highlightLayer.highlightFeature(this.loc.locationdata.wmsUrl, this.loc.locationdata.sldServletUrl, this.loc.locationdata.featureTypeName, this.loc.locationdata.propertyName, this.loc.propertyvalue, null, null)
						TextField(this.thisObject["text"]).textColor = 0xff0000;
						this.thisObject.requestsent = true;
					})
			,400));
		}

		function onRollOut():Void {
			clearHighlight();
		}
		function onReleaseOutside():Void{
			clearHighlight();
		}
		function onMouseUp():Void {
			if(this.over){
				viewer._zoom(index);
			}	
		}
		
		private function clearHighlight(){
			viewer.doClearInterval();
			if(requestsent){
				this.location.locationdata.highlightLayer.resetFeature();
			}
			this.over = false;
			this.requestsent = false;
			TextField(this["text"]).textColor = 0x0000ff;
		}			
}
