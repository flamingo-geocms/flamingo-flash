﻿/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners bv
 -----------------------------------------------------------------------------*/
import flash.external.ExternalInterface;
/**
 * tools.Logger
 */
class tools.Logger{
	private var className="";
	public static var DEBUG:Number=10;
	public static var INFO:Number=8;
	public static var WARN:Number=6;	
	public static var ERROR:Number=4;
	public static var CRITICAL:Number=2;
	
	private var logLevel:Number=4;
	private var screenLogLevel:Number=2;
	/**
	 * constructor
	 * @param	className
	 * @param	logLevel
	 * @param	screenLogLevel
	 */
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
	/**
	 * getLogLevel
	 * @return
	 */
	function getLogLevel():Number{
		return this.logLevel;
	}
	/**
	 * setLogLevel
	 * @param	logLevel
	 */
	function setLogLevel(logLevel):Void{
		this.logLevel=logLevel;
	}
	/**
	 * getScreenLogLevel
	 * @return
	 */
	function getScreenLogLevel():Number{
		return this.screenLogLevel;
	}
	/**
	 * setScreenLogLevel
	 * @param	screenLogLevel
	 */
	function setScreenLogLevel(screenLogLevel):Void{
		this.screenLogLevel=screenLogLevel;
	}
	
	/*Messaging functions*/
	/**
	 * error
	 * @param	logMessage
	 */
	public function error(logMessage:Object):Void{
		traceMessage(logMessage,ERROR);
	}
	/**
	 * warn
	 * @param	logMessage
	 */
	public function warn(logMessage:Object):Void{
		traceMessage(logMessage,WARN);
	}
	/**
	 * info
	 * @param	logMessage
	 */
	public function info(logMessage:Object):Void{
		traceMessage(logMessage,INFO);
	}
	/**
	 * debug
	 * @param	logMessage
	 */
	public function debug(logMessage:Object):Void{
		traceMessage(logMessage,DEBUG);
	}
	/**
	 * critical
	 * @param	logMessage
	 */
	public function critical(logMessage:Object):Void{
		traceMessage(logMessage,CRITICAL);
	}
	/**
	 * console
	 */
	public static function console():Void {
		var str:String = arguments.join(', ');
		ExternalInterface.call( "console.log" , str );
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
	/**
	 * logLevelToString
	 * @param	type
	 * @return
	 */
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
	/**
	 * logLevelToNumber
	 * @param	type
	 * @return
	 */
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