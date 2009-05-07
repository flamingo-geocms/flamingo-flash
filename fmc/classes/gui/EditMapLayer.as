/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.*;

import event.*;
import gismodel.GIS;
import gismodel.Layer;
import gismodel.Feature;

class gui.EditMapLayer extends MovieClip implements StateEventListener {
    
    private var gis:GIS = null; // Set by init object.
	private var map:Object = null; // Set by init object.
    private var layer:Layer = null; // Set by init object.
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    
    private var editMapFeatures:Array = null;
    private var stateEventDispatcher:StateEventDispatcher;
    
    function onLoad():Void {
        editMapFeatures = new Array();
        addEditMapFeatures(layer.getFeatures());
        layer.addEventListener(this, "Layer", StateEvent.ADD_REMOVE, "features");
    }
    
    function remove():Void { // This method is an alternative to the default MovieClip.removeMovieClip. Also unsubscribes as event listener. The event method MovieClip.onUnload cannot be used, because it works buggy.
        layer.removeEventListener(this, "Layer", StateEvent.ADD_REMOVE, "features");
        
        for (var i:String in editMapFeatures) {
            EditMapFeature(editMapFeatures[i]).remove();
        }
        this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    
    function setSize(width:Number, height:Number):Void {
        this.width = width;
        this.height = height;
        
        for (var i:String in editMapFeatures) {
            EditMapFeature(editMapFeatures[i]).setSize(width, height);
        }
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.ADD_REMOVE + "_features") {
            var addedFeatures:Array = AddRemoveEvent(stateEvent).getAddedObjects();
            addEditMapFeatures(addedFeatures);
            var removedFeatures:Array = AddRemoveEvent(stateEvent).getRemovedObjects();
            removeEditMapFeatures(removedFeatures);
        }
    }
    
    function getLayer():Layer {
        return layer;
    }
    
    private function addEditMapFeatures(features:Array):Void {
        for (var i:Number = 0; i < features.length; i++) {
            addEditMapFeature(Feature(features[i]));
        }
    }
    
    private function removeEditMapFeatures(features:Array):Void {
        for (var i:Number = 0; i < features.length; i++) {
            removeEditMapFeature(Feature(features[i]));
        }
    }
    
    private function addEditMapFeature(feature:Feature):Void {
        var depth:Number = layer.getFeaturePosition(feature);
        var editMapFeature:EditMapFeature = null;
        for (var i:Number = editMapFeatures.length - 1; i >= depth ; i--) { // Increments the depths of all gui features in the collection that have a depth greater than or equal to the feature that will be added. Loops top down; a bottom up loop will not work with a getDepth() + 1.
            editMapFeature = EditMapFeature(editMapFeatures[i]);
            editMapFeature.swapDepths(editMapFeature.getDepth() + 1);
            editMapFeature._name = "mcFeature" + editMapFeature.getDepth();
        }
        var initObject:Object = new Object();
        initObject["gis"] = gis;
		initObject["map"] = map;
        initObject["feature"] = feature;
        initObject["style"] = layer.getStyle();
        initObject["width"] = width;
        initObject["height"] = height;
        editMapFeatures.push(attachMovie("EditMapFeature", "mEditMapFeature" + depth, depth, initObject)); // Adds the feature to the collection of gui features.
    }
    
    private function removeEditMapFeature(feature:Feature):Void {
        var editMapFeature:EditMapFeature = null;
        var swapDepths:Boolean = false;
        for (var i:Number = 0; i < editMapFeatures.length; i++) {
            editMapFeature = EditMapFeature(editMapFeatures[i]);
            if (editMapFeature.getFeature() == feature) { // Removes the feature from the collection of gui features. Assumes that there is not more than one gui feature with the given gis feature. 
                editMapFeature.remove();
                editMapFeatures.splice(i--, 1); // The i-- is necessary here, because the array that is spliced is also being looped.
                swapDepths = true;
            } else if (swapDepths) { // Decrements the depths of all gui features in the collection that have a depth greater than the feature that was removed.
                editMapFeature.swapDepths(editMapFeature.getDepth() - 1);
                editMapFeature._name = "mcFeature" + editMapFeature.getDepth();
            }
        }
    }

}
