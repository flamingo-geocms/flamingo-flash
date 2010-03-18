/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels
* IDgis bv
* Part of the LocationResultViewer component
 -----------------------------------------------------------------------------*/
import gui.LocationResultViewer;
import gui.LocationResult;

class gui.LocationResults extends MovieClip {
	
	private var results:MovieClip;
	private var viewer:LocationResultViewer;

	private function drawLocations(locations:Array) : Void {
		results = createEmptyMovieClip("mContentPane" , this.getNextHighestDepth());
		for(var i:Number = 0; i<locations.length; i++){
			var initObject:Object = new Object();
			initObject.location = locations[i];
			initObject.viewer = this.viewer;
			initObject.index = i;
			var locationResult:LocationResult = LocationResult(results.attachMovie("LocationResult", "mc" + i, results.getNextHighestDepth(),initObject));
			locationResult._y = 20*i;
		}
	}
	
	
	
}
