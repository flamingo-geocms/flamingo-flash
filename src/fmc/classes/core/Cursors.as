﻿import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: LindaVels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component fmc:Cursors
* The Cursors component is a container for map cursors.
* This component is used when toolcomponents (with a cursor) are in a different flamingo instance as the map component. 
* @file Cursors.as  (sourcefile)
* @file Cursors.fla (sourcefile)
* @file Cursors.swf (compiled Map, needed for publication on internet)
*/

/** @tag <fmc:Cursors>  
* This tag defines a Cursors component. Cursors can contain different cursor tags
* example:
*<fmc:Cursors> 
* <cursor id="zoomout"  url="fmc/CursorsMap.swf" linkageid="zoomout"/>
* <cursor id="zoomin"  url="fmc/CursorsMap.swf" linkageid="zoomin"/>
* <cursor id="default"  url="fmc/CursorsMap.swf" linkageid="zoomin"/>
*</fmc:Cursors>
*	
* @attr id unique identifier for the component
*/


/**
* The Cursors component is a container for map cursors.
*/
class core.Cursors extends AbstractComponent {
	var version:String = "1.0";
	/**
	* Sets the cursor of an flamingo component
	* @param compId:String Id of the flamingo component to set the cursor of.
	* @param cursor:Object A cursor object
	*/
	public function setCursor(compId:String,cursor:Object):Void{
		var comp:Object = _global.flamingo.getComponent(compId);
		comp.setCursor(this.cursors[cursor.linkageid]);
	}

}