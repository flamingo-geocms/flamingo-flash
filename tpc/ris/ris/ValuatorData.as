import ris.Publication;
import ris.ValuatorSelector;
import ris.BridgisConnectorListener;
import tools.XMLTools;
/**
 * @author Velsll
 */
class ris.ValuatorData implements BridgisConnectorListener{
	
	private var years:Array;
	private var maxYear:Number = 0;
	private var minYear:Number = 3000;
	private var publications:Array;
	private var labelsSet:Boolean = false;
	private var results:Array;

	private var valuatorSelector:ValuatorSelector; 

	private var iYears:Array;
	private var sWorths:Array;
	private var sPublication:String;
	
	function ValuatorData(valuatorSelector:ValuatorSelector) {
		this.valuatorSelector = valuatorSelector;
		createValArrays();
	}
			
	private function createValArrays():Void{
		valuatorSelector.getConnector().addListener(this);
		valuatorSelector.getConnector().getAvailableYears();
	
		publications=new Array();

		//TODO: Get publications from service GetAvailablePublications	
		publications[-1] = new Publication(-1,"totaal",null);
		for (var i:Number=1;i<6;i++){
			publications[i] = new Publication(i,"tak",null);
		}
		for (var i:Number=7;i<13;i++){
			publications[i] = new Publication(i,"tak",null);
		}
		publications[21] = new Publication(21,"klasse",1);	
		publications[22] = new Publication(22,"klasse",2);
		//Industrie
		for (var i:Number=23;i<36;i++){
			publications[i] = new Publication(i,"klasse",3);
		}
		publications[36] = new Publication(36,"klasse",4);
		//BouwNijverheid
		for (var i:Number=37;i<40;i++){
			publications[i] = new Publication(i,"klasse",5);
		}
		//Handel en reparatie
		for (var i:Number=40;i<42;i++){
			publications[i] = new Publication(i,"klasse",7);
		}
		publications[42] = new Publication(42,"klasse",8);
		//Vervoer, opslag en communicatie
		for (var i:Number=43;i<47;i++){
			publications[i] = new Publication(i,"klasse",9);
		}
		//Financiele instellingen
		for (var i:Number=47;i<50;i++){
			publications[i] = new Publication(i,"klasse",10);
		}
		//Verhuur en zakelijke dienstverlening
		for (var i:Number=50;i<52;i++){
			publications[i] = new Publication(i,"klasse",11);
		}
		//Niet-commerciele dienstverlening
		for (var i:Number=52;i<58;i++){
			publications[i] = new Publication(i,"klasse",12);
		}	
	}
	
	public function getYears():Array{
		return years;
	}
	
	public function onLoadResult(result : XML) : Void {
		//var statusNodes:Array =  XMLTools.getElementsByTagName("Status", result);
		//if(statusNodes[0].firstChild.nodeValue == "FAILED"){
			//onLoadFail(result);
		//} else {
			var curDate:Date = new Date(); 
			if(years==undefined){
				var availableYearsNodes:Array = XMLTools.getElementsByTagName("GetAvailableYearsResult", result);
				if(availableYearsNodes.length > 0){
					loadYears(availableYearsNodes[0]);
					return;
				}
			}
			if(!labelsSet){
				var availablePubNodes:Array = XMLTools.getElementsByTagName("GetAvailablePublicationsResult", result);
				if(availablePubNodes.length > 0){
					setPubLabels(availablePubNodes[0]);
					return;
				}
			}
			showResults(result);
		//}
	
	}
	
	function onLoadFail(result : XML) : Void {
		valuatorSelector["mSendRequestButton"].enabled = true;
		valuatorSelector.setStatusText("Er is een fout opgetreden.", "warning", true);
	}
	
	
	function showResults(result: XML):Void{
		var resultNode:XMLNode = result.firstChild.firstChild.firstChild.firstChild;
		var yearWorthPublications:Array = XMLTools.getChildNodes("YearWorthPublication", XMLNode(resultNode.firstChild));//XMLTools.getElementsByTagName("YearWorthPublication", result.firstChild);
		if(yearWorthPublications.length > 0) {
			//var input:Array = XMLTools.getChildNodes("oInput",result.nextSibling);//XMLTools.getElementsByTagName("oInput", result.firstChild);
			var inputNode:XMLNode =XMLTools.getChild("oInput", resultNode)
			parseInput(inputNode);
			parseResults(yearWorthPublications);
			valuatorSelector.showReport(getHtmlString());
		}
	}
	
	
	private function loadYears(availableYearsNode : XMLNode): Void{
		years = new Array();
		var yearNodes:Array = availableYearsNode.childNodes;
		for(var i:Number=0;i<yearNodes.length;i++){
			if(maxYear < yearNodes[i].firstChild.nodeValue){
				maxYear = yearNodes[i].firstChild.nodeValue;
			}
			if(minYear > yearNodes[i].firstChild.nodeValue){
				minYear = yearNodes[i].firstChild.nodeValue;
			}
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
		labelsSet = true;
	}		

	function parseInput(input:XMLNode):Void {
		var yrs:Array = XMLNode(XMLTools.getChild("iYears", input)).childNodes;//XMLNode(XMLTools.getElementsByTagName("iYears",input)[0]).childNodes;
		iYears = new Array();
		for (var i:Number = 0;i<yrs.length ;i++){
			iYears[XMLNode(yrs[i]).firstChild.nodeValue] = XMLNode(yrs[i]).firstChild.nodeValue;
		}
		var wrths:Array =  XMLNode(XMLTools.getChild("sWorth", input)).childNodes;//XMLNode(XMLTools.getElementsByTagName("sWorth",input)[0]).childNodes;
		sWorths = new Array;
		for (var i:Number = 0;i<wrths.length ;i++){
			sWorths[XMLNode(wrths[i]).firstChild.nodeValue] = XMLNode(wrths[i]).firstChild.nodeValue;
		}
		//var sPubs:Array = XMLTools.getElementsByTagName("sPublication",input);
		sPublication = XMLNode(XMLTools.getChild("sPublication", input)).firstChild.nodeValue;//XMLNode(sPubs[0]).firstChild.nodeValue;
	}

	function parseResults(yearWorthPublications:Array):Void {	
		results = new Array();
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
			results[id+worth+year] = value;
		}
		
		
	}
	
	function getHtmlString():String{
		var htmlStr:String = getDateString();
		switch (sPublication) {
		 	case "TOTAAL" :
		 		htmlStr += "<span class='small'><textformat tabstops='[1,230,300,370,440,510,580,650,720,790,860,930]'>";
				htmlStr += getTotaalStr();
				break;	
			case "BEDRIJFSTAKKEN" :
				htmlStr += "<span class='small'><textformat tabstops='[1,240,315,390,465,540,615,690,765,840,915,990,1065,1140,1215,1290,1365,1440,1515,1590,1665,1740,1815,1890,1965,2040]'>";
				htmlStr += getTakStr();
				break;
			case "BEDRIJFSKLASSEN" :
				htmlStr += "<span class='small'><textformat tabstops='[1,240,315,390,465,540,615,690,765,840,915,990,1065,1140,1215,1290,1365,1440,1515,1590,1665,1740,1815,1890,1965,2040]'>";				htmlStr += getKlasseStr();
				break;
		 }	
		 return htmlStr;	
	}
	

	private function getDateString():String {
		var text:String = "<span class='normal'><textformat tabstops='[1,250]'>";
		var curDate:Date = new Date(); 
		var curDateStr:String = format(String(curDate.getDate())) + "-" + format(String(curDate.getMonth() + 1)) + "-"+ curDate.getFullYear() + " " + format(String(curDate.getHours())) + ":" + format(String(curDate.getMinutes()));
		text += "\r\tDatum/tijd aanvraag \t" + curDateStr + "\r\r";
		text += "</textformat></span>";
		return text;
	}
	
	private function getTotaalStr():String{
		var str:String = "";
		if(sWorths["TWLP"]!= undefined ||sWorths["PWLP"]!= undefined){
			str += "\t<i>Lopende prijzen</i> " + getYearsStr("");
			if(sWorths["TWLP"]!= undefined){
				str += "<br>\tTotaal Toegevoegde Waarde" +  getValueStr(-1,"TWLP") + "<br>";
			}
			if(sWorths["PWLP"]!= undefined){
				str += "\tTotaal Productiewaarde" +  getValueStr(-1,"PWLP") + "<br>";
			}	
			str += "<br>";	 
		}
		if(sWorths["TWCP"]!= undefined ||sWorths["PWCP"]!= undefined){
			str += "\t<i>Constante prijzen</i> " + getYearsStr("");
			if(sWorths["TWCP"]!= undefined){
				str += "<br>\tTotaal Toegevoegde Waarde" +  getValueStr(-1,"TWCP") + "<br>";
			}
			if(sWorths["PWCP"]!= undefined){
				str += "\tTotaal Productiewaarde" +  getValueStr(-1,"PWCP");
			}		 
		}
		return str;	
	}
	

	
		
	private function getTakStr():String{
		var str:String = "";
		//Lopende waarden
		if(sWorths["TWLP"]!= undefined||sWorths["TWCP"]!= undefined){
			str += "\t<i>Toegevoegde Waarde per CBS Bedrijfstak:</i>";	
			if(sWorths["TWCP"] == undefined){
				str += getYearsStr("LP") + "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWLP") + "<br>";
				}
			} 
			if(sWorths["TWLP"]== undefined ){
				str += getYearsStr("CP")+ "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWCP") + "<br>";;
				}
			}
			if(sWorths["TWCP"]!= undefined && (sWorths["TWLP"] != undefined)){
				str += getYearsStr("LPCP")+ "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWLP,TWCP") + "<br>";;
				}
			}
			str += "<br/>";
		}

		//values
		//Produktie waarden
		if(sWorths["PWLP"]!= undefined||sWorths["PWCP"]!= undefined){
			str += "\t<i>Produktie Waarde per CBS Bedrijfstak:</i>";	
			if(sWorths["PWCP"] == undefined){
				str += getYearsStr("LP") + "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWLP") + "<br>";;
				}
			} 
			if(sWorths["PWLP"]== undefined ){
				str += getYearsStr("CP")+ "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWCP") + "<br>";;
				}
			}
			if(sWorths["PWCP"]!= undefined && (sWorths["PWLP"] != undefined)){
				str += getYearsStr("LPCP")+ "<br>";
				for (var i:Number = 1;i<13 ;i++){
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWLP,PWCP") + "<br>";;
				}
			}
		}
		
		
		return str;
	}	
	
	
	private function getKlasseStr():String{
		var str:String = "";
		//Lopende waarden
		if(sWorths["TWLP"]!= undefined||sWorths["TWCP"]!= undefined){
			str += "\t<i>Toegevoegde Waarde per CBS Bedrijfsklasse:</i>";	
			var takId:Number = 0;
			if(sWorths["TWCP"] == undefined){
				str += getYearsStr("LP") + "<br>";	
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWLP") + "<br>";
				}
			} 
			if(sWorths["TWLP"]== undefined ){
				str += getYearsStr("CP")+ "<br>";
				
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWCP") + "<br>";;
				}
			}
			if(sWorths["TWCP"]!= undefined && (sWorths["TWLP"] != undefined)){
				str += getYearsStr("LPCP")+ "<br>";
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"TWLP,TWCP") + "<br>";;
				}
			}
			str += "<br>";
		}

		//values
		//Produktie waarden
		if(sWorths["PWLP"]!= undefined||sWorths["PWCP"]!= undefined){
			str += "\t<i>Produktie Waarde per CBS Bedrijfsklasse:</i>";	
			var takId:Number = 0;
			if(sWorths["PWCP"] == undefined){
				str += getYearsStr("LP") + "<br>";
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWLP") + "<br>";;
				}
			} 
			if(sWorths["PWLP"]== undefined ){
				str += getYearsStr("CP")+ "<br>";
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWCP") + "<br>";;
				}
			}
			if(sWorths["PWCP"]!= undefined && (sWorths["PWLP"] != undefined)){
				str += getYearsStr("LPCP")+ "<br>";
				for (var i:Number = 21;i<58 ;i++){
					if(takId!=publications[i].getTakId()){
						takId = publications[i].getTakId();
						str+="\t<b>" + publications[takId].getLabel() + "</b><br>";
					}
					str+="\t" + publications[i].getLabel();
					str+= getValueStr(i,"PWLP,PWCP") + "<br>";
				}
			}
		}
		return str;
	}
		
	private function getYearsStr(type:String ):String{
		var str:String = "<i>";
		for(var i:Number=maxYear;i>=minYear;i--){
			if(iYears[i]!=undefined){
				if(type == "LP" || type == "CP" || type == ""){
					str+="\t" + i + " " + type;
				}
				if(type == "LPCP"){
					str+="\t" + i + " LP" + "\t" + i + " CP";
				}	
			}
		}
		str += "</i>"
		return str;
	}	
	
	private function getValueStr(id:Number,worths:String):String{
		var w:Array = worths.split(",");
		var str:String = "";
		for(var k:Number=maxYear;k>=minYear;k--){
			for(var j:Number=0;j<w.length;j++){
				if(results[id+w[j]+k]!=undefined){
					str+="\t" + results[id+w[j]+k];
				}
			}
		}
		return str;
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
