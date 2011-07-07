/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLabelLegendItem;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendVisitor;

class gui.legend.TextLegendItem extends AbstractLabelLegendItem {
	
	public function TextLegendItem (parent: AbstractGroupLegendItem) {
		super (parent);
	}
	
	public function visit (visitor: LegendVisitor, context: Object): Void {
		visitor.visitText (this, context);
	}
}
