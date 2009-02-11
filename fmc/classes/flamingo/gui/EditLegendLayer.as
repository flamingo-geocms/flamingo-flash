// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gui.*;

import flamingo.coregui.ButtonBar;
import flamingo.coregui.ButtonConfig;
import flamingo.event.ActionEvent;
import flamingo.event.ActionEventListener;
import flamingo.event.StateEvent;
import flamingo.event.StateEventListener;
import flamingo.geometrymodel.CircleFactory;
import flamingo.geometrymodel.LineStringFactory;
import flamingo.geometrymodel.PointFactory;
import flamingo.geometrymodel.PolygonFactory;
import flamingo.gismodel.CreateGeometry;
import flamingo.gismodel.GIS;
import flamingo.gismodel.Layer;

import mx.controls.CheckBox;
import mx.controls.Label;

class flamingo.gui.EditLegendLayer extends MovieClip implements StateEventListener, ActionEventListener {
    
    private var width:Number = -1; // Set by init object.
    private var height:Number = -1; // Set by init object.
    private var gis:GIS = null; // Set by init object.
    private var layer:Layer = null; // Set by init object.
    
    private var checkBox:CheckBox = null;
    
    function onLoad():Void {
        layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
        drawBackGround();
        addCheckBox();
        addGraphic();
        addLabel();
        addButtonBar();
    }
    
    function setSize(width:Number, height:Number):Void {
        this.width = width;
        this.height = height;
        
        drawBackGround();
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.CHANGE + "_visible") {
            checkBox.selected = layer.isVisible();
        }
    }
    
    function onActionEvent(actionEvent:ActionEvent):Void {
        var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "Button_" + ActionEvent.CLICK) {
            var buttonName:String = actionEvent.getSource()._name;
            if (buttonName.indexOf("Point") > -1) {
                gis.setCreateGeometry(new CreateGeometry(layer, new PointFactory()));
            } else if (buttonName.indexOf("Curve") > -1) {
                gis.setCreateGeometry(new CreateGeometry(layer, new LineStringFactory()));
            } else if (buttonName.indexOf("Surface") > -1) {
                gis.setCreateGeometry(new CreateGeometry(layer, new PolygonFactory()));
            } else {
                gis.setCreateGeometry(new CreateGeometry(layer, new CircleFactory()));
            }
        }
    }
    
    private function drawBackGround():Void {
        var lightColor:Number = 0xF0F0F0;
        var middleColor:Number = 0xE0E0E0;
        var darkColor:Number = 0x404040;
        
        clear();
        moveTo(0, height - 1);
        lineStyle(1, lightColor, 100);
        beginFill(middleColor, 0);
        lineTo(0, 0);
        lineTo(width - 1, 0);
        lineStyle(1, darkColor, 0);
        lineTo(width - 1, height - 1);
        endFill();
    }
    
    private function addCheckBox():Void {
        var initObject:Object = new Object();
        initObject["_x"] = 5;
        initObject["_y"] = 7;
        initObject["selected"] = layer.isVisible();
        checkBox = CheckBox(attachMovie("CheckBox", "mcCheckBox", 0, initObject));
        checkBox.addEventListener("click", onClickCheckBox);
    }
    
    private function addGraphic():Void {
        var style:Object = layer.getStyle();
        var graphic:MovieClip = createEmptyMovieClip("mGraphic", 1);
        graphic._x = 22;
        graphic._y = 5;
        graphic.lineStyle(1, 0x000000, 0);
        graphic.moveTo(0, 0);
        graphic.beginFill(style.getFillColor(), style.getFillOpacity());
        graphic.lineTo(14, 0);
        graphic.lineTo(14, 14);
        graphic.lineTo(0, 14);
        graphic.endFill();
        graphic.moveTo(7, 7);
        graphic.lineStyle(style.getStrokeWidth() * 3, style.getStrokeColor(), style.getStrokeOpacity());
        graphic.lineTo(7.15, 7.45);
    }
    
    private function addLabel():Void {
        var initObject:Object = new Object();
        initObject = new Object();
        initObject["_x"] = 40;
        initObject["_y"] = 3;
        initObject["autoSize"] = "left";
        initObject["text"] = layer.getTitle();
        var label:Label = Label(attachMovie("Label", "mLabel", 2, initObject));
        var style:Object = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        label.setStyle("fontFamily", style["fontFamily"]);
        label.setStyle("fontSize", style["fontSize"]);
    }
    
    private function addButtonBar():Void {
        var geometryTypes:Array = layer.getGeometryTypes();
        if (geometryTypes.length == 0) {
            geometryTypes = new Array("Point", "LineString", "Polygon", "Circle");
        }
        var geometryType:String = null;
        var buttonConfigs:Array = new Array();
        for (var i:Number = 0; i < geometryTypes.length; i++) {
            geometryType = String(geometryTypes[i]);
            if (geometryType == "Point") {
                buttonConfigs.push(new ButtonConfig("AddPointButton", "punt toevoegen", this, null, null));
            } else if (geometryType == "LineString") {
                buttonConfigs.push(new ButtonConfig("AddCurveButton", "lijn toevoegen", this, null, null));
            } else if (geometryType == "Polygon") {
                buttonConfigs.push(new ButtonConfig("AddSurfaceButton", "vlak toevoegen", this, null, null));
            } else { // Circle
                buttonConfigs.push(new ButtonConfig("AddCircleButton", "cirkel toevoegen", this, null, null));
            }
        }
        var initObject:Object = new Object();
        initObject["_x"] = 22;
        initObject["_y"] = 5;
        initObject["buttonWidth"] = 15;
        initObject["buttonHeight"] = 15;
        initObject["spacing"] = 0;
        initObject["expandable"] = true;
        initObject["buttonConfigs"] = buttonConfigs;
        attachMovie("ButtonBar", "mButtonBar", 3, initObject);
    }
    
    function onClickCheckBox():Void {
        var env:EditLegendLayer = EditLegendLayer(_parent); // The context of this method is not the EditLegendLayer object, but the check box.
        env.layer.setVisible(env.checkBox.selected);
    }
    
}
