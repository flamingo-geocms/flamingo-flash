/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels
* IDgis bv
* Part of the LocationResultViewer component
 -----------------------------------------------------------------------------*/
import flash.external.ExternalInterface;

import mx.utils.Delegate;
import gui.LocationResultViewer;

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
		var tooltip:String = viewer.getString(location.locationdata,"locationtip");
		for (var a in location){ 
			var n:Number =tooltip.indexOf("["+a+"]", 0);
			if (n >= 0) {
				tooltip = tooltip.substring(0,n) + location[a] +
						tooltip.substr(n + a.length + 2);
			}
		} 
		if (tooltip!=null){	
			_global.flamingo.showTooltip(tooltip, this);
		}
		viewer.doClearInterval();
		this.over = true;	
		TextField(this["text"]).textColor = 0x00ff00;
		if( !viewer.isHighlightScale()){
			showLocation();
		} else {
			hightlightLocation();
		}
		
	}
		
	private function showLocation():Void{
		viewer.showLocation(index);
	}
		
		
	function hightlightLocation(){
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
			ExternalInterface.call("setROLayersVisible",this.location["app:planstatus"],this.location["app:typePlan"]);
			viewer._zoom(index);
		}	
	}
	
	private function clearHighlight(){
		viewer.clearLocation();
		viewer.doClearInterval();
		if(requestsent){
			this.location.locationdata.highlightLayer.resetFeature();
		}
		this.requestsent = false;
		this.over = false;
		TextField(this["text"]).textColor = 0x0000ff;
	}
	
}
