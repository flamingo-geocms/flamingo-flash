﻿/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/**
 * tools.XMLSchema
 */
class tools.XMLSchema {
    
    private var targetNamespace:String = null;
    private var targetNamespacePrefix:String = null;
    private var schemaNamespacePrefix:String = null;
    /**
     * constructor
     * @param	rootNode
     */
    function XMLSchema(rootNode:XMLNode) {
        targetNamespace = rootNode.attributes["targetNamespace"];
        var attr:String = null;
        for (var i:String in rootNode.attributes) {
            attr = rootNode.attributes[i];
            if (i.split(":")[0] == "xmlns" && attr == targetNamespace) {
                targetNamespacePrefix = i.split(":")[1];                
            }
            
            if(attr == "http://www.w3.org/2001/XMLSchema") {
            	schemaNamespacePrefix = i.split(":")[1];
            }
        }
    }
    /**
     * getTargetNamespacePrefix
     * @return
     */
    function getTargetNamespacePrefix():String {
        return targetNamespacePrefix;
    }
    /**
     * getSchemaNamespacePrefix
     * @return
     */
    function getSchemaNamespacePrefix():String {
    	return schemaNamespacePrefix;
    }
}