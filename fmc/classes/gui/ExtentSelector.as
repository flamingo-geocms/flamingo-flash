/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component ExtentSelector
* A radiobuttons component that gives you the possibility to select an extent (defined by an Extent component). 
* An Extent defines an extent of a map, this can be f.i. the full extent or the current extent.  
* The ExtentSelector can be used in combination with a locationFinder component.
* The ExtentSelector should listento a mapComponent.
* @file flamingo/tpc/classes/flamingo/gui/ExtentSelector.as  (sourcefile)
* @file flamingo/fmc/ExtentSelector.fla (sourcefile)
* @file flamingo/fmc/ExtentSelector.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:ExtentSelector> 
* This tag defines an extentSelector instance. ...
* @class gui.ExtentSelector 
* @hierarchy child node of Flamingo 
* @example
   <fmc:ExtentSelector  id="extentselector"   left="0" top="210" width="200" listento="map">
    <fmc:Extent  id="fullExtent" extent="full">
      <string id="label" nl="Zoeken binnen gehele bestand" />
    </fmc:Extent>
    <fmc:Extent id="currentExtent" extent="current">
      <string id="label" nl="Zoeken binnen kaartbeeld"/>
    </fmc:Extent>
    <fmc:Extent id="nedExtent" extent="13562,306839;13562,875000;278026,875000;278026,306839">
      <string id="label" nl="Zoeken binnen Nederland"/>
     </fmc:Extent> 
  </fmc:ExtentSelector>
* @attr	default This is the id of an Extent that has to be selected at startup. By default the first Extent is selected. 
*/
import gui.Tab;

import mx.controls.RadioButton;

import gui.Extent;
import core.AbstractContainer;

import mx.utils.Delegate;

class gui.ExtentSelector extends AbstractContainer {
	private var componentID:String = "ExtentSelector";
	private var map:Object = null;
	private var textFormat:TextFormat; 
    private var currentExtent:Extent = null;
    private var extents:Array;
    private var numExtents:Number = 0;
	private var defaultExtentId : String;
	private var componentIDs:Array 

	function init():Void {
		setVisible(false);
		this.map =_global.flamingo.getComponent(listento[0]);
        componentIDs = getComponents();
        var component:MovieClip = null;
        extents= new Array();
        for (var comp:String in componentIDs) {
            component = _global.flamingo.getComponent(componentIDs[comp]);
            if (component.getComponentName() != "Extent") {
                continue;
            }
            component.setMap(map);
			extents.push(component); 
			numExtents++;
        }
        if (extents.length == 0) {
            _global.flamingo.tracer("Exception in gui.ExtentSelector.<<init>>()\nNo extent configured.");
            return;
        }
 	}
 	
 	function setAttribute(name:String, value:String):Void {		     
        if(name=="default"){
        	defaultExtentId = value;
        }    
    }
 	
 	function extentReady():Void{
		numExtents--;
		if(numExtents==0){
			drawExtentSelector();		
		}	
	}
 	    
    function getMap(){
    	return map;
    }
    
    function getMapId():String {
    	return _global.flamingo.getId(map);// mapId;
    }
	
	function getCurrentExtent():Extent {
		return currentExtent;
	}
	
	function getExtents():Array {
		return extents;
	}
	
	function setVisible(vis:Boolean, initiator:String):Void{
		//Make only (in)visible when initiated by the LocationFinder
		if(initiator=="locationFinder"){
			this.visible = vis;
			this._visible = vis;
		} 
	}
	
    private function drawExtentSelector():Void {
    	var radioContainer:MovieClip = this.createEmptyMovieClip("mRadio", this.getNextHighestDepth());
    	componentIDs.reverse();
    	for(var i:Number=0;i<extents.length;i++){
    		var nr:Number =radioContainer.getNextHighestDepth();
    	 	var extent:RadioButton = RadioButton(radioContainer.attachMovie("RadioButton", "mInAreaRadioButton" + nr, nr));
    	 	extent.move(5,5 + i*20);
			extent.data = extents[i];
			extent.groupName = "inExtent";
			extent.label = Extent(extents[i]).getLabel();
			extent.setSize(this.__width - 5 , 20);		
			if(defaultExtentId != null){
				if(componentIDs[i] == defaultExtentId){
					extent.selected = true;
					currentExtent = extents[i];
				}
			} else if(i==0){
				extent.selected = true;
				currentExtent = extents[i];
			}
		}  
    	radioContainer["inExtent"].addEventListener("click", Delegate.create(this, onClickRadioButton)); 
	}
	
	function onClickRadioButton(evtObj:Object):Void {
		currentExtent = Extent(evtObj.target.selectedRadio.data);
		_global.flamingo.raiseEvent(this, "onChangeSearchExtent", this);
		
	}
}