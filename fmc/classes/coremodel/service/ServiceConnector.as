/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/

import coremodel.service.*;

import coremodel.service.wfs.WFSConnector;
import event.ActionEvent;
import event.ActionEventListener;
import geometrymodel.Geometry;
import tools.XMLTools;

class coremodel.service.ServiceConnector {
    
    static private var instances:Object = new Object(); // Associative array;
    
    static function getInstance(url):ServiceConnector {
        if (url == null) {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nNo url given.");
            return;
        }
        if (url.indexOf("::") == -1) {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nThe given url does not contain \"::\". Required format example: \"wfs::http://localhost:8080/\"");
            return;
        }
        
        var connectorType:String = url.split("::")[0];
        if (connectorType != "wfs") {
            _global.flamingo.tracer("Exception in ServiceConnector.getInstance()\nThe given connector type \"" + connectorType + "\" is not supported.");
            return;
        }
        
        url = url.split("::")[1];
        if (instances[url] == null) {
            if (connectorType == "wfs") {
                instances[url] = new WFSConnector(url);
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
    function setServiceVersion(serviceVersion):Void {}
	
	function setSrsName(srsName):Void {}

    function performDescribeFeatureType(featureTypeName:String, actionEventListener:ActionEventListener):Void { }
    
    function performGetFeature(serviceLayer:ServiceLayer, extent:Geometry, whereClauses:Array, notWhereClause:WhereClause, hitsOnly:Boolean, actionEventListener:ActionEventListener):Void { }
    
    function performTransaction(transaction:Transaction, actionEventListener:ActionEventListener):Void { }
    
    function request(url:String, requestString:String, processMethod:Function, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void {
        //_global.flamingo.tracer(url + "\n" + requestString);
		
		var env:ServiceConnector = this;
        
        var responseXML:XML = new XML();
        responseXML.ignoreWhite = true;
        responseXML.onLoad = function(successful:Boolean):Void {
            if (!successful) {
                exceptionMessage = "Exception in ServiceConnector.request(" + url + ")\nCould not load the resource.";
                _global.flamingo.tracer("Exception in ServiceConnector.request(" + url + ")\nCould not load the resource.");
                
                var crossDomainURL = url.substring(0, url.indexOf("/", url.indexOf("//") + 2)) + "/crossdomain.xml";
                if (crossDomainURL != url) {
                    var crossDomainXML:XML = new XML();
                    crossDomainXML.ignoreWhite = true;
                    crossDomainXML.onLoad = function(successful:Boolean):Void {
                        if (!successful) {
                            _global.flamingo.tracer("Could not load the crossdomain file, " + crossDomainURL + ", either.");
                        } else {
                            _global.flamingo.tracer("There is a crossdomain file, " + crossDomainURL + ", though. Its status is: " + this.status + ".");
                        }
                    };
                    crossDomainXML.load(crossDomainURL);
                }
            } else {
                var exceptionNode:XMLNode = null;
                var exceptionMessage:String = null;
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
    
    function processDescribeFeatureType(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void { }
    
    function processGetFeature(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener, contextObject:Object):Void { }
    
    function processTransaction(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void { }
    
}
