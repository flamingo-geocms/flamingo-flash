/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;

import coremodel.search.ServiceDescription;
import coremodel.search.Request;

import coremodel.service.ServiceLayer;


class coremodel.search.FeatureType extends AbstractComposite {
	
	private var _serviceDescription: ServiceDescription;
	
	private var _id: String;
	private var _type: String;
	private var _server: String;
	private var _serverVersion: String;
	private var _layerId: String;
	private var _properties: Array;
		
	public function get serviceDescription (): ServiceDescription {
		return _serviceDescription;
	}
	
	public function get id (): String {
		return _id;
	}
	
	public function get type (): String {
		return _type;
	}
	
	public function get hasServer (): Boolean {
		return !!_server;
	}
	
	public function get server (): String {
		return _server;
	}
	
	public function get serverVersion (): String {
		return _serverVersion;
	}
	
	public function get layerId (): String {
		return _layerId;
	}
	
	public function get hasProperties (): Boolean {
		return !!_properties;
	}
	
	public function get properties (): Array {
		return _properties ? _properties : [ ];
	}
	
	public function FeatureType(serviceDescription: ServiceDescription, xmlNode: XMLNode) {
		_serviceDescription = serviceDescription;
		
		if (xmlNode) {
			parseConfig (xmlNode);
		}
	}
	
    function setAttribute (name:String, value:String): Void {
    	switch (name.toLowerCase ()) {
    	case 'id':
    		_id = value;
    		break;
    	case 'type':
    		_type = value;
    		break;
    	case 'server':
    		_server = value;
    		break;
    	case 'serverversion':
    		_serverVersion = value;
    		break;
    	case 'layerid':
    		_layerId = value;
    		break;
    	default:
    		throw new Error ("Unknown feature type attribute: " + name);
    	}
    }
    
    function addComposite (name:String, xmlNode:XMLNode): Void {
    	var id: String;
    	
    	switch (name.toLowerCase ()) {
    	case 'property':
    		if (!_properties) {
    			_properties = [ ];
    		}
    		_properties.push (xmlNode.attributes);
    		break;
    	default:
    		throw new Error ('Invalid composite: ' + name);
       	}
    }
}
