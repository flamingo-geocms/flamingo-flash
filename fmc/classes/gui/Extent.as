/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component Extent
* An Extent defines an extent of a map, this can be f.i. the full extent or the current extent.
* An Extent can be set by selecting an extent from the ExtenSelector Component. 
* The ExtentSelector can be used in combination with a locationFinder component.
* @file flamingo/tpc/classes/flamingo/gui/Extent.as  (sourcefile)
* @file flamingo/fmc/Extent.fla (sourcefile)
* @file flamingo/fmc/Extent.swf (compiled component, needed for publication on internet)
* @configstring label Label text for the label in the ExtentSelector radiobutton.
*/

/** @tag <fmc:Extent> 
* This tag defines an extent instance. 
* @class gui.Extent 
* @hierarchy child node of ExtentSelector 
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
* @attr extString A string that defines the extent Reconized values: full, current, 
*                 string of comma seprated coördinate pairs seperated by a semi-colon. 
 */
import geometrymodel.Point;
import geometrymodel.LinearRing;

import core.AbstractComponent;

import geometrymodel.Polygon; 

class gui.Extent extends AbstractComponent  {
    private var componentID:String = "Extent";
    private var map:Object; 
    private var extString:String;

	function setAttribute(name:String, value:String):Void {
		     
        if(name="extent"){
        	extString = value;
        }    
    }

	function go(){
		getParent().extentReady();
	}
    
    function setMap(map:Object):Void{
    	this.map = map;
    	
    }

    function getExtent():Object {
    	var extent:Object ;
    	switch (extString) {
			case "full" :
    			extent=map.getFullExtent();
    			break;
    		case "current" :
    			extent=map.getCurrentExtent();
    			break;
    		default:
    			var points:Array = new Array();
    			var coords:Array = extString.split(";")
    			for(var i:Number = 0;i<coords.length; i++){
    				var coord:Array = coords[i].split(",");
    				points.push(new Point(coord[0],coord[1]));	
    			}
    			points.push(points[0]);
    			
    			if(points.length > 0){
    				extent=new Polygon(new LinearRing(points));
    			} else {
    				extent=map.getFullExtent();	
    			}	
    			break;	
    	}
    	return extent;		
    }
    
    function getLabel():String {
    	return _global.flamingo.getString(this,"label");
    }
    	
		
}
