
/**
 * @author Velsll
 */
class ris.PopActivity {
	private var id:String;
	private var label:String;
	private var type:String; //values struct or temp  
	private var total:Number;
	private var maximum:Number;
	private var weekdag:Number;
	private var weeknacht:Number;
	private var einddag:Number;
	private var eindnacht:Number;

	function PopActivity(id:String, label:String, type:String){
		this.id = id;
		this.label = label;
		this.type = type;
	}
	
	public function setAnalyseTypeValues(analyseType:String,value:Number):Void{
		switch (analyseType) {
		case "UNDEFINED" :
			total = value;
			break;	
		case "MAXIMUM" :
			maximum = value;
			break;
		case "WEEKDAG" :
			weekdag = value;
			break;
		case "WEEKNACHT" :
			weeknacht = value;
			break;
		case "EINDDAG" :
			einddag = value;
			break;	
		case "EINDNACHT" :
			eindnacht = value;
			break;
		}	
	}
	
	public function clearAll():Void {
		total = null;
		maximum = null;
		weekdag = null;
		weeknacht = null;
		einddag = null;
		eindnacht = null;
	}
		
	public function getHtmlString(analyzeTypes:Array):String {
		var str:String = label;
		if(analyzeTypes["MAXIMUM"].requested){
			if(maximum != null){
				str += "\t" + maximum;
			} else {
				str += "\t";
			}
		}
		if(analyzeTypes["WEEKDAG"].requested){
			if(weekdag  != null){
				str += "\t" + weekdag;
			} else {
				str += "\t";
			}
		}
		if(analyzeTypes["WEEKNACHT"].requested){
			if(weeknacht != null){
				str += "\t" + weeknacht;
			} else {
				str += "\t";
			}
		}
		if(analyzeTypes["EINDDAG"].requested){
			if(einddag != null){
				str += "\t" + einddag;
			} else {
				str += "\t";
			}
		}
		if(analyzeTypes["EINDNACHT"].requested){
			if(eindnacht != null){
				str += "\t" + eindnacht;
			} else {
				str += "\t";
			}
		}
		return str;
	}	
	
	public function getId():String{
		return id;
	}
	
	public function getType():String{
		return type;
	}
	
	public function getPopdata(analyseType:String):Number{
		var pop:Number;
		switch (analyseType) {
		case "MAXIMUM" :
			pop = maximum;
			break;
		case "WEEKDAG" :
			pop = weekdag;
			break;
		case "WEEKNACHT" :
			pop = weeknacht;
			break;
		case "EINDDAG" :
			pop = einddag;
			break;	
		case "EINDNACHT" :
			pop = eindnacht;
			break;
		}
		if(pop==undefined){
			return -1;
		} else	{	
			return pop;
		}
	}
	


}
