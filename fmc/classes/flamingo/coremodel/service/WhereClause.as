// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

class flamingo.coremodel.service.WhereClause {
    
    static var EQUALS:Number = 0;
    static var LIKE:Number = 1;
    
    private var propertyName:String = null;
    private var value:String = null;
    private var operator:Number = -1;
    private var caseSensitive:Boolean = false;
    
    function WhereClause(propertyName:String, value:String, operator:Number, caseSensitive:Boolean) {
        if (propertyName == null) {
            trace("Exception in flamingo.coremodel.WhereClause.<<init>>(" + propertyName + ", " + value + ")");
            return;
        }
        if (value == null) {
            trace("Exception in flamingo.coremodel.WhereClause.<<init>>(" + propertyName + ", " + value + ")");
            return;
        }
        
        this.propertyName = propertyName;
        this.value = value;
        this.operator = operator;
        this.caseSensitive = caseSensitive;
    }
    
    function getPropertyName():String {
        return propertyName;
    }
    
    function getValue():String {
        return value;
    }
    
    function getOperator():Number {
        return operator;
    }
    
    function isCaseSensitive():Boolean {
        return caseSensitive;
    }
    
    function toString():String {
        return "WhereClause(" + propertyName + "," + value + ")";
    }
    
}
