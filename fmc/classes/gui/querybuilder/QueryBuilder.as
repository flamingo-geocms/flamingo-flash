/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.core.View;
import mx.core.ScrollView;
import mx.containers.ScrollPane;
import mx.utils.Delegate;
import gui.querybuilder.Filter;
import mx.controls.Button;
import mx.controls.ProgressBar;
import mx.controls.Label;

/**
 * Events:
 * - search: This event is fired when the search button is clicked.
 * - clear: The user pressed the clear button.
 * 
 * TODO:
 * - When a scrollview is used as a parent class, the component is
 *   not rendered correctly in Flash player 10.0. Scrolling needs to
 *   be re-enabled if a way around this bug can be found.
 *   
 */
class gui.querybuilder.QueryBuilder extends View {
	
	static var symbolName:String = "__Packages.gui.querybuilder.QueryBuilder";
	static var symbolOwner:Function = gui.querybuilder.QueryBuilder;
	static var symbolLinked = Object.registerClass(symbolName, symbolOwner);
	
	static var PADDING:Number = 3;
	 
	private var button: Button;
	private var clearButton: Button;
	private var progressBar: ProgressBar;
	private var infoLabelControl: Label;
	
	private var _searchLabel: String = 'Search';
	private var _clearLabel: String = 'Clear';
	private var _canSearch: Boolean = false;
	private var _autoNavigate: Boolean = false;
	private var _showProgress: Boolean = false;
	private var _infoLabel: String = '';
	
	private var filterComponents: Array;
	
	private var filterIndex: Number;
	
	public function setScrollProperties (): Void {
		
	}
	public var vPosition: Number = 0;
	public var vScroller: Object = {
		width: 0
	};
	
	/**
	 * Returns the label of the 'Search' button as a string.
	 * 
	 * @return The label of the search button.
	 */
	public function get searchLabel (): String {
		return _searchLabel;
	}
	
	/**
	 * Sets a new value for the label of the search button. If the
	 * query builder is visible when altering the label, the button
	 * control is updated directly.
	 * 
	 * @param label		The new search button label.
	 */
	public function set searchLabel (label: String): Void {
		_searchLabel = label;
		if (button) {
			button.label = label;
		}
	}
	
	public function get clearLabel (): String {
		return _clearLabel;
	}
	
	public function set clearLabel (label: String): Void {
		_clearLabel = label;
		if (clearButton) {
			clearButton.label = label;
		}
	}

	public function get canSearch (): Boolean {
		return _canSearch;
	}
	
	public function set canSearch (cs: Boolean): Void {
		_canSearch = cs;
		
		if (button) {
			button.enabled = cs;
		}
	}
	
	public function get autoNavigate (): Boolean {
		return _autoNavigate;
	}
	
	public function set autoNavigate(an: Boolean): Void {
		_autoNavigate = an;
		if (button) {
			button.visible = !an;
			clearButton.visible = !an;
		}
		
	}
	
	
	public function get showProgress (): Boolean {
		return _showProgress;
	}
	
	public function set showProgress (p: Boolean): Void {
		_showProgress = p;
		
		if (button && progressBar) {
			button.visible = !showProgress;
			clearButton.visible = !showProgress;
			infoLabelControl.visible = !showProgress;
			progressBar.visible = showProgress;
		}
	}
	
	public function get infoLabel (): String {
		return _infoLabel;
	}
	
	public function set infoLabel (s: String): Void {
		_infoLabel = s;
		
		if (infoLabelControl) {
			infoLabelControl.text = s;
		}
	}
	
	/**
	 * Creates a new filter contro and adds it to this query builder.
	 * 
	 * @return The newly created filter control.
	 */
	function addFilter (): Filter {
		
		if (!filterIndex) {
			filterIndex = 1;
		}
		
		var instanceName:String = 'filter' + (filterIndex ++);
		var filter:Filter = Filter (this.createChild (gui.querybuilder.Filter, instanceName, { }));

		this.filterComponents.push (filter);
		
		// Bind the enter event and dispatch a search event when enter is pressed in a filter only if
		// the query builder is currently in a state where a search is possible (e.g. canSearch == true):
		filter.addEventListener ('enter', Delegate.create (this, function (): Void {
			if (this.canSearch) {
				this.dispatchEvent ({ type: 'search' });
			}
		}));
		

		// Update the layout, possibly adding scrollbars:		
		layoutFilters (true);
		
		return filter;
	}
	
	function removeFilter (filter: Filter): Void {
		
		var i: Number;
		
		for (i = 0; i < filterComponents.length; ++ i) {
			if (filterComponents[i] == filter) {
				filterComponents.splice (i, 1);
				break;
			}
		}
		
		for (i = 0; i < numChildren; ++ i) {
			if (getChildAt (i) == filter) {
				destroyChildAt (i);
				break;
			}
		}
		
		layoutFilters (true);
	}
	
	/**
	 * Reimplementation of destroyChildAt to fix a bug in the depth management of the original.
	 */
	function destroyChildAt (childIndex: Number): Void {
		if (!(childIndex >= 0 && childIndex < numChildren)) {
			return;
		}
		
		var childName: String = childNameBase + childIndex;
		var nChildren: Number = numChildren;
		
		destroyObject (childName);
		
		for (var i = childIndex; i < (nChildren - 1); ++ i) {
			var c = this[childNameBase + i] = this[childNameBase + (i + 1)];
			c.swapDepths (i + depth - nChildren);
		}
		
		delete this[childNameBase + (nChildren - 1)];
		-- depth;
	}
	
	public function getFilters (filter: Function): Array {
		
		if (!filter) {
			return filterComponents;
		}
		
		var result: Array = [ ];
		var i: Number;
		
		for (i = 0; i < filterComponents.length; ++ i) {
			var f: Filter = filterComponents[i];
			if (filter (f)) {
				result.push (f);
			}
		}
		
		return result;
	}
	
	function init (): Void {
		super.init ();

		//_global.flamingo.tracer ('QueryBuilder::init');
		
		filterComponents = [ ];	
	}
	
	function createChildren (): Void {
		//_global.flamingo.tracer ('QueryBuilder::createChildren');	
		super.createChildren ();
		
		createUI ();
		bindUI ();
		syncUI ();
	}
	
	private function createUI (): Void {
		//this.setSize (400, 400);
		//this.opaqueBackground = 0xFF0000;
		//this.createChild (mx.controls.TextArea, "textarea", {});
		
		// This is required for comboboxes of child components to function properly, otherwise the
		// combobox popup will not be shown:
		//this._lockroot = true;
		
		button = Button (this.createChild (
				mx.controls.Button, 
				"searchButton", 
				{
					label: 'search',
					enabled: false
				}
			));
		clearButton = Button (this.createChild (
				mx.controls.Button,
				"clearButton",
				{
					label: 'clear',
					enabled: true
				}
			));
			
		// Create a progressbar that will be displayed instead of the search button when a search is in progress:
		progressBar = ProgressBar (this.createChild (mx.controls.ProgressBar, 'progressBar', { visible: false, mode: 'manual' }));
		progressBar.indeterminate = true;
		progressBar.label = undefined;
		
		// Create a label that will display an info message:
		infoLabelControl = Label (this.createChild (mx.controls.Label, 'infoLabelControl', { visible: false }));
	}
	
	private function bindUI (): Void {
		
		button.addEventListener ('click', Delegate.create (this, function (): Void {
			this.dispatchEvent ({ type: 'search' });
		}));
		clearButton.addEventListener ('click', Delegate.create (this, function (): Void {
			this.dispatchEvent ({ type: 'clear' });
		}));
	}

	private function syncUI (): Void {
		button.visible = !autoNavigate;
		button.enabled = canSearch;
		button.label = searchLabel;
		clearButton.label = clearLabel;
		clearButton.visible = !autoNavigate;
		button.visible = !showProgress;
		infoLabelControl.visible = !showProgress;
		progressBar.visible = showProgress;
		
		infoLabelControl.text = infoLabel;
	}
	
	function size (): Void {
		super.size ();
		
		//_global.flamingo.tracer ("QueryBuilder size: " + width + ", " + height);
		
		layoutFilters (true);
	}
	
	public function calculateContentHeight (): Number {
		
		var y:Number = PADDING;
		
		// _global.flamingo.tracer ("Calculating content height for: " + this._name);
		
		for (var i:Number = 0; i < filterComponents.length; ++ i) {
			var filter:Filter = filterComponents[i];
			var height:Number = Math.max (filter.minHeight, filter.height);
			
			y += height + PADDING;
			
			// _global.flamingo.tracer (" - Filter component " + filter._name + ": " + height);
		}
		
		var buttonY: Number = Math.max (y, this.height - PADDING - button.height);
		
		//_global.flamingo.tracer ("   Total content height for " + this._name + " " + (buttonY + button.height + PADDING));
		
		return buttonY + button.height + PADDING;
	}
	
	private function layoutFilters (updateSize: Boolean): Void {
		// _global.flamingo.tracer ("QueryBuilder::size: " + this.width + ", " + this.height + " (" + filters + ")");

		// Display or hide scroll bars depending on content size:		
		var childWidth: Number = this.width - 2 * PADDING;
		var buttonPaddingRight: Number = PADDING;
		if (updateSize) {
			var contentHeight: Number = calculateContentHeight ();
			if (contentHeight > this.height) {
				setScrollProperties (
						this.width,
						1,
						Math.max (contentHeight, this.height - 4),
						1,
						0,
						0
					);
				childWidth = this.width - 2 * PADDING - this.vScroller.width;
				buttonPaddingRight = PADDING + this.vScroller.width;
			} else {
				setScrollProperties (
						0,
						1,
						0,
						1,
						0,
						0
					);
			}
		}
		
		// Layout the filters:
		var y:Number = -this.vPosition + PADDING;
		var x:Number = PADDING;
		
		for (var i:Number = 0; i < filterComponents.length; ++ i) {
			var filter:Filter = filterComponents[i];
			var height:Number = Math.max (filter.minHeight, filter.height);
	
			filter.move (x, y);
			if (updateSize) {
				filter.setSize (childWidth, height);
			}
			
			// _global.flamingo.tracer ("  Moving filter: " + x + ", " + y + ", " + childWidth + ", " + height);
			
			y += height + PADDING;		
		}
		
		// Place the button at the bottom of the view, or below the last filter:
		var buttonWidth: Number = button.width + (clearButton ? clearButton.width + PADDING : 0);
		var buttonY: Number = Math.max (y, this.height - PADDING - button.height);
		var buttonX: Number = updateSize ? this.width - buttonPaddingRight - buttonWidth : button.x;
		button.move (buttonX, buttonY);
		if (clearButton) {
			clearButton.move (buttonX + button.width + PADDING, buttonY);
		}
		
		// Place the progress bar at the same height as the search button:
		progressBar.move (PADDING, buttonY + (button.height / 2 - progressBar.height / 2));
		if (updateSize) {
			progressBar.setSize (childWidth, progressBar.height);
		}
		
		// Place the info label next to the button:
		infoLabelControl.move (PADDING, buttonY);
		if (updateSize) {
			infoLabelControl.setSize (childWidth - button.width - PADDING, button.height);
		}
	}
	
	function onScroll (docObj: Object): Void {
		// super.onScroll (docObj);
		
		layoutFilters (false);
	}
}
