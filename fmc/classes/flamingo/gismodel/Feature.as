// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gismodel.*;

import flamingo.event.*;
import flamingo.coremodel.service.*;
import flamingo.coremodel.service.wfs.*;
import flamingo.geometrymodel.Geometry;
import flamingo.geometrymodel.GeometryTools;

class flamingo.gismodel.Feature {
    
    private var layer:Layer = null;
    private var serviceFeature:ServiceFeature = null;
    private var id:String = null;
    private var geometry:Geometry = null;
    private var values:Array = null;
    
    private var stateEventDispatcher:StateEventDispatcher = null;
    
    function Feature(layer:Layer, serviceFeature:ServiceFeature, id:String, geometry:Geometry, values:Array, ownerName:String) {
        if (layer == null) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>(" + id + ")\nNo layer given.");
            return;
        }
        if (id == null) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>()\nNo id given.");
            return;
        }
        if (geometry == null) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>(" + id + ")\No geometry given.");
            return;
        }
        var geometryTypes:Array = layer.getGeometryTypes();
        if (geometryTypes.length > 0) {
            var clazz:Function = null;
            var match:Boolean = false;
            for (var i:String in geometryTypes) {
                clazz = GeometryTools.getGeometryClass(geometryTypes[i]);
                if (geometry instanceof clazz) {
                    match = true;
                    break;
                }
            }
            if (!match) {
                _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>(" + id + ")\nType of the given geometry does not match any of the geometry types of the layer.");
                return;
            }
        }
        var properties:Array = layer.getProperties();
        if ((values != null) && (values.length != properties.length)) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>(" + id + ", " + values.toString() + ")\nNumber of given values does not match the number of properties of the layer.");
            return;
        }
        if (values == null) {
            values = new Array();
            var defaultValue:String = null;
            for (var i:Number = 0; i < properties.length; i++) {
                defaultValue = Property(properties[i]).getDefaultValue();
                values.push(defaultValue); // Default value may be null.
            }
            var ownerPropertyName:String = layer.getOwnerPropertyName();
            if ((ownerPropertyName != null) && (ownerName != null)) {
                values[layer.getPropertyIndex(ownerPropertyName)] = ownerName;
            }
        }
        
        var whereClauses:Array = layer.getWhereClauses();
        var whereClause:WhereClause = null;
        var propertyIndex:Number = -1;
        var value:String = null;
        for (var i:String in whereClauses) {
            whereClause = WhereClause(whereClauses[i]);
            propertyIndex = layer.getPropertyIndex(whereClause.getPropertyName());
            if (propertyIndex > -1) {
                value = whereClause.getValue();
                if (values[propertyIndex] == null) {
                    values[propertyIndex] = value;
                } else if (values[propertyIndex] != value) {
                    _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.<<init>>(" + id + ", " + values.toString() + ")");
                    return;
                }
            }
        }
        
        this.layer = layer;
        this.serviceFeature = serviceFeature;
        this.id = id;
        this.geometry = geometry;
        this.values = values;
        
        stateEventDispatcher = new StateEventDispatcher();
    }
    
    function getLayer():Layer {
        return layer;
    }
    
    function getServiceFeature():ServiceFeature {
        return serviceFeature;
    }
    
    function getID():String {
        return id;
    }
    
    function getGeometry():Geometry {
        return geometry;
    }
    
    function setValues(values:Array):Void {
        var properties:Array = layer.getProperties();
        if ((values == null) || (values.length != properties.length)) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.setValues(" + values.toString() + ")");
            return;
        }
        
        var property:Property = null;
        var value:Object = null;
        for (var i:Number = 0; i < properties.length; i++) {
            property = Property(properties[i]);
            value = values[i];
            if (property.isImmutable()) {
                continue;
            }
            
            this.values[i] = value;
            
            if (serviceFeature != null) {
                serviceFeature.setValue(property.getName(), value);
            }
        }
        if (serviceFeature != null) {
            layer.addOperation(new Update(serviceFeature));
        }
        
        stateEventDispatcher.dispatchEvent(new StateEvent(this, "Feature", StateEvent.CHANGE, "values"));
    }
    
    function setValue(name:String, value:String):Void {
        var propertyIndex:Number = layer.getPropertyIndex(name);
        if (propertyIndex == -1) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.setValue(" + name + ")\nGiven property does not exist.");
            return;
        }
        if (layer.getProperty(name).isImmutable()) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.setValue(" + name + ")\nGiven property is immutable.");
            return;
        }
        
        if (values[propertyIndex] != value) {
            values[propertyIndex] = value;
            
            if (serviceFeature != null) {
                serviceFeature.setValue(name, value);
                layer.addOperation(new Update(serviceFeature));
            }
            
            stateEventDispatcher.dispatchEvent(new StateEvent(this, "Feature", StateEvent.CHANGE, "values"));
        }
    }
    
    function getValues():Array {
        return values.concat();
    }
    
    function getValue(propertyName:String):String {
        var propertyIndex:Number = layer.getPropertyIndex(propertyName);
        if (propertyIndex == -1) {
            // _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.getValue(" + propertyName + ")");
            return null;
        }
        
        return values[propertyIndex];
    }
    
    function getLabelText():String {
        var labelPropertyName:String = layer.getLabelPropertyName();
        if (labelPropertyName == null) {
            return null;
        }
        
        return getValue(labelPropertyName);
    }
    
    function addEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (sourceClassName + "_" + actionType + "_" + propertyName != "Feature_" + StateEvent.CHANGE + "_values") {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.addEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        stateEventDispatcher.addEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    function removeEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (sourceClassName + "_" + actionType + "_" + propertyName != "Feature_" + StateEvent.CHANGE + "_values") {
            _global.flamingo.tracer("Exception in flamingo.gismodel.Feature.removeEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        stateEventDispatcher.removeEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    function toString():String {
        return "Feature(" + id + ")";
    }
    
}
