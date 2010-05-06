/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component PopulationDataSelector
* This component is shown in the Window component of Flamingo and offers an user 
* interface for querying population data.  
* @file flamingo/fmc/classes/flamingo/gui/populationdata/PopulationDataSelector.as  (sourcefile)
* @file flamingo/fmc/PopulationDataSelector.fla (sourcefile)
* @file flamingo/fmc/PopulationDataSelector.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/classes/flamingo/gui/dde/DDEConnector.as (holds the model for the DDE download settings, compiles and sends  
* requests to a DDE servlet, dispatches an event to listeners when the request is returned)
* @file flamingo/fmc/classes/flamingo/gui/dde/DDEConnectorListener.as (listener interface) 
* @file flamingo/fmc/classes/flamingo/gui/dde/DownLoadLegend.as (Draws an (simplified) legend using the legendItems from the legend component
* matches the DDELayers from the servlet with the legendtems and is an user interface to select ddeLayers 
* for downloading)
* @file flamingo/fmc/classes/AbstractComponent.as (super class for components)
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/Geometry.as (hierachical classes for the geometry model -> used for digitizing polygons, boxes and circles)
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/LinearRing.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/LineSegment.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/LineString.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/Point.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/Square.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/Envelope.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/Circle.as
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/GeometryEventDispatcher.as (eventdispatcher of a geometry, dispatches events to all listener when the geometry (model) changes)
* @file flamingo/fmc/classes/flamingo/geometrymodel/dde/GeometryListener.as (geometry listener interface class)
* @file flamingo/fmc/classes/flamingo/gui/dde/TraceLayer.as (dummy layer for tracing geometries in the mapviewer)
* @file flamingo/fmc/classes/flamingo/gui/dde/TraceLinearRing.as (the representation of the traced geometry in the TraceLayer)
* @configstring layers label above the layer legend
* @configstring inArea radiobuttonlabel for selecting predefined areas (in a combobox)
* @configstring inBox radiobuttonlabel for lowerleft and upperright coördinate input (in textinput fields)
* @configstring inGeometry radiobuttonlabel for geometrycoördinate input (digitizing on trace layer in the map)  
* @configstring inAll radiobuttonlabel for downloading the whole file
* @configstring crs comboboxlabel for selecting the coordinate reference system of the download layers
* @configstring format comboboxlabel for selecting the format of the download layer 
* @configstring emailAddress textinput label for entering the e-mail adress whereto the download link will be sent
* @configstring warningNoLayer warning text shown when no layer is selected
* @configstring warningNoEmail Warning text shown when no valid e-mail adress is entered
* @configstring warningOutOfExtent Warning text show when inBox coordinates are outside the full extent of the map
* @configstring warningErrorInBox Warning text show when there is an error in the inBox coordinates (f.e. llX > urX)
* @configstring extentButtonLabel Button label for the button that copies the mapextents into textfields
* @configstring requestButtonLabel Button label for the button that sends the request
* @configstring closeButtonLabel Button label for the button that closes the DownloadSelector
*/

/** @tag <fmc:DownloadSelector>   
* This tag defines the presence of a downloadselector. The downloadselector must be registered as a listener to the map, and to the legend. 
* @class gui.dde.DownloadSelector extends AbstractComponent
* @hierarchy childnode of a container component. e.g. <fmc:Window> 
* @example
	<fmc:Window id="downloadSelectorWindow" skin="g" top="100" left="100" width="500" height="500" canresize="true" canclose="true" visible="false">
		<string id="title" en="Download Selector" nl="Downloadkiezer"/>
		<fmc:DownloadSelector id="downloadSelector" top="10" left="10" right="right -10" bottom="bottom -10" listento="map,legend" ddeservleturl="http://idgisvv.xs4all.nl/DDEDownload/flamingo" debug="false">
	</fmc:Window>
* @attr ddeservleturl url of the ddeservlet
* @attr debug sets debugging on or off (true/false). Debugging is usefull when checking the 
* configuration of ddeLayers in the ddeservlet configuration file.
*/
	
/** @tag <fmc:crs> 
* This tag defines an(output)coödinatesystem. 
* @hierarchy childnode of <fmc:DownloadSelector> 
* @example
	<fmc:crs label="Lat/Long" data="LL84"/>
    <fmc:crs label="Rijksdriehoek" data="EPSG:28992"/>
    <fmc:crs label="Belgie Lambert 72" data="EPSG:31370"/>
* @attr label a name shown to the user
* @attr data value used in the url 
*/

/** @tag <fmc:outputFormat>
* This tag defines a dde download format.
* @hierarchy childnode of <fmc:DownloadSelector> 
* @example
	<fmc:outputFormat label="gif" data="2gif.fme"/>
	<fmc:outputFormat label="Shapefile" data="2shp.fme"/>
* @attr label a name shown to the user
* @attr data value used in the url 	
*/

/** @tag <fmc:inArea>
* This tag defines an area for downloading from dde.
* @hierarchy childnode of <fmc:DownloadSelector> 
* @example
	  <fmc:inArea label="Goes" coords="38244+388821+56760+388821+56760+397307+38244+397307+38244+388821"/>
	  <fmc:inArea label="Hulst" coords="55018+362197+74859+362197+74859+380617+55018+380617+55018+362197"/>* @attr label a name shown to the user
* @attr label a name shown to the user
* @attr data value used in the url, an coördinate string of x and y values seperated by a + sign	
*/	

import geometrymodel.dde.*;
import mx.utils.Delegate;
import mx.controls.RadioButton;
import mx.controls.ComboBox;
import mx.controls.TextInput;

import core.AbstractComponent;

import gui.dde.TraceLayer;

import ris.PopDataConnectorListener;
import ris.PopulationdataConnector;

import mx.controls.TextArea;
import mx.core.View;
import mx.skins.Border;

import flash.external.ExternalInterface;

class ris.PopulationDataSelector extends AbstractComponent implements GeometryListener,PopDataConnectorListener{
    var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<PopulationDataSelector>" + 
							"<string id='layers' en='Layers' nl='Kaartlagen'/>" +
						      "<string id='inArea' en='Within Area' nl='Binnen gebied'/>" +
						      "<string id='inGeometry' en='Within Geometry' nl='Binnen geometrie'/>"+
						      "<string id='inBox' en='Within Box' nl='Binnen rechthoek'/>" +
						      "<string id='inAll' en='Whole file' nl='Gehele bestand'/>" +
						      "<string id='warningOutOfExtent' en='Requested extent outside the fullextent of the map' nl='Ingevulde coördinaten vallen buiten bereik van de kaart'/>" +
						      "<string id='warningErrorInBox' en='Error in box coördinates' nl='Fouten in coördinaten van rechthoek'/>" +
						      "<string id='extentButtonLabel' en='from map' nl='van kaart'/>" + 
						      "</PopulationDataSelector>";

    private var map:Object = null;
    private var thisObj:Object = null;
    private var depth:Number = 0;

	private var textFormatUrl:TextFormat;
	
	private var textFormatWarning:TextFormat;
	
	private var textFormatInfo:TextFormat;
	
	private var textFormat:TextFormat;
	
    private var statusDelayIntervalID:Number = 0;
		
	private var sendRequestButton:Button;
	private var infoButton:Button;
	private var closeButton:Button;
	
	private var geometry:Geometry;
	
	private var inAreaChoser; 
	private var llX:TextInput;
	private var llY:TextInput;
	private var urX:TextInput;
	private var urY:TextInput;
	private var setExtentButton;
	private var statusLine:TextField;
	private var popDataConnector : PopulationdataConnector;
	private var areaSelectionType : String;
	private var inArea:Object = new Object;
	private var coords:String = null;
	private var resultCompId = "populationresults";

	
	function onLoad():Void {
		popDataConnector = new PopulationdataConnector();
		popDataConnector.addListener(this);
		this.setAreaSelectionType("inArea");
		super.onLoad();
	}
	
	function init():Void{
		map = _global.flamingo.getComponent(listento[0]);
		thisObj = this;
		textFormat = new TextFormat();
    	textFormat.font = "_sans";
		textFormat.underline = false;
		textFormatUrl = new TextFormat();
		textFormatUrl.font = "_sans";
		textFormatUrl.color = 0x0000ff;
		textFormatUrl.underline = true;
		textFormatWarning = new TextFormat();
		textFormatWarning.underline = false;
		textFormatWarning.font = "_sans";
		textFormatWarning.color = 0xff0000;
		textFormatInfo = new TextFormat();
		textFormatInfo.underline = false;
		textFormatInfo.font = "_sans";
		textFormatInfo.color = 0x0000ff;
		addControls();
		resetControls();
		popDataConnector.getAreas();
	}



   function setVisible(visible:Boolean):Void {
    	super.setVisible(visible);
		if(!visible){
			if(map["mTraceSheet"]!=null){
				map["mTraceSheet"].removeMovieClip();
			}
		} else {
			resetControls();
		}
		
    }

	
    private function addControls():Void {
		this.createEmptyMovieClip("mHolder",100);
		this["mHolder"]._lockroot = true;         
        var inArea:RadioButton = RadioButton(attachMovie("RadioButton", "mInAreaRadioButton", depth++));
		inArea.move(20,0);
		inArea.data = "inArea";
		inArea.groupName = "inWhat";
		inArea.label =_global.flamingo.getString(this,"inArea");
		inArea.selected = true;
		inArea.setSize(200,20);
		inAreaChoser = ComboBox(this["mHolder"].attachMovie("ComboBox", "cmbInAreaChoser", 1));
		inAreaChoser.addEventListener("close", Delegate.create(this, onChangeInArea));
        inAreaChoser.drawFocus = function() {
			};
		inAreaChoser.getDropdown().drawFocus = "";
		// to prevent the list to close after scrolling
		inAreaChoser.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		inAreaChoser.move(20, 20);
		inAreaChoser.setSize(170,25);

        var inBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInBoxRadioButton", depth++));
		inBox.move(20,60);
		inBox.data = "inBox";
		inBox.groupName = "inWhat";
		inBox.label = _global.flamingo.getString(this,"inBox");
		inBox.setSize(200,20);
		
		var bBox:MovieClip = this.createEmptyMovieClip("mbBox", depth++);
		bBox._x = 20;
		bBox._y = 75;
		var xLabel:TextField = bBox.createTextField("tXLabel",depth++,25,0, 90,20);
		xLabel.setNewTextFormat(textFormat);
		xLabel.text = "X:";
	 	var yLabel:TextField = bBox.createTextField("tYLabel",depth++,110,0,90, 20);
		yLabel.setNewTextFormat(textFormat);
		yLabel.text = "Y:";
		var llLabel:TextField = bBox.createTextField("tLlLabel",depth++,0,20,25,20);
		llLabel.setNewTextFormat(textFormat);
		llLabel.text = "LL:";
		var urLabel:TextField = bBox.createTextField("tUrLabel",depth++,0,50,25,20);
		urLabel.setNewTextFormat(textFormat);
		urLabel.text = "UR:";
		llX = TextInput(bBox.attachMovie("TextInput","llX",depth++));
		llX.setSize(80,25);
		llX.move(25,20);
		llX.restrict = "0-9";
		llX.addEventListener("change", Delegate.create(this, onChangeBox));
		llX.enabled = false;
		llY = TextInput(bBox.attachMovie("TextInput","llY",depth++));
		llY.setSize(80,25);
		llY.move(110,20);
		llY.restrict = "0-9";
		llY.addEventListener("change", Delegate.create(this, onChangeBox));
		llY.enabled = false;
		urX = TextInput(bBox.attachMovie("TextInput","urX",depth++));
		urX.setSize(80,25);
		urX.move(25,50);
		urX.restrict = "0-9";
		urX.addEventListener("change", Delegate.create(this, onChangeBox));
		urX.enabled = false;
		urY = TextInput(bBox.attachMovie("TextInput","urY",depth++));
		urY.setSize(80,25);
		urY.move(110,50);
		urY.restrict = "0-9";
		urY.addEventListener("change", Delegate.create(this, onChangeBox));
		urY.enabled = false;

		setExtentButton = bBox.createClassObject(mx.controls.Button, "mSetExtentButton", depth++);
		setExtentButton.move(25,80); 
		setExtentButton.label = _global.flamingo.getString(this,"extentButtonLabel");
		setExtentButton.enabled = false;
		setExtentButton.onRelease = function(){_parent._parent.onClickGetExtentButton();};
		setExtent();
		
		var inGeometryLabel:TextField = createTextField("mInGeometryLabel",depth++,20,190,200,20);
		inGeometryLabel.setNewTextFormat(textFormat);
		inGeometryLabel.text = _global.flamingo.getString(this,"inGeometry");
		
        var inGeometryPoly:RadioButton  = RadioButton(attachMovie("RadioButton", "mInGeometryPolyRadioButton", depth++));
		inGeometryPoly.move(20,210);
		inGeometryPoly.data = "inGeometryPoly";
		inGeometryPoly.groupName = "inWhat";
		var poly:MovieClip  = attachMovie("DrawPolyImage", "mDrawPolyImage", depth++); 
		poly._x = 10;
		poly._y = 230;
		
        var inGeometryBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryBoxRadioButton", depth++));
		inGeometryBox.move(90,210);
		inGeometryBox.data = "inGeometryBox";
		inGeometryBox.groupName = "inWhat";
		var box:MovieClip = attachMovie("DrawBoxImage", "mDrawBoxImage", depth++);
		box._x = 80; 
		box._y = 230;
		
        var inGeometryCircle:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryCircleRadioButton", depth++));
		inGeometryCircle.move(160,210);
		inGeometryCircle.data = "inGeometryCircle";
		inGeometryCircle.groupName = "inWhat";
		var circle:MovieClip = attachMovie("DrawCircleImage", "mDrawCircleImage", depth++); 
		circle._x = 155;
		circle._y = 230;
		
		sendRequestButton = Button(attachMovie("Button", "mSendRequestButton", depth++));
	    this["mSendRequestButton"].onRelease = function(){_parent.onClickRequestButton();};
		this["mSendRequestButton"].move(20,290);
		this["mSendRequestButton"].setSize(180,20);
		var label:String = _global.flamingo.getString(this,"requestButtonLabel");
		if(label == undefined){
			label = "OK";
		}	
		this["mSendRequestButton"].label = label;
		infoButton = Button(attachMovie("Button", "mInfoButton", depth++));
	  	this["mInfoButton"].onRelease = function(){_parent.onClickInfoButton();};
		this["mInfoButton"].move(20,315);
		this["mInfoButton"].setSize(180,20);
		label = _global.flamingo.getString(this,"infoButtonLabel");
		if(label == undefined){
			label = "Information";
		}
		this["mInfoButton"].label = label;
		
		closeButton = Button(attachMovie("Button", "mCloseButton", depth++));
	  	this["mCloseButton"].onRelease = function(){_parent.onClickCloseButton();};
		this["mCloseButton"].move(20,340);
		this["mCloseButton"].setSize(180,20);
		label = _global.flamingo.getString(this,"closeButtonLabel");
		if(label == undefined){
			label = "Close";
		}
		this["mCloseButton"].label = label;
		
		statusLine = createTextField("mCommandLine",depth++,0,370,this._width,60);
		statusLine.multiline = true;
		statusLine.wordWrap = true;
		this["inWhat"].addEventListener("click", Delegate.create(this, onClickRadioButton));
	}
	
	private function onChangeInArea(evtObj:Object) : Void {
		inArea = evtObj.target.selectedItem;
	}
	

	function resetControls(){
		if(this._visible){
			removeStatusText();
			//ddeConnector.setAreaSelectionType("inArea");
			RadioButton(this["mInAreaRadioButton"]).selected = true;
			RadioButton(this["mInAreaRadioButton"]).setFocus();
			this.setAreaSelectionType("inArea");
			inAreaChoser.enabled = true;
			llX.enabled = false;
			llY.enabled = false;
			urX.enabled = false;
			urY.enabled = false;
			setExtent();
			setExtentButton.enabled = false;
		}
	}
	
	function setStatusText(statusText:String, type:String, permanent:Boolean):Void{
		if(type=="url"){
			statusLine.html = true;
			statusLine.setNewTextFormat(textFormatUrl);
			statusLine.htmlText = statusText
		} else {
			if(type=="warning"){
				statusLine.setNewTextFormat(textFormatWarning);	
			} else {
			if(type=="info"){
				statusLine.setNewTextFormat(textFormatInfo);	
				} else {
					statusLine.setNewTextFormat(textFormat);	
				}
			}
			statusLine.html = false;	
			statusLine.text = statusText;
		}
		if(permanent != true && statusText != ""){
			statusDelayIntervalID = setInterval(this, "removeStatusText", 5000);
		}
		
    }
	
	function removeStatusText():Void{
		clearInterval(statusDelayIntervalID);
      	statusDelayIntervalID = 0;
		setStatusText("");
	}
    
	
    private function onClickRadioButton(evtObj:Object):Void {
		removeStatusText();
		var selectedOption:String = evtObj.target.selectedRadio.data;
		if(map["mTraceSheet"]!=null){
			map["mTraceSheet"].removeMovieClip();
		}
		llX.enabled = false;
		llY.enabled = false;
		urX.enabled = false;
		urY.enabled = false;
		setExtentButton.enabled = false;
		inAreaChoser.enabled = false;
		switch (selectedOption){
			case "inArea" :
         		inAreaChoser.enabled = true;
				this.setAreaSelectionType("inArea");
				break;
			case "inBox" :
				llX.enabled = true;
				llY.enabled = true;
				urX.enabled = true;
				urY.enabled = true;
				setExtentButton.enabled = true;
				this.setAreaSelectionType("inBox");
				onChangeBox();
				break;	
			case "inGeometryPoly" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"tracePoly");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;
			case "inGeometryBox" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceBox");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);	
				break;	
			case "inGeometryCircle" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceCircle");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;	
	
		}     
    }
	
	private function onClickGetExtentButton(evtObj:Object):Void {
		setExtent();
	}
	
	private function setExtent():Void{
		if (map.getMapExtent() != undefined){
			if(map.getMapExtent().minx < map.getFullExtent().minx) {
				llX.text = Math.round(map.getFullExtent().minx).toString();
			} else {
				llX.text = Math.round(map.getMapExtent().minx).toString();	
			}
			if( map.getMapExtent().miny < map.getFullExtent().miny) {
				llY.text = Math.round(map.getFullExtent().miny).toString();
			} else {
				llY.text = Math.round(map.getMapExtent().miny).toString();
			}
			if(map.getFullExtent().maxx <= map.getMapExtent().maxx){
				urX.text = Math.round(map.getFullExtent().maxx).toString();
			} else {
				urX.text = Math.round(map.getMapExtent().maxx).toString();
			}
			if(map.getFullExtent().maxy <= map.getMapExtent().maxy){
				urY.text = Math.round(map.getFullExtent().maxy).toString();
			} else {
				urY.text = Math.round(map.getMapExtent().maxy).toString();
			}
			onChangeBox();
		} 
	}
	
	private function onClickRequestButton():Void{
		var busyText:String = _global.flamingo.getString(this,"busy");
		if(busyText==null||busyText==""){
			busyText="Ophalen populatie gegevens....";
		}
		setStatusText(busyText,"info",true);
		this["mSendRequestButton"].enabled = false;
		var area:Number = null;
		if(areaSelectionType=="inGeometry"){
			area = getArea(coords);
		}  
		if(areaSelectionType=="inBox"){
			var crds:Array = coords.split(",");
			area =(crds[2]-crds[0]) * (crds[3]-crds[1]); 	
		}
		if(areaSelectionType!="inArea"){
			if(area < 1000000){
				popDataConnector.getReport(areaSelectionType,inArea, coords);
			} else {
				if(area > 20000000){
					setStatusText("Gebied te groot, selecteer een kleiner gebied (max. 20km2).", "warning", true);
					this["mSendRequestButton"].enabled = true;
				} else {
					popDataConnector.getReport(areaSelectionType + "_pc",inArea, coords);
				}
			}
		} else {
			popDataConnector.getReport(areaSelectionType,inArea, coords);
		}	
	}
	
	private function onClickCloseButton():Void{
		this.setVisible(false);
	}
	
	private function onClickInfoButton():Void{
    	var url:String =_global.flamingo.getString(this,"infoButtonUrl");
    	ExternalInterface.call("popWin",url);  
	}
	
	private function onChangeBox(evtObj:Object):Void{
		coords = llX.text + "," + llY.text + "," +  urX.text + "," + urY.text;
		if(areaSelectionType=="inBox"){
			var crds:Array = coords.split(",");
			setStatusText("Opp.van de rechthoek: " + Math.round((crds[2]-crds[0]) * (crds[3]-crds[1])/10000)/100 + " km2", "info", true);
		}
	}
	
	function onChangeGeometry(geometry:Geometry):Void{
		var crds:Array = geometry.getCoords();
		coords = "";
		for (var n:Number = 0; n<crds.length; n++){
			this.coords += crds[n].getX() + "," + crds[n].getY() + ",";
		}
		coords = coords.substr(0,coords.length-2);	
	}
	
	function onFinishGeometry(geometry:Geometry):Void{
		setStatusText("Opp.van de geometrie: " + Math.round(getArea(coords)/10000)/100 + " km2", "info", true);
	}
	
	
	
	private  function getArea(coords):Number {
		var crds:Array = coords.split(",");
   		var area:Number = 0;
   		var points:Array = new Array();
		for (var i:Number = 0; i < crds.length; i++) {
			var point:Point = new Point(crds[i],crds[i++]);
			points.push(point);
		}
		for (var i:Number = 0; i < points.length-1; i++) {	
			area += ( points[i].getX() * points[i+1].getY() - points[i+1].getX() * points[i].getY() );
		}
		area /= -2.0;
		return Math.abs(area);
	}
	
	
	
    function setAttribute(name:String, value:String):Void {	
        switch (name) {
			case "reporturl":
				popDataConnector.setReportUrl(value);
				break;
			case "areasurl":
				popDataConnector.setAreasUrl(value);
				break;	
			case "resulttext":
				resultCompId = value;
				break;
        }
    }
	
	function onUpdate(map:MovieClip):Void{
	}
	
	public function onAreaLoad(result : XML) : Void {
			var areas:Array = new Array();
		 	var list:Array = result.firstChild.childNodes;
			for (var i = 0; i<list.length; i++) {	
				if(list[i].nodeName == "Gebied"){
					areas.push({label:list[i].attributes["label"],data:list[i].attributes["name"],type:list[i].attributes["type"]});
				}
			}
			inAreaChoser.dataProvider = areas;
			inAreaChoser.open();
			inAreaChoser.close();
	}
	
	public function onPopulationReportLoad(result : XML) : Void {
		removeStatusText();
		this["mSendRequestButton"].enabled = true;
		var resultComp:Object =_global.flamingo.getComponent(this.resultCompId);
		resultComp.ta.border_mc.setStyle("borderStyle", "none");
		var txt:String = result.toString().split("\\t").join("\t");
		txt = txt.split("\\n").join("\n");
		resultComp.setText( txt);
		resultComp._visible =true;
		if (resultComp._parent._parent._name == "mWindow") {
            resultComp._parent._parent._parent.setVisible(true);
        }
		
	}
	
	function onLoadFail(result : XML) : Void {
		this["mSendRequestButton"].enabled = true;
		setStatusText("Er is een fout opgetreden.", "warning", true);
	}
	
	private function setAreaSelectionType(areaSelectionType : String) : Void {
		this.areaSelectionType = areaSelectionType;
	}
	

}
