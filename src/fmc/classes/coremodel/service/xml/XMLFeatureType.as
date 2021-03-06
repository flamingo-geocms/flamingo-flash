/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.service.*;
import coremodel.service.xml.*;
import mx.xpath.XPathAPI;
import tools.XMLSchema;

/**
 * coremodel.service.xml.XMLFeatureType
 */
class coremodel.service.xml.XMLFeatureType extends ServiceLayer {
	
	private var _connector: XMLConnector;
	private var _namespace: String = "app=\"http://www.degree.org/app\"";
	/**
	 * constructor
	 * @param	connector
	 * @param	name
	 * @param	properties
	 */
	public function XMLFeatureType(connector: XMLConnector, name: String, properties: Array) {
		_connector = connector;
		this.name = name;
		
		if (properties) {
			setProperties (properties);
		}
	}
	
	/**
	 * Sets properties for this feature type from an array containing objects that have
	 * the following keys:
	 * - name (string): The name of the property.
	 * - type (string): The type of the property.
	 * - path (string): XPath expression to extract the property from the XML document.
	 * 
	 * @param	properties
	 */
	public function setProperties (properties: Array): Void {
		var i: Number,
			p: Object,
			name: String,
			type: String;
			
		serviceProperties = [ ];
		geometryProperties = [ ];
		
		for (i = 0; i < properties.length; ++ i) {
			p = properties[i];
			addProperty (p.name, p.type, p.path);
		}
	}
	/**
	 * addProperty
	 * @param	name
	 * @param	type
	 * @param	path
	 */
	public function addProperty (name: String, type: String, path: String): Void {
		var property: XMLProperty = new XMLProperty (name, type, path);
		
		serviceProperties.push (property);
		if (type == "gml:GeometryPropertyType" || type == "gml:MultiSurfacePropertyType") {
			geometryProperties.push (property);
		}
	}
	/**
	 * getNamespace
	 * @return
	 */
	function getNamespace():String {
        return _namespace;
    }
    /**
     * getServiceFeatureFactory
     * @return
     */
    function getServiceFeatureFactory(): ServiceFeatureFactory {
        return null;//new XMLFeatureFactory ();
    }
}
