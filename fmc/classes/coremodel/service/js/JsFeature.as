﻿/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/
import coremodel.service.js.*;

import coremodel.service.*;
import geometrymodel.GeometryParser;

import geometrymodel.Geometry;

class coremodel.service.js.JsFeature extends ServiceFeature {
	var propArray=null;
	
    function JsFeature(featureObject:Object, serviceLayer:ServiceLayer){
		this.values = new Array();		
		if (serviceLayer==null){
			this.propArray = new Array();
		}
		this.serviceLayer = serviceLayer;
		for (var i in featureObject){
			if (i.toLowerCase()=="id"){
				this.id=featureObject[i];
				//_global.flamingo.tracer("TRACE in JsFeature.<<JsFeature>>() id = "+id);
			}else{
				if (i=="wktgeom"){
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
				propArray.push(i);
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
	
	function getValue(name:String):Object {
        if (serviceLayer==null){		
			for (var i:Number = 0; i < propArray.length; i++) {
				if (propArray[i] == name) {
					return values[i];
				}
			}
		}else{
			return super.getValue();
		}        
        _global.flamingo.tracer("Exception in coremodel.service.js.JsFeature.getValue(" + name + ")");
        return null;
    }
        
    function toString():String {
        return "JsFeature(" + id + ")";
    }    
}