
/**
 * @author velsll
 */
 

import ris.BridgisConnectorListener;
import ris.BridgisAccount;
import ris.BridgisConnector;

class ris.PopulatorConnector extends BridgisConnector{
	private var xmlResponse:XML = null;
	private var reportUrl:String = "";
	//private var areasUrl:String = "";
	private var bridgisConnectorListeners:Array = new Array();
	private var account;
	
	var xmlheader:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";

		

    
    function setReportUrl(url:String):Void{
		this.reportUrl=url;
	}
	
    function retrieveWKT(sWKTArea:String,eAnalyzeTypes:Array,sActivityList:Array,sUserName:String,sUsage:String){
		var soapReqStr:String = '<geow:RetrieveWKT>';
		soapReqStr += getAdditionalInformation("populatoranalyze.asmx",sUserName,sUsage);
		soapReqStr += getSoapUserString();
		soapReqStr += '<geow:sWKTArea>' + sWKTArea + '</geow:sWKTArea>';
		soapReqStr += getNodesString('geow','eAnalyzeTypes', eAnalyzeTypes, 'AnalyseType');
		soapReqStr += getNodesString('geow','sActivityList', sActivityList, 'string');
		request(soapReqStr);
	}
	
	

}
