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
* @file flamingo/cmc/classes/flamingo/gui/LocationResultViewer.as  (sourcefile)
* @file flamingo/cmc/LocationResultViewer.swf (compiled component, needed for publication on internet)
* @file flamingo/cmc/classes/gui/LocationResults.as
* @file flamingo/cmc/classes/gui/LocationResult.as
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

import mx.core.UIObject;
import mx.controls.TextArea;

import core.AbstractComponent;
import core.AbstractContainer;
import gui.Map;

import mx.utils.Delegate;

import geometrymodel.Point;

class gui.LocationResultViewer extends AbstractComponent {
    
    private var htmlText:String = "";
    private var textArea:TextArea = null;
    private var locationFinder:Object = null;
    private var locations:Array = null;
 	private var locationlayer:MovieClip = null;
	private var mask : Boolean = true;
	private var intervalId: Number;
	private var scrollPane : ScrollPane;
	private var	useLocationFinder: Boolean = true;

	public function getMap (): Map {
		if (useLocationFinder) {
			return locationFinder.map;
		}
		
		for (var i: Number = 0; i < listento.length; ++ i) {
			var component: Object = _global.flamingo.getComponent (listento[i]);
			if (component.moveToExtent) {
				return Map (component);
			}
		}
		
		return null;
	}
	
	function init (): Void {
		super.init ();
		
		// Listen to components that provide locations to display:
		for (var i: Number = 0; i < listento.length; ++ i) {
			var component: MovieClip = _global.flamingo.getComponent (listento[i]);
			if (!component) {
				continue; 
			}
			
			_global.flamingo.addListener (this, component, this);
		}
	}
	
	function onFindLocation (source: MovieClip, locations: Array, updateFeatures: Boolean): Void {
		
		var i: Number;
		for (i = 0; i < locations.length; ++ i) {
			locations[i].str = "<span class='feature'><a href='asfunction:_parent._zoom,"+i+"'>"+locations[i].label+"</a></span>";
		}
		
		setLocations (locations);
		useLocationFinder = false;
		
		// Zoom to the first location if only a single result is found:
		if (locations.length == 1) {
			_zoom (0);
		} else if (locations.length == 0) {
			setText (_global.flamingo.getString (this, 'noresults', 'No results have been found'));
		}
	}

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
        
        useLocationFinder = true;
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
	
	function showLocation(index:Number) {
		var map:Map = getMap ();
		if(locationlayer == null){
			locationlayer = map.container.createEmptyMovieClip("mLocation", map.container.getNextHighestDepth());
		} else {
			locationlayer.clear();
		}
		var ext:Object = locations[index].extent;
		var min:Object = new Object;
		min.x = ext.minx;
		min.y = ext.miny;
		var pmin:Object = map.coordinate2Point(min);
		var max:Object = new Object;
		max.x = ext.maxx;
		max.y = ext.maxy;
		var pmax:Object = map.coordinate2Point(max);
		locationlayer.lineStyle(2, 0x00ff00, 100);	
		locationlayer.moveTo(pmin.x,pmin.y);
		locationlayer.lineTo(pmin.x,pmax.y);
		locationlayer.lineTo(pmax.x,pmax.y);
		locationlayer.lineTo(pmax.x,pmin.y);
		locationlayer.lineTo(pmin.x,pmin.y);
	}
	
	function isHighlightScale():Boolean {
		var map:Map = getMap ();
		var currentLocation:Object = locations[0].locationdata;
		if(map.getCurrentScale() >= currentLocation.highlightmaxscale){
			return false;
		} else {
			return true;
		}
	} 
	
	function clearLocation(){
		locationlayer.clear();
		
	}
	
	function _moveToLocation (index: Number): Void {
		
		var location: Object = locations[index],
			i: Number,
			map: Object;
		
		if (!location) {
			return;
		}
		
		// Zoom on all maps this component listens to:
		for (i = 0; i < listento.length; ++ i) {
			map = _global.flamingo.getComponent (listento[i]);
			if (!map || !map.moveToExtent) {
				continue;
			}
			
			map.moveToExtent (location.extent, 0);
		}
	}
	
	function _zoom(index:Number) {
		if (!useLocationFinder) {
			_moveToLocation (index);
		} else {
	 		locationFinder._zoom(index);	
		}
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
		 	//scrollPane.removeMovieClip();
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
