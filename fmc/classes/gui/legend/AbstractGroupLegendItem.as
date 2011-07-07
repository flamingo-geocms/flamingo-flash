/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLabelLegendItem;
import gui.legend.LegendContainer;
import gui.legend.Parser;
import tools.Arrays;
import gui.legend.AbstractLegendItem;

import mx.utils.Delegate;

class gui.legend.AbstractGroupLegendItem extends AbstractLabelLegendItem {
	
	private var _configuration: XMLNode;
	private var _items: Array;
	private var _continuations: Array = null;
	
	public function get configuration (): XMLNode {
		return _configuration;
	}
	
	public function get isGroupOpen (): Boolean {
		return false;
	}
	
	public function AbstractGroupLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode) {
		super (parent);
		
		this._configuration = configuration;
		this._items = null;
	}

    /**
     * Returns an array of all suib-items in this group that match the given filter.
     * 
     * @param filter    The filter method. Each legend item is passed as the first argument of this filter,
     *                  if the result is true the legend item is added to the result.
     * @param doLoad    When true, items that have not yet been loaded will be loaded first. This will
     *                  load the entire legend configuration down to the deepest item.
     * @param callback  When doLoad is true, callback will be invoked with the result of this method.
     * @param groupFilter If a group filter is given, only groups that match the filter are expanded.
     * @return          An array containing all items that match the filter, or null if doLoad is true.
     */
    public function getAllItemsFiltered (filter: Function, doLoad: Boolean, callback: Function, groupFilter: Function): Array {
    	
    	if (doLoad) {
    		loadAllItems (function (self: AbstractGroupLegendItem): Void {
    			self.getAllItemsFiltered (filter, false, callback, groupFilter);
    		}, groupFilter);
    		return null;
    	}
    	
        var result: Array = [ ];
        
        if (filter) {
        	var fringe: Array = [this];
                
            while (fringe.length > 0) {
            	var item: AbstractGroupLegendItem = AbstractGroupLegendItem (fringe.shift ()),
                    children: Array = item.getItems ();
                    
                if (!children) {
                	continue;
                }
                
                for (var i: Number = 0; i < children.length; ++ i) {
                	var child: Object = children[i];
                	
                	if (child instanceof AbstractGroupLegendItem && (!groupFilter || groupFilter (child))) {
                		fringe.unshift (child);
                	}
                	
                	if (filter (child)) {
                		result.push (child);
                	}
                }
            }
        }
        
        if (callback) {
        	callback (result);
        	return null;
        } else {
            return result;
        }
    }

    private function loadAllItems (callback: Function, groupFilter: Function): Void {
    	var groupFringe: Array = [this],
            asyncCount: Number = 0,
            processGroup: Function,
            processGroupChildren: Function,
            self: AbstractGroupLegendItem = this;
            
        processGroup = function (): Void {
        	while (groupFringe.length > 0) {
        		var group: AbstractGroupLegendItem = AbstractGroupLegendItem (groupFringe.shift ());
        		
        		// Skip groups that are filtered out:
        		if (groupFilter && !groupFilter (group)) {
        			continue;
        		}
        		
        		// Process the children of the group:
        		if (group.getItems ()) {
        			var items: Array = group.getItems ();
        			for (var i: Number = 0; i < items.length; ++ i) {
        				if (items[i] instanceof AbstractGroupLegendItem) {
        					groupFringe.push (items[i]);
        				}
        			}
        		} else {
        			asyncCount = asyncCount + 1;
        			group.getItems (processGroupChildren);
        		}
        	}
        	
        	if (asyncCount <= 0) {
        		callback (self);
        	}
        };
        
        processGroupChildren = function (items: Array): Void {
        	// Add all child groups to the fringe array:
        	for (var i: Number = 0; i < items.length; ++ i) {
        		if (items[i] instanceof AbstractGroupLegendItem) {
        			groupFringe.push (items[i]);
        		}
        	}
        	
        	asyncCount = asyncCount - 1;
        	
        	processGroup ();
        };
        
        processGroup ();
    }
    
	/**
	 * Returns the sub-items of this group by invoking the given continuation with the items array as an argument. If the sub-items have not
	 * been loaded yet this call is performed asynchronous, otherwise the continuation is invoked directly. After the sub-items have been loaded
	 * (and the continuation has been invoked at least once) this method may also be called without a continuation, in that case the list of
	 * sub-items is returned directly. Invoking getItems without a continuation before items have been loaded results in a null return value.
	 * When this method loads new legend items, the onItemsAdded event is raised on the LegendContainer that contains this group.
	 * 
	 * @param continuation     The continuation to invoke when the items have been loaded. The array of items is passed as the first argument
	 *                         to the continuation.
	 * @return                 The list of previously loaded sub-items, or null if no items have been loaded yet and the method must be
	 *                         invoked with a continuation.
	 */
	public function getItems (continuation: Function): Array {
		if (!continuation) {
			return _items;
		}
		
		return fetchItems (continuation);
	}
	
	public function fetchItems (continuation: Function): Array {
		
		if (_items !== null) {
			if (continuation) {
                continuation (_items, this);
			}
			return _items;
		}
		
		// Parse the items:
		var parent: AbstractGroupLegendItem = this;
		while (parent && !(parent instanceof LegendContainer)) {
			parent = parent.parent;
		}
		var parser: Parser = parent ? LegendContainer (parent).parser : null;
		
		if (parser && _continuations === null) {
			_continuations = continuation ? [continuation] : [];
			_items = parser.items (this, configuration, Delegate.create (this, function (items: Array): Void {
				this._items = items;
				
				for (var i: Number = 0; i < items.length; ++ i) {
					items[i]._setIndex (i);
				}
				
				LegendContainer (parent)._onItemsAdded (this, items);
				Arrays.each (this._continuations, function (c): Void {
					c (items);
				});
				this._continuations = null;
			}));
		} else if (parser) {
			if (continuation) {
                _continuations.push (continuation);
			}
		} else {
			_items = [ ];
			LegendContainer (parent)._onItemsAdded (this, this._items);
			
			if (continuation) {
                continuation (_items, this);
			}
		}
		
		return _items;
	}
	
	/**
	 * Updates the configuration of this group after new XML has been added. If this group's children have been
	 * previously parsed, new items are parsed from the configuration. If this group has never been parsed before
	 * invoking this method does nothing.
	 */
	public function updateConfiguration (): Void {
		
		// The configuration hasn't been parsed yet, there is no need to update the items:
		if (_items === null) {
			return;
		}
		
		var item: AbstractLegendItem,
			i: Number,
			newItems: Array = [ ];

		var parent: AbstractGroupLegendItem = this;
		while (parent && !(parent instanceof LegendContainer)) {
			parent = parent.parent;
		}
		var parser: Parser = parent ? LegendContainer (parent).parser : null;
		
		for (i = _items.length; i < configuration.childNodes.length; ++ i) {
			item = parser.item (this, configuration.childNodes[i]);
			newItems.push (item);
			_items.push (item);
		}
		
		if (newItems.length > 0) {
			LegendContainer (parent)._onItemsAdded (this, newItems);
		}
	}
}
