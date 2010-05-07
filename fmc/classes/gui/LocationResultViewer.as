/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component LocationResultViewer
* A component that shows locationfinder results in a htmlTextArea or as movieclips with TextFields with RollOver 
* functionality (highlight locations in a highlightlayer component). By default the LocationFinder results are 
* shown just under the comboboxes widthin the LocationFinder Component, with this LocationResultViewer 
* the Location results can be shown anywhere in the flamingo viewer f.i. in a window. 
* @file flamingo/fmc/classes/flamingo/gui/LocationResultViewer.as  (sourcefile)
* @file flamingo/fmc/LocationResultViewer.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/classes/flamingo/gui/LocationResults.as
* @file flamingo/fmc/classes/flamingo/gui/LocationResult.as
* The last two classes are only used when rollover/highlight functionality is configured (in one of
* the Locations of the LocationFinder component). For a more thourough explanation on how to configure
* highlight functionality see the LocationFinder Component.
**/

/** @tag <fmc:LocationResultViewer> 
* This tag defines a locationresultviewer instance. ...
* @class gui.LocationResultViewer extends AbstractComponent
* @hierarchy child node of Flamingo or a container component 
* @example
* <fmc:Window top="100" left="100" width="300" height="300">
    <fmc:LocationResultViewer id="locationresults" top="top" left ="5" width="100%" height="100%" visible="false" >
     	<style id='a' font-family='verdana' font-size='13px' color='#0033cc' display='block' font-weight='normal'/> 
    </fmc:LocationResultViewer> 
  </fmc:Window> 
*/


import mx.containers.ScrollPane;

import roo.HighlightLayer;

import mx.core.UIObject;
import mx.controls.TextArea;

import core.AbstractComponent;
import core.AbstractContainer;

import mx.utils.Delegate;


class gui.LocationResultViewer extends AbstractComponent {
    
    private var htmlText:String = "";
    private var textArea:TextArea = null;
    private var locationFinder:Object = null;
    private var locations:Array = null;

	private var mask : Boolean = true;
	private var intervalId: Number;
	private var scrollPane : ScrollPane; 

	function setLocations(locations:Array){
		this.locations = locations;
		if(textArea != null){
			textArea._visible = false;
		}
		if(scrollPane!=null){
			scrollPane.removeMovieClip();
		}
		scrollPane = ScrollPane(attachMovie("ScrollPane", "mScrollPane", this.getNextHighestDepth()));
		scrollPane.contentPath = "LocationResults";
    	scrollPane.content.viewer = this;
    	scrollPane.setSize(__width, __height);
        scrollPane.content.drawLocations(locations); 
	}
	
	function doClearInterval():Void{
		clearInterval(intervalId);
	}
	
	function doSetIntervalId(id:Number):Void{
		intervalId = id;
	}
	
	function getString(item:Object, stringid:String):String {
		return locationFinder.getString(item,stringid);
	}
	function _zoom(index:Number) {
	 	locationFinder._zoom(index);	
	}
	 
	function _next() {
	 	locationFinder._next();
	 	
	 }
	 function _prev() {
	 	locationFinder._prev();
	 }

	function setText(text:String):Void {
		if(textArea == null){
			addTextArea();
		} 
		if(scrollPane != null){
		 	scrollPane._visible = false;
		}
		textArea._visible = true; 
        textArea.setText(text);
    }

    
     function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
    	super.setBounds(x,y,width,height);
    	textArea.setSize(width,height); 
    	scrollPane.setSize(width,height);
    }
    function setLocationFinder(locationFinder:Object):Void{
    	this.locationFinder = locationFinder;
    }
    

    private function addTextArea():Void {
        var initObject:Object = new Object();
        initObject["html"] = true;
        textArea = TextArea(this.attachMovie("TextArea", "mTextArea" +this.getNextHighestDepth(), this.getNextHighestDepth(), initObject));
        textArea.setSize(this.__width,this.__height);
        textArea.styleSheet = _global.flamingo.getStyleSheet(locationFinder);

	}
	
  
    
}
