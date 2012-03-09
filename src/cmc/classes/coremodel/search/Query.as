/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.search.QueryFilter;
import coremodel.search.ServiceDescription;
import coremodel.search.SearchField;
import coremodel.search.FeatureType;
import coremodel.search.Relation;
import coremodel.search.Request;

import coremodel.service.WhereClause;


class coremodel.search.Query {
	
	private var _serviceDescription: ServiceDescription;
	private var _filters: Array;
	
	/**
	 * Returns the service description that is associated with this query.
	 * 
	 * @return The service description that is associated with this query.
	 */
	public function get serviceDescription (): ServiceDescription {
		return _serviceDescription;
	}
	
	/**
	 * Returns the first filter in this query, or null if the query has no filters.
	 * 
	 * @return The first filter in this query, or null.
	 */
	public function get firstFilter (): QueryFilter {
		return _filters.length > 0 ? _filters[0] : null;
	}
	
	/**
	 * Returns the last filter in this query, or null if the query has no filters.
	 * 
	 * @return The last filter in this query, or null.
	 */
	public function get lastFilter (): QueryFilter {
		return _filters.length > 0 ? _filters[_filters.length - 1] : null;
	}
	
	/**
	 * Returns true if this query can be considered 'complete'. A query is complete when
	 * the following conditions are met:
	 * - At least serviceDescription.minFields fields are complete
	 * - All mandatory search fields are complete.
	 * 
	 * @return True if the query is complete, false otherwise.
	 */
	public function get complete (): Boolean {
		
		var completeFilters: Number = 0,
			completeFiltersMap: Object = { },
			i: Number;
		
		for (i = 0; i < _filters.length; ++ i) {
			var filter: QueryFilter = _filters[i];
			
			// If the filter is complete it is not relevant whether it is mandatory or not:
			if (filter.complete) {
				++ completeFilters;
				completeFiltersMap [filter.searchField.id] = true;
				continue;
			}
			
			// Incomplete filters should not be mandatory:
			if (filter.searchField && serviceDescription.isFieldMandatory (filter.searchField)) {
				return false;
			}
		}
		
		// Check whether all mandatory search fields have a value:
		var mandatorySearchFields: Array = serviceDescription.mandatoryFields;
		for (i = 0; i < mandatorySearchFields.length; ++ i) {
			if (!completeFiltersMap[mandatorySearchFields[i].id]) {
				return false;
			}
		}
		
		/*
		for (var i: Number = 0; i < _filters.length - 1; ++ i) {
			var filter:QueryFilter = _filters[i];
			if (!filter.complete) {
				return false;		
			}
		}
		*/
		
		return true;
	}
	
	/**
	 * Returns true if the query is empty.
	 * 
	 * @return True if the query is empty, false if it contains at least one filter.
	 */
	public function get empty (): Boolean {
		return _filters.length == 0;
	}
	
	/**
	 * Returns a list of search fields that are not assigned to a filter. Only
	 * unassigned filters are available for use in a new filter. Search fields that are assigned with
	 * an operator other other than '=' can be used twice in a query.
	 * 
	 * @return A list of unassigned search fields.
	 */
	public function get availableSearchFields (): Array {
		var searchFields: Array = serviceDescription.searchFields;
		var i: Number;
		var used: Object = { },
			usedLT: Object = { },
			usedGT: Object = { };
		var available: Array = [ ];
		
		for (i = 0; i < _filters.length; ++ i) {
			var filter: QueryFilter = _filters[i];
			switch (filter.operator) {
			default:
			case '=':
				used[filter.searchField.id] = true;
				break;
			case '>':
				usedGT[filter.searchField.id] = true;
				break;
			case '<':
				usedLT[filter.searchField.id] = true;
				break;
			}
		}
		
		for (i = 0; i < searchFields.length; ++ i) {
			var searchField: SearchField = searchFields[i];
			if (!used[searchField.id] && !(usedGT[searchField.id] && usedLT[searchField.id])) {
				available.push (searchField);
			}
		}
		
		return available;
	}
	
	public function get filters (): Array {
		return _filters;
	}
	
	public function get resultFeatureType (): FeatureType {
		var ft: FeatureType = serviceDescription.resultFeatureType;
		
		if (ft) {
			return ft;
		}
		
		// Look for the last feature type in the query:
		var i: Number;
		for (i = 0; i < _filters.length; ++ i) {
			var f: QueryFilter = _filters[i];
			
			if (!f.complete) {
				break;
			}
			
			ft = f.searchField.featureType;
		}
		
		return ft;
	}
	
	public function get serviceUrl (): String {
		var ft: FeatureType = resultFeatureType;
		
		if (!ft) {
			return '';
		}
		
		var url: String = ft.server,
			i: Number;
		
		// Modify the URL using all filters:
		for (i = 0; i < _filters.length; ++ i) {
			var f: QueryFilter = _filters[i];
			
			/*
			if (!f.complete || f.searchField.featureType != ft) {
				continue;
			}
			*/
			var pattern: String = '[' + f.searchField.searchFieldName + ']',
				value: String = f.complete ? f.value : '',
				o: Number;
				
			// _global.flamingo.tracer (pattern + ' = ' + value);
			
			if ((o = url.indexOf (pattern)) >= 0) {
				url = url.substr (0, o) + value + url.substr (o + pattern.length);	
			}
		}
		
		return url;
	}
	
	public function Query (serviceDescription: ServiceDescription) {
		
		_filters = [ ];	
		_serviceDescription = serviceDescription;
	}
	
	public function addFilter (): QueryFilter {
		var filter: QueryFilter = new QueryFilter (this);
		_filters.push (filter);
		
		return filter; 
	}
	
	public function removeFilter (filter: QueryFilter): Void {
		var i: Number;
		
		for (i = 0; i < _filters.length; ++ i) {
			var f: QueryFilter = _filters[i];
			if (f == filter) {
				_filters.splice(i, 1);
			}
		}
	}
	
	public function getFilters (filter: Function): Array {
		if (!filter) {
			return _filters;
		}
		
		var result: Array = [ ];
		var i: Number;
		
		for (i = 0; i < _filters.length; ++ i) {
			if (filter (_filters[i])) {
				result.push (_filters[i]);
			}
		}
		
		return result;
	}
	
	public function getPreviousFilter (filter: QueryFilter): QueryFilter {
		var previous: QueryFilter = null,
			i: Number;
			
		for (i = 0; i < _filters.length; ++ i) {
			if (_filters[i] == filter) {
				return previous;
			}
			previous = _filters[i];
		}
		
		return null;
	}
	
	/**
	 * Returns true if the given filter is the last filter in this query.
	 * 
	 * @return True if the filter is the last one in this query, false otherwise.
	 */
	public function isLastFilter (filter: QueryFilter): Boolean {
		return filter === lastFilter;
	}

	/**
	 * Starts enumerating possible values for a filter using an asynchronous query to
	 * the WFS server.
	 */	
	public function enumerateFilterValues (filter: QueryFilter): Void {
		var searchField: SearchField = filter.searchField;
		
		if (!searchField || !searchField.enumerate) {
			return;
		}
	}
	
	public function getWhereClauses (): Array {
		return getFilterWhereClauses (resultFeatureType);
	}
	
	public function getFilterString (): String {
		var filterString: String = '';
		
		for (var i: Number = 0; i < _filters.length; ++ i) {
			var filter: QueryFilter = _filters[i];
			
			// Skip incomplete filters:
			if (!filter.complete) {
				continue;
			}
			
			var searchFieldName: String = filter.searchField.searchFieldName,
				value: String = filter.value,
				operator: String = filter.operator;
				
			if (operator == '>') {
				operator = "&gt;";
			}
			if (operator == '<') {
				operator = "&lt;";
			}
			
			if (filterString != "") {
				filterString += " AND ";
			}
			
			filterString += searchFieldName + operator + "&apos;" + value + "&apos;";
		}
		
		return filterString;
	}
	
	public function getFilterWhereClauses (resultFeatureType: FeatureType, lastFilter: QueryFilter): Array {
		
		var i: Number,
			j: Number,
			whereClauses: Array = [ ];
		
		//_global.flamingo.tracer ("Constructing query:");
		
		// Get the feature type that will be used for the result:
		//var resultFeatureType: FeatureType = serviceDescription.resultFeatureType;
		if (!resultFeatureType) {
			_global.flamingo.tracer ("Service description has no result feature type");
			return;
		}
		//_global.flamingo.tracer (" - Result feature type: " + resultFeatureType.id);
		
		// Construct a WFS query:
		for (i = 0; i < _filters.length; ++ i) {
			var filter: QueryFilter = _filters[i];
			
			// Incomplete filters are ignored:	
			if (!filter.complete) {
				continue;
			}
			
			var filterFeatureType: FeatureType = filter.searchField.featureType;
			var filterSearchField: String = filter.searchField.searchFieldName;
			
			// Filters that act on the result feature type are directly transformed
			// in where clauses:
			if (filterFeatureType == resultFeatureType) {
				//_global.flamingo.tracer (" - Where: " + resultFeatureType.id + "." + filterSearchField + " = `" + filter.value + "`");
				//whereClauses.push (new WhereClause (filterSearchField, filter.value, WhereClause.EQUALS, filter.searchField.matchCase));
				var wc: WhereClause = makeWhereClause (filter);
				//_global.flamingo.tracer (" - " + wc);
				whereClauses.push (wc);
				continue;
			}

			// _global.flamingo.tracer (" - Looking for relations between: " + resultFeatureType.id + " <-> " + filterFeatureType.id + "." + filterSearchField);
						
			// Search for relations that have the filter's feature type as a source and the result
			// feature type as destination. The search field of the filter must match the source
			// field of the relation:
			var relations: Array = serviceDescription.findRelations (function (r: Relation): Boolean {
				var res: Boolean =
					r.sourceFeatureType == filterFeatureType
					&& r.destFeatureType == resultFeatureType
					&& r.sourceField == filterSearchField;
					
				// _global.flamingo.tracer ("   - " + r.sourceFeatureType.id + "." + r.sourceField + " -> " + r.destFeatureType.id + "." + r.destField + ": " + res);
				
				return res;
			});
			
			// If no relations exist, this filter can be skipped:
			if (relations.length == 0) {
				continue;
			}
			
			// Create a where clause for each filter (usually there is only one):
			for (j = 0; j < relations.length; ++ j) {
				var r: Relation = relations[j];
				//_global.flamingo.tracer (" - Filter where: " + resultFeatureType.id + "." + r.destField + " = `" + filter.value + "`");
				whereClauses.push (new WhereClause (r.destField, filter.value, WhereClause.EQUALS, filter.searchField.matchCase));
			}
			
			if (filter == lastFilter) {
				break;
			}
		}
		
		return whereClauses;
	}
	
	private function makeWhereClause (filter: QueryFilter): WhereClause {
		var filterSearchFieldName: String = filter.searchField.searchFieldName;
		
		if (filter.searchField.hasPattern) {
			var pattern: String = filter.searchField.pattern;
			var replace: String = '[' + filterSearchFieldName + ']';
			var index: Number = pattern.indexOf (replace);
			var value: String;
			if (index >= 0) {
				value = pattern.substr(0, index)
					+ filter.value
					+ pattern.substr (index + replace.length);
			} else {
				value = pattern;
			}
			return new WhereClause (filterSearchFieldName, value, WhereClause.LIKE, filter.searchField.matchCase);
		} else {
			return new WhereClause (filterSearchFieldName, filter.value, WhereClause.EQUALS, filter.searchField.matchCase);
		}
	}
	
	public function persistState (document: XML, node: XMLNode): Void {
		// Do not persist queries whose service doesn't have an ID:
		if (!serviceDescription.id) {
			return;
		}
		
		var queryNode: XMLNode = document.createElement ('Query'),
			filtersNode: XMLNode = document.createElement ('Filters');
		
		queryNode.attributes['service'] = serviceDescription.id;
		
		for (var i: Number = 0; i < filters.length; ++ i) {
			var filter: QueryFilter = filters[i];
			
			filter.persistState (document, filtersNode);
		}
		
		queryNode.appendChild (filtersNode);
		node.appendChild (queryNode);
	}
}