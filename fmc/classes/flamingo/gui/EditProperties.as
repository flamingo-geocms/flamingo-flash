/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/


/** @component EditProperties
* Edit properties component. A component that shows the properties of the active feature in the feature model, and their values. 
* As a single line or multi line text inputs, or as drop down lists. The user can change the values for properties that are not immutable.
* Changing values in the edit properties component means changing them in the feature model at the same time. Please refer to the GIS component.
* @file flamingo/tpc/classes/flamingo/gui/EditProperties.as  (sourcefile)
* @file flamingo/tpc/EditProperties.fla (sourcefile)
* @file flamingo/tpc/EditProperties.swf (compiled component, needed for publication on internet)
*/

/** @tag <tpc:EditProperties>
* This tag defines an edit properties component instance. The edit properties component must be registered as a listener to an edit map. 
* Actually, the edit properties component listens to the feature model underneath the edit map. 
* An edit properties component should be placed in a window so that the active feature event of the feature model can make it pop-up. 
* The visible parameter of EditProperties and the window should both be configured to false.
* @class flamingo.gui.EditProperties extends AbstractComponent implements StateEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example
  <fmc:Window id="editPropertiesWindow">
     <tpc:EditProperties id="editProperties" top="0" left="0" right="right" bottom="bottom" visible="false" listento="editMap"/>
  </fmc:Window>
*/


import flamingo.gui.*;

import flamingo.event.*;
import flamingo.coremodel.service.ServiceLayer;
import flamingo.gismodel.Feature;
import flamingo.gismodel.GIS;
import flamingo.gismodel.Layer;
import flamingo.gismodel.Property;

import flash.geom.Rectangle;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.TextArea;
import mx.controls.UIScrollBar;
import mx.utils.Delegate;

import flamingo.core.AbstractComponent;

class flamingo.gui.EditProperties extends AbstractComponent implements StateEventListener {
    
    private var gis:GIS = null;
    private var components:Array = null;
    private var mainLabel:Label = null;
    private var labelStyle:Object = null;
    private var componentsPanel:MovieClip = null;
    private var componentHeight:Number = 22;
    private var vertiSpacing:Number = 7;
    private var minTextAreaHeight:Number = 50;
    private var scrollBar:UIScrollBar = null;
    private var nullValueText:String = "";
    
    function init():Void {
        gis = _global.flamingo.getComponent(listento[0]).getGIS();
        
        components = new Array();
        
        gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
        
        mainLabel = Label(attachMovie("Label", "mMainLabel", 0, {autoSize: "left"}));
        labelStyle = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        mainLabel.setStyle("fontFamily", labelStyle["fontFamily"]);
        mainLabel.setStyle("fontSize", labelStyle["fontSize"]);
        mainLabel.setStyle("fontWeight", "bold");
        componentsPanel = createEmptyMovieClip("mPanel", 1);
        componentsPanel._y = componentHeight;
        componentsPanel._lockroot = true; // Without this line comboboxes wouldn't open.
    }
    
    private function layout():Void {
        var numLabels:Number = 0;
        var numTextAreas:Number = 0;
        for (var i:String in components) {
            if (components[i] instanceof Label) {
                numLabels++;
            } else if (components[i] instanceof TextArea) {
                numTextAreas++;
            }
        }
        var panelWidth:Number = __width - 15 - 1;
        var panelHeight:Number = __height - componentHeight;
        var textAreaHeight:Number = (__height - ((components.length + 1 - numTextAreas) * componentHeight) - (numLabels * vertiSpacing)) / numTextAreas;
        if (textAreaHeight < minTextAreaHeight) {
            textAreaHeight = minTextAreaHeight;
        }
        var y:Number = 0;
        
        var component:MovieClip = null;
        for (var i:Number = 0; i < components.length; i++) {
            component = MovieClip(components[i]);
            if (component instanceof Label) {
                y += vertiSpacing;
                component._y = y;
                y += componentHeight;
            } else if (component instanceof TextArea) {
                component._y = y;
                component.setSize(panelWidth, textAreaHeight);
                y += textAreaHeight;
            } else {
                component._y = y;
                component.setSize(panelWidth, componentHeight);
                y += componentHeight;
            }
        }
        
        if (y > panelHeight) {
            if (scrollBar == null) {
                scrollBar = UIScrollBar(attachMovie("UIScrollBar", "mScrollBar", 2, {_y: componentHeight}));
                scrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            }
            scrollBar._x = panelWidth;
            scrollBar.setSize(15, panelHeight);
            scrollBar.setScrollProperties(panelHeight, 0, y - panelHeight);
            componentsPanel.scrollRect = new Rectangle(0, scrollBar.scrollPosition, panelWidth, y);
        } else {
            if (scrollBar != null) {
                scrollBar.removeMovieClip();
                scrollBar = null;
                componentsPanel.scrollRect = null;
            }
        }
    }
    
    function onScrollBar(eventObject:Object):Void {
        var rectangle:Rectangle = Rectangle(componentsPanel.scrollRect);
        rectangle.y = scrollBar.scrollPosition;
        componentsPanel.scrollRect = rectangle;
    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
        
        if (!this.visible) {
            gis.setActiveFeature(null);
        }
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            var previousActiveFeature:Feature = Feature(ChangeEvent(stateEvent).getPreviousState());
            var activeFeature:Feature = gis.getActiveFeature();
            if (previousActiveFeature != null) {
                previousActiveFeature.removeEventListener(this, "Feature", StateEvent.CHANGE, "values");
            }
            if (activeFeature != null) {
                activeFeature.addEventListener(this, "Feature", StateEvent.CHANGE, "values");
                
                setVisible(true);
                if (previousActiveFeature == null) {
                    addComponents();
                } else if (previousActiveFeature.getLayer() == activeFeature.getLayer()) {
                    setComponentValues();
                } else { // From a different layer; not from null.
                    removeComponents();
                    addComponents();
                }
            } else {
                setVisible(false);
                removeComponents();
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Feature_" + StateEvent.CHANGE + "_values") {
            setComponentValues();
        }
    }
    
    private function addComponents():Void {
        if (components.length > 0) {
            _global.flamingo.tracer("Exception in flamingo.gui.EditProperties.addComponents()");
            return;
        }
        
        var feature:Feature = gis.getActiveFeature();
        var layer:Layer = feature.getLayer();
        var layerName:String = layer.getName();
        var serviceLayer:ServiceLayer = layer.getServiceLayer();
        var properties:Array = layer.getProperties();
        var property:Property = null;
        var propertyName:String = null;
        var propertyType:String = null;
        var initObject:Object = null;
        var dataProvider:Array = null;
        
        for (var i:Number = 0; i < properties.length; i++) {
            property = Property(properties[i]);
            propertyName = property.getName();
            propertyType = property.getType();
            
            initObject = new Object();
            initObject["autoSize"] = "left";
            initObject["text"] = property.getTitle();
            components.push(componentsPanel.attachMovie("Label", "mLabel" + layerName + i, i * 2, initObject));
            Label(components[i * 2]).setStyle("fontFamily", labelStyle["fontFamily"]);
            Label(components[i * 2]).setStyle("fontSize", labelStyle["fontSize"]);
            if ((serviceLayer == null) || (serviceLayer.getServiceProperty(propertyName).isOptional())) {
                Label(components[i * 2]).setStyle("fontStyle", "italic");
            }
            
            initObject = new Object();
            initObject["enabled"] = !property.isImmutable();
			initObject["tabIndex"] = i;
			initObject["tabEnabled"] = true;
            if (propertyType == "SingleLine") {
                components.push(componentsPanel.attachMovie("TextInput", "mComponent" + layerName + i, i * 2 + 1, initObject));
            } else if (propertyType == "MultiLine") {
                components.push(componentsPanel.attachMovie("TextArea", "mComponent" + layerName + i, i * 2 + 1, initObject));
            } else { // DropDown
                dataProvider = propertyType.split(":")[1].split(",");
                dataProvider.splice(0, 0, nullValueText);
                initObject["dataProvider"] = dataProvider;
                initObject["rowCount"] = dataProvider.length;
                initObject["editable"] = false;
                components.push(componentsPanel.attachMovie("ComboBox", "mComponent" + layerName + i, i * 2 + 1, initObject));
                ComboBox(components[i * 2 + 1]).getDropdown().drawFocus = ""; // Without this line the green focus would remain after selecting from the combobox.
            }
            MovieClip(components[i * 2 + 1]).addEventListener("change", Delegate.create(this, onComponentChange));
        }
        
        layout();
        setComponentValues();
    }
    
    function onComponentChange(eventObject:Object):Void {
        setFeatureValues();
    }
    
    private function removeComponents():Void {
        for (var i:String in components) {
            MovieClip(components[i]).removeMovieClip();
        }
        components = new Array();
    }
    
    private function setComponentValues():Void {
        var feature:Feature = gis.getActiveFeature();
        var properties:Array = feature.getLayer().getProperties();
        var values:Array = feature.getValues();
        var value:String = null;
        var component:MovieClip = null;
        for (var i:Number = 0; i < properties.length; i++) {
            value = values[i];
            if (value == null) {
                value = nullValueText;
            }
            component = MovieClip(components[i * 2 + 1]);
            if (component instanceof ComboBox) {
                setComboBoxValue(ComboBox(component), value);
            } else {
                component.text = value;
            }
        }
        
        mainLabel.text = feature.getLayer().getTitle() + ": " + feature.getID();
    }
    
    private function setComboBoxValue(comboBox:ComboBox, value:String):Void {
        var dataProvider:Array = comboBox.dataProvider;
        for (var i:Number = 0; i < dataProvider.length; i++) {
            if (dataProvider[i] == value) {
                comboBox.selectedIndex = i;
                return;
            }
        }
        _global.flamingo.tracer("Exception in flamingo.gui.EditProperties.setComboBoxValue()\nThe value \"" + value + "\" does not exist in \"" + dataProvider.toString() + "\".");
    }
    
    private function setFeatureValues():Void {
        var feature:Feature = gis.getActiveFeature();
        var properties:Array = feature.getLayer().getProperties();
        var values:Array = new Array();
        var value:String = null;
        var component:MovieClip = null;
        for (var i:Number = 0; i < properties.length; i++) {
            component = MovieClip(components[i * 2 + 1]);
            if (component instanceof ComboBox) {
                value = String(ComboBox(component).selectedItem);
            } else {
                value = component.text;
            }
            if (value == nullValueText) {
                value = null;
            }
            values.push(value);
        }
        feature.setValues(values);
    }
    
}
