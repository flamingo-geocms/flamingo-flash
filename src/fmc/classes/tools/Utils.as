class tools.Utils{
	
	public static function trim(str:String):String{
		var stripCharCodes = {
			code_9  : true, // tab
			code_10 : true, // linefeed
			code_13 : true, // return
			code_32 : true  // space
		};
		while(stripCharCodes["code_" + str.charCodeAt(0)] == true) {
			str = str.substring(1, str.length);
		}
		while(stripCharCodes["code_" + str.charCodeAt(str.length - 1)] == true) {
			str = str.substring(0, str.length - 1);
		}
		return str;
	}
}