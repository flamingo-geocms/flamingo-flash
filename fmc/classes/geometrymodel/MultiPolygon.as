/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

class geometrymodel.MultiPolygon extends Geometry {
    
    private var polygons:Array=null;
    
    function MultiPolygon(polygon:Polygon) {
        if (polygon == null) {
            _global.flamingo.tracer("Exception in geometrymodel.MultiPolygon.<<init>>(null)");
            return;
        }
        polygon.setParent(this);
		polygons=new Array();
		polygons.push(polygon);
		
        addGeometryListener(polygon);
        geometryEventDispatcher.addChild(this,polygon);
    }
    function addPolygon(polygon:Polygon):Void{
		polygons.push(polygon);
	}
/*    function addPoint(polygonIndex:Number,point:Point):Void { 
		Polygon(polygons[polygonIndex]).addPoint(point);
    }
	
	function insertPoint(polygonIndex:Number,point:Point, insertIndex:Number):Void {
        Polygon(polygons[polygonIndex]).insertPoint(point, insertIndex);
    }*/
	
    function getChildGeometries():Array {
		/*var childGeometries:Array = polygons.concat();
		return childGeometries;*/
		return polygons;
    }
    
	function getArea(performSimpleTest:Boolean):Number {
		var area:Number = 0;
		for (var i:Number = 0; i < polygons.length; i++){
			area+= Polygon(polygons[i]).getArea(performSimpleTest);
		}
		return area;
	}
		  
	function selfIntersectionTest():Boolean {
		for (var i:Number = 0; i < polygons.length; i++){
			if(Polygon(polygons[i]).selfIntersectionTest()){
				return true;
			}
		}
		return false;
	}	
	    
	function toGMLString(srsName:String):String {
        var gmlString:String = "";
		
		if (srsName == undefined) {
			gmlString += "<gml:MultiPolygon srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
        } else {
		    gmlString += "<gml:MultiPolygon srsName=\""+srsName+"\">\n";
		}
		for (var i:Number = 0; i < polygons.length; i++) {
			gmlString+= "<gml:polygonMember>";
			gmlString+= Polygon(polygons[i]).toGMLString(null);
			gmlString+= "</gml:polygonMember>";
        }        
        gmlString += "</gml:Polygon>\n";        
        return gmlString;
    }
	
	function toWKT():String{
		var wktGeom:String="";
		wktGeom+="MULTIPOLYGON(";		
		for (var i=0; i < polygons.length; i++){
			if (i!=0){
				wktGeom+=",";
			}
			wktGeom+="("+Polygon(polygons[i]).toWKTPart()+")";
		}
		wktGeom+=")";
		return wktGeom;
	}
	
	
	function toString():String {
		var s="MultiPolygon (";
		for (var i=0; i < polygons.length; i++){
			s+="("+Polygon(polygons[i]).getExteriorRing().toString()+")";
		}
        return (s + ")");
    }
    
}
