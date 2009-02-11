// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

class flamingo.coremodel.service.Transaction {
    
    private var operations:Array = null;
    
    function Transaction() {
        operations = new Array();
    }
    
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
    
    function removeOperation(operation:Operation):Void {
        for (var i:Number = 0; i < operations.length; i++) {
            if (operations[i] == operation) {
                operations.splice(i, 1);
                return;
            }
        }
    }
    
    function getOperations():Array {
        return operations.concat();
    }
    
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
    
    function toString():String {
        return "Transaction(" + operations.length + ")";
    }
    
}
