/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import geometrymodel.Polygon;
import gui.*

import event.StateEventListener;
import event.StateEvent;
import tools.Logger;

import gismodel.Feature;

class gui.EditMapFeature extends GeometryPane implements StateEventListener {
    
    private var feature:Feature = null; // Set by init object.
	private var log:Logger=null;
    
    function onLoad():Void {
        super.onLoad(); 
        this.log = new Logger("gui.EditMapFeature",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
        feature.addEventListener(this, "Feature", StateEvent.CHANGE, "values");
        if (feature == gis.getActiveFeature()) {
            addEditMapGeometry(feature.getGeometry(), EditMapGeometry.ACTIVE, feature.getLabelText(), 0, false);
        } else {
            addEditMapGeometry(feature.getGeometry(), EditMapGeometry.NORMAL, feature.getLabelText(), 0, false);
        }
        editMapGeometries[0].addChildGeometries();
    }
    
    function remove():Void { // This method is an alternative to the default MovieClip.removeMovieClip. Also unsubscribes as event listener. The event method MovieClip.onUnload cannot be used, because it works buggy.
		gis.removeEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
        feature.removeEventListener(this, "Feature", StateEvent.CHANGE, "values");
        this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    
    function setSize(width:Number, height:Number):Void { // This method is a stub. It is necessary though, because of the "super" bug in Flash.
        super.setSize(width, height);
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            var editMapGeometry:EditMapGeometry = EditMapGeometry(editMapGeometries[0]);
			if (feature == gis.getActiveFeature()) {
                editMapGeometry.setType(EditMapGeometry.ACTIVE);
            } else {
                editMapGeometry.setType(EditMapGeometry.NORMAL);
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Feature_" + StateEvent.CHANGE + "_values") {
            var editMapGeometry:EditMapGeometry = EditMapGeometry(editMapGeometries[0]);
            editMapGeometry.setLabelText(feature.getLabelText());
        }
    }
    
    function getFeature():Feature {
        return feature;
    }
    
    function onPress():Void {
		
        if (gis.getActiveFeature() == feature) {
			//Allow editing of the current active feature if the geometry is editable.
			if (!editable){
				gis.setActiveFeature(null);
			}
        } else {
            gis.setActiveFeature(feature);
        }
		if (feature.getGeometry() instanceof Polygon ) {
			editMapGeometries[0].dragFeature();
		}
    }
    
}