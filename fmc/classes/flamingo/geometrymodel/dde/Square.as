import flamingo.geometrymodel.dde.*;

class flamingo.geometrymodel.dde.Square extends LinearRing {

    function Square(points:Array) {
		super(points);
    }
	
    function addPoint(point:Point):Void {
		 points[1].setXY(point.getX(),points[0].getY());
		 points[2].setXY(point.getX(),point.getY());
		 points[3].setXY(points[0].getX(),point.getY())
		 geometryEventDispatcher.changeGeometry(this);
    }
	
	  function setPointXY(x:Number, y:Number):Void {
		 points[1].setXY(x,points[0].getY());
		 points[2].setXY(x,y);
		 points[3].setXY(points[0].getX(),y)
    }



}
