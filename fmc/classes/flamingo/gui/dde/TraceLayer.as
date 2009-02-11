import mx.utils.Delegate;
import flamingo.geometrymodel.dde.*;
import flamingo.gui.dde.*;



class flamingo.gui.dde.TraceLayer {
	
	//private var traceGeometry:Geometry;
	private var map:Object = null;
	private var point:Point;
	private var numMouseDowns:Number = 0;
    private var intervalID:Number = null;
	private var traceSheet:MovieClip
	private var traceLinearRing:TraceLinearRing;
	private var geometry:Geometry;
	private var traceMode:String;
	private var firstClick: Boolean = true;
	
	function TraceLayer(parentMap:Object, traceMode:String){
		geometry = new Geometry();
		this.traceMode = traceMode;
		map = parentMap;
		drawLayer();
	}
	
	private function drawLayer():Void{
		traceSheet = map.createEmptyMovieClip("mTraceSheet",map.getNextHighestDepth());
		traceSheet.beginFill(0xFF0000,20);
		traceSheet.moveTo(0, 0);
		traceSheet.lineTo(map.getWidth(),0);
		traceSheet.lineTo(map.getWidth(), map.getHeight());
		traceSheet.lineTo(0, map.getHeight());
		traceSheet.lineTo(0, 0);
		traceSheet.endFill();
		var tl:Object = this
		traceSheet.onPress = function(){
			tl.performPress()};
		traceSheet.onMouseMove = function(){
			tl.performMouseMove()};
	}
	
	 function resetNumMouseDowns():Void {
        if (numMouseDowns >= 1) {
            numMouseDowns = 0;
            clearInterval(intervalID);
        }
    }
	
	function performPress():Void {
        if (numMouseDowns == 0) {
            intervalID = setInterval(this, "resetNumMouseDowns", 400);
        }
        numMouseDowns++;
        var double:Boolean = false;
        if (numMouseDowns == 2) {
            double = true;
            resetNumMouseDowns();
        }
		var coord:Object = map.point2Coordinate({x:map._xmouse, y:map._ymouse});
        point = new Point(coord.x,coord.y);
		if (firstClick){
			map["mTraceSheet"]["mTraceGeometry"].removeMovieClip();
			firstClick = false;
			switch (traceMode){
			case "tracePoly" :
				var newPoint = new Point(point.getX(),point.getY());
				var points:Array = new Array();
				points.push(point,newPoint,point);
				var geom:LinearRing = new LinearRing(points);
				geom.setGeometryEventDispatcher(geometry.getGeometryEventDispatcher());
				geometry = geom;
				traceLinearRing = new TraceLinearRing(map,LinearRing(geometry));
				
				//geom.addPoint(newPoint);
				break;
			 case "traceBox":
			 	var points:Array = new Array();
				points.push(point);
				for (var j:Number = 1; j < 5; j++) {
					var newPoint = new Point(point.getX(),point.getY());
					points.push(newPoint);
				}
				points.push(point);
				var geom:Square = new Square(points);
				geom.setGeometryEventDispatcher(geometry.getGeometryEventDispatcher());
				geometry = geom;
				traceLinearRing = new TraceLinearRing(map,LinearRing(geometry));
				break;
			 case "traceCircle":
			 	var points:Array = new Array();
				points.push(point,point,point);
				var geom:Circle = new Circle(points);
				geom.setGeometryEventDispatcher(geometry.getGeometryEventDispatcher());
				geometry = geom;
				traceLinearRing = new TraceLinearRing(map,LinearRing(geometry));
				//var newPoint = new Point(point.getX(),point.getY());
				//geom.addPoint(newPoint);
				//Circle(geom).setRadius(0);
				break;
			}
		}
		else {
			if (double){
				firstClick = true;
				if(traceMode == "tracePoly" ){ 
					geometry.removePoint(null);
				} 
			} else {
				switch (traceMode){
				case "tracePoly" :
					LinearRing(geometry).addPoint(point);
					break;	
				case "traceBox":
					geometry.removePoint();
					Square(geometry).addPoint(point);
					firstClick = true;
					break;	
				case "traceCircle" :
					Circle(geometry).setPointXY(point.getX(),point.getY());
					firstClick = true;
					break;		
				}
			}
		}
	}
	
	 function performMouseMove():Void {
		var coord:Object = map.point2Coordinate({x:map._xmouse, y:map._ymouse});
        //point = new Point(coord.x,coord.y);
		if (!firstClick){
				geometry.setPointXY(coord.x,coord.y);
		}
    }
	
	function getGeometry():Geometry{
		return geometry;
	}
	


	
	
	
}