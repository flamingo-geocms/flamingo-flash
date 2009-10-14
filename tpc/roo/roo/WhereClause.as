
class roo.WhereClause {

	static var EQUALS:Number = 0;
    static var LIKE:Number = 1;
    
    private var columnName:String = null;
    private var value:String = null;
    private var operator:Number = -1;
    
    function WhereClause(columnName:String, value:String, operator:Number) {
        if (columnName == null) {
            return;
        }
        if (value == null) {
            return;
        }
        
        this.columnName = columnName;
        this.value = value;
        this.operator = operator;
    }
    
    function getColumnName():String {
        return columnName;
    }
    
    function getValue():String {
        return value;
    }
    
    function getOperator():Number {
        return operator;
    }
    
    function toString():String {
        return "WhereClause(" + columnName + "," + value + ")";
    }
    
}
