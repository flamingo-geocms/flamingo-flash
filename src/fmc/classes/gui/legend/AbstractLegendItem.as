/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.LegendContainer;
import gui.legend.AbstractGroupLegendItem;

class gui.legend.AbstractLegendItem {
	
	public static var IV_VISIBLE: Number = 1;		// The corresponding layer is visible.
	public static var IV_INSCALE: Number = 2;		// The corresponding layer is in scale.
	public static var IV_ITEMINSCALE: Number = 4;	// The legend item is in scale.
	
	private var _index: Number;
	private var _parent: AbstractGroupLegendItem;
	private var _dx: Number;
	private var _dy: Number;
	private var _id: String;
	private var _minScale: Number;
	private var _maxScale: Number;
	private var _movieClip: MovieClip = null;
	private var _invalid: Boolean = false;
	private var _visible: Number = 0;
	
	public function get index (): Number {
		return _index;
	}
	
	/**
	 * Returns the direct parent of this legend item, or null if this item does not have a parent.
	 */
	public function get parent (): AbstractGroupLegendItem {
		return _parent;
	}
	
	public function get dx (): Number {
		return _dx;
	}
	
	public function set dx (dx: Number): Void {
		_dx = dx;
	}
	
	public function get dy (): Number {
		return _dy;
	}
	
	public function set dy (dy: Number): Void {
		_dy = dy;
	}
	
	public function get id (): String {
		return _id;
	}
	
	public function set id (id: String): Void {
		_id = id;
	}
	
	public function get minScale (): Number {
		return _minScale;
	}
	
	public function set minScale (minScale: Number): Void {
		_minScale = minScale;
	}
	
	public function get maxScale (): Number {
		return _maxScale;
	}
	
	public function set maxScale (maxScale: Number): Void {
		_maxScale = maxScale;
	}
	
	public function get movieClip (): MovieClip {
		return _movieClip;
	}
	
	public function get invalid (): Boolean {
		return _invalid;
	}
	
    public function get visible (): Boolean {
    	return (_visible & IV_VISIBLE) != 0;
    }
    
    public function get outOfScale (): Boolean {
    	return (_visible & IV_INSCALE) == 0;
	}
	
	public function get itemInScale (): Boolean {
		return (_visible & IV_ITEMINSCALE) != 0;
	}

	public function AbstractLegendItem (parent: AbstractGroupLegendItem) {
		this._parent = parent;
		this._visible = IV_INSCALE | IV_ITEMINSCALE;
	}

	public function _setIndex (index: Number): Void {
        _index = index;
    }
    
	public function _setMovieClip (movieClip: MovieClip): Void {
		_movieClip = movieClip;
	}
	
	/**
	 * Indicates that this legend item has changed. Invoke this method when the dimensions of the legend item change or the
	 * item visibility is updated.
	 */
	public function invalidate (): Void {
		if (_invalid) {
			return;
		}
		
		_invalid = true;
		
		if (parent) {
			parent.invalidate ();
		}
	}
	
	public function _invalidateRecursive (): Void {
		this.invalidate ();
	}
	
	public function validate (): Void {
		_invalid = false;
	}

    /**
     * The correct prototype for this method is:
     * 
     *   public function visit (visitor: LegendVisitor, context: Object): Void
     *   
     * We cannot import legend visitor in this class because this triggers a bug
     * in the runtime or compiler that breaks the inheritance chain of legend items,
     * causing the non-abstract legend items not to have their base classes set at runtime.
     */
	public function visit (visitor: Object, context: Object): Void {
		_global.flamingo.tracer ("Visiting unknown legend item");
	}
	
	public function show (visible: Boolean, outOfScale: Boolean, itemInScale: Boolean): Void {
		if (this.visible == visible && this.outOfScale == outOfScale && this.itemInScale == itemInScale) {
			return;
		}
		
		this._visible = 0;
		if (visible) {
			this._visible |= IV_VISIBLE;
		}
		if (!outOfScale) {
			this._visible |= IV_INSCALE;
		}
		if (itemInScale) {
			this._visible |= IV_ITEMINSCALE;
		}
		
		_invalidateRecursive ();
		
		// Locate the legend container and invoke the item visibility change handler:
		var parent: Object = this.parent;
		while (parent.parent) {
			parent = parent.parent;
		}
		parent._onLegendItemVisbilityChanged (this);
	}
}