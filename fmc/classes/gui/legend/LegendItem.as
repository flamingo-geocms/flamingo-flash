/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendVisitor;

import mx.utils.Delegate;

class gui.legend.LegendItem extends AbstractGroupLegendItem {
	
	public static var IV_VISIBLE: Number = 1;
	public static var IV_INSCALE: Number = 2;
	
	private var _symbolPosition: String;
	private var _listenTo: Object;
	private var _canHide: Boolean;
	private var _stickyLabel: Boolean;
	private var _infoURL: String;
	private var _linkStyleId: String;
	private var _visible: Number = 0;
	
	public function get symbolPosition (): String {
		return _symbolPosition;
	}
	
	public function set symbolPosition (symbolPosition: String): Void {
		_symbolPosition = symbolPosition;
	}
	
	public function get listenTo (): Object {
		return _listenTo;
	}
	
	public function set listenTo (listenTo: Object): Void {
		_listenTo = listenTo;
	}
	
	public function get canHide (): Boolean {
		return _canHide;
	}
	
	public function set canHide (canHide: Boolean): Void {
		_canHide = canHide;
	}
	
	public function get stickyLabel (): Boolean {
		return _stickyLabel;
	}
	
	public function set stickyLabel (stickyLabel: Boolean): Void {
		_stickyLabel = stickyLabel;
	}
	
	public function get infoURL (): String {
		return _infoURL;
	}
	
	public function set infoURL (infoURL: String): Void {
		_infoURL = infoURL;
	}
	
	public function get linkStyleId (): String {
		return _linkStyleId;
	}
	
	public function set linkStyleId (linkStyleId: String): Void {
		_linkStyleId = linkStyleId;
	}

    public function get visible (): Boolean {
    	return (_visible & IV_VISIBLE) != 0;
    }
    
    public function get outOfScale (): Boolean {
    	return (_visible & IV_INSCALE) == 0;
	}
    
    public function get isGroupOpen (): Boolean {
        return visible;
    }
    
	public function LegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode) {
		super (parent, configuration);
	}
	
	public function visit (visitor: LegendVisitor, context: Object): Void {
		visitor.visitItem (this, context);
	}
	
	public function show (visible: Boolean, outOfScale: Boolean): Void {
		if (this.visible == visible && this.outOfScale == outOfScale) {
			return;
		}
		
		this._visible = 0;
		if (visible) {
			this._visible |= IV_VISIBLE;
		}
		if (!outOfScale) {
			this._visible |= IV_INSCALE;
		}
		
		if (visible) {
    		getItems (Delegate.create (this, function (): Void {
    			this.invalidate ();
    		}));
		} else {
			invalidate ();
		}
		
		// Locate the legend container and invoke the item visibility change handler:
		var parent: Object = this.parent;
		while (parent.parent) {
			parent = parent.parent;
		}
		parent._onLegendItemVisbilityChanged (this);
	}
	
	public function _onPress (newCheckboxState: Boolean): Void {
		if (!listenTo) {
			return;
		}
		
        for (var mapLayer: String in listenTo) {
            var layers: Array = listenTo[mapLayer],
                comp: MovieClip = _global.flamingo.getComponent (mapLayer);

            if (layers.length == 0) {
                // Make sure the map layer is visible:            
                if (comp instanceof gui.layers.AbstractLayer) {
                    comp.setVisible (newCheckboxState);
                } else {
                    comp.visible = newCheckboxState;
                    comp.updateCaches ();
                }
                _global.flamingo.raiseEvent (comp, newCheckboxState ? 'onShow' : 'onHide', comp);
            } else {

                if (newCheckboxState) {
                    if (comp instanceof gui.layers.AbstractLayer) {
                        comp.setVisible (newCheckboxState);
                    } else {
                        comp.visible = newCheckboxState;
                        comp.updateCaches ();
                    }
                    _global.flamingo.raiseEvent (comp, newCheckboxState ? 'onShow' : 'onHide', comp);
                }
                
                comp.setLayerProperty(layers.join (','), "visible", newCheckboxState);
            }
            
            //do update here to make sure that show/hide and setLayerProperty is done before update.
            updateMapLayer (mapLayer);
        }

        // Collapse any siblings if hideAllButOne is true on the containing group:
        if (!Object (parent).hideAllButOne || !newCheckboxState) {
            return;
        }
        
        parent.getItems (Delegate.create (this, function (items: Array): Void {
            for (var i: Number = 0; i < items.length; ++ i) {
                if (!(items[i] instanceof LegendItem) || items[i] == this) {
                    continue;
                }
                
                if (items[i].visible) {
                    items[i]._onPress (false);
                }
            }
        }));
	}
	
	private static function updateMapLayer (mapLayer: String): Void {
		_global.setTimeout (function (): Void {
            _global.flamingo.getComponent (mapLayer).update ();
		}, 100);
	}
}
