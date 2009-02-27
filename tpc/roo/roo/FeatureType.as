/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.FeatureType {

	private var name:String = null;
    private var geometryPropertyName:String = null;
    private var namespace:String = null;
    
    function FeatureType(name:String, geometryPropertyName:String, namespace:String) {
        if (name == null) {
            return;
        }
        if (geometryPropertyName == null) {
            return;
        }
        
        this.name = name;
        this.geometryPropertyName = geometryPropertyName;
        this.namespace = namespace;
    }
    
    function getName():String {
        return name;
    }
    
    function getGeometryPropertyName():String {
        return geometryPropertyName;
    }
    
    function getNamespace():String {
        return namespace;
    }
    
    function toString():String {
        return "FeatureType(" + name + ")";
    }
    
}
