// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

import flamingo.coremodel.service.*;

import flamingo.tools.XMLTools;

class flamingo.coremodel.service.TransactionResponse {
    
    private var ids:Object = null; // Associative array.
    
    function TransactionResponse(xmlNode:XMLNode) {
        ids = new Object();
        
        var insertResultsNode:XMLNode = XMLTools.getChild("wfs:InsertResults", xmlNode);
        if (insertResultsNode != null) {
            var featureNodes:Array = XMLTools.getChildNodes("wfs:Feature", insertResultsNode);
            var featureNode:XMLNode = null;
            var featureIDNode:XMLNode = null;
            for (var i:Number = 0; i < featureNodes.length; i++) {
                featureNode = XMLNode(featureNodes[i]);
                featureIDNode = XMLTools.getChild("ogc:FeatureId", featureNode);
                
                ids[featureNode.attributes["handle"]] = featureIDNode.attributes["fid"];
            }
        }
    }
    
    function getPreviousIDs():Array {
        var previousIDs:Array = new Array();
        
        for (var previousID:String in ids) {
            previousIDs.push(previousID);
        }
        
        return previousIDs;
    }
    
    function getID(previousID:String):String {
        if (ids[previousID] == null) {
            _global.flamingo.tracer("Exception in TransactionResponse.getID(" + previousID + ")");
            return null;
        }
        
        return ids[previousID];
    }
    
    function toString():String {
        return "TransactionResponse()"
    }
    
}
