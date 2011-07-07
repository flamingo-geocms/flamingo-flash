/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.LegendContainer;
import gui.legend.GroupLegendItem;
import gui.legend.LegendItem;
import gui.legend.SymbolLegendItem;
import gui.legend.TextLegendItem;
import gui.legend.RulerLegendItem;

interface gui.legend.LegendVisitor {
	
	public function visitGroup (item: GroupLegendItem, context: Object): Void;
	public function visitContainer (item: LegendContainer, context: Object): Void;
	public function visitItem (item: LegendItem, context: Object): Void;
	public function visitSymbol (item: SymbolLegendItem, context: Object): Void;
	public function visitText (item: TextLegendItem, context: Object): Void;
	public function visitRuler (ruler: RulerLegendItem, context: Object): Void;
}
