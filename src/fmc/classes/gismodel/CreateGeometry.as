/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gismodel.*;

import geometrymodel.GeometryFactory;
/**
 * gismodel.CreateGeometry
 */
class gismodel.CreateGeometry {
    
    private var layer:Layer = null;
    private var geometryFactory:GeometryFactory = null;
    /**
     * constructor
     * @param	layer
     * @param	geometryFactory
     */
    function CreateGeometry(layer:Layer, geometryFactory:GeometryFactory) {
        if (layer == null) {
            _global.flamingo.tracer("Exception in gismodel.CreateGeometry.<<init>>()\nNo layer given.");
            return;
        }
        if (geometryFactory == null) {
            _global.flamingo.tracer("Exception in gismodel.CreateGeometry.<<init>>()\nNo geometry factory given.");
            return;
        }
        
        this.layer = layer;
        this.geometryFactory = geometryFactory;
    }
    /**
     * getLayer
     * @return
     */
    function getLayer():Layer {
        return layer;
    }
    /**
     * getGeometryFactory
     * @return
     */
    function getGeometryFactory():GeometryFactory {
        return geometryFactory;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "CreateGeometry(" + layer.getName() + ")";
    }
    
}
