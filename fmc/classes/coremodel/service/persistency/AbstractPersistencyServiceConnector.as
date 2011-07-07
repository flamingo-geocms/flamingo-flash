/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
 
class coremodel.service.persistency.AbstractPersistencyServiceConnector {
	
	private var	_applicationIdentifier: String;
	
	public function get applicationIdentifier (): String {
		return _applicationIdentifier;
	}
	
	public function AbstractPersistencyServiceConnector (applicationIdentifier: String) {
		_applicationIdentifier = applicationIdentifier;
	}

	public function store (document: XML, documentIdentifier: String, callback: Function): Void {
	}
	
	public function retrieve (documentIdentifier: String): Void {
	}
}
