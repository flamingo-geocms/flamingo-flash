/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/

 /**
  * core.PersistableComponent
  */
 interface core.PersistableComponent {
	/**
	 * persistState
	 * @param	document
	 * @param	node
	 */
	public function persistState (document: XML, node: XMLNode): Void;
	/**
	 * restoreState
	 * @param	node
	 */
	public function restoreState (node: XMLNode): Void;
}
