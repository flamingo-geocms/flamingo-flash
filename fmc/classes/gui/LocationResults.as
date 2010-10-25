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
		//results = createEmptyMovieClip("mContentPane" , this.getNextHighestDepth());
		var h:Number;
		for(var i:Number = 0; i<locations.length; i++){
			var initObject:Object = new Object();
			initObject.location = locations[i];
			initObject.viewer = this.viewer;
			initObject.index = i;
			var locationResult:LocationResult = LocationResult(this.attachMovie("LocationResult", "mc" + i, this.getNextHighestDepth(),initObject));
			h=20*i;
			locationResult._y = h;
		}
		//add fill to be able to see the last result when hor scrollbar is visible
		var fill:MovieClip = this.createEmptyMovieClip("mFill",this.getNextHighestDepth());
		fill._y = h;
		fill.lineStyle(5, 0xFFFFFF, 100);
		fill.moveTo(0,0);
		fill.lineTo(0,30);
		
	}
	
	
	
}
