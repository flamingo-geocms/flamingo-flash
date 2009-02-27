import roo.Envelope;
import roo.FeatureType;
import roo.WhereClause;
import roo.XMLTools;
import roo.WFSFeature;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/

class roo.WFSConnector {

	static private var instances:Object = new Object(); // Associative array;
    
    static function getInstance(name, url):WFSConnector {
        if (url == null) {
            return;
        }
        
        if (instances[name] == null) {
            instances[name] = new WFSConnector(url);
        }
        return instances[name];
    }
    
    private var url:String = null;
    
    private function WFSConnector(url:String) {
        this.url = url;
    }
    
    function getURL():String {
        return url;
    }
    
    function performGetFeature(featureType:FeatureType, extent:Envelope, whereClauses:Array, additionalFilter:String, hitsOnly:Boolean, actionEventListener:Object):Void {
        var numFilterElements:Number = ((extent == null)? 0: 1) + ((whereClauses == null)? 0: whereClauses.length) + ((additionalFilter.length > 0)? 1: 0);
        var featureTypeName:String = featureType.getName();
        var requestString:String = "";
        
        requestString += "<wfs:GetFeature service=\"WFS\" version=\"1.1.0\"";
        //_global.flamingo.tracer("performGetFeature = " + featureType);
        if (hitsOnly) {
            requestString += " resultType=\"hits\"";
        }
        requestString += "\n";
        requestString += "  xmlns:wfs=\"http://www.opengis.net/wfs\"\n";
        requestString += "  xmlns:ogc=\"http://www.opengis.net/ogc\"\n";
        requestString += "  xmlns:gml=\"http://www.opengis.net/gml\"\n";
        requestString += "  xmlns:" + featureType.getNamespace() + ">\n";
        requestString += "  <wfs:Query typeName=\"" + featureTypeName + "\">\n";
        
        if (numFilterElements > 0) {
            requestString += "    <ogc:Filter>\n";
            if (numFilterElements > 1) {
                requestString += "      <ogc:And>\n";
            }
            if (extent != null) {
                requestString += "        <ogc:BBOX>\n";
                requestString += "          <ogc:PropertyName>" + featureType.getGeometryPropertyName() + "</ogc:PropertyName>\n";
                requestString += "          <gml:Box srsName=\"urn:ogc:def:crs:EPSG::28992\">\n";
                requestString += "              <gml:coordinates>" + extent.getMinX() + "," + extent.getMinY() + "\n";
                requestString += "                  " + extent.getMaxX() + "," + extent.getMaxY() + "</gml:coordinates>\n";
                requestString += "          </gml:Box>\n";
                requestString += "        </ogc:BBOX>\n";
            }
            if ((whereClauses != null) && (whereClauses.length > 0)) {
                var whereClause:WhereClause = null;
                for (var i:String in whereClauses) {
                    whereClause = WhereClause(whereClauses[i]);
                    if (whereClause.getOperator() == WhereClause.EQUALS) {
                        requestString += "        <ogc:PropertyIsLike wildCard=\"*\" singleChar=\"#\" escapeChar=\"!\">\n";
                        requestString += "          <ogc:PropertyName>" + whereClause.getColumnName() + "</ogc:PropertyName>\n";
                        requestString += "          <ogc:Literal>" + whereClause.getValue() + "</ogc:Literal>\n";
                        requestString += "        </ogc:PropertyIsLike>\n";
                    }
                }
            }
            if (additionalFilter.length > 0) {
                requestString += additionalFilter;
            }
            if (numFilterElements > 1) {
                requestString += "      </ogc:And>\n";
            }
            requestString += "    </ogc:Filter>\n";
        }
        requestString += "  </wfs:Query>\n";
        requestString += "</wfs:GetFeature>\n";
        
        request(url, requestString, processGetFeature, featureType, actionEventListener, 0);
    }
    
    function request(url:String, requestString:String, processMethod:Function, featureType:FeatureType, actionEventListener:Object, tryIndex:Number):Void {
        var env:WFSConnector = this;
        //_global.flamingo.tracer("WFSConnector.request, url = " + url + " featureType = " + featureType + " requestString = " + requestString);
        var responseXML:XML = new XML();
        responseXML.ignoreWhite = true;
        responseXML.onLoad = function(successful:Boolean):Void {
            if (!successful) {
                tryIndex++;
                if (tryIndex < 3) {
                    _global.flamingo.tracer("Retrying for " +  tryIndex + " time: " + url);
                    env.request(url, requestString, processMethod, featureType, actionEventListener, tryIndex);
                } else {
                    _global.flamingo.tracer("Giving up; no more tries.");
                }
            } else {
                var errorNode:XMLNode = XMLTools.getChild("OGCWebServiceException", this);
                if (errorNode != null) {
                    trace("Error in WFS server: " + XMLTools.getStringValue("Message", XMLTools.getChild("Exception", errorNode)));
                } else {
                    processMethod.call(env, this, featureType, actionEventListener);
                }
            }
        }
        
        if (requestString == null) {
            responseXML.load(url);
        } else {
            var requestXML:XML = new XML(requestString);
            requestXML.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
            requestXML.addRequestHeader("Content-Type", "text/xml");
            requestXML.addRequestHeader("Accept", "text/xml");
            requestXML.sendAndLoad(url, responseXML);
        }
    }
    
    function processGetFeature(responseXML:XML, featureType:FeatureType, actionEventListener:Object):Void {
        var numFeatures:Number = Number(responseXML.firstChild.attributes["numberOfFeatures"]);
        
        var featureNodes:Array = XMLTools.getChildNodes("gml:featureMember", responseXML.firstChild);
        var wfsFeatures:Array = new Array();
        var wfsFeature:WFSFeature = null;
        for (var i:Number = 0; i <featureNodes.length; i++) {
            wfsFeature = parseGetFeatureResponse(XMLNode(featureNodes[i]), featureType);
            wfsFeatures.push(wfsFeature);
        }
        //_global.flamingo.tracer("processGetFeature, actionEventListener = " + actionEventListener + " numFeatures = " + numFeatures);
        if (actionEventListener != null) {
            var actionEvent:Object = new Object();
            actionEvent["numFeatures"] = numFeatures;
            actionEvent["wfsFeatures"] = wfsFeatures;
            actionEventListener.onActionEvent(actionEvent);
        }
    }
    
    private function parseGetFeatureResponse(featureNode:XMLNode, featureType:FeatureType):WFSFeature {
        featureNode = featureNode.firstChild;
        
        var id:String = featureNode.attributes["gml:id"];
        var values:Object = new Object(); // Associative array.
        var columnNode:XMLNode = null;
        var columnName:String = null;
        for (var i:String in featureNode.childNodes) {
            columnNode = XMLNode(featureNode.childNodes[i]);
            columnName = columnNode.nodeName;
            columnNode = columnNode.firstChild;
            if (columnNode == null) {
                values[columnName] = "";
            } else if (columnNode.nodeType == 3) { // Text node.
                values[columnName] = columnNode.nodeValue;
            } else { // XML element. Assumes that this will contain a geometry gml.
                values[columnName] = ""; // GMLParser.parseGML(columnNode);
            }
        }
        
        return new WFSFeature(id, values);
    }
    
    function toString():String {
        return "WFSConnector(" + url + ")";
    }
    
}
