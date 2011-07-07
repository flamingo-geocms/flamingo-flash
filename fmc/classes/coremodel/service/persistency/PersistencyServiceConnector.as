/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.utils.Delegate;

import coremodel.service.persistency.AbstractPersistencyServiceConnector;

class coremodel.service.persistency.PersistencyServiceConnector extends AbstractPersistencyServiceConnector {
	
	public static var STATUS_SUCCESS: String = 'success';
	public static var STATUS_INVALID_CODE: String = 'invalid_code';
	
	private var _baseURL: String;
	
	public function get baseURL (): String {
		return _baseURL;
	}
	
	public function PersistencyServiceConnector (baseURL: String, applicationIdentifier: String) {
		super (applicationIdentifier);
		
		_baseURL = baseURL;
	}

	public function persistDocument (document: XML, documentIdentifier: String, callback: Function): Void {
		var responseDocument: XML = new XML (),
			httpStatus: Number = 0;
		
		responseDocument.onData = Delegate.create (this, function (data: String): Void {
			if (data == undefined) {
				callback (STATUS_INVALID_CODE, documentIdentifier);
			} else {
				callback (STATUS_SUCCESS, data);
			}
		});
		
		var parameters: Object = {
			appId: applicationIdentifier
		};
		if (documentIdentifier && documentIdentifier.length > 0) {
			parameters['code'] = documentIdentifier;
		}
		
		document.contentType = "text/xml";
		document.sendAndLoad (buildURL ('persist', parameters), responseDocument);
	}
	
	public function getDocument (documentIdentifier: String, callback: Function): Void {
		var responseDocument: XML = new XML ();
		responseDocument.ignoreWhite = true;
		responseDocument.onLoad = Delegate.create (this, function (success: Boolean): Void {
			if (success) {
				callback (STATUS_SUCCESS, responseDocument);
			} else {
				callback (STATUS_INVALID_CODE, null);
			}
		});

		var url: String = buildURL ('get', { appId: applicationIdentifier, code: documentIdentifier });
		responseDocument.load (url);
	}
	
	private function buildURL (action: String, parameters: Object): String {
		var parameterString: String = "";
		
		for (var i: String in parameters) {
			if (parameterString != "") {
				parameterString += "&";
			}
			
			parameterString += i + "=";
			
			parameterString += escape (parameters[i]);
		}
		
		var url: String = baseURL;
		if (url.substr (-1) != '/') {
			url += '/';
		}
		
		return url + action + "?" + parameterString;
	}
}
