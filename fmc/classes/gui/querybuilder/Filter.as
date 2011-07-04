/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.events.EventDispatcher;
import mx.controls.ComboBase;
import mx.controls.ProgressBar;
import mx.core.View;
import mx.utils.Delegate;
import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.controls.Label;
import mx.core.UIComponent;
import mx.controls.Button;
import mx.skins.RectBorder;

import gui.querybuilder.AutocompleteTextInput;

/**
 * Events:
 * - selectedFieldChanged
 * - valueChanged
 * - delete
 * - enter
 * - prefixChanged
 * 
 * @author Erik
 */
class gui.querybuilder.Filter extends View {
	
	static var symbolName:String = "__Packages.gui.querybuilder.Filter";
	static var symbolOwner:Function = gui.querybuilder.Filter;
	static var symbolLinked = Object.registerClass(symbolName, symbolOwner);
	
	static var DELETE_BUTTON_SIZE: Number = 24;
	static var HORPADDING: Number = 4;
	static var VERPADDING: Number = 1;
	
	
	private static var operators: Array = [
		"=",
		">",
		"<"
	];
	
	private var border: RectBorder;
	private var fieldNameLabel: Label;
	private var fieldNameComboBox: ComboBox;
	private var valueTextInput: TextInput;
	private var operatorComboBox: ComboBox;
	private var valueComboBox: ComboBox;
	private var valueAutocomplete : AutocompleteTextInput;
	private var deleteButton: Button;
	private var progressBar: ProgressBar;
	
	private var _fields: Array;
	private var _allowFieldSelection: Boolean = true;
	private var _canDelete: Boolean = true;
	private var _possibleValues: Array = null;
	private var _selectedField: Object = null;
	private var _value: String = '';
	private var _operator: String = '=';
	private var _selectFieldLabel: String = 'Select a field ...';
	private var _selectValueLabel: String = 'Select a value ...';
	private var _showProgress: Boolean = false;
	private var _mandatory: Boolean = false;
	private var _disabled: Boolean = false;
	private var _autocomplete: Boolean = false;
	private var _allowOperatorSelection: Boolean = true;
	
	/**
	 * Returns the list of available fields for this filter. Each element in the array is an object
	 * containing the following attributes:
	 * - label: The label that is displayed in the combobox.
	 * - data: An application specific object that is associated with the field.
	 */
	public function get fields (): Array {
		return _fields;
	}

	/**
	 * (Re-)sets the fields that can be selected for this filter. If field selection is allowed the combobox
	 * that lists the fields is updated to contain the new list of fields. If the combobox previously had a
	 * selection, that selection is kept if the new list contains the old field, otherwise the selection is
	 * removed.
	 * 
	 * If field selection is not allowed, the selectedField attribute must be explicitly set to one of the items
	 * in this array.
	 * 
	 * Each element in the fields array is an object containing the following attributes:
	 * - label: The label that is displayed in the combobox.
	 * - data: An application specific data field for the field. This field is not used by the filter component,
	 *   however it is passed to event handlers.
	 */	
	public function set fields (fields: Array): Void {
		_fields = fields;
		
		if (fieldNameComboBox) {
			populateFields ();
		}
	}
	
	public function get allowFieldSelection (): Boolean {
		return _allowFieldSelection;
	}
	
	public function set allowFieldSelection (value: Boolean): Void {
		_allowFieldSelection = value;
		
		if (fieldNameComboBox && fieldNameLabel) {
			populateFields ();
		}
	}
	
	public function get canDelete (): Boolean {
		return _canDelete;
	}
	
	public function set canDelete (v: Boolean): Void {
		_canDelete = v;
		
		if (deleteButton) {
			deleteButton.visible = v;
			size ();
		}
	}
	
	public function get possibleValues (): Array {
		return _possibleValues;
	}
	
	/**
	 * Sets a list of possible values for this filter, each possible value is an object
	 * containing at least the following attributes:
	 * - label: The label that is displayed in the combobox.
	 * - value: The actual value that can be accessed through the 'value' property
	 *   after the value has been selected.
	 */
	public function set possibleValues (values: Array): Void {
		_possibleValues = values;
		
		if (valueComboBox && valueTextInput && valueAutocomplete) {
			populateValues ();
		}
	}
	
	public function get selectedField (): Object {
		return _selectedField;
	}
	
	public function set selectedField (field: Object): Void {
		var oldValue: Object = _selectedField;
		
		_selectedField = field;
		
		if (oldValue !== _selectedField) {
			dispatchEvent ({type: 'selectedFieldChanged', oldValue: oldValue, newValue: field });
		}
		
		if (fieldNameComboBox && field != fieldNameComboBox.selectedItem) {
			if (field === null) {
				fieldNameComboBox.setSelectedIndex (0);
			} else {
				fieldNameComboBox.setSelectedItem (field);
			}
		}
		
		if (fieldNameLabel) {
			fieldNameLabel.text = field.label;
		}
		
		populateValues ();
	}
	
	public function get value (): String {
		return _value;
	}
	
	public function set value (v: String): Void {
		var oldValue: String = _value;
		
		_value = v;
		
		if (oldValue != _value) {
			dispatchEvent ({type: 'valueChanged', oldValue: oldValue, newValue: v });
		}
		
		setValue (v);
	}
	
	public function get operator (): String {
		return _operator;
	}
	
	public function set operator (op: String): Void {
		var oldOperator: String = _operator;
		
		_operator = op;
		
		if (oldOperator != _operator) {
			dispatchEvent ({type: 'operatorChanged', oldOperator: oldOperator, newOperator: op });
		}
		
		setOperator (op);
	}
	
	public function get selectFieldLabel (): String {
		return _selectFieldLabel;
	}
	
	public function set selectFieldLabel (l: String): Void {
		_selectFieldLabel = l;
	}
	
	public function get selectValueLabel (): String {
		return _selectValueLabel;
	}
	
	public function set selectValueLabel (l: String): Void {
		_selectValueLabel = l;
		
		if (valueAutocomplete) {
			valueAutocomplete.disabledLabel = selectValueLabel;
		}
	}
	
	public function get showProgress (): Boolean {
		return _showProgress;
	}
	
	public function set showProgress (sp: Boolean): Void {
		_showProgress = sp;
		
		if (valueComboBox && valueTextInput && valueAutocomplete) {
			populateValues ();
		}
	}
	
	public function set mandatory (m: Boolean): Void {
		_mandatory = m;
		
		if (fieldNameComboBox && fieldNameLabel) {
			populateFields ();
		}
	}
	
	public function get mandatory (): Boolean {
		return _mandatory;
	}
	
	public function get disabled (): Boolean {
		return _disabled;
	}
	
	public function set disabled (d: Boolean): Void {
		_disabled = d;
		
		if (valueComboBox) {
			valueComboBox.enabled = !d;
		}
		if (valueAutocomplete) {
			valueAutocomplete.enabled = !d;
		}
		if (valueTextInput) {
			valueTextInput.enabled = !d;
		}
	}
	
	public function get autocomplete (): Boolean {
		return _autocomplete;
	}
	
	public function set autocomplete (a: Boolean): Void {
		_autocomplete = a;
		
		if (valueAutocomplete) {
			populateValues ();
		}
	}
	
	public function get allowOperatorSelection (): Boolean {
		return _allowOperatorSelection;
	}
	
	public function set allowOperatorSelection (a: Boolean): Void {
		_allowOperatorSelection = a;
		if (operatorComboBox) {
			operatorComboBox.visible = a;
			size ();
		}
	}

	public function init (): Void {
		super.init ();
		
		_fields = [ ];
	}
	
	public function clear (): Void {
		if (allowFieldSelection) {
			
		}
	}

	public function createChildren (): Void {
		//_global.flamingo.tracer ("Filter::createChildren");
		super.createChildren ();
		
		createUI ();
		bindUI ();
		syncUI ();
	}
	
	private function createUI (): Void {
		
		// Create a simple border around the filter component:		
		// border = RectBorder (createChild (mx.skins.RectBorder, 'border', { }));
		opaqueBackground = 0xEEEEEE;
		
		// Create controls for this filter, the controls are initially hidden. A selection of these
		// controls will be made visible depending on the configuration of this component:		
		fieldNameLabel = Label (createChild (mx.controls.Label, 'fieldNameLabel', { visible: false } ));
		fieldNameComboBox = ComboBox (createChild (mx.controls.ComboBox, 'fieldNameComboBox', { visible: false } ));
		valueTextInput = TextInput (createChild (mx.controls.TextInput, 'valueTextField', { visible: false } ));
		valueComboBox = ComboBox (createChild (mx.controls.ComboBox, 'valueComboBox', { visible: false } ));
		operatorComboBox = ComboBox (createChild (mx.controls.ComboBox, 'operatorComboBox', { visible: false }));
		valueAutocomplete = AutocompleteTextInput (createChild (gui.querybuilder.AutocompleteTextInput, 'autocompleteTextInput', { visible: false }));
		deleteButton = Button (createChild (mx.controls.Button, 'deleteButton', { visible: false, icon: 'IconDelete' } ));
		progressBar = ProgressBar (createChild (mx.controls.ProgressBar, 'progressBar', { visible: false, mode: 'manual' } ));
		
		// Configure control styles:
		deleteButton.setSize (24, 24);
		progressBar.indeterminate = true;
		progressBar.label = undefined;
		fieldNameLabel.fontWeight = 'bold';
		
		// Populate the operators combobox:
		for (var i: Number = 0; i < operators.length; ++ i) {
			operatorComboBox.addItem (operators[i], operators[i]);
		}
	}

	private function bindUI (): Void {
		
		// Add handlers to the comboboxes to prevent the focus rectangle on the popup from
		// being drawn (otherwise the focus rectangle will remain visible after the combobox
		// is closed):
		var onOpenComboBox: Function = function (): Void {
			this.dropdown.drawFocus = function (): Void { };
		};
		fieldNameComboBox.addEventListener ('open', onOpenComboBox);
		valueComboBox.addEventListener ('open', onOpenComboBox);
		operatorComboBox.addEventListener ('open', onOpenComboBox);
		valueComboBox.onKillFocus = function (): Void {
			super.onKillFocus ();
		};
		fieldNameComboBox.onKillFocus = function (): Void {
			super.onKillFocus ();
		};
		operatorComboBox.onKillFocus = function (): Void {
			super.onKillFocus ();
		};
		
		// Add change handlers to comboboxes and the text input:
		fieldNameComboBox.addEventListener ('change', Delegate.create (this, onFieldNameChange));
		valueComboBox.addEventListener ('change', Delegate.create (this, onValueSelect));
		operatorComboBox.addEventListener ('change', Delegate.create (this, onOperatorSelect));
		valueAutocomplete.addEventListener ('change', Delegate.create (this, onValueSelect));
		valueTextInput.addEventListener ('change', Delegate.create (this, onValueChange));
		valueTextInput.addEventListener ('enter', Delegate.create (this, onEnter));
		
		deleteButton.addEventListener ('click', Delegate.create (this, onClosePressed));
		
		valueAutocomplete.addEventListener ('change', Delegate.create (this, onAutocompleteSelect));
		valueAutocomplete.addEventListener ('prefixChanged', Delegate.create (this, function (e: Object): Void { this.dispatchEvent (e); }));
	}

	private function syncUI (): Void {
		var minHeight: Number = 3 * VERPADDING;
		
		if (allowFieldSelection) {
			fieldNameComboBox.visible = true;
			populateFields ();
			
			minHeight += fieldNameComboBox.height;
		}
		
		populateValues ();
		minHeight += Math.max (valueComboBox.height, valueTextInput.height);
		
		if (canDelete) {
			deleteButton.visible = true;
		}
		
		operatorComboBox.visible = allowOperatorSelection;
		
		// Update the minHeight attribute so that the query builder can neatly
		// pack multiple filters in the scroll area: 
		this.minHeight = minHeight;
		
		valueTextInput.enabled = !disabled;
		valueComboBox.enabled = !disabled;
		valueAutocomplete.enabled = !disabled;
		valueAutocomplete.disabledLabel = selectValueLabel;
	}

	/**
	 * Populates the values in the fields combobox. If possible, this method keeps the old
	 * selection in the combobox, even if its index is altered. If the old selection is no
	 * longer available, the combobox defaults to the first item.
	 */
	private function populateFields (): Void {
		
		if (!fieldNameComboBox || !fieldNameLabel) {
			return;
		}
		
		
		if (allowFieldSelection) {
			var oldSelection: Object = selectedField;
			var keepOldSelection: Boolean = false;
			var oldSelectionIndex: Number;
			
			fieldNameComboBox.visible = true;
			fieldNameLabel.visible = false;
			
			fieldNameComboBox.removeAll ();
			
			fieldNameComboBox.addItem (selectFieldLabel);
			
			for (var i: Number = 0; i < fields.length; ++ i) {
				if (fields[i].data == oldSelection.data) {
					keepOldSelection = true;
					oldSelectionIndex = i + 1;
				}
				fieldNameComboBox.addItem (fields[i]);
			}
			
			if (!keepOldSelection) {
				fieldNameComboBox.setSelectedIndex (0);
				selectedField = null;
			} else {
				fieldNameComboBox.setSelectedIndex (oldSelectionIndex);
			}
		} else {
			fieldNameComboBox.visible = false;
			fieldNameLabel.visible = true;
			
			fieldNameLabel.text = selectedField === null ? '[ no field selected ]' : selectedField.label;
			
			if (mandatory) {
				fieldNameLabel.text += ' (*)';
			}
		}
	}
	
	/**
	 * Populates the values combobox with possible values.
	 */
	private function populateValues (): Void {
		
		if (!valueComboBox || !valueTextInput || !valueAutocomplete) {
			return;
		}
		
		// Show or hide the progress bar:
		if (showProgress) {
			operatorComboBox.visible = valueComboBox.visible = valueTextInput.visible = valueAutocomplete.visible = false;
			progressBar.visible = true;
			return;
		} else {
			progressBar.visible = false;
		}
		
		// Hide input controls if no field is selected:
		if (selectedField === null) {
			operatorComboBox.visible = valueComboBox.visible = valueTextInput.visible = valueAutocomplete.visible = false;
			return; 
		}
		
		// Show either a combobox or a text input:
		operatorComboBox.visible = allowOperatorSelection;
		if (possibleValues !== null && !autocomplete) {
			var oldSelection: String = value;
			var keepOldSelection: Boolean = false;
			var oldSelectionIndex: Number;
			var enabled: Boolean = valueComboBox.enabled;
			
			valueComboBox.visible = true;
			valueTextInput.visible = false;
			valueAutocomplete.visible = false;
			
			valueComboBox.removeAll ();
		
			valueComboBox.addItem (selectValueLabel);
		
			valueComboBox.enabled = true;
			for (var i: Number = 0; i < possibleValues.length; ++ i) {
				if (possibleValues[i].value == value) {
					keepOldSelection = true;
					oldSelectionIndex = i;
				}
				valueComboBox.addItem (possibleValues[i]);
			}
			
			if (keepOldSelection) {
				valueComboBox.setSelectedIndex (oldSelectionIndex);
			} else {
				valueComboBox.setSelectedIndex (0);
				value = '';
			}
			valueComboBox.enabled = enabled;
		} else if (possibleValues !== null && autocomplete) {
			valueComboBox.visible = false;
			valueTextInput.visible = false;
			valueAutocomplete.visible = true;
			
			valueAutocomplete.setValues (possibleValues);
		} else {
			valueComboBox.visible = false;
			valueTextInput.visible = true;
			valueAutocomplete.visible = false;
			
			valueTextInput.text = value;
		}
	}
	
	/**
	 * This handler is bound to the 'change' event of the field name combobox and is
	 * invoked whenever the user selects a new field.
	 */
	private function onFieldNameChange (): Void {
		var selectedFieldName: Object = fieldNameComboBox.selectedItem;
		
		if (!selectedFieldName.data) {
			selectedFieldName = null;
		}
		
		
		selectedField = selectedFieldName;
	}

	/**
	 * This handler is bound to the 'change' event of the value combobox and is invoked
	 * whenever the user selects a new value.
	 */
	private function onValueSelect (): Void {
		var selectedValue: Object = valueComboBox.selectedItem;
		
		if (autocomplete) {
			return;
		}
		
		if (!selectedValue.value) {
			selectedValue = null;
		}
		
		value = selectedValue === null ? '' : selectedValue.value;
	}
	
	public function onAutocompleteSelect (): Void {
		var selectedValue: Object = valueAutocomplete.value;
		
		//_global.flamingo.tracer ("Autocomplete select: " + selectedValue + ", " + selectedValue.value);
		if (!autocomplete) {
			return;
		}
		
		if (!selectedValue || !selectedValue.value) {
			selectedValue = null;
		}
		
		value = selectedValue === null ? '' : selectedValue.value;
	}
	
	public function onOperatorSelect (): Void {
		operator = String (operatorComboBox.value);
	}

	/**
	 * This handler is bound to the 'change' event of the value input and is invoked
	 * whenever the user alters the text in the input.
	 */
	private function onValueChange (): Void {
		value = valueTextInput.text;
	}
	
	/**
	 * This handler is bound to the 'click' event of the close button of this filter and fires a
	 * close event for this object.
	 */
	private function onClosePressed (): Void {

		dispatchEvent ({ type: 'delete' });
	}
	
	/**
	 * This handler is bound to the 'enter' event of the value text input, it dispatches an 'enter' event
	 * from the filter whenever the user presses enter in a value input. The query builder can respond to
	 * this event by initiating a search when the user presses the enter key.
	 */
	private function onEnter (): Void {
		
		dispatchEvent ({ type: 'enter' });
	}
	
	private function setValue (v: String): Void {
		
		if (possibleValues !== null) {
			// Select an item from the value combobox:
			var selectedValue: Object = valueComboBox.selectedItem,
				found: Boolean = false;
			if (selectedValue && selectedValue.value && selectedValue.value != v) {
				for (var i: Number; i < valueComboBox.getLength (); ++ i) {
					var item: Object = valueComboBox.getItemAt (i);
					if (item.value && item.value == v) {
						valueComboBox.setSelectedIndex (i);
						found = true;
						break;
					}
				}
				if (!found) {
					valueComboBox.setSelectedIndex (0);
				}
			} else if (selectedValue && !v && valueComboBox.selectedIndex != 0) {
				valueComboBox.setSelectedIndex (0);
			}
		} else if (v != valueTextInput.text) {
			// Set the value of the text input:
			valueTextInput.text = v;
		}
	}
	
	private function setOperator (op: String): Void {
		_operator = op;
		
		if (operatorComboBox && allowOperatorSelection) {
			for (var i: Number = 0; i < operators.length; ++ i) {
				if (operators[i] == op) {
					operatorComboBox.setSelectedIndex (i);
				}
			}
		}
	}
	
	/**
	 * Resizes and moves all children of this control to reflect the new dimensions of the parent container.
	 * The width of the input controls/labels is adjused to match the width of the parent container (minus some padding),
	 * the close button is positioned in the top right corner of the parent container if it is visible.
	 */
	public function size (): Void {
		super.size ();
		
		if (border) {
			border.move (0, 0);
			border.setSize (width, height);
		}
		
		var contentWidth: Number = width - 2 * HORPADDING - (canDelete ? DELETE_BUTTON_SIZE + HORPADDING : 0);
		var rowHeight: Array = [
				Math.max (fieldNameComboBox.height, fieldNameLabel.height),
				Math.max (valueComboBox.height, valueTextInput.height)
			];
			
		// Move the controls to their proper positions:
		fieldNameComboBox.move (HORPADDING, VERPADDING);
		fieldNameComboBox.setSize (contentWidth, fieldNameComboBox.height);
		
		fieldNameLabel.move (HORPADDING, VERPADDING);
		fieldNameLabel.setSize (contentWidth, fieldNameComboBox.height);
		
		operatorComboBox.move (HORPADDING, 2 * VERPADDING + rowHeight[0]);
		operatorComboBox.setSize (40, valueComboBox.height);
		
		var valueX: Number = allowOperatorSelection ? 42 : 0;
		
		valueComboBox.move (HORPADDING + valueX, 2 * VERPADDING + rowHeight[0]);
		valueComboBox.setSize (contentWidth - valueX, valueComboBox.height);
		
		valueTextInput.move (HORPADDING + valueX, 2 * VERPADDING + rowHeight[0]);
		valueTextInput.setSize (contentWidth - valueX, valueTextInput.height);
		
		valueAutocomplete.move (HORPADDING + valueX, 2 * VERPADDING + rowHeight[0]);
		valueAutocomplete.setSize (contentWidth - valueX, valueAutocomplete.height);
		
		progressBar.move (HORPADDING, 2 * VERPADDING + rowHeight[0] + (Math.max (valueComboBox.height, valueTextInput.height) / 2) - (progressBar.height / 2));
		progressBar.setSize (contentWidth, progressBar.height);
		
		deleteButton.move (width - HORPADDING - DELETE_BUTTON_SIZE, VERPADDING);
	}
}