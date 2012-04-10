/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
import gismodel.*;
import core.AbstractComposite;
/**
 * gismodel.Style
 */
class gismodel.Style extends AbstractComposite {
    
    private var fillColor:Number = -1;
    private var fillOpacity:Number = -1;
    private var strokeColor:Number = -1;
    private var strokeOpacity:Number = -1;
    private var strokeWidth:Number = 2;
    /**
     * constructor
     * @param	xmlNode
     */
    function Style(xmlNode:XMLNode) {
        parseConfig(xmlNode);
    }
    /**
     * setAttribute
     * @param	name
     * @param	value
     */
    function setAttribute(name:String, value:String):Void {
        if (name == "fillcolor") {
            fillColor = Number(value);
        } else if (name == "fillopacity") {
            fillOpacity = Number(value);
        } else if (name == "strokecolor") {
            strokeColor = Number(value);
        } else if (name == "strokeopacity") {
            strokeOpacity = Number(value);
        } else if (name == "strokewidth") {
            strokeWidth = Number(value);
        }
    }
    /**
     * getFillColor
     * @return
     */
    function getFillColor():Number {
        return fillColor;
    }
    /**
     * getFillOpacity
     * @return
     */
    function getFillOpacity():Number {
        return fillOpacity;
    }
    /**
     * getStrokeColor
     * @return
     */
    function getStrokeColor():Number {
        return strokeColor;
    }
    /**
     * getStrokeOpacity
     * @return
     */
    function getStrokeOpacity():Number {
        return strokeOpacity;
    }
    /**
     * getStrokeWidth
     * @return
     */
    function getStrokeWidth():Number {
        return strokeWidth;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Style(" + strokeColor + ", " + strokeOpacity + ")";
    }
    
}
