// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.gismodel.*;

class flamingo.gismodel.Style extends AbstractComposite {
    
    private var fillColor:Number = -1;
    private var fillOpacity:Number = -1;
    private var strokeColor:Number = -1;
    private var strokeOpacity:Number = -1;
    private var strokeWidth:Number = 3;
    
    function Style(xmlNode:XMLNode) {
        parseConfig(xmlNode);
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "fillcolor") {
            fillColor = Number(value);
        } else if (name == "fillopacity") {
            fillOpacity = Number(value);
        } else if (name == "strokecolor") {
            strokeColor = Number(value);
        } else if (name == "strokeopacity") {
            strokeOpacity = Number(value);
        }
    }
    
    function getFillColor():Number {
        return fillColor;
    }
    
    function getFillOpacity():Number {
        return fillOpacity;
    }
    
    function getStrokeColor():Number {
        return strokeColor;
    }
    
    function getStrokeOpacity():Number {
        return strokeOpacity;
    }
    
    function getStrokeWidth():Number {
        return strokeWidth;
    }
    
    function toString():String {
        return "Style(" + strokeColor + ", " + strokeOpacity + ")";
    }
    
}
