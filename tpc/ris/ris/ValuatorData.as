import ris.PubLevel;
import ris.ValuatorSelector;
import ris.BridgisConnectorListener;
import tools.XMLTools;
/**
 * @author Velsll
 */
class ris.ValuatorData implements BridgisConnectorListener{
	
	private var years:Array;
	private var publications:Array;
	private var currentPubs:Array;
	private var valuatorSelector:ValuatorSelector; 
	
	function ValuatorData(valuatorSelector:ValuatorSelector) {
		this.valuatorSelector = valuatorSelector;
		years = new Array();
		createValArrays();
	}
			
	private function createValArrays():Void{
		valuatorSelector.getConnector().addListener(this);
		valuatorSelector.getConnector().getAvailableYears();
	
	
		publications=new Array();

		//TODO: Get publications from service GetAvailablePublications	
		publications[-1] = new PubLevel(-1,"totaal",null);
		for (var i:Number=1;i<6;i++){
			publications[i] = new PubLevel(i,"tak",null);
		}
		for (var i:Number=7;i<13;i++){
			publications[i] = new PubLevel(i,"tak",null);
		}
		publications[21] = new PubLevel(21,"klasse",1);	
		publications[22] = new PubLevel(22,"klasse",2);
		//Industrie
		for (var i:Number=23;i<36;i++){
			publications[i] = new PubLevel(i,"klasse",3);
		}
		publications[36] = new PubLevel(36,"klasse",4);
		//BouwNijverheid
		for (var i:Number=37;i<40;i++){
			publications[i] = new PubLevel(i,"klasse",5);
		}
		//Handel en reparatie
		for (var i:Number=40;i<42;i++){
			publications[i] = new PubLevel(i,"klasse",6);
		}
		publications[42] = new PubLevel(42,"klasse",7);
		//Vervoer, opslag en communicatie
		for (var i:Number=43;i<47;i++){
			publications[i] = new PubLevel(i,"klasse",8);
		}
		//Financiele instellingen
		for (var i:Number=47;i<50;i++){
			publications[i] = new PubLevel(i,"klasse",9);
		}
		//Verhuur en zakelijke dienstverlening
		for (var i:Number=50;i<52;i++){
			publications[i] = new PubLevel(i,"klasse",10);
		}
		//Niet-commerciele dienstverlening
		for (var i:Number=52;i<58;i++){
			publications[i] = new PubLevel(i,"klasse",11);
		}	
	}
	
	public function getYears():Array{
		return years;
	}
	
	public function onLoadResult(result : XML) : Void {
		var availableYearsNodes:Array = XMLTools.getElementsByTagName("GetAvailableYearsResult", result);
		if(availableYearsNodes.length > 0){
			loadYears(availableYearsNodes[0]);
		}
		var availablePubNodes:Array = XMLTools.getElementsByTagName("GetAvailablePublicationsResult", result);
		if(availablePubNodes.length > 0){
			setPubLabels(availablePubNodes[0]);
		}
	}
	
	private function loadYears(availableYearsNode : XMLNode): Void{
		var yearNodes:Array = availableYearsNode.childNodes;
		for(var i:Number=0;i<yearNodes.length;i++){
			years.push(XMLNode(yearNodes[i]).firstChild.nodeValue);
		}
		valuatorSelector.addPeriodControls(500,0);
		valuatorSelector.getConnector().getAvailablePublications();		
	}
	
	private function setPubLabels(availablePubNodes : XMLNode): Void{
		var pubNodes:Array = availablePubNodes.childNodes;
		for(var i:Number=0;i<pubNodes.length;i++){
			var pub:String = pubNodes[i].firstChild.nodeValue;
			var pubArray:Array = pub.split(" - ");
			if(pubArray[0] == "TOTAAL" || pubArray[0] == "BEDRIJFSKLASSEN" || pubArray[0] == "BEDRIJFSTAKKEN"){
				//niks doen
			} else  {
				publications[pubArray[0]].setLabel(pubArray[1]);
			}
		}
		valuatorSelector.getConnector().removeListener(this);	
	}		
	
	public function onLoadFail(result : XML) : Void {
	}	
	
	function setValues(yearWorthPublications:Array){	
		currentPubs = new Array();
		for (var i:Number=0;i<yearWorthPublications.length;i++){
			var valueNodes:Array = XMLNode(yearWorthPublications[i]).childNodes;
			var year:Number;
			var id:Number;
			var worth:String;
			var value:Number;
			for (var j:Number=0;j<valueNodes.length;j++){
				switch (XMLNode(valueNodes[j]).nodeName) {
					case "Year" :
						year = Number(XMLNode(valueNodes[j]).firstChild.nodeValue);
						break;	
					case "ActivityID" :
						id = Number(XMLNode(valueNodes[j]).firstChild.nodeValue);
						break;
					case "Worth" :
						worth = XMLNode(valueNodes[j]).firstChild.nodeValue;
						break;
					case "Value" :
						value = Number(XMLNode(valueNodes[j]).firstChild.nodeValue);
					break;		
				}		
			}
			PubLevel(publications[id]).setWorthValue(worth, value, year);
			currentPubs[id] = publications[id];
		}
	}
	
	function getHtmlString():String{ 
		var text:String = getDateString();
		text += "<span class='small'><textformat tabstops='[1,250,315,380,445,510,575,640,705,770,835,900]'>";
		for (var i:Number=-1;i<40;i++) {
			if(currentPubs[i]!=undefined){
				text += PubLevel(currentPubs[i]).getHtmlString();
			}
		}
		return text;		
	}
	
	private function getDateString():String {
		var text:String = "<span class='normal'><textformat tabstops='[1,250]'>";
		var curDate:Date = new Date(); 
		var curDateStr:String = format(String(curDate.getDate())) + "-" + format(String(curDate.getMonth() + 1)) + "-"+ curDate.getFullYear() + " " + format(String(curDate.getHours())) + ":" + format(String(curDate.getMinutes()));
		text += "\r\tDatum/tijd aanvraag \t" + curDateStr + "\r\r";
		text += "</textformat></span>";
		return text;
	}
	
	 private function format(d:String):String {
    	if(d.length == 1){
    		return "0" + d;
    	} else {
    		return d;
    	}	
	}
	
 
    /*
    private function calcTotalStruct(analyseType:String):Number {
    	var totalStruct:Number = 0;
    	for(var a in popActivities){
    		if(popActivities[a].getType() == "struct"){
    			var pop:Number = popActivities[a].getPopdata(analyseType);
    			if(pop != -1){
    				totalStruct += pop;
    			}
    		}
    	}
    	return totalStruct;
    }
    
    private function calcTotalTemp(analyseType:String):Number {
       	var totalTemp:Number = 0;
    	for(var a in popActivities){
    		if(popActivities[a].getType() == "temp"){
    			var pop:Number = popActivities[a].getPopdata(analyseType);
    			if(pop != -1){
    				totalTemp += pop;
    			}
    		}
    	}
    	return totalTemp;
    }
    
    
		*/	
	
}
