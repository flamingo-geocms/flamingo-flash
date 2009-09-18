/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/
import coremodel.service.js.*;

import coremodel.service.*;
import geometrymodel.GeometryParser;

import geometrymodel.Geometry;

class coremodel.service.js.JsFeature extends ServiceFeature {
    function JsFeature(featureObject:Object){
		this.values = new Array();
		
		for (var i in featureObject){
			if (i=="id"){
				this.id=featureObject[i];
				//_global.flamingo.tracer("TRACE in JsFeature.<<JsFeature>>() id = "+id);
			}else if (i=="wktgeom"){
				var wktGeom:String = String(featureObject[i]);
				
				//_global.flamingo.tracer("TRACE in JsFeature.<<JsFeature>>() wktGeom = "+wktGeom);
				
				if (wktGeom != null) {
					//this.values.push(GeometryParser.parseGeometryFromWkt(wktGeom));
					
					//debug
					var tmpGeometry:Geometry = GeometryParser.parseGeometryFromWkt(wktGeom);
					//_global.flamingo.tracer("TRACE in JsFeature.<<JsFeature>>() tmpGeometry = "+tmpGeometry);
					
					this.values.push(tmpGeometry);
				}
			}else{
				this.values.push(featureObject[i]);
			}
		}
		
	}
	function getGeometry(){
		for (var i=0; i < this.values.length; i++){
			if (this.values[i] instanceof Geometry){
				return this.values[i];
			}
		}
		return null;
	}
        
    function toString():String {
        return "JsFeature(" + id + ")";
    }    
}