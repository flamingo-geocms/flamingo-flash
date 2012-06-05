// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

import geometrymodel.Point;

/**
 * EditMapLineGraphic
 * Note: Unfortunately the LineSegment Class can not be used because it's not a movieclip descedant. 
 * And, in addition, we can not use multiple inheritance in as2. Therfore this class is created.
 */
class gui.EditMapLineGraphic extends MovieClip {
	private var startPointNr:Number = -1;
	private var endPointNr:Number = -1;
	private var startPoint:Point = null;
	private var endPoint:Point = null;
	
	/**
	 * setter StartPointNr
	 * @param	nr
	 */
	function setStartPointNr(nr:Number):Void {
		startPointNr = nr;
	}
	/**
	 * getter StartPointNr
	 * @return
	 */
	function getStartPointNr():Number {
		return startPointNr;
	}
		
	/**
	 * setter EndPointNr
	 * @param	nr
	 */	
	function setEndPointNr(nr:Number):Void {
		endPointNr = nr;
	}
	/**
	 * getter EndPointNr
	 * @return
	 */
	function getEndPointNr():Number {
		return endPointNr;
	}
	/**
	 * setter StartPoint
	 * @param	p
	 */
	function setStartPoint(p:Point):Void{
		startPoint = p;
	}
	/**
	 * getter StartPoint
	 * @return
	 */
	function getStartPoint():Point{
		return startPoint;
	}
	/**
	 * setter EndPoint
	 * @param	p
	 */
	function setEndPoint(p:Point):Void{
		endPoint = p;
	}
	/**
	 * getter EndPoint
	 * @return
	 */
	function getEndPoint():Point{
		return endPoint;
	}
	
	
	
}




