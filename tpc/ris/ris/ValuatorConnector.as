
/**
 * @author velsll
 */
 

import ris.BridgisConnector;

class ris.ValuatorConnector extends BridgisConnector{
	private var xmlResponse:XML = null;
	private var reportUrl:String = "";
	//private var areasUrl:String = "";
	private var account;
	
	var xmlheader:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
	
	function getAvailableYears(){
_global.flamingo.tracer("getAvailableYears");
		var soapReqStr:String = '<geow:GetAvailableYears>';
      	soapReqStr += getSoapUserString();
     	soapReqStr+='</geow:GetAvailableYears>';
		request(soapReqStr);
	}
	
	function getAvailablePublications(){
		_global.flamingo.tracer("getAvailablePublications");
		var soapReqStr:String = '<geow:GetAvailablePublications>';
      	soapReqStr += getSoapUserString();
     	soapReqStr+='</geow:GetAvailablePublications>';
		request(soapReqStr);
	}
	

	function retrieveWKT(sWKTArea:String,sWorths:Array,iYears:Array,sPublications:Array){
		var soapReqStr:String = '<geow:RetrieveWKT>';
		soapReqStr += getSoapUserString();
		soapReqStr += '<geow:sWKTArea>' + sWKTArea + '</geow:sWKTArea>';
		soapReqStr += getNodesString('geow','iYears', iYears, 'int');
		soapReqStr += getNodesString('geow','sWorth', sWorths, 'string');
		soapReqStr += getNodesString('geow','sPublication', sPublications, 'string');
		request(soapReqStr);
	}

}
