import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component LocationPin
* A component that can be used in combination with the LocationFinder to indicate the position of a found location. 
* The pin is placed in the centre of the zoombox after the user zoomed to a location. It will remain untill the user zooms
* to another location or the user removes the pin by clicking on the cross. 
* @file flamingo/cmc/classes/flamingo/gui/LocationPin.as  (sourcefile)
* @file flamingo/cmc/LocationPin.fla (sourcefile)
* @file flamingo/cmc/LocationPin.swf (compiled component, needed for publication on internet)
* For configuration instructions see LocationFinder
*/
 
class gui.LocationPin extends AbstractComponent {
	private var tooltipText:String = null;
	private var coord:Object = null;
	private var map:Object = null;
	private var pin:MovieClip = null;  
	private var closebutton:MovieClip = null;
	
	
	function init(){
		_parent.init();
	}

	function setTooltipText(text:String){
		this.tooltipText = text;
	}
    
    function setMap(map:Object){
    	this.map = map;
    	var thisObj:Object = this;
    	var lMap:Object = new Object();
    	lMap.onChangeExtent = function(map:MovieClip){
			thisObj.setVisible(false);		
		}; 
		lMap.onStopMove = function(map:MovieClip){
			thisObj.setVisible(true);
			thisObj.placePin();	
		};   
		_global.flamingo.addListener(lMap, map , this);  	
    }
    
    function setCoord(coord:Object){
    	this.coord = coord;
    }
     
    function placePin(){
		var pixel:Object = null;
    	if(coord !=null){
    		pixel = map.coordinate2Point(coord);
    	} else {
    		pixel = new Object({x:-500,y:-500}); 
    	}
    	if(pin == null){
			pin = this.attachMovie("pin" ,"mPin",1);
    	}
    	if(closebutton == null){
			closebutton = this.attachMovie("close" ,"mClose",2);
			closebutton._x = 13;
			closebutton._y = -33;
			var thisObj:Object = this;
			closebutton.onRollOver = function () {
				_global.flamingo.showTooltip(thisObj.tooltipText, thisObj.closebutton);
			};	
			closebutton.onPress = function () {
				thisObj.setCoord(null);
				thisObj.placePin();		
			};	
		} 
		//this._alpha = 90;
		this._x = pixel.x;
    	this._y = pixel.y;
	}	
    	   


}
