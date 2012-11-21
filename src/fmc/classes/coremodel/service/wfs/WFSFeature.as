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
import geometrymodel.GeometryTools;
import tools.Logger;

/**
 * coremodel.service.wfs.WFSFeature
 */
class coremodel.service.wfs.WFSFeature extends ServiceFeature {
    /**
     * constructor
     * @param	xmlNode
     * @param	id
     * @param	values
     * @param	serviceLayer
     * @param	contextObject
     */
    function WFSFeature(xmlNode:XMLNode, id:String, values:Array, serviceLayer:ServiceLayer, contextObject:Object) {
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
        	var preFix:String = xmlNode.getPrefixForNamespace("http://www.opengis.net/gml");
            this.id = xmlNode.attributes[preFix + ":id"];
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
                	//TODO: include more geometry types
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
							
                		if(!contextObject.parseGeometry){
                			//keep xmlNode as value
                			this.values.push(propertyNode);
                		} else {		 
                    		this.values.push(GeometryParser.parseGeometry(propertyNode));
                		}
                    	 
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
            if(contextObject.parseEnvelope){
	            var envNode:XMLNode = XPathAPI.selectSingleNode(xmlNode, "/" + serviceLayer.getName() + "/" + preFix + ":boundedBy");
	        	if (envNode != null) {				
	        		this.envelope = Envelope(GeometryParser.parseGeometry(envNode.firstChild));
	        	} else {
	        		if(!contextObject.parsegeometry){
	        			this.envelope = GeometryTools.getEnvelopeFromGeometryNode(XMLNode(this.getValue(serviceLayer.getDefaultGeometryProperty().getName())));
	        		}
	        	}
            }
        		
        } else {
            this.id = id;
            this.values = values;
        }
    }
    /**
     * toString
     * @return
     */
    function toString():String {
        return "WFSFeature(" + id + ")";
    }
    
}
