/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import gismodel.*;
import core.AbstractComposite;
/**
 * gismodel.GeometryProperty
 */
class gismodel.GeometryProperty extends Property {
    
    private var availableColors:Array = null;
	private var availableIcons:Array = null;
	private var availablePatterns:Array = null;
	private var availableDashStyles:Array = null;
	private var inGeometryTypes:Array = null;
	private var minvalue:Number = null;
	private var maxvalue:Number = null;
	private var nrTilesHor:Number = null;
	private var nrTilesVer:Number = null;
	private var curColorName:String = null;
	private var propertyType:String = null;
	/**
	 * constructor
	 * @param	xmlNode
	 */
    function GeometryProperty(xmlNode:XMLNode) {
		super(xmlNode);
    }
	/**
	 * onload
	 */
	function onload():Void{
		inGeometryTypes = new Array();
	}
    /**
     * setAttribute
     * @param	name
     * @param	value
     */
    function setAttribute(name:String, value:String):Void {
        super.setAttribute(name,value);
		if (name == "ingeometrytypes") {
            inGeometryTypes = value.split(",");
        } else if (name == "minvalue") {
            minvalue = Number(value);
        } else if (name == "maxvalue") {
            maxvalue = Number(value);
        } else if (name == "nrtileshor") {
            nrTilesHor = Number(value);
        } else if (name == "nrtilesver") {
            nrTilesVer = Number(value);
        } else if (name == "propertytype") {
            propertyType = String(value);
        }
    }
	/**
	 * addComposite
	 * @param	name
	 * @param	xmlNode
	 */
	function addComposite(name:String, xmlNode:XMLNode):Void {
		if (name == "availableColor") {
			if (availableColors == null){
				availableColors = new Array();
			}
            availableColors.push(new AvailableColor(xmlNode));
        } else if (name == "availableIcon") {
			if (availableIcons == null){
				availableIcons = new Array();
			}
            availableIcons.push(new AvailableIcon(xmlNode));
		} else if (name == "availablePattern") {
			if (availablePatterns == null){
				availablePatterns = new Array();
			}
            availablePatterns.push(new AvailablePattern(xmlNode));
        } else if (name == "availableDashStyle") {
			if (availableDashStyles == null){
				availableDashStyles = new Array();
			}
			availableDashStyles.push(new AvailableDashStyle(xmlNode));
        }
    }
	/**
	 * getMinvalue
	 * @return
	 */
	function getMinvalue():Number {
        return minvalue;
    }
	/**
	 * getMaxvalue
	 * @return
	 */
	function getMaxvalue():Number {
        return maxvalue;
    }
	/**
	 * getNrTilesHor
	 * @return
	 */
	function getNrTilesHor():Number {
        return nrTilesHor;
    }
	/**
	 * getNrTilesVer
	 * @return
	 */
	function getNrTilesVer():Number {
        return nrTilesVer;
    }
	/**
	 * getInGeometryTypes
	 * @return
	 */
	function getInGeometryTypes():Array {
        return inGeometryTypes.concat();
    }
	/**
	 * getPropertyType
	 * @return
	 */
	function getPropertyType():String {
		return propertyType;
	}
	/**
	 * getFlashValue
	 * @param	val
	 * @return
	 */
	function getFlashValue(val:String):String{
		if (type == "ColorPalettePicker") {
			for (var i:Number = 0; i<availableColors.length; i++) { 
				if (availableColors[i].getValue() == val) {
					return availableColors[i].getPickColor();
				}
			}
			//trace("GeometryProperty.as getFlashValue() No matching availableColors");
			return null;
		} else if (type == "IconPicker") {
			if (val == "" || val == "null") {
				return "";
			}
			for (var i:Number = 0; i<availableIcons.length; i++) { 
				if (availableIcons[i].getValue() == val) {
					return availableIcons[i].getPickIconUrl();
				}
			}
			//trace("GeometryProperty.as getFlashValue() No matching availableIcons");
			return "";
		} else if (type == "PatternPicker") {
			if (val == "" || val == "null") {
				return "";
			}
			for (var i:Number = 0; i<availablePatterns.length; i++) { 
				if (availablePatterns[i].getValue() == val) {
					return availablePatterns[i].getPickPatternUrl();
				}
			}
			return "";			
		} else if (type == "DashStylePicker") {
			for (var i:Number = 0; i<availableDashStyles.length; i++) { 
				if (availableDashStyles[i].getValue() == val) {
					return availableDashStyles[i].getPickDashStyle();
				}
			}
			return "";			
		}
		
		return val;
	}
   /**
	* getAvailableColors
	* @return
	*/       
	function getAvailableColors():Array {
        return availableColors.concat();
    }
	/**
	 * getAvailableIcons
	 * @return
	 */
	function getAvailableIcons():Array {
        return availableIcons.concat();
    }
	/**
	 * getAvailablePatterns
	 * @return
	 */
	function getAvailablePatterns():Array {
        return availablePatterns.concat();
    }
	/**
	 * getAvailableDashStyles
	 * @return
	 */
	function getAvailableDashStyles():Array {
        return availableDashStyles.concat();
    }
	/**
	 * setCurColorName
	 * @param	curColorName
	 */
	function setCurColorName(curColorName:String):Void {
		this.curColorName = curColorName;
	}
	/**
	 * getCurColorName
	 * @return
	 */
	function getCurColorName():String {
        return curColorName;
    }
	/**
	 * getCurColor
	 * @return
	 */
	function getCurColor():AvailableColor{
		for (var i:Number = 0; i < availableColors.length; i++) { 
			if (availableColors[i].getName() == curColorName) {
				return availableColors[i];
			}
		}
	}
	/**
	 * isImmutable
	 * @return
	 */	
    function isImmutable():Boolean {
        return immutable;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "GeometryProperty(" + name + ", " + title + ", " + type + ")";
    }
    
}
