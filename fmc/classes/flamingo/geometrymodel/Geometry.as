// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.geometrymodel.*;

import flamingo.event.StateEvent;
import flamingo.event.StateEventListener;
import flamingo.event.StateEventDispatcher;

class flamingo.geometrymodel.Geometry {
    
    private var stateEventDispatcher:StateEventDispatcher = null;
    private var parent:Geometry = null;
    
    function Geometry() {
        stateEventDispatcher = new StateEventDispatcher();
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
            } else if ((this.parent != null) && (parent != null)) {
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
        if (parent == null) {
            return this;
        } else {
            return parent.getFirstAncestor();
        }
    }
    
    function addChild(child:Geometry):Void { }
    
    function removeChild(child:Geometry):Void { }
    
    function isChild(child:Geometry):Boolean {
        var childGeometries:Array = getChildGeometries();
        for (var i:String in childGeometries) {
            if (childGeometries[i] == child) {
                return true;
            }
        }
        return false;
    }
    
    function getChildGeometries():Array { return null; }
    
    function getPoints():Array { return null; }
    
    function getEndPoint():Point { return null; }
    
    function getCenterPoint():Point { return null; }
    
    function getEnvelope():Envelope { return null; }
    
    function isWithin(envelope:Envelope):Boolean {
        var points:Array = getPoints();
        for (var i:String in points) {
            if (!Point(points[i]).isWithin()) {
                return false;
            }
        }
        return true;
    }
    
    function move(dx:Number, dy:Number):Void {
        var childGeometries:Array = getChildGeometries();
        for (var i:String in childGeometries) {
            Geometry(childGeometries[i]).move(dx, dy);
        }
    }
    
    function equals(geometry:Geometry):Boolean {
        return false;
    }
    
    function clone():Geometry { return null; }
    
    function toGML():XML {
        return new XML(toGMLString());
    }
    
    function toGMLString():String { return null; }
    
    function addEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.CHANGE + "_null")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.ADD_REMOVE + "_childGeometries")
           ) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Geometry.addEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.addEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    function removeEventListener(stateEventListener:StateEventListener, sourceClassName:String, actionType:Number, propertyName:String):Void {
        if (
                (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.CHANGE + "_null")
             && (sourceClassName + "_" + actionType + "_" + propertyName != "Geometry_" + StateEvent.ADD_REMOVE + "_childGeometries")
           ) {
            _global.flamingo.tracer("Exception in flamingo.geometrymodel.Geometry.removeEventListener(" + sourceClassName + ", " + propertyName + ")");
            return;
        }
        
        stateEventDispatcher.removeEventListener(stateEventListener, sourceClassName, actionType, propertyName);
    }
    
    private function dispatchEvent(stateEvent:StateEvent):Void {
        stateEventDispatcher.dispatchEvent(stateEvent);
        
        if (parent != null) {
            parent.dispatchEvent(stateEvent);
        }
    }
    
}
