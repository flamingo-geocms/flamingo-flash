/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.core.UIComponent;

import mx.containers.Accordion;
import mx.core.View;
import mx.utils.Delegate;
import mx.controls.ComboBox;
import mx.managers.DepthManager;
import mx.controls.Label;

class gui.querybuilder.FilterContainer extends View {
	
	static var symbolName:String = "__Packages.gui.querybuilder.FilterContainer";
	static var symbolOwner:Function = gui.querybuilder.FilterContainer;
	static var symbolLinked = Object.registerClass(symbolName, symbolOwner);
	
	private var accordion: Accordion = null;
	private var comboBox: ComboBox = null;
	private var label: Label = null;
	private var caption: Label = null;
	
	private var _label: String = 'Label:';
	private var _caption: String = 'Caption:';
	private var _blankSelectionLabel: String = 'Select a value ...';
	
	private var useAccordion: Boolean = false;
	
	// selectedIndex property
	// createChild
	// calcContentWidth
	// calcContentHeight
	// resize event
	// setSize -> delegeren naar accordion
	
	public function get selectedIndex (): Number {
		if (accordion) {
			return accordion.selectedIndex;
		} else {
			return comboBox.selectedIndex;
		}
	}
	
	public function set selectedIndex (index: Number): Void {
		if (accordion) {
			accordion.selectedIndex = index;
		} else {
			comboBox.selectedIndex = index;
		}
	}
	
	public function get selectLabel (): String {
		return _label;
	}
	
	public function set selectLabel (label: String): Void {
		_label = label;
		
		if (this.label) {
			this.label.text = label;
			doLayout ();
		}
	}
	
	public function get selectCaption (): String {
		return _caption;
	}
	
	public function set selectCaption (caption: String): Void {
		_caption = caption;
		
		if (this.caption) {
			this.caption.text = caption;
		}
	}
	
	public function get blankSelectionLabel (): String {
		return _blankSelectionLabel;
	}
	
	public function set blankSelectionLabel (label: String): Void {
		var old: String = _blankSelectionLabel;
		_blankSelectionLabel = label;
		
		if (old != _blankSelectionLabel && comboBox) {
			populateComboBox ();
		}
	}

	public function FilterContainer() {
		super();
	}
	
	public function createChildren (): Void {
		createUI ();
		bindUI ();
		syncUI ();
	}
	
	private function createUI (): Void {
		if (useAccordion) {
			accordion = Accordion (attachMovie ("Accordion", "accordion", this.getNextHighestDepth ()));
			return;
		} else {
			label = Label (super.createChild (mx.controls.Label, 'label', { autoSize:  'left' }));
			comboBox = ComboBox (super.createChild (mx.controls.ComboBox, 'comboBox', { }));
			caption = Label (super.createChild (mx.controls.Label, 'caption', { }));
		}
	}

	private function bindUI (): Void {
		if (accordion) {
			accordion.addEventListener ('resize', Delegate.create (this, function (e: Object): Void {
				this.dispatchEvent (e);
			}));
		} else {
			// Add handlers to the comboboxes to prevent the focus rectangle on the popup from
			// being drawn (otherwise the focus rectangle will remain visible after the combobox
			// is closed):
			var onOpenComboBox: Function = function (): Void {
				this.dropdown.drawFocus = function (): Void { };
			};
			comboBox.addEventListener ('open', onOpenComboBox);
			comboBox.onKillFocus = function (): Void {
				super.onKillFocus ();
			};
			
			comboBox.addEventListener ('change', Delegate.create (this, onComboBoxChanged));
		}
	}
	
	private function syncUI (): Void {
		if (!accordion) {
			populateComboBox ();
			label.text = _label;
			caption.text = _caption;
		}
	}
	
	private function onComboBoxChanged (): Void {
		var i: Number,
			selectedItem: Object = comboBox.selectedItem;
		
		for (i = 1; i < numChildren; ++ i) {
			var child: MovieClip = getChildAt (i);
			child._visible = child.containerChildEnabled && child == selectedItem.data;
		}
		
		doLayout ();
	}
	
	public function setChildEnabled (child: MovieClip, enabled: Boolean): Void {
		// The accordion currently doesn't support enabling or disabling children:
		if (accordion) {
			return;
		}
		
		var childIndex: Number;
		
		for (var i: Number = 1; i < numChildren; ++ i) {
			if (getChildAt (i) == child) {
				childIndex = i;
				break;
			}
		}
		
		if (!childIndex || child.containerChildEnabled == enabled) {
			return;
		}
		
		child._visible = enabled;
		child.containerChildEnabled = enabled;

		populateComboBox ();		
	}
	
	public function createChild (symbolName, instanceName:String, props:Object): MovieClip {
		if (accordion) {
			return accordion.createChild (symbolName, instanceName, props);
		} else {
			var contentMovieClip: MovieClip = super.createChild(symbolName, instanceName, props);
			
			contentMovieClip.containerChildEnabled = true;
			contentMovieClip._visible = false;
			
			populateComboBox ();
									
			return contentMovieClip;
		}
	}

	private function populateComboBox (): Void {
		var items: Array = [ ],
			i: Number,
			idx: Number,
			selectedItem: Object = comboBox.selectedItem,
			selectedIndex: Number = 0;
			
		comboBox.removeAll ();
		comboBox.addItem ({ label: blankSelectionLabel });
		for (i = 1, idx = 1; i < numChildren; ++ i) {
			var child: MovieClip = getChildAt (i);
			
			if (child.containerChildEnabled) {
				comboBox.addItem ({ label: child.label, data: child });	
				if (child == selectedItem.data) {
					selectedIndex = idx;
				}
				++ idx;
			}
		}
		
		comboBox.setSelectedIndex (selectedIndex);
	}
	
	public function calcContentWidth (): Number {
		if (accordion) {
			return accordion.calcContentWidth ();
		} else {
			return width;
		}
	}
	
	public function calcContentHeight (): Number {
		if (accordion) {
			return accordion.calcContentHeight ();
		} else {
			return height - (4 + Math.max (label.height, comboBox.height) + 5 + caption.height + 5);
		}
	}
	
	public function setSize (w:Number, h:Number, noEvent:Boolean): Void {
		super.setSize (w, h, noEvent);
		
		if (accordion) {
			accordion.setSize (w, h, noEvent);
		} else {
			
		}
	}
	
	public function doLayout (): Void {
		var localContentWidth: Number = calcContentWidth ();
		var localContentHeight: Number = calcContentHeight ();
		
		// comboBox.move (0, 0);
		var selectHeight: Number = Math.max (label.height, comboBox.height);
		label.move (5, 4 + (selectHeight / 2) - (label.height / 2));
		comboBox.move (label.width + 10, 4 + (selectHeight / 2) - (label.height / 2));
		comboBox.setSize (width - label.width - 20, comboBox.height);
		caption.move (5, 4 + selectHeight + 5);
		var headingHeight: Number = 4 + selectHeight + 5 + caption.height + 5;
		
		for (var i: Number = 3; i < numChildren; ++ i) {
			var contentMovieClip: MovieClip = getChildAt (i);
			
			contentMovieClip._x = 0;
			contentMovieClip._y = headingHeight;
		}
	}
}
