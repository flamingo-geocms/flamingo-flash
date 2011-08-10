
/**
 * @author Velsll
 */
class ris.PubLevel{
	private var id:Number
	private var label:String;
	private var type:String; //values tak of klasse 
	private var takId:Number; //values only for klasse: id of bedrijfstak)
	 
	private var PWCP:Array;
	private var PWLP:Array;
	private var TWCP:Array;
	private var TWLP:Array;
	private var minyear:Number = 3000;
	private var maxyear:Number = 0;
	
	

	function PubLevel(id:Number, type:String, takId:Number){
		this.id = id;
		this.type = type;
		this.takId = takId;
		PWCP = new Array();
		PWLP = new Array();
		TWCP = new Array();
		TWLP = new Array();
		
	}
	
	public function setLabel(label:String){
		this.label = label;
	}
	
	public function setWorthValue(worth:String,value:Number,year:Number):Void{
		if (year < minyear){
			minyear=year;
		}
		if (year > maxyear){
			maxyear=year;
		}
		switch (worth) {
		case "PWCP" :
			PWCP[year] = value;
			break;	
		case "PWLP" :
			PWLP[year] = value;
			break;
		case "TWCP" :
			TWCP[year] = value;
			break;
		case "TWLP" :
			TWLP[year] = value;
			break;
		}
	}
	
	public function clearAll():Void {
		PWCP = new Array();
		PWLP = new Array();
		TWCP = new Array();
		TWLP = new Array();
		minyear = 3000;
		maxyear = 0; 
	}
		
	public function getHtmlString():String{
		var str:String = "";
		if(type=="totaal"){
			if(TWLP.length != 0 || PWLP.length != 0){
				str += "\t<i>Lopende prijzen</i>";
				if(TWLP.length != 0){
					str += getYearStr(TWLP);
				} else {
					str += getYearStr(PWLP);
				}
				if(TWLP.length != 0){
					str += "<br>\tTotaal Toegevoegde Waarde" +  getValueStr(TWLP);
				}	
				if(PWLP.length != 0){
					str += "<br>\tTotaal Productiewaarde" +  getValueStr(PWLP);
				}
			}
			if(TWCP.length != 0 || PWCP.length != 0){
				str += "<br><br>\t<i>Constante prijzen</i>";
				if(TWCP.length != 0){
					str += getYearStr(TWCP);
				} else {
					str += getYearStr(PWCP);
				}
				if(TWCP.length != 0){
					str += "<br>\tTotaal Toegevoegde Waarde" +  getValueStr(TWCP);
				}
				if(PWCP.length != 0){
					str += "<br>\tTotaal Productiewaarde" +  getValueStr(PWCP);
				}
			}
		}
		if(type=="tak"){
			str += "<br>\t" + label +  getValueStr(TWLP);
		}
		return str;
	
	}
	
	private function getYearStr(worthYears:Array):String {
		var str:String = "<i>";
		for(var i:Number=maxyear;i>=minyear;i--){
			if(worthYears[i]!=undefined){
				str+="\t" + i;
			}
		}
		return str + "</i>";
	}
	private function getValueStr(worthYears:Array):String{
		var str:String = "";
		for(var i:Number=maxyear;i>=minyear;i--){
			if(worthYears[i]!=undefined){
				str+="\t" + worthYears[i];
			}
		}
		return str;
	}
	
	public function getId():Number{
		return id;
	}
	
	public function getType():String{
		return type;
	}
	
	public function getTakId():Number{
		return takId;
	}
	
	public function getWorthValue(worth:String, year:String):Number{
		var value:Number;
		switch (worth) {
		case "PWCP" :
			value = PWCP[year];
			break;	
		case "PWLP" :
			value = PWLP[year];
			break;
		case "TWCP" :
			value= TWCP[year];
			break;
		case "TWLP" :
			value = TWLP[year];
			break;
		}	
		if(value==undefined){
			return -1;
		} else	{	
			return value;
		}
	}
}
