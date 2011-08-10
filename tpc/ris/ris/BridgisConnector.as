
/**
 * @author velsll
 */
 

import ris.BridgisConnectorListener;
import ris.BridgisAccount;

class ris.BridgisConnector{
	private var xmlResponse:XML = null;
	private var url:String = "";
	//private var areasUrl:String = "";
	private var connectorListeners:Array = new Array();
	private var account;
	
	var xmlheader:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";

	
	function BridgisConnector(){
		var thisobj = this;
		xmlResponse = new XML();
		xmlResponse.ignoreWhite = true;
		xmlResponse.onLoad = function(succes:Boolean){
			if(succes){
				thisobj.onLoadSucces();
			} else {
				thisobj.onLoadFail();
			}
		}
		account = new BridgisAccount(); 
	}
	
	function setUrl(url){
		this.url = url;
	}
	
	
	function addListener(bridgisConnectorListener:BridgisConnectorListener):Void {
        connectorListeners.push(bridgisConnectorListener);
    }
    
    function removeListener(bridgisConnectorListener:BridgisConnectorListener):Void {
    	for (var i:Number = 0; i <  connectorListeners.length; i++) {
            if ( bridgisConnectorListener ==  connectorListeners[i]) {
                connectorListeners.splice(i, 1);
            }
        }
    }
    
    private function request(soapReqStr:String):Void{
    	var requestXML:XML = new XML(completeSoapRequest(soapReqStr));
        requestXML.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        requestXML.addRequestHeader("Content-Type", "text/xml");
        _global.flamingo.tracer("sendAndLoad " + xmlResponse);
        requestXML.sendAndLoad(url, xmlResponse); 
   }
   
    private function completeSoapRequest(reqString:String):String{
		var soapString:String = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:geow="http://services.bridgis.nl/GeoWebService">';
   		soapString+='<soapenv:Header/>';
   		soapString+='<soapenv:Body>';
   		soapString+=reqString;
   		soapString+='</soapenv:Body>';
		soapString+='</soapenv:Envelope>'
		return soapString;
	}
		
	private function getSoapUserString():String{
		var userStr:String = '<geow:sUser>' + account.getUserName() +  '</geow:sUser>';
		userStr += '<geow:sPassword>' + account.getPassword() + '</geow:sPassword>';
        return userStr;
	}
	
	private function getNodesString(nodePrefix:String,nodeName:String, nodeValues:Array, valueType:String):String{
		var nodeString:String = '';
		nodeString+='<'+ nodePrefix + ':' + nodeName + '>';
		for (var i:Number=0;i<nodeValues.length;i++){
			nodeString+='<'+ nodePrefix + ':' + valueType + '>';
			nodeString+=nodeValues[i];
			nodeString+='</'+ nodePrefix + ':' + valueType + '>';
		}
		nodeString+='</'+ nodePrefix + ':' + nodeName + '>';
        return nodeString;
	}
	
	
	function onLoadSucces():Void{	
		var result:XML = xmlResponse;
		//var result:XML = new XML('<result xmlns="http://services.bridgis.nl/GeoWebService"><listPopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>1</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>2</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity></listPopulationPerActivity><oInput><eAnalyseTypes><AnalyseType>MAXIMUM</AnalyseType><AnalyseType>WEEKDAG</AnalyseType><AnalyseType> WEEKNACHT</AnalyseType><AnalyseType>EINDDAG</AnalyseType><AnalyseType>EINDNACHT</AnalyseType></eAnalyseTypes><sActivityList><string>wonena</string><string>werken</string></sActivityList></oInput><metadata/></result>');
		for (var i:Number = 0; i < connectorListeners.length; i++) { 
		 	BridgisConnectorListener(connectorListeners[i]).onLoadResult(result);	 	
        }
	}
	

	
	function onLoadFail():Void{
		var result:XML = xmlResponse;
		for (var i:Number = 0; i < connectorListeners.length; i++) { 
			BridgisConnectorListener(connectorListeners[i]).onLoadFail(result);
		}
	}
	

	

}
