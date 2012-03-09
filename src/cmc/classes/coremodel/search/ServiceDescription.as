/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;

import coremodel.search.FeatureType;
import coremodel.search.SearchField;
import coremodel.search.Relation;

/**
 * @author Erik
 */
class coremodel.search.ServiceDescription extends AbstractComposite {
	
	public static var TYPE_SEARCH: String = 'search';
	public static var TYPE_FILTER: String = 'filter';
	
	private var _type: String;
	private var _id: String;
	private var _srs: String = 'EPSG:28992';
	private var _outputFields: Array = null;
	private var _label: String = 'Service description';
	private var _fixedFields: Array = null;
	private var _mandatoryFields: Array = null;
	private var _minFields: Number = 1;
	private var _maxFields: Number = 0;
	private var _resultFeatureType: String;
	private var _enlargeExtent: Number;
	//private var _pinLocation: Boolean;
	private var _outputFormat: String;
	private var _tooltip: String;
	private var _highlightLayer: String;
	private var _highlightWmsUrl: String;
	private var _highlightSldServletUrl: String;
	private var _highlightFeatureTypeName: String;
	private var _highlightPropertyName: String;
	private var _highlightMaxScale: String;
	private var _sortFields: Array = null;
	private var _useExtent: Boolean = true;
	private var _defaultValue: String = '';
	private var _filterLayer: String = null;
	
	private var _featureTypes: Object;
	private var _searchFields: Object;
	private var _relations: Object;

	public function get type (): String {
		return _type;
	}
	
	public function get id (): String {
		return _id;
	}
	
	public function get highlightLayer (): String { return _highlightLayer; }
	public function get highlightWmsUrl (): String { return _highlightWmsUrl; }
	public function get highlightSldServletUrl (): String { return _highlightSldServletUrl; }
	public function get highlightFeatureTypeName (): String { return _highlightFeatureTypeName; }
	public function get highlightPropertyName (): String { return _highlightPropertyName; }
	public function get highlightMaxScale (): String { return _highlightMaxScale; }
		
	public function get srs (): String {
		return _srs;
	}
	
	public function get label (): String {
		return _label;
	}
	
	public function get featureTypes (): Array {
		var result: Array = [ ];
		for (var i: String in _featureTypes) {
			result.push (_featureTypes[i]);
		}
		return result;
	}
	
	public function get searchFields (): Array {
		var result: Array = [ ];
		for (var i: String in _searchFields) {
			result.push (_searchFields[i]);	
		}
		return result;
	}
	
	/**
	 * Returns an array containing all SearchField instances that are mandatory for
	 * this service. Fields are listed in the order in which they should be assigned
	 * a value by the user.
	 * 
	 * @return The list of mandatory fields.
	 */
	public function get mandatoryFields (): Array {
		if (!_mandatoryFields) {
			return [ ];
		}
		
		var result: Array = [ ];
		
		for (var i: Number = 0; i < _mandatoryFields.length; ++ i) {
			var field: SearchField = _searchFields[_mandatoryFields[i]];
			if (field) {
				result.push (field);
			}
		}
		
		return result;
	}
	
	/**
	 * Returns an array containing all SearchField instances that are fixed for this service.
	 * Fixed fields are always displayed and their value can be left empty.
	 * 
	 * @return The list of fixed fields.
	 */
	public function get fixedFields (): Array {
		if (!_fixedFields) {
			return [ ];
		}
		
		var result: Array = [ ];
		
		for (var i: Number = 0; i < _fixedFields.length; ++ i) {
			var field: SearchField = _searchFields[_fixedFields[i]];
			if (field) {
				result.push (field);
			}
		}
		
		return result;
	}
	
	/**
	 * Returns the minimum number of fields that must be present in a query on this service. The
	 * default value is 1. 
	 */
	public function get minFields (): Number {
		return _minFields;
	}
	
	/**
	 * Returns the maximum number of fields that can be present in a query on this service. A value of 0
	 * indicates there is no maximum.
	 */
	public function get maxFields (): Number {
		return _maxFields;
	}
	
	public function get relations (): Array {
		var result: Array = [ ];
		for (var i: String in _relations) {
			result.push (_relations[i]);
		}
		return result;	
	}
	
	public function get resultFeatureType (): FeatureType {
		return getFeatureTypeById (_resultFeatureType);
	}
	
	public function get outputFields (): Array {
		return _outputFields;
	}
	
	public function get enlargeExtent (): Number {
		return _enlargeExtent;
	}
	
	//public function get pinLocation (): Boolean {
		//return _pinLocation;
	//}
	
	public function get outputFormat (): String {
		
		// Generate a default output format string if none was configured:
		if (!_outputFormat) {
			if (outputFields) {
				var fmt: Array = [ ];
				for (var i: Number = 0; i < outputFields.length; ++ i) {
					fmt.push ('[' + outputFields[i] + ']');	
				}
				return fmt.join (', ');
			} else {
				return '** no output format and fields configured **';
			}
		}
		
		return _outputFormat;
	}
	
	public function get tooltipFormat (): String {
		return _tooltip;
	}
	
	public function get sortFields (): Array {
		
		if (!_sortFields) {
			return [ { searchFieldName: searchFields[0].searchFieldName, direction: 'asc' } ];
		}
		
		var i: Number,
			result: Array = [ ];
			
		for (i = 0; i < _sortFields.length; ++ i) {
			var parts: Array = filter (String (_sortFields[i]).split (' '), function (a: String): Boolean { return a != ''; });
			var dir: String = parts.length > 1 ? _global.flamingo.trim (parts[1]).toLowerCase () : 'asc';
			var searchFieldName: String = parts[0];
			
			if (dir != 'asc' && dir != 'desc') {
				dir = 'asc';
			}
	
			result.push ({ searchFieldName: searchFieldName, direction: dir });		
		}
		
		if (result.length == 0) {
			return [ { searchFieldName: searchFields[0].searchFieldName, direction: 'asc' } ];
		}
		
		return result;
	}
	
	public function get useExtent (): Boolean {
		return _useExtent;
	}
	
	public function get filterLayer (): String {
		return _filterLayer;
	}
	
	public function ServiceDescription (xmlNode: XMLNode) {
		
		if (xmlNode.localName.toLowerCase () == 'servicedescription') {
			_type = TYPE_SEARCH;
		} else if (xmlNode.localName.toLowerCase () == 'filterdescription') {
			_type = TYPE_FILTER;
		} else {
			_global.flamingo.tracer ("Unknown query composite type: `" + xmlNode.localName + "`");
		}
		
		_featureTypes = { };
		_searchFields = { };
		_relations = { };
		
		if (xmlNode) {
			parseConfig (xmlNode);
		}
	}
	
	public function isFieldMandatory (field: SearchField): Boolean {
		if (!_mandatoryFields) {
			return false;
		}
		
		for (var i: Number = 0; i < _mandatoryFields.length; ++ i) {
			if (_mandatoryFields[i] == field.id) {
				return true;
			}
		}
		
		return false;
	}
	
	public function getFeatureTypeById (id: String): FeatureType {
		return _featureTypes[id];
	}
	
	public function getSearchFieldById (id: String): SearchField {
		return _searchFields[id];
	}
	
	public function getRelationById (id: String): Relation {
		return _relations[id];
	}
	
	public function findRelations (filter: Function): Array {
		if (!filter) {
			return relations;
		}
		
		var result: Array = [ ];
		var i: String;
		
		for (i in _relations) {
			if (filter (_relations[i])) {
				result.push (_relations[i]);
			}
		}
		
		return result;
	}
	
    function setAttribute (name:String, value:String): Void {
    	switch (name.toLowerCase ()) {
    	case 'id':
    		_id = value;
    		break;
		case 'srs':
			_srs = value;
			break;
		case 'label':
			_label = value;
			break;
		case 'outputfields':
			_outputFields = _global.flamingo.asArray (value);
			break;
		case 'mandatoryfields':
			_mandatoryFields = _global.flamingo.asArray (value);
			break;
		case 'fixedfields':
			_fixedFields = _global.flamingo.asArray (value);
			break;
		case 'minfields':
			_minFields = Math.max (1, Number (value));
			break;
		case 'maxfields':
			_maxFields = Math.max (0, Number (value));
			break;
		case 'resultfeaturetype':
			_resultFeatureType = value;
			break;
		case 'enlargeextent':
			_enlargeExtent = Number (value);
			break;
		/*case 'pinlocation':
			if(value=="true")
				_pinLocation =  true;
			else 
				_pinLocation =  false;
			break;*/	
		case 'outputformat':
			_outputFormat = String (value);
			break;
		case 'tooltipformat':
			_tooltip = value;
			break;
		case "highlightlayer":
			_highlightLayer = String (value);	
			break;
		case "highlightwmsurl":
			_highlightWmsUrl = String (value);
			break;
		case "highlightsldservleturl":
			_highlightSldServletUrl = String (value);
			break;
		case "highlightfeaturetypename":
			_highlightFeatureTypeName = String (value);
			break;
		case "highlightpropertyname":
			_highlightPropertyName = String (value);
			break;
		case "highlightmaxscale":
			_highlightMaxScale = String (value);
			break;
		case "sortfields":
			_sortFields = _global.flamingo.asArray (value);
			break;
		case "useextent":
			_useExtent = value.toLowerCase() == 'true';
			break;
		case "filterlayer":
			_filterLayer = value;
			break;
		default:
			throw new Error ('Invalid attribute: ' + name);
    	}
    }
    
    function addComposite (name:String, xmlNode:XMLNode): Void {
    	var id: String;
    	
    	switch (name.toLowerCase ()) {
    	case 'featuretype':
    		id = xmlNode.attributes.id ? xmlNode.attributes.id : uniqueId (_featureTypes, '_featureType');
    		xmlNode.attributes.id = id;
    		_featureTypes[id] = new FeatureType (this, xmlNode);
    		break;
    	case 'searchfield':
    		id = xmlNode.attributes.id ? xmlNode.attributes.id : uniqueId (_searchFields, '_searchField');
    		xmlNode.attributes.id = id;
    		_searchFields[id] = new SearchField (this, xmlNode);
    		break;
    	case 'relation':
    		id = xmlNode.attributes.id ? xmlNode.attributes.id : uniqueId (_relations, '_relation');
    		xmlNode.attributes.id = id;
    		_relations[id] = new Relation (this, xmlNode);
    		break;
    	default:
    		throw new Error ('Invalid composite: ' + name);
    	}
    }

	private static var uid: Number = 0;
	
	private function uniqueId (list: Object, prefix: String): String {
		return prefix + '_' + (uid ++);
	}
	
	private function filter (list: Array, f: Function): Array {
		var result: Array = [ ],
			i: Number;
			
		for (i = 0; i < list.length; ++ i) {
			if (f (list[i])) {
				result.push (list[i]);
			}
		}
		
		return result;
	}
}
