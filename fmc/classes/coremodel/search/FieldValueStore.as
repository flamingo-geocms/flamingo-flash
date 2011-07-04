/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import core.AbstractComposite;
import coremodel.search.SearchField;

import mx.utils.Delegate;
import mx.events.EventDispatcher;

/**
 * The field value store is an abstract class that provides possible field values for search field
 * in synchronous or asynchronous fashion. A field value store delivers a list of value-label pairs
 * in the form of an array of objects.
 * 
 * The field value store emits two types of events:
 * 
 * 
 * @author Erik Orbons
 */
class coremodel.search.FieldValueStore extends AbstractComposite {
	
	private var _searchField: SearchField;

	var dispatchEvent: Function;
	var addEventListener: Function;
	var removeEventListener: Function;
	
	public function get searchField (): SearchField {
		return _searchField;
	}
	
	public function FieldValueStore(searchField: SearchField, node: XMLNode) {
		EventDispatcher.initialize (this);
		
		_searchField = searchField;
		
		if (node) {
			parseConfig (node);
		}
	}
	
	public function searchValues (filters: Object): Void { }
}
