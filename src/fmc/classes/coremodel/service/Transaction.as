/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

/**
 * coremodel.service.Transaction
 */
class coremodel.service.Transaction {
    
    private var operations:Array = null;
    /**
     * constructor
     */
    function Transaction() {
        operations = new Array();
    }
    /**
     * addOperation
     * @param	operation
     */
    function addOperation(operation:Operation):Void {
        var existingOperation:Operation = getOperation(operation.getFeatureID());
        
        if (existingOperation instanceof Delete) {
            return;
        }
        if ((existingOperation != null) && (operation instanceof Insert)) {
            return;
        }
        
        if ((existingOperation instanceof Update) || ((existingOperation instanceof Insert) && (operation instanceof Delete))) {
            removeOperation(existingOperation);
        }
        if ((existingOperation == null) || (existingOperation instanceof Update)) {
            operations.push(operation);
        }
    }
    /**
     * removeOperation
     * @param	operation
     */
    function removeOperation(operation:Operation):Void {
        for (var i:Number = 0; i < operations.length; i++) {
            if (operations[i] == operation) {
                operations.splice(i, 1);
                return;
            }
        }
    }
    /**
     * getOperations
     * @return Array
     */
    function getOperations():Array {
        return operations.concat();
    }
    /**
     * getOperation
     * @param	featureID
     * @return Operation
     */
    function getOperation(featureID:String):Operation {
        var operation:Operation = null;
        for (var i:String in operations) {
            operation = Operation(operations[i]);
            if (operation.getFeatureID() == featureID) {
                return operation;
            }
        }
        return null;
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "Transaction(" + operations.length + ")";
    }
    
}
