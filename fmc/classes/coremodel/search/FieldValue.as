/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;

import coremodel.search.ServiceDescription;
import coremodel.search.SearchField;
import coremodel.search.FeatureType;

class coremodel.search.FieldValue extends AbstractComposite {
	
	private var _searchField: SearchField;
	
	private var _label: String = '';
	private var _value: String = '';
	
	public function get searchField (): SearchField {
		return _searchField;
	}
	
	public function get label (): String {
		return _label;
	}
	
	public function get value (): String {
		return _value;
	}
	
	public function FieldValue(searchField: SearchField, xmlNode: XMLNode) {
		_searchField = searchField;
		
		if (xmlNode) {
			parseConfig (xmlNode);
		}
	}
    function setAttribute (name:String, value:String): Void {
    	switch (name.toLowerCase ()) {
    	case 'label':
    		_label = value;
    		break;
    	case 'value':
    		_value = value;
    		break;
    	default:
    		throw new Error ('Invalid FieldValue attribute: ' + name);
    	}
    }
}
