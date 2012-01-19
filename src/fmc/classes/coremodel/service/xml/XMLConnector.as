/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.xpath.XPathAPI;

import coremodel.service.ServiceConnector;
import event.ActionEvent;
import event.ActionEventListener;
import geometrymodel.Geometry;
import tools.XMLTools;
import coremodel.service.WhereClause;
import coremodel.service.ServiceLayer;
import coremodel.service.Transaction;
import coremodel.service.ServiceProperty;
import coremodel.service.xml.*;
import geometrymodel.*;

import mx.utils.Delegate;

// Optional replacement XPath API:
// import com.xfactorstudio.xml.xpath.XPath;

/**
 * Property type parsers
 * gml:boundedBy property is interpreted as feature envelope, when available.
 */
class coremodel.service.xml.XMLConnector extends ServiceConnector {
	
	private var _featureTypes: Object;
	private var _propertyTypeParsers: Object;
	
	public function XMLConnector(url : String) {
		super(url);
		
		_featureTypes = { };
		_propertyTypeParsers = { };
		
		_propertyTypeParsers = {
			boundingBox: Delegate.create (this, parseBoundingBox)
		};
	}
	
	/**
	 * Adds a new feature type to this connector. A feature type consists of a name and
	 * an array of properties. Each property in the array is an object that has the following
	 * attributes:
	 * - name (string): The name of the property.
	 * - type (string): The type of the property.
	 * - path (string): An xpath expression that is used to extract feature values from source documents.
	 */
	public function addFeatureType (name: String, properties: Array): ServiceLayer {
		
		//_global.flamingo.tracer ("XMLConnector::addFeatureType: " + name);
		
		var ft: XMLFeatureType;
		
		if ((ft = _featureTypes[name]) != undefined) {
			ft.setProperties (properties);
			return ft;
		}
		
		ft = new XMLFeatureType (this, name, properties);
		_featureTypes[name] = ft;
		
		return ft;
	}
	
	/**
	 * Performs a describe features request on this XML connection. The possible feature types are
	 * known before invoking this method, therefore an event is fired immediately containing the
	 * requested feature type, or an error in case the feature type does not exist.
	 */
    function performDescribeFeatureType(featureTypeName:String, actionEventListener:ActionEventListener):Void {
    	
    	var actionEvent: ActionEvent;
    	
    	//_global.flamingo.tracer ("XMLConnector::performDescribeFeatureType: " + featureTypeName);
    	
    	if (_featureTypes[featureTypeName]) {
    		var serviceLayer: ServiceLayer = _featureTypes[featureTypeName];
	        actionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
	        actionEvent["serviceLayer"] = serviceLayer;
	        actionEventListener.onActionEvent(actionEvent);
	        var id:String =  _global.flamingo.getId(this);
            if(id != null){
        		_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
            }
    	} else {
            actionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
            actionEvent["exceptionMessage"] = "Feature type `" + featureTypeName + "` does not exist.";
            actionEventListener.onActionEvent(actionEvent);
            var id:String =  _global.flamingo.getId(this);
    		if(id != null){
            	_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
    		}
       	}
    }
    
    function performGetFeature(serviceLayer:ServiceLayer, extent:Geometry, whereClauses:Array, notWhereClause:WhereClause, hitsOnly:Boolean, actionEventListener:ActionEventListener):Void {
    	
    	 //_global.flamingo.tracer ("XMLConnector::performGetFeature");
    	 
    	 // Request the XML document that contains the features, the process method extracts properties
    	 // using xpath expressions:
    	 request (url, null, processGetFeature, serviceLayer, actionEventListener, 0);
    }
    
    /**
     * Dummy implementation, transactions are not supported by the XML service connector.
     */
    function performTransaction(transaction:Transaction, actionEventListener:ActionEventListener):Void {
    	_global.flamingo.tracer ("Transactions are not supported on XML services.");
    }
    
    function processGetFeature(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void {
    	
    	//_global.flamingo.tracer ("XMLConnector::processGetFeature");
    	var features: Array = [ ],
    		values: Object = { },
    		i: Number,
    		j: String,
    		featureCount: Number = 0,
    		properties: Array = serviceLayer.getServiceProperties ().concat ();
    		
    	if (serviceLayer.getDefaultGeometryProperty ()) {
    		properties.push (serviceLayer.getDefaultGeometryProperty());
    	}
    		
    	// Find values for all properties:
    	//_global.flamingo.tracer ("Finding values for all properties: " + properties);
    	for (i = 0; i < properties.length; ++ i) {
    		if (!(properties[i] instanceof XMLProperty)) {
    			//_global.flamingo.tracer ("Property " + properties[i].getName () + " is not of type XMLProperty");
    			continue;
    		}
    		
    		var property: XMLProperty = XMLProperty (properties[i]),
    			// xmlNodes: Array = XPathAPI.selectNodeList (responseXML.firstChild, property.getXPathExpression ()),
    			xmlNodes: Array = selectNodes (responseXML.firstChild, property.getXPathExpression ()),
    			propertyValues: Array = processPropertyValues (property, xmlNodes);
    			
    		//_global.flamingo.tracer ("Values for property: " + property.getName () + " (" + property.getXPathExpression () + "): " + xmlNodes.length);
    			
    		values[property.getName ()] = propertyValues;
    		
    		featureCount = Math.max (featureCount, propertyValues.length);
		}
    		
		// Combine property values into a list of features:
		//_global.flamingo.tracer ("Constructing features");
		for (i = 0; i < featureCount; ++ i) {
			var feature: XMLFeature = new XMLFeature (serviceLayer);
			for (j in values) {
				feature.setValue (j, values[j][i]);
				
				// Set the feature envelope if a 'gml:boundedBy' property exists:
				if (j == 'gml:boundedBy' && values[j][i] instanceof Envelope) {
					feature.setEnvelope (values[j][i]);
				}
			}
			
			features.push (feature);
		}
    	
    	// Dispatch an event:
    	//_global.flamingo.tracer ("Raising event");
        var actionEvent:ActionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
        actionEvent["numFeatures"] = features.length;
        actionEvent["features"] = features;
        actionEventListener.onActionEvent(actionEvent);
	}

	private function processPropertyValues (property: XMLProperty, values: Array): Array {
		var i: Number,
			result: Array = [ ];
		
		for (i = 0; i < values.length; ++ i) {
			var node: XMLNode = values[i];
	
			if (_propertyTypeParsers[property.getType ()]) {
				result.push (_propertyTypeParsers[property.getType ()] (node));		
			} else if (property.getType () == "gml:GeometryPropertyType") {
				result.push (GeometryParser.parseGeometry(node));
			} else if (node.firstChild.nodeType == 3) { // Text node.
				result.push(node.firstChild.nodeValue);
			} else {
				result.push(null);
            }
            
            //_global.flamingo.tracer (" - " + property.getName () + " = " + result[result.length - 1]);
		}
		
		return result;
	}
	
	private function parseBoundingBox (node: XMLNode): Envelope {
		var minX: Number = Number (node.attributes['minx']),
			minY: Number = Number (node.attributes['miny']),
			maxX: Number = Number (node.attributes['maxx']),
			maxY: Number = Number (node.attributes['maxy']);
			
		return new Envelope (minX, minY, maxX, maxY);
	}
	
	private static function selectNodes (context: XMLNode, path: String): Array {
		return XPathAPI.selectNodeList (context, path);
		
		// Optional replacement XPath API:
		// return XPath.selectNodes (context, path);
	}
}