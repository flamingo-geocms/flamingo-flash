/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
 /**
  * coremodel.service.persistency.AbstractPersistencyServiceConnector
  */
class coremodel.service.persistency.AbstractPersistencyServiceConnector {
	
	private var	_applicationIdentifier: String;
	/**
	 * getter applicationIdentifier
	 */
	public function get applicationIdentifier (): String {
		return _applicationIdentifier;
	}
	/**
	 * AbstractPersistencyServiceConnector
	 * @param	applicationIdentifier
	 */
	public function AbstractPersistencyServiceConnector (applicationIdentifier: String) {
		_applicationIdentifier = applicationIdentifier;
	}
    /**
     * store stub
     * @param	document
     * @param	documentIdentifier
     * @param	callback
     */
	public function store (document: XML, documentIdentifier: String, callback: Function): Void {
	}
	/**
	 * retrieve stub
	 * @param	documentIdentifier
	 */
	public function retrieve (documentIdentifier: String): Void {
	}
}
