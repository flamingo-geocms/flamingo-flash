// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.
// Changes by author: Maurits Kelder, B3partners bv

import geometrymodel.Geometry;
import gismodel.Feature;

class gismodel.SelectedFeature {  
    
	static var PLUS:Number = 0;
    static var MINUS:Number = 1;
	
    private var id:String = null;
    private var feature:Feature = null;
    private var name:String = null; 
	private var status:Number= null;
	private var extraText:String=null;
    
    function SelectedFeature(id:String, name:String, extraText:String,feature:Feature) {
		setId(id);
		setName(name);
		setFeature(feature);
		setExtraText(extraText);
		setStatus(PLUS);
    }	
    function setId(id:String){
		if (id == null) {
            _global.flamingo.tracer("Exception in gismodel.SelectedGeometry.<<init>>(" + id + ")\nNo layer given.");
            return;
        }
		this.id=id;
	}
	function getId():String{
		return id;
	}
	function setName(name:String){		
		this.name=name;
	}
	function getName():String{
		return name;
	}
	
	function setExtraText(extraText:String){
		if (extraText==undefined){
			this.extraText=null;
		}
		this.extraText=extraText;
	}
	
	function getExtraText():String{
		return extraText;
	} 
	function setFeature(feature:Feature){
		this.feature=feature;
	}
	function getFeature(){
		return this.feature;
	}
	function getGeometry():Geometry{
		return feature.getGeometry();
	}
	function setStatus(status:Number){
		this.status=status;
	}
	function getStatus():Number{
		return this.status;
	}
}
