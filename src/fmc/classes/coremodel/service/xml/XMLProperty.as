/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.service.ServiceProperty;

class coremodel.service.xml.XMLProperty extends ServiceProperty {
	
	private var _xpathExpression: String;
	
	public function get xpathExpression (): String {
		return _xpathExpression;
	}
	
	public function getXPathExpression (): String {
		return _xpathExpression;
	}
	
	public function XMLProperty(name: String, type: String, xpathExpression: String) {
		this.name = name;
		this.type = type;
		_xpathExpression = xpathExpression;
	}
}
