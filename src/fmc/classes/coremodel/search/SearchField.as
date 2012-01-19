/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;

import coremodel.search.ServiceDescription;
import coremodel.search.FeatureType;
import coremodel.search.FieldValue;
import coremodel.search.FieldValueStore;
import coremodel.search.XmlFieldValueStore;

class coremodel.search.SearchField extends AbstractComposite {
	
	private var _serviceDescription: ServiceDescription;
	
	private var _id: String;
	private var _label: String = 'Search field';
	private var _matchCase: Boolean = false;
	private var _enumerate: Boolean = false;
	private var _staticFieldValues: Array = null;
	private var _featureType: String;
	private var _searchField: String;
	private var _autoNavigateField: String;
	private var _pattern: String;
	private var _minInput: Number = 3;
	private var _maxInput: Number = 0;
	private var _displayFields: Array;
	private var _autocomplete: Boolean = false;
	private var _autonavigate: Boolean = false;
	private var _displayFieldSeparator: String;
	private var _valueStore: FieldValueStore;
	private var _defaultValue: String;
	private var _operator: String = null;
	
	public function get serviceDescription (): ServiceDescription {
		return _serviceDescription;
	}
	
	public function get id (): String {
		return _id;
	}
	
	public function get label (): String {
		return _label;
	}
	
	public function get enumerate (): Boolean {
		return _enumerate;
	}
	
	public function get matchCase (): Boolean {
		return _matchCase;
	}
	
	public function get hasFieldValues (): Boolean {
		return _staticFieldValues && _staticFieldValues.length > 0;
	}
	
	public function get fieldValues (): Array {
		return _staticFieldValues;
	}
	
	public function get valueStore (): FieldValueStore {
		return _valueStore;
	}
	
	public function get featureType (): FeatureType {
		return serviceDescription.getFeatureTypeById (_featureType);
	}
	
	public function get searchFieldName (): String {
		return _searchField;
	}
	
	public function get autoNavigateFieldName (): String {
		return _autoNavigateField;
	}
	
	public function get displayFieldNames (): Array {
		return _displayFields ? _displayFields : [ searchFieldName ];
	}
	
	public function get displayFieldSeparator (): String {
		return _displayFieldSeparator ? _displayFieldSeparator : ' ';
	}

	public function get hasPattern (): Boolean {
		return !!_pattern;
	}
	
	public function get pattern (): String {
		return _pattern; 
	}
	
	public function get minInput (): Number {
		return int (_minInput);
	}
	
	public function get maxInput (): Number {
		return int (_maxInput);
	}
	
	public function get autocomplete (): Boolean {
		return _autocomplete;
	}
	
	public function get autonavigate(): Boolean {
		return _autonavigate;
	}

	public function get defaultValue (): String {
		return _defaultValue;
	}
	
	public function get operator (): String {
		return _operator;
	}
	
	public function SearchField(serviceDescription: ServiceDescription, xmlNode: XMLNode) {
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
    	case 'label':
    		_label = value;
    		break;
    	case 'matchcase':
    		_matchCase = value.toLowerCase () == 'true';
    		break;
    	case 'enumerate':
    		_enumerate = value.toLowerCase () == 'true';
    		break;
    	case 'featuretype':
    		_featureType = value;
    		break;
    	case 'searchfield':
    		_searchField = value;
    		break;
    	case 'autonavigatefield':
    		_autoNavigateField = value;
    		break;	
    	case 'pattern':
    		_pattern = value;
    		break;
    	case 'mininput':
			_minInput = Math.max (1, Number (value));
			break;
		case 'maxinput':
			_maxInput = Math.max (0, Number (value));
			break;
		case 'displayfield':
			_displayFields = [ value ];
			break;
		case 'displayfields':
			_displayFields = _global.flamingo.asArray (value);
			break;
		case 'displayfieldseparator':
			_displayFieldSeparator = String (value);
			break;
		case 'autocomplete':
			_autocomplete = value.toLowerCase() == 'true';
			break;
		case 'autonavigate':
    		_autonavigate = value.toLowerCase () == 'true';
    		break;	
		case "default":
		case "defaultValue":
			_defaultValue = value;
			break;
		case "operator":
			_operator = value;
			break;
		default:
    		throw new Error ("Unknown search field attribute: " + name);
    	}
    }
    	
    function addComposite (name:String, xmlNode:XMLNode): Void {
    	switch (name.toLowerCase ()) {
    	case 'fieldvalue':
    		if (!_staticFieldValues) {
    			_staticFieldValues = [ ];
    		}
    		_staticFieldValues.push (new FieldValue (this, xmlNode));
    		break;
    	case 'xmlvaluestore':
    		// The presence of a value store implies enumerate and cannot be combined with the autocmplete feature:
    		_valueStore = new XmlFieldValueStore (this, xmlNode);
			_enumerate = true;
			_autocomplete = false;
			break;
		default:
    		throw new Error ("Unknown feature composite: " + name);
    	}
    }
}
