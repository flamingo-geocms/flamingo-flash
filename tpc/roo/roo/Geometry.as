import roo.Point;
import roo.Envelope;

class roo.Geometry {

	//private var stateEventDispatcher:StateEventDispatcher = null;
    private var parent:Geometry = null;
    
    function Geometry() {
        //stateEventDispatcher = new StateEventDispatcher();
    }
    
    function setParent(parent:Geometry):Void {
        if (this.parent != parent) {
            if ((this.parent != null) && (parent == null)) {
                var previousParent:Geometry = this.parent;
                this.parent = null;
                previousParent.removeChild(this);
            } else if ((this.parent == null) && (parent != null)) {
                this.parent = parent;
                parent.addChild(this);
            } else { // ((this.parent != null) && (parent != null))
                var previousParent:Geometry = this.parent;
                this.parent = null;
                previousParent.removeChild(this);
                this.parent = parent;
                parent.addChild(this);
            }
        }
    }
    
    function getParent():Geometry {
        return parent;
    }
    
    function getFirstAncestor():Geometry {
        if (parent != null) {
            return parent;
        } else {
            return this;
        }
    }
    
    function addChild(child:Geometry):Void { }
    
    function removeChild(child:Geometry):Void { }
    
    function getChildGeometries():Array { return null; }
    
    function move(dx:Number, dy:Number):Void { }
    
    function getEndPoint():Point { return null; }
    
    function getCenterPoint():Point { return null; }
    
    function getEnvelope():Envelope { return null; }
    
    function toGML():XML {
        return new XML(toGMLString());
    }
    
    function toGMLString():String { return null; }
    
    /*function addEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.CHANGE + "_null")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.ADD_REMOVE + "_childGeometries")
           ) {
            trace("Exception in geometrymodel.Geometry.addEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.addEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    function removeEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.CHANGE + "_null")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.ADD_REMOVE + "_childGeometries")
           ) {
            trace("Exception in geometrymodel.Geometry.removeEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.removeEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    private function dispatchEvent(stateEvent:StateEvent):Void {
        stateEventDispatcher.dispatchEvent(stateEvent);
        
        if (parent != null) {
            parent.dispatchEvent(stateEvent);
        }
    }*/
    
}
