/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

import coremodel.service.wfs.WFSConnector;
import coremodel.service.xml.XMLConnector;
import event.ActionEvent;
import event.ActionEventListener;
import geometrymodel.Geometry;
import tools.XMLTools;

/**
 * coremodel.service.ServiceConnector
 */
class coremodel.service.ServiceConnector {
    
    static private var instances:Object = new Object(); // Associative array;
    /**
     * getInstance
     * @param	url
     * @return
     */
    static function getInstance(url):ServiceConnector {
        if (url == null) {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nNo url given.");
            return null;
        }
        if (url.indexOf("::") == -1) {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nThe given url does not contain \"::\". Required format example: \"wfs::http://localhost:8080/\"");
            return null;
        }
        
        var connectorType:String = url.split("::")[0];
        if (connectorType != "wfs" && connectorType != 'xml') {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nThe given connector type \"" + connectorType + "\" is not supported.");
            return null;
        }
        
        url = url.split("::")[1];
        if (instances[url] == null) {
            if (connectorType == "wfs") {
                instances[url] = new WFSConnector(url);
            } else if (connectorType == "xml") {
            	instances[url] = new XMLConnector (url);
            }
        }
        return instances[url];
    }
    
    private var url:String = null;
    
    private function ServiceConnector(url:String) {
        this.url = url;
    }
    
    function getURL():String {
        return url;
    }
	/**
	 * stub
	 * @param	serviceVersion
	 */
    function setServiceVersion(serviceVersion):Void {}
	/**
	 * stub
	 * @param	srsName
	 */
	function setSrsName(srsName):Void {}
    /**
     * stub
     * @param	featureTypeName
     * @param	actionEventListener
     */
    function performDescribeFeatureType(featureTypeName:String, actionEventListener:ActionEventListener):Void { }
    /**
     * stub
     * @param	serviceLayer
     * @param	extent
     * @param	whereClauses
     * @param	notWhereClause
     * @param	hitsOnly
     * @param	actionEventListener
     */
    function performGetFeature(serviceLayer:ServiceLayer, extent:Geometry, whereClauses:Array, notWhereClause:WhereClause, hitsOnly:Boolean, actionEventListener:ActionEventListener):Void { }
    /**
     * stub
     * @param	transaction
     * @param	actionEventListener
     */
    function performTransaction(transaction:Transaction, actionEventListener:ActionEventListener):Void { }
    /**
     * request
     * @param	url
     * @param	requestString
     * @param	processMethod
     * @param	serviceLayer
     * @param	actionEventListener
     * @param	contextObject
     */
    function request(url:String, requestString:String, processMethod:Function, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void {
        //_global.flamingo.tracer(url + "\n" + requestString);
		
		var env:ServiceConnector = this;
        var responseXML:XML = new XML();
        responseXML.ignoreWhite = true;
        responseXML.onLoad = function(successful:Boolean):Void {
			var exceptionMessage:String = null;
            if (!successful) {
                exceptionMessage = "Exception in ServiceConnector.request(" + url + ")\nCould not load the resource.";
                _global.flamingo.tracer("Exception in ServiceConnector.request(" + url + ")\nCould not load the resource.");
                
                var crossDomainURL = url.substring(0, url.indexOf("/", url.indexOf("//") + 2)) + "/crossdomain.xml";
                if (crossDomainURL != url) {
                    var crossDomainXML:XML = new XML();
                    crossDomainXML.ignoreWhite = true;
                    crossDomainXML.onLoad = function(successful2:Boolean):Void {
                        if (!successful2) {
                            _global.flamingo.tracer("Could not load the crossdomain file, " + crossDomainURL + ", either.");
                        } else {
                            _global.flamingo.tracer("There is a crossdomain file, " + crossDomainURL + ", though. Its status is: " + this.status + ".");
                        }
                    };
                    crossDomainXML.load(crossDomainURL);
                }
            } else {
                var exceptionNode:XMLNode = null;                
                exceptionNode = XMLTools.getChild("Exception", this.firstChild);
                if (exceptionNode != null) {
                    exceptionMessage = "Exception in ServiceConnector.request(" + url + ")\n" + exceptionNode.firstChild.firstChild.nodeValue;
                }
                exceptionNode = XMLTools.getChild("ServiceException", this.firstChild);
                if (exceptionNode != null) {
                    exceptionMessage = "Kan de bewerkingen niet opslaan, om een of meer van de volgende redenen:\n\n-verplicht veld niet ingevuld\n-tekst in numeriek veld ingevuld\n-te lange tekst ingevuld\n-geen unieke waarde in uniek veld ingevuld\n\n" + url + "\n\n" + exceptionNode.firstChild.nodeValue;
                }
            }
                
            if (actionEventListener != null) {
                if (exceptionMessage == null) {
                    processMethod.call(env, this, serviceLayer, actionEventListener, contextObject);
                } else {
                    var actionEvent:ActionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
                    actionEvent["exceptionMessage"] = exceptionMessage;
                    actionEventListener.onActionEvent(actionEvent);
                    var id:String =  _global.flamingo.getId(this);
            		if(id != null){
                    	_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
            		}
                }
            }
        }
        
        if (requestString == null) {
            responseXML.load(url);
        } else {
            var requestXML:XML = new XML(requestString);
            requestXML.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
            requestXML.addRequestHeader("Content-Type", "application/xml");
            requestXML.sendAndLoad(url, responseXML);
        }
    }
    /**
     * stub
     * @param	responseXML
     * @param	serviceLayer
     * @param	actionEventListener
     * @param	contextObject
     */
    function processDescribeFeatureType(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void { }
    /**
     * stub
     * @param	responseXML
     * @param	serviceLayer
     * @param	actionEventListener
     * @param	contextObject
     */
    function processGetFeature(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void { }
    /**
     * stub
     * @param	responseXML
     * @param	serviceLayer
     * @param	actionEventListener
     */
    function processTransaction(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void { }
    
}
