/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.wfs.*;
import coremodel.service.*;
import mx.xpath.XPathAPI;
import tools.XMLSchema;

class coremodel.service.wfs.FeatureType extends ServiceLayer {
    
    private var namespacePrefix:String = null;
	private var ftNamespacePrefix:String = null;
    private var xmlSchema:XMLSchema = null;
	
    function FeatureType(rootNode:XMLNode) {
		xmlSchema = new XMLSchema(rootNode);
		namespacePrefix = xmlSchema.getTargetNamespacePrefix(); 
		ftNamespacePrefix = xmlSchema.getSchemaNamespacePrefix();
        var firstElementNode:XMLNode = XPathAPI.selectSingleNode(rootNode, "/" + ftNamespacePrefix + ":schema/" + ftNamespacePrefix + ":element");
		if (firstElementNode == null) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype schema cannot be parsed.\n" + rootNode);
            return;
        }
        name = firstElementNode.attributes["name"];
        if (name == null) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype has no name.\n" + firstElementNode);
            return;
        }
        name = namespacePrefix + ":" + name;
        
        var type:String = firstElementNode.attributes["type"].split(":")[1];
        var complexTypeNode:XMLNode = XPathAPI.selectSingleNode(rootNode, "/" + ftNamespacePrefix + ":schema/" + ftNamespacePrefix + ":complexType[@name=" + type + "]");
        var propertyNodes:Array = XPathAPI.selectNodeList(complexTypeNode, "/" + ftNamespacePrefix + ":complexType/" + ftNamespacePrefix + ":complexContent/" + ftNamespacePrefix + ":extension/" + ftNamespacePrefix + ":sequence/" + ftNamespacePrefix + ":element");
        var property:WFSProperty = null;
        serviceProperties = new Array();
        geometryProperties = new Array();
        for (var i:Number = 0; i < propertyNodes.length; i++) {
            property = new WFSProperty(XMLNode(propertyNodes[i]), namespacePrefix);
            serviceProperties.push(property);
            if (property.getType() == "gml:GeometryPropertyType") {
                geometryProperties.push(property);
            }
        }
        
        if (serviceProperties.length == 0) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype \"" + name + "\" has no properties.");
            return;
        }
        if (geometryProperties.length == 0) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype \"" + name + "\" has no geometry property.");
            return;
        }
    }
    
    function getNamespace():String {
        return "app=\"http://www.deegree.org/app\"";
    }
    
    function getServiceFeatureFactory():ServiceFeatureFactory {
        return new WFSFeatureFactory();
    }
    
    function toString():String {
        return "FeatureType(" + name + ")";
    }
    
}
