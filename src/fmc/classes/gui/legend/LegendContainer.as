/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.utils.Delegate;

import gui.legend.AbstractLegendItem;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendItem;
import gui.legend.Parser;
import gui.legend.LegendVisitor;
import gui.legend.SymbolLegendItem;

import mx.events.EventDispatcher;

class gui.legend.LegendContainer extends AbstractGroupLegendItem {
	
	private var _componentId: String;
	private var _shadowSymbols: Boolean;
	private var _updateDelay: Number;
	private var _symbolPath: String;
	private var _defaultDelta: Object;
	private var _map: String = 'map';
	
	private var _parser: Parser;
	private var _layerListener: Object = null;
	private var _layerListeners: Object = { };
	private var _layerVisibility: Object = { };
	private var _dirtyLayers: Object = { };
	private var _itemIdMap: Object;
	
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var dispatchEvent: Function;
	
	public function get map (): String {
		return _map;
	}
	
	public function set map (map: String): Void {
		_map = map;
	}
	
	public function get parser (): Parser {
		return _parser;
	}
	
	public function get shadowSymbols (): Boolean {
		return _shadowSymbols;
	}
	
	public function set shadowSymbols (shadowSymbols: Boolean): Void {
		_shadowSymbols = shadowSymbols;
	}
	
	public function get updateDelay (): Number {
		return _updateDelay;
	}
	
	public function set updateDelay (updateDelay: Number): Void {
		_updateDelay = updateDelay;
	}
	
	public function get symbolPath (): String {
		return _symbolPath;
	}
	
	public function set symbolPath (symbolPath: String): Void {
		_symbolPath = symbolPath;
	}

    public function get defaultDelta (): Object {
        return _defaultDelta;		
    }
    
    public function get isGroupOpen (): Boolean {
        return true;
    }
    
    public function get outOfScaleMessage (): String {
    	return _global.flamingo.getString (_componentId, 'outofscale');
    }
    
	public function LegendContainer(configuration: XMLNode, parser: Parser, componentId: String) {
		super (null, configuration);
		
		// Make the legend container an event dispatcher:
		EventDispatcher.initialize (this);
		
		this._defaultDelta = {
			group: [0, 0],
			item: [0, 0],
			symbol: [0, 0],
			hr: [0, 0],
			text: [0, 0]
		};
		
		this._parser = parser;
		this._componentId = componentId;
		this._layerListeners = { };
		this._layerVisibility = { };
		this._dirtyLayers = { };
		this._itemIdMap = { };
		this._layerListener = {
            onShow: Delegate.create (this, onLayerShow),
            onHide: Delegate.create (this, onLayerHide),
            onUpdateComplete: Delegate.create (this, onLayerUpdateComplete)
		};
	}
	
	public function invalidate (): Void {
		if (!invalid) {
            super.invalidate ();
			this.dispatchEvent ({ type: 'onInvalidateLegend', legend: this });
		}
	}

    public function visit (visitor: LegendVisitor, context: Object): Void {
    	visitor.visitContainer (this, context);
    }
    
    /**
     * Searches for a legend item by identifier.
     * 
     * @return The legend item with the given ID, or null if no such item exists in the legend.
     */
    public function getItemById (id: String): AbstractLegendItem {
    	if (_itemIdMap[id]) {
    		return _itemIdMap[id];
    	}
    	
    	return null;
    }
    
	// =========================================================================
	// Events:
    // =========================================================================
	public function addLayerListener (layerId: String, legendItem: AbstractLegendItem, layers: Array): Void {
		 if (!_layerListeners[layerId]) {
            _layerListeners[layerId] = [ ];
            _global.flamingo.addListener (_layerListener, layerId, this);
		 }
		 
		 _layerListeners[layerId].push ({ item: legendItem, subLayers: layers });
		 
		 if (!_layerVisibility[layerId]) {
		 	_layerVisibility[layerId] = {
		 		scale: 0,
		 		visibility: AbstractLegendItem.IV_INSCALE, 
		 		subLayerVisibility: { }
		 	};
		 }
		 
		 for (var i: Number = 0; i < layers.length; ++ i) {
		 	if (!_layerVisibility[layerId].subLayerVisibility[layers[i]]) {
		 	    _layerVisibility[layerId].subLayerVisibility[layers[i]] = AbstractLegendItem.IV_INSCALE;
		 	}
		 }
		 
		 _dirtyLayers[layerId] = true;
	}
	
	private function onLayerShow (layer: MovieClip): Void {
		var layerId: String = _global.flamingo.getId (layer);
        onLayerUpdateComplete (layer);
	}
	
	private function onLayerHide (layer: MovieClip): Void {
        var layerId: String = _global.flamingo.getId (layer);
        onLayerUpdateComplete (layer);
		
	}
	
	private function onLayerUpdateComplete (layer: MovieClip): Void {
		updateLayerVisibility (layer);
		updateItemsVisibility (layer);
	}
	
	/**
	 * This method is invoked by a legend item whenever the visibility changes, in response to which the legend container dispatches an event.
	 * This method should never be invoked directly.
	 */
	public function _onLegendItemVisbilityChanged (item: LegendItem): Void {
		this.dispatchEvent ({ type: 'onLegendItemVisibilityChanged', item: item });
	}
	
	/**
	 * This method is invoked whenever a legend item has been 'pressed' (the onPress event has been fired on the corresponding
	 * MovieClip). This method is only called from the renderer and should never be invoked manually.
	 */
	public function _onPressLegendItem (item: AbstractLegendItem): Void {
		this.dispatchEvent ({ type: 'onPressLegendItem', item: item });
	}
	
	/**
	 * This method is invoked whenever new items have been loaded somewhere in the legend. Initialy none of the legend items
	 * are loaded. This method is only called from AbstractGroupLegendItem and should never be invoked manually.
	 */
	public function _onItemsAdded (group: AbstractGroupLegendItem, items: Array): Void {
		var i: Number;
		
		// Register listeners on legend items and load items inside sub-groups that are opened initialy:
		for (i = 0; i < items.length; ++ i) {
			// Update the ID map:
			if (items[i].id) {
				if (_itemIdMap[items[i].id]) {
					_global.flamingo.tracer ("Duplicate legend item ID: `" + items[i].id + "`");
				}
				
				_itemIdMap[items[i].id] = items[i];
			}
			
			if (items[i] instanceof LegendItem) {
    			var item: LegendItem = LegendItem (items[i]);
    			if (item.listenTo) {
    				registerItemListeners (item);
    			}
			} else if (items[i] instanceof SymbolLegendItem && (items[i].minScale != undefined || items[i].maxScale != undefined) && items[i].parent instanceof LegendItem) {
				registerSymbolListeners (SymbolLegendItem (items[i]));
			}
			
			if (items[i] instanceof AbstractGroupLegendItem && AbstractGroupLegendItem (items[i]).isGroupOpen) {
				AbstractGroupLegendItem (items[i]).fetchItems ();
			}
		}
		
		// Update the visibility of all layers to which new listeners have been added:
		initLayerVisibility ();
		
		this.dispatchEvent ({ type: 'onItemsAdded', group: group, items: items });
		
        // Update the visibility of all layers that have been added after events have been dispatched:
        for (i = 0; i < items.length; ++ i) {
        	if (items[i] instanceof LegendItem) {
        		updateItemVisibility (items[i]);
        	}
        }
	}
	
	private function registerItemListeners (item: LegendItem): Void {
		
		for (var layerId: String in item.listenTo) {
			addLayerListener (layerId, item, item.listenTo[layerId]);
		}
	}
	
	private function registerSymbolListeners (symbol: SymbolLegendItem): Void {
		if (!(symbol.parent instanceof LegendItem)) {
			return;
		}
		
		var parent: LegendItem = LegendItem (symbol.parent);
		if (!parent.listenTo) {
			return;
		}
		
		for (var layerId: String in parent.listenTo) {
			addLayerListener (layerId, symbol, parent.listenTo[layerId]);
		}
	}
	
	private function initLayerVisibility (): Void {
		for (var layerId: String in _dirtyLayers) {
			var component: MovieClip = _global.flamingo.getComponent (layerId);
			if (component) {
				updateLayerVisibility (component);
				if (_layerListeners[layerId]) {
					updateItemsVisibility (component);
				}
			}
		}
		
		_dirtyLayers = { };
	}
	
	/**
	 * Updates the local cache containing the visibility attributes of the given layer and all sublayers.
	 * This cache is maintained so that the visibility of a legend item can be efficiently determined.
	 */
	private function updateLayerVisibility (layer: MovieClip): Void {
		var layerId: String = _global.flamingo.getId (layer);
		
		if (!_layerVisibility[layerId]) {
			return;
		}
		
        var layerVisible: Object = layer.getVisible ();
        _layerVisibility[layerId].visibility = 0;
        if (layerVisible > 0) {
        	_layerVisibility[layerId].visibility |= LegendItem.IV_VISIBLE;
		}
		if (layerVisible >= -1 && layerVisible <= 1) {
			_layerVisibility[layerId].visibility |= LegendItem.IV_INSCALE;
		}
        
        _layerVisibility[layerId].scale = layer.getScale ();
        
        for (var subLayerId: String in _layerVisibility[layerId].subLayerVisibility) {
        	var subLayerVisibility: Number = layer.getVisible (subLayerId);
        	
        	_layerVisibility[layerId].subLayerVisibility[subLayerId] = 0;
        	if (subLayerVisibility > 0) {
        		_layerVisibility[layerId].subLayerVisibility[subLayerId] |= LegendItem.IV_VISIBLE;
        	}
        	if (subLayerVisibility >= -1 && subLayerVisibility <= 1) {
        		_layerVisibility[layerId].subLayerVisibility[subLayerId] |= LegendItem.IV_INSCALE;
        	}
        }
	}
	
	private function updateItemsVisibility (layer: MovieClip): Void {
		var layerId: String = _global.flamingo.getId (layer),
            items: Array = _layerListeners[layerId];
            
        if (!items) {
        	return;
        }
        
        for (var i: Number = 0; i < items.length; ++ i) {
        	var item: AbstractLegendItem = items[i].item;
        	updateItemVisibility (item);
        }
	}
	
	private function updateItemVisibility (item: AbstractLegendItem): Void {
		var itemVisibility: Number = 0,
			listenTo: Object = { };
			
		if (item instanceof LegendItem) {
			listenTo = LegendItem (item).listenTo;
		} else {
			listenTo = LegendItem (item.parent).listenTo;
		}
		
		
		var scale: Number = undefined;
		for (var mapLayerId: String in listenTo) {
			var subLayers: Array = listenTo[mapLayerId];
			
			if (subLayers.length > 0) {
    			for (var i: Number = 0; i < subLayers.length; ++ i) {
    				var subLayerId: String = subLayers[i];
    				
    				itemVisibility |= _layerVisibility[mapLayerId].subLayerVisibility[subLayerId];
    			}
			} else {
				itemVisibility |= _layerVisibility[mapLayerId].visibility;
			}
			
			if (scale == undefined || _layerVisibility[mapLayerId].scale < scale) {
				scale = _layerVisibility[mapLayerId].scale;
			}
		}
		
		var itemInScale: Boolean = true;
		if (scale != undefined) {
			if ((item.minScale != undefined && scale < item.minScale) || (item.maxScale != undefined && scale > item.maxScale)) {
				itemInScale = false;
			}
		}
		
		item.show ((itemVisibility & LegendItem.IV_VISIBLE) != 0, (itemVisibility & LegendItem.IV_INSCALE) == 0, itemInScale);
	}
}
