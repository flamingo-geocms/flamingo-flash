
/**
 * @author velsll
 */
 
import mx.utils.Delegate;

import ris.PopDataConnectorListener;

class ris.PopulationdataConnector{
	private var xmlResponse:XML = null;
	private var reportUrl:String = "";
	private var areasUrl:String = "";
	private var popdataConnectorListeners:Array = new Array();

	
	function PopulationdataConnector(){
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
		var url:String = reportUrl;
		var send_lv:LoadVars = new LoadVars();
		send_lv.request = "getReport";
		send_lv.areaSelectionType = areaSelectionType;
		if (areaSelectionType == "inArea"){
			send_lv.areaType = inArea.type;
			send_lv.areaValue = inArea.data;
		} else {
			send_lv.coords = coords;
		}
		send_lv.sendAndLoad(url, xmlResponse, "POST");
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
		 		PopDataConnectorListener(popdataConnectorListeners[i]).onPopulationReportLoad(xmlResponse);
				
			}	
		 	
        }
	}
	
	function onLoadFail():Void{
		for (var i:Number = 0; i < popdataConnectorListeners.length; i++) { 
			PopDataConnectorListener(popdataConnectorListeners[i]).onLoadFail(xmlResponse);
		}
	}
	

	

}
