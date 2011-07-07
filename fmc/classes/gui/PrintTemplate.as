/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component PrintTemplate 
* A container that holds and positions a number of components, with the intension to send them to a printer. 
* As a container it can hold any type of Flamingo component.
* With the print component a user can change the make-up of a template and preview it. Please refer to the Print component.
* Zoom and pan events in Flamingo's "main map" reflect on the first map in the template. 
* Identify events also reflect on the first map in the template, provided that the map is configured to handle identifies, 
* for example with an identify icon or with an identify results component that listens to the template's map.
* @file flamingo/fmc/classes/flamingo/gui/PrintTemplate.as  (sourcefile)
* @file flamingo/fmc/PrintTemplate.fla (sourcefile)
* @file flamingo/fmc/PrintTemplate.swf (compiled component, needed for publication on internet)
*/


/** @tag <fmc:PrintTemplate> 
* This tag defines a print template. A print template is a container and as such can hold child components, for example a map. 
* Configuration of the child components is as usual in Flamingo. 
* The legend component and the map component can both be configured in two ways now: direct and indirect. 
* Direct is the usual way with their own Flamingo attributes. 
* Indirect is by referring to another legend or map and using the configuration settings of that other component (attribute configobject in Map and Legend). 
* If ids are used for the child components, make sure the ids are unique within the whole Flamingo configuration. 
* Names do not have to be unique. The names of child components are used as labels in the "container inspector" of the print component. 
* The "container inspector" lets the user set the visibility of components within the template. 
* A print template should be registered as a listener to the legend component  that controls its map, 
* and that exists in the "legend container"of the print component. 
* If registered the legend will become visible when the corresponding template is chosen and invisible when another template is chosen by the user.
* @class gui.PrintTemplate extends gui.ScalableContainer
* @hierarchy child node of Print. 
* @example
	<fmc:Print id="print" width="100%" height="100%" visible="false"  borderwidth="0" listento="map">
		...
		<fmc:PrintTemplate id="printTemplate1" name="verticaal A4" dpi="144" format="A4" orientation="portrait"
			listento="printMonitor1" maps="printMap1">
			<fmc:Map id="printMap1" name="kaartbeeld" width="100%" height="100%" movequality="HIGH" configobject="map"/>
			<fmc:EditMap id="editMap2" name="redlining"  width="100%" height="100%"  listento="gis,printMap1" editable="false"/>
			<fmc:BitmapClone name="legenda" width="30%" height="25%" listento="legend" refreshrate="2500"/>
			<fmc:BitmapClone name="identify resultaten" width="40%" height="30%" right="right" listento="identify" refreshrate="2500"/>
			<fmc:PrintLabel name="identifylabel" top="0" width="40%" right="right"  text="Identify resultaten" fontfamily="arial" fontsize="18"/>
		</fmc:PrintTemplate>
	</fmc:Print>	
* @attr dpi (default value = "72", max value = "144") Resolution in which the template is intended to be sent to the printer. In dots per inch. 
* Raising the resolution will improve the print quality but it may also show more a more detailed map than one might expect.
* @attr format ("A3", "A4", no default value) Paper format to which the template is intended to be printed.
* @attr orientation ("landscape", "portrait", no default value) Paper orientation to which the template is intended to be printed.
* @attr maps (optional, default value: "") Comma separated string with ids of a the map components within the template. 
* The first one of these maps responds to zooms and pans and identifies in the "main map". 
* If a template contains a second map, for example as an overview map, make sure that the second map is not first in the list of maps.
*/

import gui.*;

class gui.PrintTemplate extends ScalableContainer {
    
    private var componentID:String = "PrintTemplate 1.0";
    
    var top:String = "220";
    
    private var dpi:Number = 144;
    private var format:String = null;
    private var orientation:String = null;
	private var mapStrings:Array = null;
    private var maps:Array = null;
	private var layerIDs:Array;
	private var map:MovieClip;
    private var mapListener:Object;
    private var layerListeners:Array;
    private var lFlamingo:Object;
    private var mapConfigLoaded:Boolean = false;
    private var legendConfigLoaded:Boolean = false;
    
    function PrintTemplate() {
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "dpi") {
            dpi = Number(value);
			if (dpi > 144){
				dpi = 144;
			}
        } else if (name == "format") {
            format = value;
        } else if (name == "orientation") {
            orientation = value;   		
        } else if (name == "maps") {
           mapStrings = value.split(",");
        }
        if(format!=null && orientation!=null){
        	setWidthAndHeigth();
        }
    }
    
    function go():Void {
      map = getParent("Print").getMap();
      
       /*	layerIDs = map.getLayers();
		_global.flamingo.addListener(new MapPrintTemplateAdapter(this), map, this);
       	for (var i:String in layerIDs) {
          	_global.flamingo.addListener(new LayerPrintTemplateAdapter(this), layerIDs[i], this);
       	}*/
	   	maps = new Array();
		for (var i:Number = 0; i < mapStrings.length; i++) {
			maps.push(_global.flamingo.getComponent(mapStrings[i]));
        }
    }
    

    
    function addLayerListeners():Void{
    	layerIDs = map.getLayers();
       	layerListeners= new Array();
       	for (var i:String in layerIDs) {
       		var layerId:String  = layerIDs[i];
       		var layerListener:Object = new LayerPrintTemplateAdapter(this) 
          	_global.flamingo.addListener(layerListener, layerId, this);
          	layerListeners[_global.flamingo.getId(this) + layerId] = layerListener;
       	}
    }
    
    function removeLayerListeners():Void{
    	for(var i:String in layerListeners){
    		_global.flamingo.removeListener(layerListeners[i],i,this)
    	}
  
    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
//        _global.flamingo.tracer("PrintTemplate " + _global.flamingo.getId(this) + " setVisible " + visible); 
        lFlamingo = new Object;
		var component:MovieClip = null;
		//parse legend xml
        for (var i:String in listento) {
            component = _global.flamingo.getComponent(listento[i]);
            if(visible){
            	if((_global.flamingo.getUrl(component)).indexOf("Legend") > 0){
	            	if(component.configObjId!=null && !legendConfigLoaded){
	            		var legendConfigObj:Object = _global.flamingo.getComponent(component.configObjId);
		            	var xmls:Array= _global.flamingo.getXMLs(component.configObjId);
		            	if (xmls) {
    						for (var i = 0; i < xmls.length; i++){
    							component.parseCustomAttr(xmls[i]);
    						}
		            	} else {
		            		_global.setTimeout (function (): Void {
		            		    component.processConfig (legendConfigObj.getConfig ());
		            		}, 100);
		            	}
						legendConfigLoaded = true;
	            	}
	            }
            }
            if ((component.legenditems != undefined) || (component.monitorobjects != undefined))  { // Instance of Legend or MonitorLayer.
                component._visible = visible;
            }
        }   
		if(visible && maps!=null){	
			var thisObj:Object = this; 
			lFlamingo.onConfigComplete = function() { 
				_global.flamingo.removeListener(thisObj.lFlamingo, "flamingo", thisObj);
				thisObj.showMap();
    		};
    		 //parse map xml
    		_global.flamingo.addListener(lFlamingo, "flamingo", this);
    		//_global.flamingo.tracer(_global.flamingo.getId(thisObj) + " mapConfigObjId==" + maps[0].configObjId + " mapLoaded " + mapConfigLoaded);
			
			if(maps[0].configObjId!=null && !mapConfigLoaded){
				var mapConfigObj:Object = _global.flamingo.getComponent(maps[0].configObjId);
				var allXML:Array = _global.flamingo.getXMLs(mapConfigObj);
				for(var i:Number=0;i<allXML.length;i++){
					maps[0].parseCustomAttr(allXML[i]);
				}
				mapListener = new MapPrintTemplateAdapter(this);
				_global.flamingo.addListener(mapListener, map, this);
				//thisObj.moveToExtent(thisObj.configObj.getCurrentExtent(), 0, 0);
				mapConfigLoaded = true;
			} else {
				showMap();
			}		

		} else {		
			removeLayerListeners();
			maps[0].hide();
		}
		

    }
    
    function showMap(){
    	
    	synchronizeLayers();
		addLayerListeners();
		maps[0].moveToExtent(map.getCurrentExtent(), 0, 0);
		maps[0].show();
    }
    
    private function synchronizeLayers():Void{
    	layerIDs = map.getLayers();
 		for (var layerId:String in layerIDs) {
 			var masterLayerId:String = layerIDs[layerId];
 			var masterLayer:Object  = _global.flamingo.getComponent(masterLayerId);
 			var masterMapId:String=_global.flamingo.getId(map);
 			var mapID:String = _global.flamingo.getId(maps[0]);
			var printLayerId:String = mapID + masterLayerId.substr(masterMapId.length);
			var printLayer:Object =  _global.flamingo.getComponent(printLayerId);
			var lyrs:Array = masterLayer.layers;
 			for (var id in lyrs) {
				visible = masterLayer.getLayerProperty(id, "visible");
				printLayer.setLayerProperty(id, "visible", visible);
 			}
 			printLayer.visible = masterLayer.visible;
			printLayer.updateCaches();
			_global.flamingo.raiseEvent(printLayer, "onShow", printLayer);
 		}
    }
    
    function getOrientation():String {
        return orientation;
    }
    
    function getDPIFactor():Number {
        return dpi / 72;
    }
    
    function getMaps():Array {
        return maps.concat();
    }

	private function setWidthAndHeigth():Void {
        if ((format == "A4") && (orientation == "landscape")) {
            width = "" + Math.floor(813 * getDPIFactor());
            height = "" + Math.floor(561 * getDPIFactor());
        } else if ((format == "A4") && (orientation == "portrait")) {
            width = "" + Math.floor(561 * getDPIFactor());
            height = "" + Math.floor(813 * getDPIFactor());
        } else if ((format == "A3") && (orientation == "landscape")) {
            width = "" + Math.floor(1122 * getDPIFactor());
            height = "" + Math.floor(813 * getDPIFactor());
        } else if ((format == "A3") && (orientation == "portrait")) {
            width = "" + Math.floor(813 * getDPIFactor());
            height = "" + Math.floor(1122 * getDPIFactor());
        }
    }
    
       private function setScales():Void {
    	super.setScales();
    	if(this._visible){
        	//trick to trigger the autoSize of TextFields and Label fields
        	resetLabels(this.contentPane);
        	
        }
    } 
    
     private function isParent(parent : MovieClip, child : MovieClip) : Boolean {
    	var currentParent : MovieClip = parent;
    	while(currentParent != _root) {
    		if(child == currentParent) {
    			return true;
    		}
    		currentParent = currentParent._parent;
    	}
		return false;
    }
    
    private function resetLabels(parent:MovieClip){
    	for(var a in parent){
    		        	

    		if (typeof(parent[a])=="movieclip"){	
    			
    			if(isParent(parent, parent[a])) {
    					
    			} else { 
    				if(parent[a].autoSize!=null){
		    			parent[a].autoSize = parent[a].autoSize;			
		    			var txt:String = parent[a].text;
		    			var nrOfSpaces:Number =  Math.round(txt.length/8.5);
		    			var spaces:String = "";
		    			for(var i:Number=0;i<nrOfSpaces;i++){
		    				spaces += " ";
		    			}  
		    			if(txt.substr(txt.length-nrOfSpaces) == spaces){
		    			} else {
		    				parent[a].setTextFormat(parent[a].getTextFormat());
		    				parent[a].text = txt + spaces;
		    			}	
    				} 			
    				resetLabels(parent[a]);
    			}	
    		}			
    	}
	}
    
    
}
