/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

import mx.utils.Delegate;
import flamingo.coremodel.service.dde.*;
import flamingo.geometrymodel.dde.Point;

class flamingo.coremodel.service.dde.DDEConnector extends XML{
	private var areaSelectionType:String; //inArea,inBox,inGeometry
	private var userSelectedThemes:String;
	private var selectedLayers:Array;
	private var lowerLeftX:Number;
	private var lowerLeftY:Number;
	private var upperRightX:Number
	private var upperRightY:Number;
	private var clippingPoints:Array;
	private var clippingCoords:String;
	private var queryCoordsSys:String = "EPSG:28992"; // kan deze aan de map worden opgevraagd??
	private var coordsys:String;
	private var format:String;
	private var notificationEmailAddress:String;
	private var returnTemplateFilePrefix:String = "tpc";
	private var enableAutoThemeSelection:Boolean = false;
	private var url:String;
	private var ddeServletUrl:String;
	private var resultString:String;
	private var ddeConnectorListeners:Array = new Array();
	private var postXml:XML = null;
	private var xmlResponse:XML = null;
	
	function DDEConnector(){
		xmlResponse = new XML();
		var thisobj = this;
		xmlResponse.onLoad = function(succes:Boolean){
			if(succes){
				thisobj.onLoadSucces();
			} else {
				thisobj.onLoadFail();
			}
		}
	}
	
	function addListener(ddeConnectorListener:DDEConnectorListener):Void {
        ddeConnectorListeners.push(ddeConnectorListener);
    }
	
	function setServletUrl(servletUrl:String):Void{
		ddeServletUrl=servletUrl;
	}
	
	
	function setAreaSelectionType(areaSelectionType:String){
		this.areaSelectionType = areaSelectionType;
	}
	
	function setuserSelectedThemes(layers:Array):Void{
		selectedLayers = layers;
	}
	
	function getSelectedLayers():Array{
		return selectedLayers;
	}
	
	
	function setBBox(llx:Number,lly:Number,urx:Number,ury:Number):Void{
		lowerLeftX = llx;
		lowerLeftY = lly;
		upperRightX = urx;
		upperRightY = ury;
	}
	
	function setClippingPoints(clCoords:Array):Void{
		clippingPoints = clCoords;
		clippingCoords = ""
			for (var j:Number = 0; j < clippingPoints.length; j++) {
				if (j==0){
					clippingCoords =  Point(clippingPoints[j]).getX() + "+" + Point(clippingPoints[j]).getY();
				} else {
				 clippingCoords += "+" + Point(clippingPoints[j]).getX() + "+" + Point(clippingPoints[j]).getY();
				}
			}
		//_global.flamingo.tracer("coords zijn " + clippingCoords);	
	}
	
	function setClippingCoords(clCoords:String):Void{
		clippingCoords = clCoords;
	}
	
	/*function setClip(cl:Boolean):Void{
		if(cl){
			clip = "yes";
		} else {
			clip = "no";
		}
	}*/
	
	function setCoordsys(crs:String){
		this.coordsys = crs;
		//_global.flamingo.tracer("coordsys " + coordsys);
	}
		
	function setFormat(format:String):Void{
		this.format = format;
	}
	
	function setEMail(eMail:String){
		_global.flamingo.setCookie("userEMail",eMail);
		this.notificationEmailAddress = eMail;
	}

	function sendRequest(requestType:String):Void{
		if(requestType=="startDownload"){
			buildPostXml();
			postXml.addRequestHeader("Content-Type", "text/xml");
			postXml.sendAndLoad(ddeServletUrl,xmlResponse);
		} 
		if(requestType=="getDDELayers"){
			var url:String = ddeServletUrl + "?request=getLayers";
			postXml = new XML();
			postXml.sendAndLoad(url,xmlResponse);
		}
			
	}
	
	private function buildPostXml(){
		var xmlStr:String =
		"<DDErequest>"+
			"<ddeServletUrl>" + ddeServletUrl + "</ddeServletUrl>"+
			"<SSFunction>remoteFetch</SSFunction>"+
			"<coordsys>"+coordsys+"</coordsys>"+
			"<format>"+format+"</format>"+
			"<notificationEmailAdress>"+notificationEmailAddress+"</notificationEmailAdress>"+
			"<returnTemplateFilePrefix>"+returnTemplateFilePrefix+"</returnTemplateFilePrefix>"+
			"<enableAutoThemeSelection>"+enableAutoThemeSelection+"</enableAutoThemeSelection>";
		if (areaSelectionType == "inBox") {
		 	xmlStr+= "<lowerLeftX>"+lowerLeftX+"</lowerLeftX>";
			xmlStr+= "<lowerLeftY>"+lowerLeftY+"</lowerLeftY>";
			xmlStr+= "<upperRightX>"+upperRightX+"</upperRightX>";
			xmlStr+= "<upperRightY>"+upperRightY+"</upperRightY>";
		 }
		 xmlStr +="<downloadLayers>" ;
	    for (var j:Number = 0; j < selectedLayers.length; j++) {	
			xmlStr += 	"<downloadLayer name='" + selectedLayers[j].name + "' label='" + selectedLayers[j].label + "' id='" + selectedLayers[j].id+ "'/>";
		}
		xmlStr +="</downloadLayers>";
		xmlStr+= "<fmeParams>";
		xmlStr+= "<QueryCoordsSys>"+queryCoordsSys+"</QueryCoordsSys>";
		if (areaSelectionType == "inArea" || areaSelectionType == "inGeometry") {
			xmlStr+="<ClippingCoords>"+clippingCoords+"</ClippingCoords>";
		} 
		xmlStr+= "</fmeParams>";
		xmlStr+="</DDErequest>";
		postXml = new XML(xmlStr); 
	}
	

	
	function onLoadSucces():Void{	 
		 for (var i:Number = 0; i < ddeConnectorListeners.length; i++) { 
            DDEConnectorListener(ddeConnectorListeners[i]).onDDELoad(xmlResponse);
        }
	}
	
	function onLoadFail():Void{
		
	}


	
	
}