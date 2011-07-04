/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.search.FieldValueStore;
import coremodel.search.SearchField;

import mx.events.EventDispatcher;
import mx.utils.Delegate;
import mx.xpath.XPathAPI;

/**
 * Events:
 * - error: URL failed to load, or service returned an exception.
 * - valuesAvailable: New values have been loaded after a call to searchValues.
 * 
 */
class coremodel.search.XmlFieldValueStore extends FieldValueStore {
	
	private var _url: String;
	private var _labelPath: String;
	private var _valuePath: String;
	private var _sort: Boolean = true;
	 	
	public function get valuePath (): String {
		return _valuePath;
	}
	
	public function get labelPath (): String {
		return _labelPath;
	}
	
	public function XmlFieldValueStore(searchField : SearchField, node : XMLNode) {
		super(searchField, node);
	}
	
	public function searchValues (filters: Object): Void {
		
		var responseXML: XML = new XML ();
		
		responseXML.ignoreWhite = true;
		
		responseXML.onLoad = Delegate.create (this, function (success: Boolean): Void {
			
			// Dispatch an error
			if (!success) {
				// _global.flamingo.tracer ("Failed to load!");
				this.dispatchEvent ({ type: 'error', message: 'Unable to retrieve: ' + this._url });
				return;
			}
			
			this.parseValues (responseXML);
		});
		
		responseXML.load (_global.flamingo.correctUrl (_url));
	}
	
	private function parseValues (xml: XML): Void {
		var result: Array = [ ],
			i: Number,
			nValues: Number,
			values: Array,
			labels: Array;
		
		// _global.flamingo.tracer ("Parsing values: " + xml.status + ", " + xml.firstChild);
		
		var valuePath: String = this.valuePath,
			valueAttribute: String = null,
			labelPath: String = this.labelPath,
			labelAttribute: String = null,
			parts: Array;
			
		if (valuePath && valuePath.indexOf (':') > 0) {
			parts = valuePath.split (':');
			valuePath = parts[0];
			valueAttribute = parts[1];
		}
		if (labelPath && labelPath.indexOf (':') > 0) {
			parts = labelPath.split (':');
			labelPath = parts[0];
			labelAttribute = parts[1];
		} else {
			labelAttribute = valueAttribute;
		}
		
		// Request values and (possibly) labels:
		values = XPathAPI.selectNodeList(xml.firstChild, valuePath);
		if (labelPath) {
			labels = XPathAPI.selectNodeList (xml.firstChild, labelPath);
		} else {
			labels = values;
		}
		
		// _global.flamingo.tracer ("Result: " + values.length);
		
		// Construct the result array:
		nValues = Math.min (values.length, labels.length);
		for (i = 0; i < nValues; ++ i) {
			result.push ({ label: getNodeValue (labels[i], labelAttribute), value: getNodeValue (values[i], valueAttribute) });
			// _global.flamingo.tracer (" - " + getNodeValue (labels[i]) + " = " + getNodeValue (values[i]));
		}
		
		this.dispatchEvent ({ type: 'valuesAvailable', values: result });
	}
	
	private function getNodeValue (node: XMLNode, attribute: String): String {
		if (!node) {
			return '';
		}
		
		if (attribute) {
			return node.attributes[attribute] || '';
		}
		
		if (node.nodeType != 1) {
			return node.nodeValue;
		}
		
		var result: String = '',
			i: Number;
			
		for (i = 0; i < node.childNodes.length; ++ i) {
			if (node.childNodes[i].nodeType != 3) {
				continue;
			}
			
			result += node.childNodes[i].nodeValue;
		}
		
		return result;
	}
	
    function setAttribute (name:String, value:String): Void {
    	switch (name.toLowerCase ()) {
    	case 'url':
    		_url = value;
    		break;
    	case 'labelpath':
    		_labelPath = value;
    		break;
    	case 'valuepath':
    		_valuePath = value;
    		break;
    	case 'sort':
    		_sort = value.toLowerCase () == 'true';
    		break;
		default:
    		throw new Error ("Unknown field value store attribute: " + name);
    	}
    }
}
