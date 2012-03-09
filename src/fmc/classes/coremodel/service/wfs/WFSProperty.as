/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coremodel.service.wfs.*;

import coremodel.service.ServiceProperty;

class coremodel.service.wfs.WFSProperty extends ServiceProperty {
    
    function WFSProperty(rootNode:XMLNode, namespacePrefix:String) {
        name = namespacePrefix + ":" + rootNode.attributes["name"];
        if (name == null) {
            _global.flamingo.tracer("Exception in coremodel.WFSProperty.<<init>>: The property has no name.\n" + rootNode);
        }
    	type = rootNode.attributes["type"];
    	//TODO: parsing of simpletype in childnode like:
    	/**   <xs:element minOccurs="0" name="GEMNAAM">
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xs:maxLength value="40"/>
                        </xs:restriction>
                    </xs:simpleType>
                </xs:element>
    	**/
    	//if no type than make type = string
        if (type == null) {
        	type="string"
			//_global.flamingo.tracer("Exception in coremodel.WFSProperty.<<init>>: The property has no type.\n" + rootNode);
        }
        
        if ((rootNode.attributes["minOccurs"] != null) && (rootNode.attributes["minOccurs"] == 0)) {
            optional = true;
        }
    }
    
    function toString():String {
        return "WFSProperty(" + name + ", " + type + ")";
    }
    
}
