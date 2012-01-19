// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

//Note: Unfortunately the LineSegment Class can not be used because it's not a movieclip descedant. 
//And, in addition, we can not use multiple inheritance in as2. Therfore this class is created.

import geometrymodel.Point;

class gui.EditMapLineGraphic extends MovieClip {
	private var startPointNr:Number = -1;
	private var endPointNr:Number = -1;
	private var startPoint:Point = null;
	private var endPoint:Point = null;
	
	
	function setStartPointNr(nr:Number):Void {
		startPointNr = nr;
	}
	
	function getStartPointNr():Number {
		return startPointNr;
	}
		
		
	function setEndPointNr(nr:Number):Void {
		endPointNr = nr;
	}
	
	function getEndPointNr():Number {
		return endPointNr;
	}
	
	function setStartPoint(p:Point):Void{
		startPoint = p;
	}
	
	function getStartPoint():Point{
		return startPoint;
	}
	
	function setEndPoint(p:Point):Void{
		endPoint = p;
	}
	
	function getEndPoint():Point{
		return endPoint;
	}
	
	
	
}




