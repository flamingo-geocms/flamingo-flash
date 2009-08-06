/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import gismodel.*;
import core.AbstractComposite;

class gismodel.GeometryProperty extends Property {
    
    private var availableColors:Array = null;
	private var availableIcons:Array = null;
	private var availablePatterns:Array = null;
	private var inGeometryTypes:Array = null;
	private var minvalue:Number = null;
	private var maxvalue:Number = null;
	private var nrTilesHor:Number = null;
	private var nrTilesVer:Number = null;
	private var curColorName:String = null;
	private var propertyType:String = null;
	
    function GeometryProperty(xmlNode:XMLNode) {
		super(xmlNode);
    }
	function onload():Void{
		inGeometryTypes = new Array();
	}
    
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
	
	function getMinvalue():Number {
        return minvalue;
    }
	function getMaxvalue():Number {
        return maxvalue;
    }
	function getNrTilesHor():Number {
        return nrTilesHor;
    }
	function getNrTilesVer():Number {
        return nrTilesVer;
    }
	
	function getInGeometryTypes():Array {
        return inGeometryTypes.concat();
    }
	
	function getPropertyType():String {
		return propertyType;
	}
	
	
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
        }
    }
          
	function getAvailableColors():Array {
        return availableColors.concat();
    }
	
	function getAvailableIcons():Array {
        return availableIcons.concat();
    }
	
	function getAvailablePatterns():Array {
        return availablePatterns.concat();
    }
	
	function setCurColorName(curColorName:String):Void {
		this.curColorName = curColorName;
	}
	
	function getCurColorName():String {
        return curColorName;
    }
	
	function getCurColor():AvailableColor{
		for (var i:Number = 0; i < availableColors.length; i++) { 
			if (availableColors[i].getName() == curColorName) {
				return availableColors[i];
			}
		}
	}
		
    function isImmutable():Boolean {
        return immutable;
    }
    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ")";
    }
    
}
