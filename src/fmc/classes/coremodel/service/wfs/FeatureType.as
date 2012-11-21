/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import coremodel.service.wfs.*;
import coremodel.service.*;
import mx.xpath.XPathAPI;
import tools.XMLSchema;
import tools.Logger;

/**
 * coremodel.service.wfs.FeatureType
 */
class coremodel.service.wfs.FeatureType extends ServiceLayer {
    
    private var namespacePrefix:String = null;
	private var ftNamespacePrefix:String = null;
    private var xmlSchema:XMLSchema = null;
	/**
	 * constructor
	 * @param	rootNode
	 * @param	contextObject
	 */
    function FeatureType(rootNode:XMLNode, contextObject:Object) {
		Logger.console("Featuretype!");		
		xmlSchema = new XMLSchema(rootNode);
		namespacePrefix = xmlSchema.getTargetNamespacePrefix(); 
		//_global.flamingo.tracer("FeatureType namespacePrefix==" + namespacePrefix);
		ftNamespacePrefix = xmlSchema.getSchemaNamespacePrefix();
		//_global.flamingo.tracer("FeatureType ftNamespacePrefix==" + ftNamespacePrefix);
		var xpathExpression= "/";
		if (ftNamespacePrefix!=undefined){
			xpathExpression+=ftNamespacePrefix+":";
		}
		xpathExpression+="schema/";
		if (ftNamespacePrefix!=undefined){
			xpathExpression+=ftNamespacePrefix + ":";
		}
		xpathExpression += "element";
		/*try to get the element
		 * 1) try with full featurename
		 * 2) try without prefix
		 * 3) try without name, but get the first
		 */		
        var firstElementNode:XMLNode = XPathAPI.selectSingleNode(rootNode, xpathExpression+"[@name=\""+contextObject.featureTypeName+"\"]");
		if (firstElementNode == null && contextObject.featureTypeName.indexOf(":") > 0) {
			var withoutPrefix = contextObject.featureTypeName.split(":")[1];
			firstElementNode = XPathAPI.selectSingleNode(rootNode, xpathExpression+"[@name=\""+withoutPrefix+"\"]");
		}
		if (firstElementNode == null) {
			firstElementNode = XPathAPI.selectSingleNode(rootNode, xpathExpression);
		}
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
		Logger.console("Name: "+name);
		var complexTypeNode:XMLNode
		//if complexType is in element.
		if (firstElementNode.firstChild.localName == "complexType") {
			complexTypeNode=firstElementNode.firstChild;
		}else {
			var type:String = firstElementNode.attributes["type"].split(":")[1];
			var xpathExpression2= "/";
			if (ftNamespacePrefix!=undefined){
				xpathExpression2+=ftNamespacePrefix + ":schema/" + ftNamespacePrefix + ":complexType[@name=\"" + type + "\"]";
			}
			else{
				xpathExpression2+="schema/complexType[@name=\"" + type + "\"]";
			}
			complexTypeNode = XPathAPI.selectSingleNode(rootNode, xpathExpression2);
		}
		
        
		var xpathExpression3= "/";
		if (ftNamespacePrefix!=undefined){
			xpathExpression3+=ftNamespacePrefix + ":complexType/" + ftNamespacePrefix + ":complexContent/" + ftNamespacePrefix + ":extension/" + ftNamespacePrefix + ":sequence/" + ftNamespacePrefix + ":element";
		}
		else{
			xpathExpression3+="complexType/complexContent/extension/sequence/element";
		}
		var propertyNodes:Array = XPathAPI.selectNodeList(complexTypeNode, xpathExpression3);
        
        var property:WFSProperty = null;
        serviceProperties = new Array();
        geometryProperties = new Array();		
		for (var i:Number = 0; i < propertyNodes.length; i++) {
        	//_global.flamingo.tracer("FeatureType property.getType()" + property.getType());
            property = new WFSProperty(XMLNode(propertyNodes[i]), namespacePrefix);
			serviceProperties.push(property);
            //TODO: include more possible types
            var preFix:String = XMLNode(propertyNodes[i]).getPrefixForNamespace("http://www.opengis.net/gml");
			if (property.getType() == preFix + ":GeometryPropertyType" 
            	|| property.getType() == preFix + ":MultiSurfacePropertyType"
            	||property.getType() == preFix + ":MultiGeometryPropertyType"
            	||property.getType() == preFix + ":MultiPolygonPropertyType"
            	||property.getType() == preFix + ":MultiLineStringPropertyType"
            	||property.getType() == preFix + ":MultiPointPropertyType"
				||property.getType() == preFix + ":MultiCurvePropertyType"
				||property.getType() == preFix + ":SurfacePropertyType"
            	||property.getType() == preFix + ":PolygonPropertyType"
            	||property.getType() == preFix + ":LineStringPropertyType"
            	||property.getType() == preFix + ":PointPropertyType"
				||property.getType() == preFix + ":CurvePropertyType") {
                geometryProperties.push(property);
            }
        }
        
        if (serviceProperties.length == 0) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype \"" + name + "\" has no properties.");
            return;
        }
        if (geometryProperties.length == 0 && contextObject.parseGeometry != false) {
            _global.flamingo.tracer("Exception in coremodel.FeatureType.<<init>>: The featuretype \"" + name + "\" has no geometry property.");
            return;
        }
    }
    /**
     * getNamespace
     * @return
     */
    function getNamespace():String {
        return "app=\"http://www.deegree.org/app\"";
    }
    /**
     * getServiceFeatureFactory
     * @return
     */
    function getServiceFeatureFactory():ServiceFeatureFactory {
        return new WFSFeatureFactory();
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "FeatureType(" + name + ")";
    }
    
}
