﻿/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import gismodel.*;

import event.*;
import coremodel.*;
import coremodel.service.*;
import coremodel.service.wfs.*;
import coremodel.service.js.JsFeature;
import geometrymodel.*;
import tools.Randomizer;
import core.AbstractComposite;
import tools.Logger;
/**
 * gismodel.Layer
 */
class gismodel.Layer extends AbstractComposite implements ActionEventListener {
    
    private var gis:GIS = null;
    private var name:String = null;
    private var title:String = null;
    private var visible:Boolean = false;
	private var loadFeaturesOnStart=true;
    private var serviceConnector:ServiceConnector = null;
    private var serviceLayer:ServiceLayer = null;
	private var geometryTypes:Array = null;
    private var labelPropertyName:String = null;
    private var ownerPropertyName:String = null;
    private var properties:Array = null;
    private var roles:Array = null;
    private var style:Style = null;
    private var whereClauses:Array = null;
    private var features:Array = null;
    private var transaction:Transaction = null;
    private var serverReady:Boolean = false;
    private var showMeasures:Boolean = false;
	private var measureUnit:String = null;
	private var measureDecimals:Number = null;
	private var measureMagicnumber:Number = null;
	private var measureDs:String = ".";
	private var editable:Boolean = false;
    
    private var stateEventDispatcher:StateEventDispatcher = null;
    
	private var log:Logger=null;
	/**
	 * constructor
	 * @param	gis
	 * @param	xmlNode
	 */
    function Layer(gis:GIS, xmlNode:XMLNode) {
		this.log = new Logger("gismodel.Layer",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        stateEventDispatcher = new StateEventDispatcher();
        
        this.gis = gis;
        
        geometryTypes = new Array();
        properties = new Array();
        roles = new Array();
        whereClauses = new Array();
        features = new Array();
        transaction = new Transaction();
        
        parseConfig(xmlNode);
    }
    /**
     * setAttribute
     * @param	name
     * @param	value
     */
    function setAttribute(name:String, value:String):Void {
        //_global.flamingo.tracer("name = " + name + " svalue = " + value);
        if (name == "title") {
            title = value;
        } else if (name == "visible") {
            if (value.toLowerCase() == "true") {
                visible = true;
            } else {
                visible = false;
            }
         } else if (name == "showmeasures") {
            if (value.toLowerCase() == "true") {
            	showMeasures = true;
            } else {
            	showMeasures = false;
            }       
		}else if (name == "measureunit") {
			if (value.toLowerCase() == "null") {
				measureUnit = null;
			}else {
				measureUnit = value;
			}	
		}else if (name == "measuredecimals") {	
			if (value.toLowerCase() == "null") {
				measureDecimals = null;
			}else {
				measureDecimals = Number(value);
			}
		}else if (name == "measuremagicnumber") {	
			if (value.toLowerCase() == "null") {
				measureMagicnumber = null;
			}else {
				measureMagicnumber = Number(value);
			}
		}else if (name == "measureds") {			
			if (value.toLowerCase() == "null") {
				measureDs = null;
			}else {
				measureDs = value;
			}
		}else if (name== "loadfeaturesonstart"){
			if (value.toLowerCase() == "true") {
                loadFeaturesOnStart = true;
            } else {
                loadFeaturesOnStart = false;
            }
		}else if (name == "wfsurl") {
            serviceConnector = ServiceConnector.getInstance(value);
        } else if (name == "featuretypename") {
            if (serviceConnector == null) {
                _global.flamingo.tracer("Exception in gismodel.Layer.setAttribute(featuretypename)\nLayer \"" + this.name + "\" has no service connector and therefore cannot do anything with a service layer.");
                return;
            }
            serviceConnector.performDescribeFeatureType(value, this);
		} else if(name== "version"){
			if (serviceConnector == null) {
                _global.flamingo.tracer("Exception in gismodel.Layer.setAttribute(featuretypenameselection)\nLayer \"" + this.name + "\" has no service connector and therefore cannot set the version.");
                return;
            }
			serviceConnector.setServiceVersion(value);
		} else if(name== "srsname"){
			if (serviceConnector == null) {
                _global.flamingo.tracer("Exception in gismodel.Layer.setAttribute(featuretypenameselection)\nLayer \"" + this.name + "\" has no service connector and therefore cannot set the srsName.");
                return;
            }
			serviceConnector.setSrsName(value);	
		} else if (name == "geometrytypes") {
            geometryTypes = value.split(",");
        } else if (name == "labelpropertyname") {
            labelPropertyName = value;
        } else if (name == "ownerpropertyname") {
            ownerPropertyName = value;
        } else if (name == "roles") {
            roles = value.split(",");
		} else if (name == "editable") {
			if (value.toLowerCase() == "true") {
            	editable = true;
            } else {
            	editable = false;
            }   
		}
    }
    /**
     * addComposite
     * @param	name
     * @param	xmlNode
     */
    function addComposite(name:String, xmlNode:XMLNode):Void {
        if (name == "Property") {
            properties.push(new Property(xmlNode));
        } else if (name == "GeometryProperty") {
            properties.push(new GeometryProperty(xmlNode));
        } else if (name == "Style") {
            style = new Style(xmlNode);
        }
    }
    /**
     * getTitle
     * @return
     */
    function getTitle():String {
        return title;
    }
    /**
     * getName
     * @return
     */
	function getName():String{ 
		return name;
	}
	/**
	 * setVisible
	 * @param	visible
	 */
    function setVisible(visible:Boolean):Void {
        if (this.visible == visible) {
            return;
        }
        
        this.visible = visible;
        gis.raiseLayerVisibility(this.getName(),this.visible);
        stateEventDispatcher.dispatchEvent(new StateEvent(this, "Layer", StateEvent.CHANGE, "visible", gis));
    }
    /**
     * isVisible
     * @return
     */
    function isVisible():Boolean {
        return visible;
    }
    /**
     * getServiceLayer
     * @return
     */
    function getServiceLayer():ServiceLayer {
        return serviceLayer;
    }
    /**
     * getGeometryTypes
     * @return
     */
    function getGeometryTypes():Array {
        return geometryTypes.concat();
    }
    /**
     * getLabelPropertyName
     * @return
     */
    function getLabelPropertyName():String {
        return labelPropertyName;
    }
    /**
     * getOwnerPropertyName
     * @return
     */
    function getOwnerPropertyName():String {
        return ownerPropertyName;
    }
    /**
     * getProperties
     * @return
     */
    function getProperties():Array {
        return properties.concat();
    }
    /**
     * getProperty
     * @param	name
     * @return
     */
    function getProperty(name:String):Property {
        var property:Property = null;
        for (var i:String in properties) {
            property = Property(properties[i]);
            if (property.getName() == name) {
                return property;
            }
        }
        return null;
    }
    /**
     * getPropertyIndex
     * @param	name
     * @return
     */
    function getPropertyIndex(name:String):Number {
        for (var i:Number = 0; i < properties.length; i++) {
            if (Property(properties[i]).getName() == name) {
                return i;
            }
        }
        return -1;
    }
	/**
	 * getPropertyWithType
	 * @param	propType
	 * @return
	 */
	function getPropertyWithType(propType:String):GeometryProperty {
        for (var i:Number = 0; i < properties.length; i++) {
			if (properties[i] instanceof GeometryProperty) {
				if (GeometryProperty(properties[i]).getPropertyType() == propType) {
					return GeometryProperty(properties[i]);
				}
			}
        }
        return null;
    }
	/**
	 * getPropertyWithTypeIndex
	 * @param	propType
	 * @return
	 */
	function getPropertyWithTypeIndex(propType:String):Number {
        for (var i:Number = 0; i < properties.length; i++) {
            if (properties[i] instanceof GeometryProperty) {
				if (GeometryProperty(properties[i]).getPropertyType() == propType) {
					return i;
				}
			}	
        }
        return -1;
    }
	/**
	 * getRoles
	 * @return
	 */    
    function getRoles():Array {
        return roles.concat();
    }
    /**
     * getStyle
     * @return
     */
    function getStyle():Style {
        return style;
    }
    /**
     * getGIS
     * @return
     */
    function getGIS():GIS {
    	return gis;
    }
    /**
     * getEnvelope
     * @return
     */
    function getEnvelope():Envelope {
    	var feature:Feature = features[0];
    	 var minx:Number = feature.getEnvelope().getMinX();  
    	 var maxx:Number = feature.getEnvelope().getMaxX();
    	 var miny:Number = feature.getEnvelope().getMinY(); 
    	 var maxy:Number = feature.getEnvelope().getMaxY();  	  
    	 for (var i:Number = 1; i < features.length; i++) {
    	 	feature= features[i];
    	 	if (feature.getEnvelope().getMinX() < minx) {
    	 		minx =  feature.getEnvelope().getMinX();
    	 	}
    	 	if (feature.getEnvelope().getMaxX() > maxx) {
    	 		maxx = feature.getEnvelope().getMaxX();
    	 	}
    	 	if (feature.getEnvelope().getMinY() < miny) {
    	 		miny = feature.getEnvelope().getMinY();
    	 	}
    	 	if (feature.getEnvelope().getMaxY() > maxy) {
    	 		maxy =  feature.getEnvelope().getMaxY();
    	 	}
    	 }	   	 
    	 return new Envelope(minx,miny,maxx,maxy);
    }
    /**
     * addWhereClause
     * @param	whereClause
     */
    function addWhereClause(whereClause:WhereClause):Void {
        var whereClausePosition:Number = getWhereClausePosition(whereClause.getPropertyName());
        var notWhereClause:WhereClause = null;
        if (whereClausePosition > -1) {
            notWhereClause = WhereClause(whereClauses[whereClausePosition]);
            whereClauses[whereClausePosition] = whereClause;
        } else {
            whereClauses.push(whereClause);
        }
        
        var feature:Feature = null;
        var propertyName:String = whereClause.getPropertyName();
        var value:String = whereClause.getValue();
        var toBeRemoved:Array = new Array();
        for (var i:Number = 0; i < features.length; i++) {
            feature = Feature(features[i]);
            if (feature.getValue(propertyName) != value) {
                toBeRemoved.push(feature);
            }
        }
        removeFeatures(toBeRemoved, false);
        
        if ((serviceLayer != null) && (notWhereClause != null)) {
            serviceConnector.performGetFeature(serviceLayer, null, whereClauses, notWhereClause, false, this);
        }
    }
    /**
     * removeWhereClause
     * @param	propertyName
     */
    function removeWhereClause(propertyName:String):Void {
        var whereClausePosition:Number = getWhereClausePosition(propertyName);
        if (whereClausePosition == -1) {
            return;
        }
        
        var notWhereClause:WhereClause = WhereClause(whereClauses[whereClausePosition]);
        whereClauses.splice(whereClausePosition, 1);
        
        if (serviceLayer != null) {
            serviceConnector.performGetFeature(serviceLayer, null, whereClauses, notWhereClause, false, this);
        }
    }
    /**
     * getWhereClauses
     * @return
     */
    function getWhereClauses():Array {
        return whereClauses.concat();
    }
    
    private function getWhereClausePosition(propertyName:String):Number {
        for (var i:Number = 0; i < whereClauses.length; i++) {
            if (WhereClause(whereClauses[i]).getPropertyName() == propertyName) {
                return i;
            }
        }
        return -1;
    }
    /**
     * addFeature
     * @param	_object
     */
    function addFeature(_object:Object):Void {
        if (_object == null) {
            _global.flamingo.tracer("Exception in gismodel.Layer.addFeature()\\No service feature or geometry given.");
            return;
        }
        if (!(_object instanceof ServiceFeature) && !(_object instanceof Geometry)) {
            _global.flamingo.tracer("Exception in gismodel.Layer.addFeature()\\Given object is not a service feature or a geometry.");
            return;
        }
        
        var serviceFeature:ServiceFeature = null;
        var geometry:Geometry = null;
        var postAction:Boolean = false;
        if (_object instanceof ServiceFeature) {
            serviceFeature = ServiceFeature(_object);
        } else { // instanceof Geometry
            geometry = Geometry(_object);
            postAction = true;
            if (serviceLayer != null) {
                serviceFeature = serviceLayer.getServiceFeatureFactory().createServiceFeature(serviceLayer);
                serviceFeature.setValue(serviceLayer.getDefaultGeometryProperty().getName(), geometry);
            }
        }
        
        var feature:Feature = null;
        if (serviceFeature == null) {                                            // serviceFeature == null && geometry != null
            var id:String = "T_" + features.length;
            feature = new Feature(this, null, id, geometry, null, null);
        } else if (geometry != null) {                                           // serviceFeature != null && geometry != null
            var id:String = serviceFeature.getID();
            feature = new Feature(this, serviceFeature, id, geometry, null, null);
        } else {                                                                 // serviceFeature != null && geometry == null
            var id:String = serviceFeature.getID();
            			
			if (_object instanceof JsFeature) {		
				geometry= Geometry(JsFeature(serviceFeature).getGeometry());
				postAction = true;
			} else {
				geometry = Geometry(serviceFeature.getValue(serviceLayer.getDefaultGeometryProperty().getName()));
			}	
			
			var values:Array = new Array();
            for (var i:Number = 0; i < properties.length; i++) {
                values.push(serviceFeature.getValue(Property(properties[i]).getName()));
            }
            feature = new Feature(this, serviceFeature, id, geometry, values, null);
        }
        features.push(feature);

        stateEventDispatcher.dispatchEvent(new AddRemoveEvent(this, "Layer", "features", new Array(feature), null));
        
        if (postAction) {
            gis.setActiveFeature(feature);
            
            if (serviceLayer != null) {
                transaction.addOperation(new Insert(serviceFeature));
            }
        }
		if (!loadFeaturesOnStart){
			gis.setActiveFeature(feature);
		}
    }
    /**
     * removeFeatures
     * @param	features
     * @param	addOperation
     */
    function removeFeatures(features:Array, addOperation:Boolean):Void {
        if (features == null) {
            _global.flamingo.tracer("Exception in gismodel.Layer.removeFeatures()");
            return;
        }
        
        for (var i:Number = 0; i < features.length; i++) {
            doRemoveFeature(Feature(features[i]), addOperation);
        }
        
        stateEventDispatcher.dispatchEvent(new AddRemoveEvent(this, "Layer", "features", null, features));
    }
    /**
     * removeFeature
     * @param	feature
     * @param	addOperation
     */
    function removeFeature(feature:Feature, addOperation:Boolean):Void {
        if (feature == null) {
            _global.flamingo.tracer("Exception in gismodel.Layer.removeFeature()");
            return;
        }
        
        doRemoveFeature(feature, addOperation);
        
        stateEventDispatcher.dispatchEvent(new AddRemoveEvent(this, "Layer", "features", null, new Array(feature)));
    }
    
    private function doRemoveFeature(feature:Feature, addOperation:Boolean):Void { // Removes the given feature, without dispatching an event.
        var featurePosition:Number = getFeaturePosition(feature);
        
        if (featurePosition == -1) {
            _global.flamingo.tracer("Exception in gismodel.Layer.doRemoveFeature()");
            return;
        }
        gis.raiseFeatureRemoved(feature);
        if (gis.getActiveFeature() == feature) {
            gis.setActiveFeature(null);
        }
        features.splice(featurePosition, 1);
        
        if (addOperation) {
            var serviceFeature:ServiceFeature = feature.getServiceFeature();
            if (serviceFeature != null) {
                transaction.addOperation(new Delete(serviceFeature));
            }
        }
    }
    /**
     * getFeatures
     * @return
     */		
    function getFeatures():Array {
        return features.concat();
    }
    /**
     * getFeature
     * @param	id
     * @return
     */
    function getFeature(id:String):Feature {
        var feature:Feature = null;
        for (var i:String in features) {
            feature = Feature(features[i]);
            if (feature.getID() == id) {
                return feature;
            }
        }
        return null;
    }
    /**
     * getFeaturePosition
     * @param	feature
     * @return
     */
    function getFeaturePosition(feature:Feature):Number {
        for (var i:Number = 0; i < features.length; i++) {
            if (features[i] == feature) {
                return i;
            }
        }
        return -1;
    }
    /**
     * getFeatureWithGeometry
     * @param	extent
     */
	function getFeatureWithGeometry(extent:geometrymodel.Geometry):Void{
		if (serviceConnector !=null){
			serviceConnector.performGetFeature(serviceLayer, extent, whereClauses, null, false, this);			
		}
	}
    /**
     * addOperation
     * @param	operation
     */
    function addOperation(operation:Operation):Void {
        transaction.addOperation(operation);
    }
    /**
     * commit
     */
    function commit():Void {
        if ((serverReady) && (transaction.getOperations().length > 0)) {
            serverReady = false;
            serviceConnector.performTransaction(transaction, this);
        } else {
            gis.onServerReady();
        }
    }
    /**
     * isTransactionProblematic4Server
     * @return
     */
    function isTransactionProblematic4Server():Boolean {
        if (transaction.getOperations().length == 0) {
            return false;
        } else if (serverReady) {
            return false;
        } else if (serviceLayer == null) {
            return false;
        }
        return true;
    }
    /**
     * onActionEvent
     * @param	actionEvent
     */
    function onActionEvent(actionEvent:ActionEvent):Void {
        var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
		if (sourceClassName + "_" + actionType == "ServiceConnector_" + ActionEvent.LOAD) {
            var exceptionMessage:String = actionEvent["exceptionMessage"];
            var serviceLayer:ServiceLayer = ServiceLayer(actionEvent["serviceLayer"]);
		
			var serviceFeatures:Array = actionEvent["features"];
            var transactionResponse:TransactionResponse = TransactionResponse(actionEvent["transactionResponse"]);
            if (exceptionMessage != null) {
                _global.flamingo.showError("Fout bij het opslaan", exceptionMessage, 0);
                serverReady = true;
                gis.onServerReady();
            } else if (serviceLayer != null) {
                this.serviceLayer = serviceLayer;
                serverReady = true;
				if (loadFeaturesOnStart){
	                serviceConnector.performGetFeature(serviceLayer, null, whereClauses, null, false, this);
				}
            } else if (serviceFeatures != null) {
				//raise api event onFeatureFound() through a new StateEvent to reach editMap.swf from where we want to raise the api event call.
				stateEventDispatcher.dispatchEvent(new AddRemoveEvent(this, "Layer", "featuresFound", serviceFeatures, null, null) );
				
				for (var i:Number = 0; i < serviceFeatures.length; i++) {
					addFeature(ServiceFeature(serviceFeatures[i]));
				}

            } else { // Transaction response.
                var previousIDs:Array = transactionResponse.getPreviousIDs();
                var previousID:String = null;
                var feature:Feature = null;
                var serviceFeature:ServiceFeature = null;
                for (var i:String in previousIDs) {
                    previousID = previousIDs[i];
                    feature = getFeature(previousID);
                    serviceFeature = feature.getServiceFeature();
                    serviceFeature.setID(transactionResponse.getID(previousID));
                    removeFeature(feature, false);
                    addFeature(serviceFeature);
                }
                
                transaction = new Transaction();
                serverReady = true;
                gis.onServerReady();
            }
        }
    }
    /**
     * addEventListener
     * @param	stateEventListener
     * @param	sourceClassName
     * @param	actionType
     * @param	propertyName
     */
    function addEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.CHANGE + "_visible")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.ADD_REMOVE + "_features")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.ADD_REMOVE + "_featuresFound")
           ) {
            _global.flamingo.tracer("Exception in gismodel.Layer.addEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.addEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    /**
     * removeEventListener
     * @param	stateEventListener
     * @param	sourceClassName
     * @param	actionType
     * @param	propertyName
     */
    function removeEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.CHANGE + "_visible")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.ADD_REMOVE + "_features")
			 && (sourceClassName + "_" + actionType + "_" + propertyName != "Layer_" + StateEvent.ADD_REMOVE + "_featuresFound")
           ) {
            _global.flamingo.tracer("Exception in gismodel.Layer.removeEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.removeEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    /**
     * showMeasure
     * @return
     */ 
    function showMeasure():Boolean{
    	return showMeasures;
    }
	
	function getMeasureUnit():String {
		return measureUnit;
	}
	function getMeasureDecimals():Number {
		return measureDecimals;
	}
	function getMeasureMagicnumber():Number {
		return measureMagicnumber;
	}
	function getMeasureDs():String {
		return measureDs;
	}
	/**
	 * getEditable
	 * @return
	 */
	function getEditable():Boolean {
		return this.editable;
	}
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Layer(" + name + ", " + title + ")";
    }
    
}
