/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.service.ServiceProperty;

/**
 * coremodel.service.xml.XMLProperty
 */
class coremodel.service.xml.XMLProperty extends ServiceProperty {
	
	private var _xpathExpression: String;
	/**
	 * getter xpathExpression
	 */
	public function get xpathExpression (): String {
		return _xpathExpression;
	}
	/**
	 * getXPathExpression
	 * @return
	 */
	public function getXPathExpression (): String {
		return _xpathExpression;
	}
	/**
	 * XMLProperty
	 * @param	name
	 * @param	type
	 * @param	xpathExpression
	 */
	public function XMLProperty(name: String, type: String, xpathExpression: String) {
		this.name = name;
		this.type = type;
		_xpathExpression = xpathExpression;
	}
}
