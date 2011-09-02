/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.search.FieldValueStore;
import coremodel.search.Query;
import coremodel.search.SearchField;
import coremodel.search.FeatureType;
import coremodel.search.ServiceDescription;
import coremodel.search.Request;

import coremodel.service.ServiceFeature;
import coremodel.service.WhereClause;

import mx.events.EventDispatcher;
import mx.utils.Delegate;

/**
 * Events:
 * - enumerateStart
 * - enumerateFinish
 * - enumerateFail
 * - fieldValuesAvailable
 */
class coremodel.search.QueryFilter {
	
	private var _query: Query;
	private var _searchField: SearchField = null;
	private var _value: String = ''; 
	private var _fieldValues: Array;
	private var _currentPrefix: String = '';
	private var _operator: String = '=';
	private var request: Request = null;
			
	// Reserve slots for the methods that are added by the event dispatcher:
	public var addEventListener: Function;
	public var dispatchEvent: Function;
	public var removeEventListener: Function;
	
	public function get query (): Query {
		return _query;
	}
	
	public function get searchField (): SearchField {
		return _searchField;
	}
	
	public function set searchField (searchField: SearchField): Void {
		_searchField = searchField;
		_currentPrefix = '';
		
		// Dispatch a field values available event if static field values are available:
		if (searchField.hasFieldValues) {
			setFieldValues (searchField.fieldValues);
		} else if (searchField.enumerate) {
			//setFieldValues ([ ]);
			clearFieldValues ();
		} else {
			dispatchEvent ({ type: 'fieldValuesAvailable', values: null });
		}
		
		if (searchField.operator) {
			operator = searchField.operator;
		}
	}
	
	public function get value (): String {
		return _value;
	}
	
	public function set value (value: String): Void {
		_value = value;
	}
	
	public function get operator (): String {
		return _operator;
	}
	
	public function set operator (op: String): Void {
		_operator = op;
	}

	/**
	 * Returns true if this query filter is complete. A query filter is complete if it has both a
	 * search field and a value assigned. Incomplete query filters are not taken into account when
	 * processing a query.
	 */	
	public function get complete (): Boolean {
		if (searchField == null) {
			return false;
		}
		
		var v: String = _global.flamingo.trim (value);
		
		return (v.length >= searchField.minInput && (searchField.maxInput == 0 || v.length <= searchField.maxInput));
	}
	
	public function get previous (): QueryFilter {
		return query.getPreviousFilter (this);
	}
	
	public function QueryFilter (query: Query) {
		
		// Turn this object into an event dispatcher:
		EventDispatcher.initialize (this);
		
		this._query = query;
	}
	
	/**
	 * Enumerates possible field values for this filter. The enumerate operation is performed using a getFeatures request
	 * on the service, similar to performing a query. Field values are only enumerated if all previous filters
	 * are complete, if this is not the case an empty set of field values is dispatched to all listeners.
	 * 
	 * 
	 */
	public function enumerate (prefix: String): Void {
		
		// Cannot enumerate if there is no search field, if it is not enumerable
		// or if the values have been previously enumerated without clearing:
		if (!prefix && (!searchField || !searchField.enumerate || _fieldValues || request)) {
			return;
		}
		
		if (searchField.valueStore) {
		
			enumerateValueStore ();
			return;
		}
		
		// Take the first 'minInput' characters of the prefix:
		if (prefix) {
			prefix = prefix.substr (0, searchField.minInput).toLowerCase ();
		}
		
		// If the search field has the autocomplete property, a prefix of at least minInput characters
		// must be given:
		if (searchField.autocomplete) {
			if (!prefix || prefix == _currentPrefix) {
				return;
			}
			_currentPrefix = prefix;
			if (prefix.length < searchField.minInput) {
				// Clear the list of possible values if the prefix is too short:
				setFieldValues ([ ]);
				return;
			}
		}
		var resultFeatureType: FeatureType = searchField.featureType,
			whereClauses: Array = query.getFilterWhereClauses (resultFeatureType, previous),
			valueFieldName: String = searchField.searchFieldName,
			autoNavigateFieldName: String = searchField.autoNavigateFieldName,
			displayFieldNames: Array = searchField.displayFieldNames,
			displayFieldSeparator: String = searchField.displayFieldSeparator,
			i: Number;
			

		// Add another where clause if a prefix is given:
		if (prefix) {
			whereClauses.push (new WhereClause (displayFieldNames[0], prefix + '*', WhereClause.LIKE, false));
		}
		
		// Create a request object:
		request = new Request (resultFeatureType);
		
		// Add event handlers to the request object:
		request.addEventListener ('getFeaturesComplete', Delegate.create (this, function (e: Object): Void {
			var features: Array = e.features,
				i: Number,
				values: Array = [ ];
				
			for (i = 0; i < features.length; ++ i) {
				var feature: ServiceFeature = features[i];
				values.push ({
					value: String (feature.getValue (valueFieldName)),
					label: this.makeLabel (displayFieldNames, displayFieldSeparator, feature),
					boundedBy: (feature.getValue (autoNavigateFieldName))
				});
			}
			
			this.setFieldValues (values, true);
			this.request = null;
		}));
		request.addEventListener ('error', Delegate.create (this, function (e: Object): Void {
			this.dispatchEvent ({ type: 'enumerateFail', message: e.exceptionMessage });
			this.setFieldValues ([ ]);
			this.request = null;
		}));
		
		// Perform the request:
		var outputFieldNames: Array = [ ],
			hasOutputField: Boolean = false;
		for (i = 0; i < displayFieldNames.length; ++ i) {
			if (displayFieldNames[i] == valueFieldName) {
				hasOutputField = true;
			}
			outputFieldNames.push (displayFieldNames[i]);
		}
		if (!hasOutputField) {
			outputFieldNames.push (valueFieldName);
		}
		request.getFeatures (null, whereClauses, null, outputFieldNames);
	}
	
	private function enumerateValueStore (): Void {
		//_global.flamingo.tracer ("Enumerating filter value store: " + searchField.id);
		
		// Callbacks:
		var valuesAvailable: Function = Delegate.create (this, function (e: Object): Void {
			setFieldValues (e.values, this.searchField.valueStore.sort);
			cleanup ();
		});
		var error: Function = Delegate.create (this, function (e: Object): Void {
			_global.flamingo.tracer ("Enumerate fail: " + e.message);
			this.dispatchEvent ({ type: 'enumerateFail', message: e.message });
			setFieldValues ([ ]);
			cleanup ();
		});
		var cleanup: Function = Delegate.create (this, function (): Void {
			searchField.valueStore.removeEventListener ('error', error);
			searchField.valueStore.removeEventListener ('valuesAvailable', valuesAvailable);
		});
		
		// Register callbacks:
		searchField.valueStore.addEventListener ('error', error);
		searchField.valueStore.addEventListener ('valuesAvailable', valuesAvailable);
		
		// Perform a request:
		searchField.valueStore.searchValues ({});
	}
	
	public function clearFieldValues (): Void {
		
		// Ignore if the query filter currently has no possible values:
		if (!_fieldValues) {
			return;
		}
		
		// Send an event to all listeners indicating that the possible values are cleared, the
		// internal _fieldValues array is set to null in order to force a reload of the possible
		// field values the next time they are enumerated:
		setFieldValues ([ ]);
		_fieldValues = null;
	}
	
	private function setFieldValues (fv: Array, sort: Boolean): Void {
		if (sort) {
			fv = fv.concat ();
			fv.sort (function (a: Object, b: Object): Number {
				var av: String = a.label.toLowerCase (),
					bv: String = b.label.toLowerCase ();
					
				if (av < bv) {
					return -1;
				} else if (av > bv) {
					return 1;
				} else {
					return 0;
				}
			});
		}
		
		_fieldValues = fv;
		this.dispatchEvent ({ type: 'fieldValuesAvailable', values: fv });
	}
	
	private function makeLabel (displayFieldNames: Array, displayFieldSeparator: String, feature: ServiceFeature): String {
		var values: Array = [ ],
			i: Number;
						
		for (i = 0; i < displayFieldNames.length; ++ i) {
			var value: Object = feature.getValue (displayFieldNames[i]);
			if (!value || value == '') {
				continue;
			}
			values.push (String (value));
		}
		
		return values.join(displayFieldSeparator);
	}
	
	public function persistState (document: XML, node: XMLNode): Void {
		var filterNode: XMLNode = document.createElement ('Filter');
		
		if (searchField && searchField.id) {
			filterNode.attributes['searchField'] = searchField.id;
		}
		if (operator) {
			filterNode.attributes['operator'] = operator;
		}
		if (value) {
			filterNode.attributes['value'] = value;
		}
		
		node.appendChild (filterNode);
	}
}
