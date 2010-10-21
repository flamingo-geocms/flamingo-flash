// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import event.*;
import coregui.Frame;
import core.AbstractComponent;
import coremodel.service.ServiceLayer;
import gismodel.Feature;
import gismodel.GIS;
import gismodel.Layer;
import gismodel.Property;
import gismodel.SelectedFeature;
import geometrymodel.Geometry;

import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.TextArea;
import mx.utils.Delegate;
import flash.external.ExternalInterface;

class gui.ManageSelectedGeometries extends AbstractComponent implements StateEventListener {
    
    private var componentsPanel:MovieClip = null;
    private var componentHeight:Number = 22;
	private var components:Array = null;
    private var labelStyle:Object = null;
	private var vertiSpacing:Number = 7;
	private var nameProperties:Object= new Object();
	
	private var executeurl:String= null;
	//private var extraParams:Array=null;
	private var wktGeometryKeyPlus:String="wktgeometryplus";
	private var wktGeometryKeyMinus:String="wktgeometryminus";
	
	private var selectedFeatures:Array= new Array();
	private var calcButton:MovieClip;
    function init():Void {
		for (var i=0; i < listento.length; i++){
			var gis = _global.flamingo.getComponent(listento[i]).getGIS(); 
			//gis.addEventListener(this, "GIS", StateEvent.CHANGE, "createGeometry");  
			var layer:Layer = null;
			var layers= gis.getLayers();
			for (var l:String in layers) {
				layer = Layer(layers[l]);
				layer.addEventListener(this, "Layer", StateEvent.ADD_REMOVE, "features");
			}
		}
		labelStyle = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
		components = new Array();
		
		componentsPanel = createEmptyMovieClip("mPanel", 1);
        componentsPanel._y = componentHeight;
        componentsPanel._lockroot = true; // Without this line comboboxes wouldn't open.
		

		//var newButton:MovieClip =componentsPanel.createEmptyMovieClip("mButtonPlus_"+selectedFeature.getId(), i * 4 +1);
		calcButton=componentsPanel.createEmptyMovieClip("calcButton", 1000);
		calcButton.attachMovie("CalcGraphic","CalcGraphic",202);
		calcButton.manager=this;
		calcButton.onRelease = function(){
			this.manager.doCalculation();
		}
    }  
	
	function addComposite(nodeName, xmlNode){
		if (nodeName.toLowerCase()=='layer'){
			nameProperties[xmlNode.attributes['id']]=xmlNode.attributes['nameProperty'];
		}
	}
	
	function setAttribute(name:String, value:String):Void { 
		if (name=='executeurl'){
			this.executeurl=value;
		}else if (name=='wktgeometrykeyplus'){
			this.wktGeometryKeyPlus=value;
		}else if (name=='wktgeometrykeyminus'){
			this.wktGeometryKeyMinus=value;
		}
	} 
	
    function onStateEvent(stateEvent:StateEvent):Void {
		var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.ADD_REMOVE + "_features") {
            var addedFeatures:Array = AddRemoveEvent(stateEvent).getAddedObjects();
            addFeatures(addedFeatures);
            var removedFeatures:Array = AddRemoveEvent(stateEvent).getRemovedObjects();
            //removeFeatures(removedFeatures);
			removeGeometryLabels();
			drawComponents();					
        }
		
    }	
	function addFeatures(features:Array){
		for (var f:Number=0; f < features.length; f++){
			var feature:Feature=Feature(features[f]);
			   // function SelectedFeature(id:String, layerName:String, name:String, extraText:String,geometry:Geometry) {
			var propertyName= nameProperties[feature.getLayer().getName()];
			var selectedFeature:SelectedFeature=new SelectedFeature(String(feature.getID()), feature.getValue(propertyName), String("("+feature.getLayer().getName()+")"),feature);				
			this.selectedFeatures.push(selectedFeature);
		}		
	}
	function getSelectedFeatures():Array{
		return selectedFeatures;
	}
	function setSelectedFeatureStatus(id:String, status:Number){
		var selectedFeature:SelectedFeature = null;
		for (var i=0; i < this.selectedFeatures.length; i++){
			selectedFeature = SelectedFeature(this.selectedFeatures[i]);
			if (selectedFeature.getId() == id){
				selectedFeature.setStatus(status);
				break;
			}
		}
		removeGeometryLabels();
		drawComponents();
	}
	function removeFeature(id:String){
		var selectedFeature:SelectedFeature= getSelectedFeatureById(id);
		if (selectedFeature!=null){
			if (layerHasFeature(selectedFeature.getFeature())){
				selectedFeature.getFeature().getLayer().removeFeature(selectedFeature.getFeature(),false);
			}
			removeSelectedFeature(selectedFeature.getId());
		}
	}
	function layerHasFeature(feature:Feature){
		var features:Array=feature.getLayer().getFeatures();
		for (var i=0; i < features.length; i++){
			if(features[i] == feature){
				return true;
			}
		}
		return false;
	}
	function removeSelectedFeature(id:String){
		var selectedFeature:SelectedFeature = null;
		for (var i=0; i < this.selectedFeatures.length; i++){
			selectedFeature = SelectedFeature(this.selectedFeatures[i]);
			if (selectedFeature.getId() == id){
				this.selectedFeatures.splice(i,1);				
				break;
			}
		}
		removeGeometryLabels();
		drawComponents();
	}
	function getSelectedFeatureById(id:String){
		var selectedFeature:SelectedFeature = null;
		for (var i=0; i < this.selectedFeatures.length; i++){
			selectedFeature = SelectedFeature(this.selectedFeatures[i]);
			if (selectedFeature.getId() == id){
				return selectedFeature;
			}
		}
		return null;
	}
	
	function doCalculation(){
		var features= selectedFeatures;
		//if (features.length > 0){
		var urlToCall:String ="";					
		if (this.executeurl==null){
			_global.flamingo.tracer("The executeurl is empty or not set.");
			return;
		}
		urlToCall+=executeurl;					
		if (urlToCall.indexOf('?')>=0){
			urlToCall+="&";
		}else{
			urlToCall+="?";
		}					
		var wktGeomPlus="";
		var wktGeomMinus="";
		var feature:SelectedFeature = null;
		for (var i=0; i < features.length; i++){						
			feature = SelectedFeature(features[i]);
			if (feature.getStatus() == SelectedFeature.PLUS){
				if (wktGeomPlus.length > 0 && wktGeomPlus.lastIndexOf(",seperator,") != wktGeomPlus.length -1){
					wktGeomPlus+=",seperator,";
				}
				wktGeomPlus+=feature.getGeometry().toWKT();
			}
			else if (feature.getStatus() == SelectedFeature.MINUS){
				if (wktGeomMinus.length > 0 && wktGeomMinus.lastIndexOf(",seperator,") != wktGeomMinus.length -1){
					wktGeomMinus+=",seperator,";
				}
				wktGeomMinus+=feature.getGeometry().toWKT();
			}
		}
		var geomPresent:Boolean=false;
		if (wktGeomPlus!=null && wktGeomPlus.length > 0){
			urlToCall+=this.wktGeometryKeyPlus+"="+wktGeomPlus;						
			urlToCall+="&";
			geomPresent=true;
		}							
		if (wktGeomMinus!=null && wktGeomMinus.length > 0){
			urlToCall+=this.wktGeometryKeyMinus+"="+wktGeomMinus;
			geomPresent=true;
		}			
//		trace("do call " +urlToCall);
		//getURL ("javascript:openNewWindow('"+urlToCall+"','"+this.name+"');");
		if (geomPresent){
			ExternalInterface.call("openNewWindow", urlToCall, this.name);
		}
	}
	
	function drawComponents(){		
		var initObject:Object = null;
		if (this.selectedFeatures.length ==0){
			setVisible(false);
		}else{
			setVisible(true);
		}
		var selectedFeature:SelectedFeature = null;
		for (var i=0; i < this.selectedFeatures.length; i++){
			var i2:Number=0;
			selectedFeature = SelectedFeature(this.selectedFeatures[i]);
			//STATUS PLUS
			var color:Number=0x6666CC;
			var trans:Number=100;
			if (selectedFeature.getStatus()== SelectedFeature.MINUS){
				color=0xDDDDDD;
				trans=30;
			}
			var newButton:MovieClip =componentsPanel.createEmptyMovieClip("mButtonPlus_"+selectedFeature.getId(), i * 4 +1);
			components.push(newButton);						
			drawButtonBounds(components[i * 4 + i2],trans);			
			components[i * 4 + i2].lineStyle(3, color, 100);
			components[i * 4+ i2].moveTo(4, 7);
			components[i * 4 + i2].lineTo(10, 7);
			components[i * 4 + i2].moveTo(7, 4);
			components[i * 4 + i2].lineTo(7, 10);
			//Click event
			if (selectedFeature.getStatus()!= SelectedFeature.PLUS){
				components[i * 4 + i2].manager=this;
				components[i * 4 + i2].onRelease = function(){
					var geomId= this._name.substring(12);
					if (geomId!=undefined){
						this.manager.setSelectedFeatureStatus(geomId,SelectedFeature.PLUS);
					}
				}
			}
			
			i2++;
			//STATUS MIN		
			color=0x6666CC;
			trans=100;
			if (selectedFeature.getStatus()== SelectedFeature.PLUS){
				color=0xDDDDDD;
				trans=30;
			}
			newButton=componentsPanel.createEmptyMovieClip("mButtonMin_"+selectedFeature.getId(), i * 4 +2);
			components.push(newButton);			
			drawButtonBounds(components[i * 4 + i2],trans);
			components[i * 4 + i2].lineStyle(3, color, 100);
			components[i * 4 + i2].moveTo(4, 7);
			components[i * 4 + i2].lineTo(10, 7);
			//Click event
			if (selectedFeature.getStatus()!= SelectedFeature.MINUS){
				components[i * 4 + i2].manager=this;
				components[i * 4 + i2].onRelease = function(){
					var geomId= this._name.substring(11);
					if (geomId!=undefined){
						this.manager.setSelectedFeatureStatus(geomId,SelectedFeature.MINUS);
					}
				}
			}
			i2++;			
			//REMOVE SELECTED GEOM
			newButton=componentsPanel.createEmptyMovieClip("mButtonDel_"+selectedFeature.getId(), i * 4 +3);
			components.push(newButton);			
			drawButtonBounds(components[i * 4 + i2],100);			
			components[i * 4 + i2].lineStyle(3, 0xFF0000, 100);
			components[i * 4 + i2].moveTo(4, 4);
			components[i * 4 + i2].lineTo(10, 10);
			components[i * 4 + i2].moveTo(4, 10);
			components[i * 4 + i2].lineTo(10, 4);
			//CLICK EVENT
			components[i * 4 + i2].manager=this;
			components[i * 4 + i2].onRelease = function(){
				var geomId= this._name.substring(11);
				if (geomId!=undefined){
					this.manager.removeFeature(geomId);
				}
			}
			
			i2++;
			//LABEL
			initObject = new Object();
			var labelText:String="";			
			labelText+=selectedFeature.getName();
			if (selectedFeature.getExtraText()!=null && selectedFeature.getExtraText()!='undefined' && selectedFeature.getExtraText().length>0){
				labelText+=" "+selectedFeature.getExtraText();
			}
			initObject["text"] = labelText;
			initObject["autoSize"] = "left";
			components.push(componentsPanel.attachMovie("Label", "mLabel" + selectedFeature.getId() + i, i * 4, initObject));
			Label(components[i * 4 + i2]).setStyle("fontFamily", labelStyle["fontFamily"]);
			Label(components[i * 4 + i2]).setStyle("fontSize", labelStyle["fontSize"]);			
			
		}
		layout();
	}
	/*private function drawButtonBounds(movieclip:MovieClip){
		drawButtonBounds(movieclip,100);
	}*/
	private function drawButtonBounds(movieclip:MovieClip, trans:Number){		
		movieclip.lineStyle(1, 0x6666CC, trans);
		movieclip.beginFill(0xC8B6ED, trans);
		movieclip.moveTo(0,0);
		movieclip.lineTo(14,0);
		movieclip.lineTo(14,14);
		movieclip.lineTo(0,14);
		movieclip.lineTo(0,0);
		movieclip.endFill();		
	}
	
	private function layout():Void {
        
        var component:MovieClip = null;
        var y:Number = 0;
		var x:Number = 0;
        for (var i:Number = 0; i < components.length; i+=4) {			
			y += vertiSpacing;
			component = MovieClip(components[i]);            
			component._y = y;
			x = 16;
			
			component = MovieClip(components[i+1]);
			component._y =y;
			component._x =x;
			x +=16;
			
			component = MovieClip(components[i+2]);
			component._y =y;
			component._x =x;
			x+=16
			
			component = MovieClip(components[i+3]);
			component._y =y;
			component._x =x;			
			
			y += componentHeight;
			
		}
		y+=vertiSpacing;
		calcButton._y=y;
		calcButton._x=16;
    }
	
	private function removeGeometryLabels():Void {
        for (var i:String in components) {
            MovieClip(components[i]).removeMovieClip();
        }
        components = new Array();
    }
}
