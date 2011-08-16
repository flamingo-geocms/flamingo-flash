
/**
 * @author velsll
 */
 

import ris.BridgisConnectorListener;
import ris.BridgisAccount;

class ris.PopulatorConnector{
	private var xmlResponse:XML = null;
	private var reportUrl:String = "";
	//private var areasUrl:String = "";
	private var bridgisConnectorListeners:Array = new Array();
	private var account;
	
	var xmlheader:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";

	
	function PopulatorConnector(){
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
	
	function addListener(bridgisConnectorListener:BridgisConnectorListener):Void {
        bridgisConnectorListeners.push(bridgisConnectorListener);
    }
    
    function setReportUrl(url:String):Void{
		this.reportUrl=url;
	}
	
	
	
	function getReport(areaSelectionType:String, coords:String, analyzeTypes:String, activities:String){
	    var send_lv:LoadVars = new LoadVars();
    	//send_lv.sWKTArea = "POLYGON("  + coords + ")";
    	//send_lv.sUser = "ipo";
    	//send_lv.sPassword = "ipo2010";
    	//reportUrl = "http://services.bridgis.nl/geowebservice/populatoranalyze.asmx/RetrieveWKT"
    	send_lv.sendAndLoad(reportUrl + "?sUser=" + account.getUserName() + "&sPassword="+ account.getPassword()+ "&sWKTArea=POLYGON((" + coords + "))" + analyzeTypes + activities, xmlResponse, "GET");
	}

	
	function onLoadSucces():Void{	
		var result:XML = xmlResponse;
		//var result:XML = new XML('<result xmlns="http://services.bridgis.nl/GeoWebService"><listPopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>1</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>2</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>MAXIMUM</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>WEEKDAG</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>WEEKNACHT</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>EINDDAG</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>wonena</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>3</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>werken</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>4</sPopulation></PopulationPerActivity><PopulationPerActivity><sActivity>zalena</sActivity><eAnalyseType>EINDNACHT</eAnalyseType><sPopulation>10000</sPopulation></PopulationPerActivity></listPopulationPerActivity><oInput><eAnalyseTypes><AnalyseType>MAXIMUM</AnalyseType><AnalyseType>WEEKDAG</AnalyseType><AnalyseType> WEEKNACHT</AnalyseType><AnalyseType>EINDDAG</AnalyseType><AnalyseType>EINDNACHT</AnalyseType></eAnalyseTypes><sActivityList><string>wonena</string><string>werken</string></sActivityList></oInput><metadata/></result>');
		for (var i:Number = 0; i < bridgisConnectorListeners.length; i++) { 
		 	BridgisConnectorListener(bridgisConnectorListeners[i]).onLoadResult(result);	 	
        }
	}
	

	
	function onLoadFail():Void{
		for (var i:Number = 0; i < bridgisConnectorListeners.length; i++) { 
			BridgisConnectorListener(bridgisConnectorListeners[i]).onLoadFail(xmlResponse);
		}
	}
	

	

}
