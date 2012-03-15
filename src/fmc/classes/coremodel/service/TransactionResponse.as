/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

import tools.XMLTools;

/**
 * coremodel.service.TransactionResponse
 */
class coremodel.service.TransactionResponse {
    
    private var ids:Object = null; // Associative array.
    /**
     * constructor
     * @param	xmlNode
     */
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
    /**
     * getPreviousIDs
     * @return Array
     */
    function getPreviousIDs():Array {
        var previousIDs:Array = new Array();
        
        for (var previousID:String in ids) {
            previousIDs.push(previousID);
        }
        
        return previousIDs;
    }
    /**
     * getID
     * @param	previousID
     * @return
     */
    function getID(previousID:String):String {
        if (ids[previousID] == null) {
            _global.flamingo.tracer("Exception in TransactionResponse.getID(" + previousID + ")");
            return null;
        }
        
        return ids[previousID];
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "TransactionResponse()"
    }
    
}
