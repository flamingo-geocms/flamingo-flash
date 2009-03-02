/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.geometrymodel.dde.*;

class flamingo.gui.dde.TraceLinearRing implements GeometryListener{

private var geometry:LinearRing;
private var traceGeometry:MovieClip;
private var map:Object;
	 
	 
function TraceLinearRing(map,geometry:LinearRing){
	traceGeometry = map["mTraceSheet"].createEmptyMovieClip("mTraceGeometry",map["mTraceSheet"].getNextHighestDepth());
	this.geometry = geometry;
	this.map = map;
	geometry.addGeometryListener(this);
}
	 
	 
function draw():Void {
	
        traceGeometry.clear();
		var geometries:Array  = geometry.getGeometries(); //Array van LineStrings
		var points:Array = geometry.getCoords();
		//_global.flamingo.tracer("overnieuw tekenen################" + points.toString());
		//_global.flamingo.tracer("laatste " + polygon);
        traceGeometry.lineStyle(1, 0x00ff00, 100);
        traceGeometry.beginFill(0x00ff00, 30);
		var point:Point = Point(points[0]);
		var coord:Object = map.coordinate2Point({x:point.getX(),y:point.getY()});
		traceGeometry.moveTo(Number(coord.x),Number(coord.y));
		for (var j:Number = 1; j < points.length; j++) {
			point = Point(points[j]);
			var coord:Object = map.coordinate2Point({x:point.getX(),y:point.getY()});
			traceGeometry.lineTo(coord.x,coord.y);
		}
        traceGeometry.endFill();
    }
function onChangeGeometry(geometry:Geometry):Void {
	draw()
 }
 }
