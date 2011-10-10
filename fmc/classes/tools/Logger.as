/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners bv
 -----------------------------------------------------------------------------*/
 class tools.Logger{
	private var className="";
	public static var DEBUG:Number=10;
	public static var INFO:Number=8;
	public static var WARN:Number=6;	
	public static var ERROR:Number=4;
	public static var CRITICAL:Number=2;
	
	private var logLevel:Number=4;
	private var screenLogLevel:Number=2;
	
	function Logger(className:String,logLevel:Number, screenLogLevel:Number){		
		this.className=className;
		if(logLevel!=undefined){
			this.logLevel=logLevel;
		}
		if(screenLogLevel!=undefined){
			this.screenLogLevel=screenLogLevel;
		}
		
	}
	/*Getters and setters*/
	function getLogLevel():Number{
		return this.logLevel;
	}
	function setLogLevel(logLevel):Void{
		this.logLevel=logLevel;
	}
	function getScreenLogLevel():Number{
		return this.screenLogLevel;
	}
	function setScreenLogLevel(screenLogLevel):Void{
		this.screenLogLevel=screenLogLevel;
	}
	
	/*Messaging functions*/
	public function error(logMessage:Object):Void{
		traceMessage(logMessage,ERROR);
	}
	
	public function warn(logMessage:Object):Void{
		traceMessage(logMessage,WARN);
	}
	
	public function info(logMessage:Object):Void{
		traceMessage(logMessage,INFO);
	}
	
	public function debug(logMessage:Object):Void{
		traceMessage(logMessage,DEBUG);
	}
	
	public function critical(logMessage:Object):Void{
		traceMessage(logMessage,CRITICAL);
	}
	
	/*The actual trace function*/
	private function traceMessage(logMessage:Object, type:Number):Void{
		if (type<=this.logLevel){
			trace(logLevelToString(type)+" "+String(new Date())+
							"("+className +
							"):"+logMessage);
		}
		if (type<=this.screenLogLevel){
			_global.flamingo.tracer("("+className+"):"+logMessage);
		}
	}
	
	public static function logLevelToString(type:Number):String{
		if (type==CRITICAL){
			return "CRITICAL";
		}else if (type==ERROR){
			return "ERROR";
		}else if (type==WARN){
			return "WARNING";
		}else if (type==INFO){
			return "INFO";
		}else if (type==DEBUG){
			return "DEBUG";
		}
	}
	public static function logLevelToNumber(type:String):Number{
		type=type.toUpperCase();
		if (type=="CRITICAL"){
			return CRITICAL;
		}else if (type=="ERROR"){
			return ERROR;
		}else if (type=="WARN"){
			return WARN;
		}else if (type=="INFO"){
			return INFO;
		}else if (type=="DEBUG"){
			return DEBUG;
		}
		return null;
	}
}