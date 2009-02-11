// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gismodel.*;

import flamingo.geometrymodel.GeometryFactory;

class flamingo.gismodel.CreateGeometry {
    
    private var layer:Layer = null;
    private var geometryFactory:GeometryFactory = null;
    
    function CreateGeometry(layer:Layer, geometryFactory:GeometryFactory) {
        if (layer == null) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.CreateGeometry.<<init>>()\nNo layer given.");
            return;
        }
        if (geometryFactory == null) {
            _global.flamingo.tracer("Exception in flamingo.gismodel.CreateGeometry.<<init>>()\nNo geometry factory given.");
            return;
        }
        
        this.layer = layer;
        this.geometryFactory = geometryFactory;
    }
    
    function getLayer():Layer {
        return layer;
    }
    
    function getGeometryFactory():GeometryFactory {
        return geometryFactory;
    }
    
    function toString():String {
        return "CreateGeometry(" + layer.getName() + ")";
    }
    
}
