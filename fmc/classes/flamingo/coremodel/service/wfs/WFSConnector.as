/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.coremodel.service.wfs.*;

import flamingo.coremodel.service.*;
import flamingo.event.ActionEvent;
import flamingo.event.ActionEventListener;
import flamingo.gismodel.Property;
import flamingo.gismodel.Feature;
import flamingo.geometrymodel.Envelope;
import flamingo.tools.XMLTools;

class flamingo.coremodel.service.wfs.WFSConnector extends ServiceConnector {
    
    function WFSConnector(url:String) {
        super(url);
    }
    
    function performDescribeFeatureType(featureTypeName:String, actionEventListener:ActionEventListener):Void {
        var requestString:String = "";
        
        requestString += "<wfs:DescribeFeatureType service=\"WFS\" version=\"1.1.0\"\n";
        requestString += "    xmlns:wfs=\"http://www.opengis.net/wfs\"\n";
        requestString += "    xmlns:ogc=\"http://www.opengis.net/ogc\"\n";
        requestString += "    xmlns:gml=\"http://www.opengis.net/gml\"\n";
        requestString += "    xmlns:app=\"http://www.deegree.org/app\">\n";
        requestString += "    <wfs:TypeName>" + featureTypeName + "</wfs:TypeName>\n";
        requestString += "</wfs:DescribeFeatureType>\n";
        request(url, requestString, processDescribeFeatureType, null, actionEventListener, 0);
    }
    
    function performGetFeature(serviceLayer:ServiceLayer, extent:Envelope, whereClauses:Array, notWhereClause:WhereClause, hitsOnly:Boolean, actionEventListener:ActionEventListener):Void {
		var numFilterElements:Number = ((extent == null)? 0: 1) + ((whereClauses == null)? 0: whereClauses.length) + ((notWhereClause == null)? 0: 1);
        var featureTypeName:String = serviceLayer.getName();
        var requestString:String = "";
        
        requestString += "<wfs:GetFeature service=\"WFS\" version=\"1.1.0\"";
        
        if (hitsOnly) {
            requestString += " resultType=\"hits\"";
        }
        requestString += "\n";
        requestString += "  xmlns:wfs=\"http://www.opengis.net/wfs\"\n";
        requestString += "  xmlns:ogc=\"http://www.opengis.net/ogc\"\n";
        requestString += "  xmlns:gml=\"http://www.opengis.net/gml\"\n";
        requestString += "  xmlns:" + serviceLayer.getNamespace() + ">\n";
        requestString += "  <wfs:Query typeName=\"" + featureTypeName + "\">\n";
        
        if (numFilterElements > 0) {
            requestString += "    <ogc:Filter>\n";
            if (numFilterElements > 1) {
                requestString += "      <ogc:And>\n";
            }
            if (extent != null) {
                requestString += "        <ogc:BBOX>\n";
                requestString += "          <ogc:PropertyName>" + serviceLayer.getDefaultGeometryProperty().getName() + "</ogc:PropertyName>\n";
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
                        requestString += "          <ogc:PropertyName>" + whereClause.getPropertyName() + "</ogc:PropertyName>\n";
                        requestString += "          <ogc:Literal>" + whereClause.getValue() + "</ogc:Literal>\n";
                        requestString += "        </ogc:PropertyIsLike>\n";
                    }
                }
            }
            if (notWhereClause != null) {
                requestString += "        <ogc:Not>\n";
                requestString += "          <ogc:PropertyIsEqualTo>\n";
                requestString += "            <ogc:PropertyName>" + "/" + featureTypeName + "/" + notWhereClause.getPropertyName() + "</ogc:PropertyName>\n";
                requestString += "            <ogc:Literal>" + notWhereClause.getValue() + "</ogc:Literal>\n";
                requestString += "          </ogc:PropertyIsEqualTo>\n";
                requestString += "        </ogc:Not>\n";
            }
            if (numFilterElements > 1) {
                requestString += "      </ogc:And>\n";
            }
            requestString += "    </ogc:Filter>\n";
        }
        requestString += "  </wfs:Query>\n";
        requestString += "</wfs:GetFeature>\n";
        //_global.flamingo.tracer(url + "\n" + requestString);
        request(url, requestString, processGetFeature, serviceLayer, actionEventListener, 0);
    }
    
    function performTransaction(transaction:Transaction, actionEventListener:ActionEventListener):Void {
        if (transaction == null) {
            _global.flamingo.tracer("Exception in WFSConnector.performTransaction()\nNo transaction given.");
            return;
        }
        var operations:Array = transaction.getOperations();
        if (operations.length == 0) {
            _global.flamingo.tracer("Exception in WFSConnector.performTransaction()\nGiven transaction contains no operations.");
            return;
        }
        
        var requestString:String = "";
        requestString += "<wfs:Transaction service=\"WFS\" version=\"1.1.0\"\n";
        requestString += "  xmlns:wfs=\"http://www.opengis.net/wfs\"\n";
        requestString += "  xmlns:ogc=\"http://www.opengis.net/ogc\"\n";
        requestString += "  xmlns:gml=\"http://www.opengis.net/gml\">\n";
        
        for (var i:Number = 0; i < operations.length; i++) {
            requestString += Operation(operations[i]).toXMLString();
        }
        requestString += "</wfs:Transaction>\n";
        
        request(url, requestString, processTransaction, null, actionEventListener, 0);
    }
    
    function processDescribeFeatureType(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void {
		var serviceLayer:ServiceLayer = new FeatureType(responseXML.firstChild);
        var actionEvent:ActionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
        actionEvent["serviceLayer"] = serviceLayer;
        actionEventListener.onActionEvent(actionEvent);
        var id:String =  _global.flamingo.getComponentID(this);
            if(id != null){
        		_global.flamingo.raiseEvent(this,"onActionEvent",id + "," + actionEvent.toString());
            }
    }
    
    function processGetFeature(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void {
		var numFeatures:Number = Number(responseXML.firstChild.attributes["numberOfFeatures"]);
        
        var featureNodes:Array = XMLTools.getChildNodes("gml:featureMember", responseXML.firstChild);
        var features:Array = new Array();
        for (var i:Number = 0; i < featureNodes.length; i++) {
            features.push(new WFSFeature(XMLNode(featureNodes[i]).firstChild, null, null, serviceLayer));
        }
        
        var actionEvent:ActionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
        actionEvent["numFeatures"] = numFeatures;
        actionEvent["features"] = features;
        actionEventListener.onActionEvent(actionEvent);
        _global.flamingo.raiseEvent(this,"onActionEvent",this + actionEvent.toString());
    }
    
    function processTransaction(responseXML:XML, serviceLayer:ServiceLayer, actionEventListener:ActionEventListener):Void {
        var transactionResponse:TransactionResponse = new TransactionResponse(responseXML.firstChild);
        
        var actionEvent:ActionEvent = new ActionEvent(this, "ServiceConnector", ActionEvent.LOAD);
        actionEvent["transactionResponse"] = transactionResponse;
        actionEventListener.onActionEvent(actionEvent);
        _global.flamingo.raiseEvent(this,"onActionEvent",this + actionEvent.toString());
    }
    
    function toString():String {
        return "WFSConnector(" + url + ")";
    }
    
}
