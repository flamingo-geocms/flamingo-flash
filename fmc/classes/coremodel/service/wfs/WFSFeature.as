/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.Envelope;

import coremodel.service.wfs.*;

import mx.xpath.XPathAPI;

import coremodel.service.*;
import geometrymodel.GeometryParser;

class coremodel.service.wfs.WFSFeature extends ServiceFeature {
    
    function WFSFeature(xmlNode:XMLNode, id:String, values:Array, serviceLayer:ServiceLayer) {
        if ((xmlNode == null) && (id == null) && (values == null)) {
            _global.flamingo.tracer("Exception in WFSFeature.<<init>>()");
            return;
        }
        if ((xmlNode != null) && ((id != null) || (values != null))) {
            _global.flamingo.tracer("Exception in WFSFeature.<<init>>()");
            return;
        }
        if (serviceLayer == null) {
            _global.flamingo.tracer("Exception in WFSFeature.<<init>>()");
            return;
        }
        
        this.serviceLayer = serviceLayer;
        
        if (xmlNode != null) {
            this.id = xmlNode.attributes["gml:id"];
			if (this.id==undefined || this.id==null){				
				this.id = xmlNode.attributes["fid"];
			}
            this.values = new Array();
            
            var properties:Array = serviceLayer.getServiceProperties();
            var property:WFSProperty = null;
            var propertyNode:XMLNode = null;
            for (var i:Number = 0; i < properties.length; i++) {
                property = WFSProperty(properties[i]);
                propertyNode = XPathAPI.selectSingleNode(xmlNode, "/" + serviceLayer.getName() + "/" + property.getName());
                if(propertyNode != null){
                	propertyNode = propertyNode.firstChild;
                	if (property.getType() == "gml:GeometryPropertyType") {
                    	this.values.push(GeometryParser.parseGeometry(propertyNode));
                	} else {
                    	if (propertyNode.nodeType == 3) { // Text node.
                        	this.values.push(propertyNode.nodeValue);
                    	} else {
                        	this.values.push(null);
                    	}
                	}
                } else {
                	this.values.push(null);
                }
            }
            var envNode:XMLNode = XPathAPI.selectSingleNode(xmlNode, "/" + serviceLayer.getName() + "/gml:boundedBy");
        	if(envNode!=null){
        		this.envelope = Envelope(GeometryParser.parseGeometry(envNode.firstChild));
        	}
        } else {
            this.id = id;
            this.values = values;
        }
    }
    
    function toString():String {
        return "WFSFeature(" + id + ")";
    }
    
}
