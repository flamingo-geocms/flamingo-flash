/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.controls.listclasses.ScrollSelectList;
import mx.core.UIComponent;
import mx.controls.TextInput;
import mx.controls.List;
import mx.core.UIObject;

import mx.utils.Delegate;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;
import mx.managers.DepthManager;

class gui.querybuilder.AutocompleteTextInput extends UIComponent {

	static var symbolName:String = "__Packages.gui.querybuilder.AutocompleteTextInput";
	static var symbolOwner:Function = gui.querybuilder.AutocompleteTextInput;
	static var symbolLinked = Object.registerClass(symbolName, symbolOwner);
	
	private var	textInputControl: TextInput;
	private var listControl: List;
	private var _values: Array;
	private var _minInput: Number = 1;
	private var _value: Object = null;
	private var _keyListener: Function;
	private var _disabledLabel: String = 'Select a value ...';
	
	public function get value (): Object {
		return _value;
	}
	
	public function get disabledLabel (): String {
		return _disabledLabel;
	}
	
	public function set disabledLabel (l: String): Void {
		_disabledLabel = l;
		
		if (textInputControl && !enabled) {
			textInputControl.text = l;
		}
	}

	public function setValues (values: Array): Void {
		_values = values;
		
		if (textInputControl) {
			var popup: List = getPopup ();
			if (popup.visible) {
				populateList();
			}
		}
		
		// Clear the current value if it is not in the list:
		for (var i: Number = 0; i < values.length; ++ i) {
			if (values[i] == _value) {
				return;
			}
		}
		
		setValue (null, false);
	}
	
	public function init (): Void {
		super.init ();
		
		_values = [
			{ label: 'A item 1', data: null },
			{ label: 'A item 2', data: null },
			{ label: 'B item 3', data: null },
			{ label: 'B item 4', data: null } 
		];
	}
	
	function setFocus():Void
	{
		Selection.setFocus(textInputControl);
	}
	
	function setEnabled(enabledFlag: Boolean): Void {
		super.setEnabled(enabledFlag);
		
		if (enabled == enabledFlag) {
			return;
		}
		
		textInputControl.enabled = enabledFlag;
		
		if (!enabledFlag && textInputControl) {
			textInputControl.text = _disabledLabel;
		} else {
			textInputControl.text = _value == null ? '' : _value.label;
		}
	}
	
	public function createChildren (): Void {
		createUI ();
		bindUI ();
		syncUI ();
	}
	
	private function createUI (): Void {
		textInputControl = TextInput (createClassObject (mx.controls.TextInput, 'textInputControl', 20));
	}
	
	private function bindUI (): Void {
		textInputControl.addEventListener ('focusIn', Delegate.create (this, this.onFocus));
		textInputControl.addEventListener ('focusOut', Delegate.create (this, this.onBlur));
		textInputControl.addEventListener ('change', Delegate.create (this, this.onTextChange));
	}

	private function syncUI (): Void {
		
	}
	
	function layoutChildren(w:Number, h:Number): Void {
		
		textInputControl.move (0, 0);
		textInputControl.setSize (w, textInputControl.height);
	}
	
	function size ():Void {
		layoutChildren (__width, __height);
	}
	
	private function setValue (value: Object, updateTextInput: Boolean): Void {
		if (_value == value) {
			if (value && value.label != textInputControl.text) {
				textInputControl.text = value.label;
			}
			return;
		}
		
		//_global.flamingo.tracer ("setValue: " + value.label + ", " + updateTextInput);
		
		if (value && updateTextInput) {
			//_global.flamingo.tracer ("updating text input");
			textInputControl.text = value.label;
		}
		
		var old: Object = _value;	
		_value = value;
	
		dispatchEvent ({ type: 'change', oldValue: old, newValue: value });
	}
	
	private function populateList (): Void {
		var popup: List = getPopup (),
			visibleValues: Array = [ ],
			i: Number,
			itemCount: Number = 0,
			value: String = textInputControl.text.toLowerCase();
		
		popup.removeAll ();	
		for (i = 0; i < _values.length; ++ i) {
			if (_values[i].label.substr (0, value.length).toLowerCase () == value) {
				visibleValues.push (_values[i]);
				popup.addItem (_values[i]);
				++ itemCount;
			}
		}
		
		//popup.vScrollPolicy = itemCount < 10 ? "off" : "on";
		
		itemCount = Math.min (10, itemCount);
		popup.rowCount = itemCount;
	}
	
	private function getPopup (): List {
		if (!textInputControl) {
			return undefined;
		}
		
		if (listControl) {
			return listControl;
		}
		
		var o: Object = {
			_visible: false
		};
		
		/*
		PopUpManager.createPopUp = createPopUp;
		MovieClip.prototype.createClassChildAtDepth = createClassChildAtDepth;
		MovieClip.prototype.createClassObject = createClassObject;
		 */
		listControl = List (PopUpManager.createPopUp (this, List, false, o, true));
		//_global.flamingo.tracer ("Popup created: " + listControl + " (" + this + ")");
		
		listControl.setDataProvider ([ ]);
		listControl.multipleSelection = false;
		listControl.rowCount = 5;
		listControl.owner = this;
		listControl.drawFocus = function (): Void { };
		listControl.vScrollPolicy = "auto";
		
		listControl.addEventListener ('change', Delegate.create (this, onListChange));
		
		return listControl;
	}
	
	private function showPopup (populate: Boolean): Void {
		var popup: List = getPopup ();
		
		if (popup.visible) {
			return;
		}
		
		if (textInputControl.text.length < _minInput) {
			return;
		}
		
		if (populate) {
			populateList ();
		}
		
		var point: Object = {
			x: 0, 
			y: textInputControl.height
		};
		localToGlobal (point);
		popup._parent.globalToLocal (point);
		
		popup.move(point.x, point.y);
		popup.setSize(textInputControl.width, popup.height);
		popup.visible = true;
		//var height: Number = _root.getNextHighestDepth () * 2;
		//popup.swapDepths (height);		
	}
	
	private function hidePopup (): Void {
		var popup: List = getPopup ();
		
		if (!popup.visible) {
			return;
		}
		
		popup.visible = false;
	}
	
	private function updateValue (): Void {
		var i: Number,
			val: String = textInputControl.text.toLowerCase ();
		
		//_global.flamingo.tracer ("updateValue: " + val + ", " + _value + ", " + _value.label);
		
		// Set the value of the control to one of the options from the list:
		for (i = 0; i < _values.length; ++ i) {
			if (_values[i].label.toLowerCase () == val) {
				setValue (_values[i], true);
				return;
			}
		}
		
		// Set the value of the control to null if the text that was entered by the user
		// does not correspond to one of the options:
		setValue (null);
	}
	
	private function onListChange (): Void {
		var item: Object = listControl.selectedItem;
		
		setValue (item, true);
	}
	
	private function onTextChange (): Void {
		
		// Show or hide the popup, depending on the amount of text that is entered
		// in the text input control:
		if (textInputControl.text.length < _minInput) {
			hidePopup ();
		} else {
			populateList ();
			showPopup (false);
		}
		
		this.dispatchEvent ({ type: 'prefixChanged', prefix: textInputControl.text });
	}

	private function onFocus (): Void {
		_keyListener = Delegate.create (this, this.onKeyDown);
		textInputControl.addEventListener ('keyDown', _keyListener);
	}

	private function onBlur (): Void {
		var popup: List = getPopup ();
		
		hidePopup ();
		popup.visible = false;
		
		doLater (this, 'updateValue');
		
		textInputControl.removeEventListener ('keyDown', _keyListener);
	}
	
	private function onKeyDown (e: Object): Void {
		var popup: List;
		
		switch (e.code) {
		case Key.UP:
		case Key.DOWN:
			popup = getPopup ();
			if (popup.visible) {
				popup.keyDown (e);
			} else {
				showPopup (true);
			}
			break;
		case Key.ENTER:
			popup = getPopup ();
			if (popup.visible) {
				// Force the first item to be selected if the list is empty:
				if (popup.selectedIndex == undefined) {
					popup.setSelectedIndex (0);
					onListChange ();
				}
				hidePopup ();
			}
			break;
		case Key.ESCAPE:
			hidePopup ();
			break;
		}
	}
}
