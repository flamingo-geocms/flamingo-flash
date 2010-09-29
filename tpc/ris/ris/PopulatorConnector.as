
/**
 * @author velsll
 */
 
import mx.utils.Delegate;

import ris.PopDataConnectorListener;

class ris.PopulatorConnector{
	private var xmlResponse:XML = null;
	private var reportUrl:String = "";
	private var areasUrl:String = "";
	private var popdataConnectorListeners:Array = new Array();
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
	}
	
	function addListener(popdataConnectorListener:PopDataConnectorListener):Void {
        popdataConnectorListeners.push(popdataConnectorListener);
    }
    
    function setReportUrl(url:String):Void{
		this.reportUrl=url;
	}
	
	function setAreasUrl(url:String):Void{
		this.areasUrl=url;
	}
	
	
	function getAreas(){
		var url:String = areasUrl;
		var send_lv:LoadVars = new LoadVars();
		send_lv.sendAndLoad(url, xmlResponse, "POST");
	}
	
	function getReport(areaSelectionType:String,inArea:Object, coords:String){
		 var send_lv:LoadVars = new LoadVars();
    	send_lv.suser = "";
    	send_lv.spassword = "";
    	send_lv.sWKTArea = "POLYGON("  + coords + ")";
    	send_lv.eAnalyseType = "MAXIMUM";
    	send_lv.sActivityList = "";
    	send_lv.sendAndLoad(reportUrl, xmlResponse, "POST");
		_global.flamingo.tracer("url " + reportUrl);
		_global.flamingo.tracer("sWKTArea " + send_lv.sWKTArea);
		
	

	}

	
	function onLoadSucces():Void{	 
		var resultType:String = xmlResponse.firstChild.nodeName;
			//_global.flamingo.tracer(xmlResponse);
		 for (var i:Number = 0; i < popdataConnectorListeners.length; i++) { 
		 	//_global.flamingo.tracer(resultType);
			if (resultType=="Gebieden"){
            	PopDataConnectorListener(popdataConnectorListeners[i]).onAreaLoad(xmlResponse);
		 	} else if (resultType=="message"){
		 		//PopDataConnectorListener(popdataConnectorListeners[i])
		 	} else {
		 		PopDataConnectorListener(popdataConnectorListeners[i]).onReportLoad(xmlResponse);
				
			}	
		 	
        }
	}
	
	function onLoadFail():Void{
		for (var i:Number = 0; i < popdataConnectorListeners.length; i++) { 
			PopDataConnectorListener(popdataConnectorListeners[i]).onLoadFail(xmlResponse);
		}
	}
	

	

}
