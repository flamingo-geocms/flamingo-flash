/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component DownloadSelector
* This component is shown in the Window component of Flamingo and offers an user 
* interface for configuring and sending an url to download a DDE layer to the client.  
* @file flamingo/fmc/classes/flamingo/gui/dde/DownloadSelector.as  (sourcefile)
* @file flamingo/fmc/DownloadSelector.fla (sourcefile)
* @file flamingo/fmc/DownloadSelector.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/DownloadSelector.xml (configurationfile, needed for publication on internet)
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

import gui.dde.*;
import geometrymodel.dde.*;
import coremodel.service.dde.*;
import mx.controls.List;
import mx.utils.Delegate;
import mx.controls.RadioButton;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.containers.ScrollPane;

import core.AbstractComponent;

class gui.dde.DownloadSelector extends AbstractComponent implements GeometryListener,DDEConnectorListener {
    var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<DownloadSelector>" + 
							"<string id='layers' en='Layers' nl='Kaartlagen'/>" +
						      "<string id='inArea' en='Within Area' nl='Binnen gebied'/>" +
						      "<string id='inGeometry' en='Within Geometry' nl='Binnen geometrie'/>"+
						      "<string id='inBox' en='Within Box' nl='Binnen rechthoek'/>" +
						      "<string id='inAll' en='Whole file' nl='Gehele bestand'/>" +
						      "<string id='crs' en='Coord. Ref. System' nl='Coordinaatstelsel'/>" +
						      "<string id='format' en='File Format' nl='Bestandsformaat'/>" +
						      "<string id='emailAddress' en='Email Download To' nl='Download e-mailen naar'/>" +
						      "<string id='warningNoLayer' en='Please select a layer' nl='Selecteer eerst een laag'/>" +
						      "<string id='warningNoEmail' en='Please fill in a valid e-mail adress' nl='Vul een geldig e-mail adres in'/>" +
						      "<string id='warningOutOfExtent' en='Requested extent outside the fullextent of the map' nl='Ingevulde coördinaten vallen buiten bereik van de kaart'/>" +
						      "<string id='warningErrorInBox' en='Error in box coördinates' nl='Fouten in coördinaten van rechthoek'/>" +
						      "<string id='extentButtonLabel' en='from map' nl='van kaart'/>" + 
						      "</DownloadSelector>";
    private var legend:Object = null;
    private var map:Object = null;
    private var depth:Number = 0;
	
	private var inAreas:Array;
	
	private var crss:Array;
	
	private var formats:Array;
	
	private var layers:Array;
	
	private var textFormatUrl:TextFormat;
	
	private var textFormatWarning:TextFormat;
	
	private var textFormatInfo:TextFormat;
	
	private var textFormat:TextFormat;
	
    private var statusDelayIntervalID:Number = 0;
		
	private var sendRequestButton:Button;
	private var closeButton:Button;

	private var ddeConnector:DDEConnector;
	
	private var geometry:Geometry;
	
	private var inAreaChoser; 
	private var llX:TextInput;
	private var llY:TextInput;
	private var urX:TextInput;
	private var urY:TextInput;
	private var setExtentButton;
	private var layerPane:ScrollPane;
	private var eMailInput:TextInput;
	private var statusLine:TextField;
	private var legendItems:Array;
	private var debug:Boolean = false;
	
    function onLoad():Void {
		ddeConnector = new DDEConnector;
		ddeConnector.addListener(this);
		ddeConnector.setAreaSelectionType("inArea");
		inAreas=new Array();
		crss=new Array();
		formats=new Array();
		layers=new Array();
		super.onLoad();
	}
	
	function init():Void{
		map = _global.flamingo.getComponent(listento[0]);
		legend =_global.flamingo.getComponent(listento[1]);
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
		textFormatInfo.color = 0x00ff00;
		addControls();
		resetControls();
	}

	function fillLegendItems(items:Array):Void {
		for (var i:Number = 0; i < items.length; i++){
			if (items[i].listento != null){
				legendItems.push({label:items[i].label,listento:items[i].listento})
			}
			if (items[i].items.length > 0){
				var subItems:Array  = new Array();
				for (var j:Number = 0; j < items[i].items.length ; j++){
					subItems.push(items[i].items[j]);
				}
				fillLegendItems(subItems);
			} 
		}
		
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
        var layersLabel = attachMovie("Label", "mLayersLabel", depth++);		
		layersLabel.move(10,10);
		layersLabel.text = _global.flamingo.getString(this,"layers");
		layerPane = ScrollPane(attachMovie("ScrollPane", "mScrollPane", depth++));
		layerPane.move(10,30);
        layerPane.setSize(190, 270);
		layerPane.contentPath = "DownloadLegend";	
		
        var inArea:RadioButton = RadioButton(attachMovie("RadioButton", "mInAreaRadioButton", depth++));
		inArea.move(240,0);
		inArea.data = "inArea";
		inArea.groupName = "inWhat";
		inArea.label =_global.flamingo.getString(this,"inArea");
		inArea.selected = true;
		inArea.setSize(200,20);
		
		inAreaChoser = this["mHolder"].createClassObject(mx.controls.ComboBox, "cmbInAreaChoser", 1);
		inAreaChoser.dataProvider = inAreas;
		// to get rid of sticky focusrects use these lines
		inAreaChoser.drawFocus = "";
		inAreaChoser.getDropdown().drawFocus = "";
		// to prevent the list to close after scrolling
		inAreaChoser.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		inAreaChoser.move(265, 20);
		inAreaChoser.setSize(170,25);
		//open/close to make sure that the ddeConnector value is set with the first in the list
		inAreaChoser.addEventListener("close", Delegate.create(this, onChangeInArea));
		inAreaChoser.open();
		inAreaChoser.close();

        var inBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInBoxRadioButton", depth++));
		inBox.move(240,60);
		inBox.data = "inBox";
		inBox.groupName = "inWhat";
		inBox.label = _global.flamingo.getString(this,"inBox");
		inBox.setSize(200,20);
		
		var bBox:MovieClip = this.createEmptyMovieClip("mbBox", depth++);
		bBox._x = 240;
		bBox._y = 75;
		var xLabel:TextField = bBox.createTextField("tXLabel",depth++,25,0, 90,20);
		xLabel.setNewTextFormat(textFormat);
		xLabel.text = "X:"
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
		
		var inGeometryLabel:TextField = createTextField("mInGeometryLabel",depth++,240,190,200,20);
		inGeometryLabel.setNewTextFormat(textFormat);
		inGeometryLabel.text = _global.flamingo.getString(this,"inGeometry");
		
        var inGeometryPoly:RadioButton  = RadioButton(attachMovie("RadioButton", "mInGeometryPolyRadioButton", depth++));
		inGeometryPoly.move(250,210);
		inGeometryPoly.data = "inGeometryPoly";
		inGeometryPoly.groupName = "inWhat";
		var poly:MovieClip  = attachMovie("DrawPolyImage", "mDrawPolyImage", depth++); 
		poly._x = 240;
		poly._y = 230;
		
        var inGeometryBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryBoxRadioButton", depth++));
		inGeometryBox.move(320,210);
		inGeometryBox.data = "inGeometryBox";
		inGeometryBox.groupName = "inWhat";
		var box:MovieClip = attachMovie("DrawBoxImage", "mDrawBoxImage", depth++);
		box._x = 310; 
		box._y = 230;
		
        var inGeometryCircle:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryCircleRadioButton", depth++));
		inGeometryCircle.move(390,210);
		inGeometryCircle.data = "inGeometryCircle";
		inGeometryCircle.groupName = "inWhat";
		var circle:MovieClip = attachMovie("DrawCircleImage", "mDrawCircleImage", depth++); 
		circle._x = 385;
		circle._y = 230;
		
       	var inAll:RadioButton = RadioButton(attachMovie("RadioButton", "mInAllRadioButton", depth++ ));
		inAll.move(240,280);
		inAll.label = _global.flamingo.getString(this,"inAll");
		inAll.data = "inAll";
		inAll.groupName = "inWhat";
		inAll.setSize(200,20);
		
		
		var crsChoserLabel:TextField = createTextField("mCrsChoserLabel",depth++,10,310,200,20);
		crsChoserLabel.setNewTextFormat(textFormat);
		crsChoserLabel.text = _global.flamingo.getString(this,"crs");
		var crsChoser = this["mHolder"].createClassObject(mx.controls.ComboBox, "cmbCrsChoser", 2);
		crsChoser.dataProvider = crss;
		crsChoser.rowCount = 3;
		// to get rid of sticky focusrects use these lines
		crsChoser.drawFocus = "";
		crsChoser.getDropdown().drawFocus = "";
		crsChoser.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		crsChoser.move(10, 330);
		crsChoser.setSize(190,25);
		crsChoser.addEventListener("close", Delegate.create(this, onChangeCrs));
		crsChoser.open();
		crsChoser.close();
		
		var formatChoserLabel:TextField = createTextField("mFormatChoserLabel",depth++,240,310,200,20);
		formatChoserLabel.setNewTextFormat(textFormat);
		formatChoserLabel.text = _global.flamingo.getString(this,"format");
		var formatChoser = this["mHolder"].createClassObject(mx.controls.ComboBox, "cmbFormatChoser", 3);
		formatChoser.dataProvider = formats;
		formatChoser.rowCount = 3;
		// to get rid of sticky focusrects use these lines
		formatChoser.drawFocus = "";
		formatChoser.getDropdown().drawFocus = "";
		formatChoser.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		formatChoser.move(240, 330);
		formatChoser.setSize(190,25);
		formatChoser.addEventListener("close", Delegate.create(this, onChangeFormat));
		formatChoser.open();
		formatChoser.close();
		
		var eMailLabel:TextField = createTextField("mEmailLabel",depth++,10,370,200,20);
		eMailLabel.setNewTextFormat(textFormat);	
		eMailLabel.text = _global.flamingo.getString(this,"emailAddress");
		eMailInput = TextInput(attachMovie("TextInput","mEmailInput",depth++));
		eMailInput.addEventListener("change", Delegate.create(this, onChangeEMail));
		eMailInput.move(10,390);
		eMailInput.setSize(190,25);

		sendRequestButton = Button(attachMovie("Button", "mSendRequestButton", depth++));
	    this["mSendRequestButton"].onRelease = function(){_parent.onClickRequestButton();};
		this["mSendRequestButton"].move(250,365);
		this["mSendRequestButton"].setSize(180,20);
		var label:String = _global.flamingo.getString(this,"requestButtonLabel");
		if(label == undefined){
			label = "OK";
		}	
		this["mSendRequestButton"].label = label;
		closeButton = Button(attachMovie("Button", "mCloseButton", depth++));
	  	this["mCloseButton"].onRelease = function(){_parent.onClickCloseButton();};
		this["mCloseButton"].move(250,390);
		this["mCloseButton"].setSize(180,20);
		label = _global.flamingo.getString(this,"closeButtonLabel");
		if(label == undefined){
			label = "Close";
		}
		this["mCloseButton"].label = label;
		
		
		statusLine = createTextField("mCommandLine",depth++,10,420,this._width - 20,60);
		statusLine.multiline = true;
		statusLine.wordWrap = true;
		this["inWhat"].addEventListener("click", Delegate.create(this, onClickRadioButton));
		
    }
	
	function resetControls(){
		if(this._visible){
			setExtent();
			ddeConnector.setAreaSelectionType("inArea");
			RadioButton(this["mInAreaRadioButton"]).selected = true;
			RadioButton(this["mInAreaRadioButton"]).setFocus();
			inAreaChoser.enabled = true;
			inAreaChoser.open();
			inAreaChoser.close();
			llX.enabled = false;
			llY.enabled = false;
			urX.enabled = false;
			urY.enabled = false;
			setExtentButton.enabled = false;
			var adress:String = _global.flamingo.getCookie("userEMail");
			if(adress!=null){
				eMailInput.text = adress;
			}
			ddeConnector.setEMail(adress);
			DownloadLegend(layerPane.content).setMap(map);
			DownloadLegend(layerPane.content).setLegend(legend, debug);
			DownloadLegend(layerPane.content).setDDEConnector(ddeConnector);
		}
	}
	
	private function setStatusText(statusText:String, type:String):Void{
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
		statusDelayIntervalID = setInterval(this, "removeStatusText", 5000);
    }
	
	private function removeStatusText():Void{
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
				ddeConnector.setAreaSelectionType("inArea");
				ddeConnector.setClippingCoords(inAreaChoser.selectedItem.data);
				break;
			case "inBox" :
				llX.enabled = true;
				llY.enabled = true;
				urX.enabled = true;
				urY.enabled = true;
				setExtentButton.enabled = true;
				ddeConnector.setAreaSelectionType("inBox");
				ddeConnector.setBBox(Number(llX.text),Number(llY.text),Number(urX.text),Number(urY.text));
				break;	
			case "inGeometryPoly" :
				ddeConnector.setAreaSelectionType("inGeometry");
				ddeConnector.setClippingCoords("");
         		var traceLayer:TraceLayer = new TraceLayer(map,"tracePoly");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;
			case "inGeometryBox" :
				ddeConnector.setAreaSelectionType("inGeometry");
				ddeConnector.setClippingCoords("");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceBox");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);	
				break;	
			case "inGeometryCircle" :
				ddeConnector.setAreaSelectionType("inGeometry");
				ddeConnector.setClippingCoords("");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceCircle");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;	
			case "inAll" :
				ddeConnector.setAreaSelectionType("inAll");
				ddeConnector.setClippingCoords("");
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
			ddeConnector.setBBox(Number(llX.text),Number(llY.text),Number(urX.text),Number(urY.text));	
		} 
	}
	
	private function onClickRequestButton():Void{
		if(ddeConnector.getSelectedLayers() == undefined){
			setStatusText(_global.flamingo.getString(this,"warningNoLayer"),"warning");
		}
		else 
		if (eMailInput.text == "" || eMailInput.text.indexOf("@")==-1){
			setStatusText(_global.flamingo.getString(this,"warningNoEmail"),"warning");
		} else 
		if (Number(llX.text) < map.getFullExtent().minx  || Number(urX.text) > map.getFullExtent().maxx 
			|| Number(llY.text) < map.getFullExtent().miny  || Number(urY.text) > map.getFullExtent().maxy){
			setStatusText(_global.flamingo.getString(this,"warningOutOfExtent"),"warning");	
		}
		else 
		if (Number(llX.text) >= Number(urX.text) || Number(llY.text) >= Number(urY.text)){
			setStatusText(_global.flamingo.getString(this,"warningErrorInBox"),"warning");	
		} else {
			removeStatusText();
			ddeConnector.sendRequest("startDownload");
		}
	}
	
	
	private function onClickCloseButton():Void{
		this.setVisible(false);
	}
	
	private function onChangeInArea(evtObj:Object):Void{
		ddeConnector.setClippingCoords(evtObj.target.selectedItem.data);
	}
	
	private function onChangeBox(evtObj:Object):Void{
		ddeConnector.setBBox(Number(llX.text),Number(llY.text),Number(urX.text),Number(urY.text));
	}
	
	private function onChangeCrs(evtObj:Object):Void{
		ddeConnector.setCoordsys(evtObj.target.selectedItem.data);
	}
	
	private function onChangeFormat(evtObj:Object):Void{
		ddeConnector.setFormat(evtObj.target.selectedItem.data);
	}

	function onChangeGeometry(geometry:Geometry):Void{
		ddeConnector.setClippingPoints(geometry.getCoords())
	}
	
	function onDDELoad(result:XML):Void{
		var resultType:String = result.firstChild.nodeName;
		if(resultType=="message"){
			setStatusText(result.firstChild.firstChild.nodeValue,"info");
		}
	}
	
	
	function onChangeEMail(eventObj:Object):Void{
		ddeConnector.setEMail(eventObj.target.text);
	}
    

    function setAttribute(name:String, value:String):Void {	
        switch (name) {
			case "ddeservleturl":
				ddeConnector.setServletUrl(value);
				break;
			case "debug":
				if(value == "true"){
					this.debug = true;
				} else {
					this.debug = false
				}
				break;
        }
    }
	
	function addComposite(name:String, value:XMLNode):Void {	
		switch (name) {
		   case "inArea":
                inAreas.push({label:value.attributes.label,data:value.attributes.coords});
                break;
            case "crs":
				 crss.push({label:value.attributes.label,data:value.attributes.data});
				 break;
			case "outputFormat":
				 formats.push({label:value.attributes.label,data:value.attributes.data});
				 break;
			case "downloadLayer":
				 layers.push({label:value.attributes.legendItem,data:value.attributes.ddeLayerName});
				 break; 
			case "DownloadLegend":	 
				var id:String;
				for (var attr in value.attributes) {
					if (attr.toLowerCase() == "id") {
					id = value.attributes[attr];
					break;
					}
				}
				if (id == undefined) {
					id = _global.flamingo.getUniqueId();
					value.attributes.id = id;
				}
				if (_global.flamingo.exists(id)) {
					// id already in use let flamingo manage double id's
					_global.flamingo.addComponent(value, id);
				} else {
					layerPane.contentPath = "DownloadLegend"; 
					_global.flamingo.loadComponent(value, layerPane.content, id);
				}
		}
	}
	
	function onUpdate(map:MovieClip):Void{
		
	}


    
}
