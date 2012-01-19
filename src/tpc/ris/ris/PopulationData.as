import ris.PopActivity;
import ris.PopulatorSelector;

/**
 * @author Velsll
 */
class ris.PopulationData {
	
	private var popActivities:Array;
	private var analyzeTypes:Array;
	private var populatorSelector:PopulatorSelector; 
	
	function PopulationData(populatorSelector:PopulatorSelector) {
		this.populatorSelector = populatorSelector;
		createPopArrays();
	}
			
	private function createPopArrays():Void{
		popActivities = new Array();
		//popActivities["undefined"] = new PopActivity("total", "Totaal", "");	
 	    popActivities["sporta"] = new PopActivity("sporta", "Sportaccommodaties", "temp");
    	popActivities["evenem"] = new PopActivity("evenem", "Evenemententerreinen", "temp");
    	popActivities["beurze"] = new PopActivity("beurze", "Beurzen en congrescentra", "temp");
    	popActivities["zalena"] = new PopActivity("zalena", "Theaters, concertzalen en bioscopen", "temp");
    	popActivities["dagrec"] = new PopActivity("dagrec", "Dagrecreatie", "temp");
    	popActivities["uitvrt"] = new PopActivity("uitvrt", "Uitvaartcentra", "temp");
    	popActivities["nieuwb"] = new PopActivity("nieuwb", "Nieuwbouw", "struct");
    	popActivities["hotels"] = new PopActivity("hotels", "Hotels", "struct");
    	popActivities["prkcmp"] = new PopActivity("prkcmp", "Bungalowparken en campings", "struct");
    	popActivities["zieken"] = new PopActivity("zieken", "Ziekenhuizen", "struct");
    	popActivities["zorgin"] = new PopActivity("zorgin", "Zorginstellingen", "struct");
    	popActivities["asielz"] = new PopActivity("asielz", "Asielzoekerscentra", "struct");
    	popActivities["jstinr"] = new PopActivity("jstinr", "Justiti&#235;le inrichtingen", "struct");	
    	popActivities["kinder"] = new PopActivity("kinder", "Kinderopvang", "struct");
    	popActivities["onderw"] = new PopActivity("onderw", "Onderwijs", "struct");
    	popActivities["werken"] = new PopActivity("werken", "Werken", "struct");
    	popActivities["wonena"] = new PopActivity("wonena", "Wonen", "struct");

    	analyzeTypes = new Array();
 		analyzeTypes["EINDNACHT"] = createTypeObject(_global.flamingo.getString(populatorSelector,"weekendnacht"));
    	analyzeTypes["EINDDAG"] = createTypeObject(_global.flamingo.getString(populatorSelector,"weekenddag"));
    	analyzeTypes["WEEKNACHT"] = createTypeObject(_global.flamingo.getString(populatorSelector,"werknacht"));
    	analyzeTypes["WEEKDAG"] = createTypeObject(_global.flamingo.getString(populatorSelector,"werkdag"));
    	analyzeTypes["MAXIMUM"] =  createTypeObject(_global.flamingo.getString(populatorSelector,"maxpop"));  	
	}
	
	/*public function getPopActivities():String{
		var popActStr:String = "";
		for (var a in popActivities){
			popActStr += "&sActivityList=" + popActivities[a].getId(); 
		} 
		return popActStr;
	}*/
	
	public function getPopActivityArray():Array {
		var popArray:Array = new Array();
		for (var a in popActivities){
			popArray.push(a)
		}
		return popArray;
	}
			
	public function getTotalActivityArray():Array {
		var popArray:Array = new Array();
		popArray.push("totstr");
		popArray.push("tottyd");
		return popArray;
	}		
		
	/*public function getTotalActivities():String{
		var totActStr:String = "";
		totActStr += "&sActivityList=totstr&sActivityList=tottyd";
		return totActStr; 
	}*/	
	
	private function resetAnalyseTypes(){	
    	analyzeTypes["EINDNACHT"].requested = false;
    	analyzeTypes["EINDDAG"].requested = false;
    	analyzeTypes["WEEKNACHT"].requested= false;
    	analyzeTypes["WEEKDAG"].requested = false;
    	analyzeTypes["MAXIMUM"].requested = false;
    	analyzeTypes["UNDEFINED"].requested =  false;
	}	
	
	private function createTypeObject(label:String):Object{
		var type:Object = new Object();
		type.requested = false;
		type.label = label;
		return type;
	}
		
	
	function getReportString(result:XML):String{
		for (var a in popActivities){
			popActivities[a].clearAll();
		}
		resetAnalyseTypes();
		
		var populationPerActivityNodes:Array = result.firstChild.firstChild.firstChild.firstChild.firstChild.childNodes;
		for(var i:Number=0;i< populationPerActivityNodes.length;i++){
			var populationPerActivityNode:XMLNode = populationPerActivityNodes[i];
			var dataNodes:Array = populationPerActivityNode.childNodes;
			var activityId:String = dataNodes[0].firstChild.nodeValue;
			var analyseType:String = dataNodes[1].firstChild.nodeValue;
			analyzeTypes[analyseType].requested = true;
			var pop:Number = Number(dataNodes[2].firstChild.nodeValue);
			if(activityId == "totstr" ||  activityId == "tottyd" ||  activityId == "totaal"){
				if(activityId == "totstr"){
					analyzeTypes[analyseType].totstr = Number(pop);
				} 
				if(activityId == "tottyd"){
					analyzeTypes[analyseType].tottyd = Number(pop);
				} 
			} else {
				popActivities[activityId].setAnalyseTypeValues(analyseType,pop);
			}	
		} 
		var kolomkop:String = "\t\t";
		for(var a in analyzeTypes){
			if(analyzeTypes[a].requested){
				kolomkop+= "\t" + analyzeTypes[a]["label"];
			}
		}
		var inhoud:String = "\tStructurele verblijfplaatsen\t";
		var i:Number = 1;
		for(var a in popActivities){
			inhoud += i + " " + popActivities[a].getHtmlString(analyzeTypes);
			if (a == "nieuwb"){
				inhoud += "\r\tTijdelijke verblijfplaatsen\t";
			} else {
				inhoud += "\r\t\t";
			}
			i++;
		}
		var text:String = "<span class='normal'><textformat tabstops='[1,250]'>";
		var curDate:Date = new Date(); 
		var curDateStr:String = format(String(curDate.getDate())) + "-" + format(String(curDate.getMonth() + 1)) + "-"+ curDate.getFullYear() + " " + format(String(curDate.getHours())) + ":" + format(String(curDate.getMinutes()));
		text += "\r\tDatum/tijd aanvraag \t" + curDateStr + "\r\r";
		text += "</textformat></span>";
		text += "<span class='small'><textformat tabstops='[1,155,420,510,590,670,750]'>";
		text += kolomkop + "\r\r";
		text += "Totaal structurele verblijfplaatsen\t";
		for(var a in analyzeTypes){
			if(analyzeTypes[a].requested){
				if(!populatorSelector.perPopType.selected){
					text += analyzeTypes[a].totstr + "\t" ;
				} else {
					text += calcTotalStruct(a) + "\t" ; 
				}
			}
		}
		text += "\rTotaal tijdelijke verblijfplaatsen\t"; 
		for(var a in analyzeTypes){
			if(analyzeTypes[a].requested){
				if(!populatorSelector.perPopType.selected){
					text += analyzeTypes[a].tottyd + "\t" ;
				} else {
					text += calcTotalTemp(a) + "\t" ; 
				}
			}
		} 
		text += "\r\r";
		if(populatorSelector.perPopType.selected){
			text += inhoud +"\r\r";
		}
		text +="</textformat></span>";
		text += "<span class='Uitleg'>" + _global.flamingo.getString(populatorSelector,"toelichting") + "</span>";
		return text;
	}
	
	 private function format(d:String):String {
    	if(d.length == 1){
    		return "0" + d;
    	} else {
    		return d;
    	}	
    } 
    
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
    
    
			
	
}
