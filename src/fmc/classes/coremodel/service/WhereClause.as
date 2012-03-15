/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

/**
 * coremodel.service.WhereClause
 */
class coremodel.service.WhereClause {
    
    static var EQUALS:Number = 0;
    static var LIKE:Number = 1;
    
    private var propertyName:String = null;
    private var value:String = null;
    private var operator:Number = -1;
    private var caseSensitive:Boolean = false;
    /**
     * WhereClause
     * @param	propertyName
     * @param	value
     * @param	operator
     * @param	caseSensitive
     */
    function WhereClause(propertyName:String, value:String, operator:Number, caseSensitive:Boolean) {
        if (propertyName == null) {
            trace("Exception in coremodel.WhereClause.<<init>>(" + propertyName + ", " + value + ")");
            return;
        }
        if (value == null) {
            trace("Exception in coremodel.WhereClause.<<init>>(" + propertyName + ", " + value + ")");
            return;
        }
        
        this.propertyName = propertyName;
        this.value = value;
        this.operator = operator;
        this.caseSensitive = caseSensitive;
    }
    /**
     * getPropertyName
     * @return
     */
    function getPropertyName():String {
        return propertyName;
    }
    /**
     * getValue
     * @return
     */
    function getValue():String {
        return value;
    }
    /**
     * getOperator
     * @return
     */
    function getOperator():Number {
        return operator;
    }
    /**
     * isCaseSensitive
     * @return
     */
    function isCaseSensitive():Boolean {
        return caseSensitive;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "WhereClause(" + propertyName + "," + value + ")";
    }
    
}
