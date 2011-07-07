/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
 import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendVisitor;

class gui.legend.GroupLegendItem extends AbstractGroupLegendItem {
	
	private var _collapsed: Boolean;
	private var _hideAllButOne: Boolean;
	private var _mouseOverStyleId: String;
	
	public function get collapsed (): Boolean {
		return _collapsed;
	}
	
	public function set collapsed (collapsed: Boolean): Void {
		_collapsed = collapsed;
	}
	
	public function get hideAllButOne (): Boolean {
		return _hideAllButOne;
	}
	
	public function set hideAllButOne (hideAllButOne: Boolean): Void {
		_hideAllButOne = hideAllButOne;
	}
	
	public function get mouseOverStyleId (): String {
		return _mouseOverStyleId;
	}
	
	public function set mouseOverStyleId (mouseOverStyleId: String): Void {
		_mouseOverStyleId = mouseOverStyleId;
	}

    public function get isGroupOpen (): Boolean {
        return !collapsed;
    }
    
	public function GroupLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode) {
		super (parent, configuration);
	}
	
	public function visit (visitor: LegendVisitor, context: Object): Void {
		visitor.visitGroup (this, context);
	}
}
