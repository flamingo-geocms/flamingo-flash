/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;

import coremodel.search.ServiceDescription;
import coremodel.search.FeatureType;

class coremodel.search.Relation extends AbstractComposite {
	private var _serviceDescription: ServiceDescription;
	
	private var _id: String;
	private var _sourceFeatureType: String;
	private var _destFeatureType: String;
	private var _sourceField: String;
	private var _destField: String;
	
	public function get serviceDescription (): ServiceDescription {
		return _serviceDescription;
	}
	
	public function get id (): String {
		return _id;
	}
	
	public function get sourceFeatureType (): FeatureType {
		return serviceDescription.getFeatureTypeById (_sourceFeatureType);
	}
	
	public function get destFeatureType (): FeatureType {
		return serviceDescription.getFeatureTypeById (_destFeatureType);
	}
	
	public function get sourceField (): String {
		return _sourceField;
	}
	
	public function get destField (): String {
		return _destField;
	}
	
	public function Relation (serviceDescription: ServiceDescription, xmlNode: XMLNode) {
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
    	case 'source':
    		_sourceFeatureType = value;
    		break;
    	case 'dest':
    		_destFeatureType = value;
    		break;
    	case 'sourcefield':
    		_sourceField = value;
    		break;
    	case 'destfield':
    		_destField = value;
    		break;
    	default:
    		throw new Error ("Unknown feature type attribute: " + name);
    	}
    }
}
