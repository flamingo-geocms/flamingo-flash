/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLegendItem;
import gui.legend.AbstractGroupLegendItem;

class gui.legend.AbstractLabelLegendItem extends AbstractLegendItem {
	private var _label: String;
	private var _styleId: String;
	private var _language: Object = null;
	
	public function get label (): String {
		if (!_label && language['label']) {
			var lang: String = _global.flamingo.getLanguage ();
			return language['label'][lang];
		}
		
		return _label;
	}
	
	public function set label (label: String) {
		_label = label;
	}
	
	public function get styleId (): String {
		return _styleId;
	}
	
	public function set styleId (styleId: String): Void {
		_styleId = styleId;
	}
	
	public function get language (): Object {
		return _language;
	}
	
	public function set language (language: Object): Void {
		_language = language;
	}
	
	public function AbstractLabelLegendItem (parent: AbstractGroupLegendItem) {
		super (parent);
	}
}
