/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
interface core.PersistableComponent {
	
	public function persistState (document: XML, node: XMLNode): Void;
	public function restoreState (node: XMLNode): Void;
}
