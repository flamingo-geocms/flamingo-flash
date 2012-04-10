/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Maurits Kelder.
* B3partners bv
 -----------------------------------------------------------------------------*/


import gismodel.*;
/**
 * gismodel.AvailableDashStyle
 */
class gismodel.AvailableDashStyle extends PropertyItem {
    
    private var pickDashStyle:String = null;
    /**
     * constructor
     * @param	xmlNode
     */
	function AvailableDashStyle(xmlNode:XMLNode) {
        super(xmlNode);
    }
	/**
	 * setAttribute
	 * @param	name
	 * @param	value
	 */		
    function setAttribute(name:String, value:String):Void {
		super.setAttribute(name,value);
       if (name == "pickdashstyle") {
			if (dashStyleValid(String(value))) {
				pickDashStyle = String(value);
			} else {
				_global.flamingo.tracer("Exception in gismodel.AvailableDashStyle.setAttribute() \nInvalid value for AvailableDashStyle in xml config. \nAttributes name = "+name+", type = "+type);
				pickDashStyle = "1.0";
			}
        }
    }
	/**
	 * getPickDashStyle
	 * @return
	 */
	function getPickDashStyle():String {
        return pickDashStyle;
    }
	/**
	 * toString
	 * @return
	 */    
    function toString():String {
        return "Property(" + name + ", " + title + ", " + type + ", " + value + ", " + defaultValue + ", " + pickDashStyle + ")";
    }
    
	private function dashStyleValid(dashstyle:String):Boolean {
		if (dashstyle != null) {
			var dashStyleArray:Array = dashstyle.split(" ");
			//check the sum of the floats > 1.0
			var sum:Number = 0.0;
			for (var i:Number = 0; i<dashStyleArray.length; i++) {
				sum += Number(dashStyleArray[i]);
			}	
			if (sum < 1.0) {
				return false;
			}
		}
		return true;
	}
}
