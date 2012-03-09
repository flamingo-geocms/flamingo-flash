/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLegendItem;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendVisitor;

class gui.legend.RulerLegendItem extends AbstractLegendItem {
	
	public function RulerLegendItem (parent: AbstractGroupLegendItem) {
		super (parent);
	}
	
	public function visit (visitor: LegendVisitor, context: Object): Void {
		visitor.visitRuler (this, context);
	}
}
