/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.WFSFeature {

	private var id:String = null;
    private var values:Object = null; // Associative array.
    
    function WFSFeature(id:String, values:Object) {
        if (id == null) {
            return;
        }
        if (values == null) {
            return;
        }
        
        this.id = id;
        this.values = values;
    }
    
    function getID():String {
        return id;
    }
    
    function getValue(name:String):String {
        if (values[name] == undefined) {
            return null;
        }
        
        return values[name];
    }
    
    function toString():String {
        return "WFSFeature(" + id + ")";
    }
    
}
