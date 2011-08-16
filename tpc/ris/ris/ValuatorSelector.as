/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component PopulatorSelector
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

import mx.controls.CheckBox;	

import geometrymodel.dde.*;
import mx.utils.Delegate;
import mx.controls.RadioButton;
import mx.controls.ComboBox;
import mx.controls.TextInput;


import gui.dde.TraceLayer;

import ris.PopDataConnectorListener;
import ris.ValuatorConnector;


import flash.external.ExternalInterface;

import ris.AbstractSelector;
import ris.ValuatorData;

import tools.XMLTools;

class ris.ValuatorSelector extends AbstractSelector {
    var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<ValuatorSelector>" + 
							  "<string id='layers' en='Layers' nl='Kaartlagen'/>" +
						      "<string id='inGeometry' en='Within Geometry' nl='Binnen geometrie'/>"+
						      "<string id='inBox' en='Within Box' nl='Binnen rechthoek'/>" +
						      "<string id='inAll' en='Whole file' nl='Gehele bestand'/>" +
						      "<string id='warningOutOfExtent' en='Requested extent outside the fullextent of the map' nl='Ingevulde coördinaten vallen buiten bereik van de kaart'/>" +
						      "<string id='warningErrorInBox' en='Error in box coördinates' nl='Fouten in coördinaten van rechthoek'/>" +
						      "<string id='extentButtonLabel' en='from map' nl='van kaart'/>" + 
						      "</ValuatorSelector>";   

	private var wTWLP:CheckBox = null;
	private var wTWCP:CheckBox = null;
	private var wPWLP:CheckBox = null;
	private var wPWCP:CheckBox = null;
	
	private var pTotaal:RadioButton = null;
	private var pBedrijfstak:RadioButton = null;
	private var pBedrijfsklasse:RadioButton = null;
	
	private var valData:ValuatorData = null;
	
	//
	private var mWorths:Array;
	private var mPeriods:Array;
	private var mPublications:Array;
	



	
	function onLoad():Void {
		areaSelector = false;
   		boxSelector = true;
   		geometrySelector = true;
		dataConnector = new ValuatorConnector();
		this.setAreaSelectionType("inBox");
		super.onLoad();
	}
	
	function init():Void{
		super.init();
		this.valData = new ValuatorData(this);
		addAreaControls(0,0);
		addReportSettingsControls(250,0);
		addButtons(500,210);
		addStatusLine(0,275);
		resetControls();	
	}
	
	function getConnector():ValuatorConnector{
		return ValuatorConnector(this.dataConnector);
	}
	
	private function addReportSettingsControls(x:Number, y:Number):Void {
		var infoTitle:TextField = createTextField("mInformationTitle",this.getNextHighestDepth(),x,y,this._width,20);
		infoTitle.text = _global.flamingo.getString(this,"titleInformation");
		infoTitle.setTextFormat(textFormat);
		infoTitle.selectable = false;
		y += 20;

		mWorths = new Array();
		var initObject:Object = new Object();
		initObject["_x"] = x;
		initObject["_width"] = 250;
		initObject["_y"] = y;
		initObject["selected"] = false;
		initObject["label"] = "Toegevoegde waarde: Lopende prijzen";
		initObject["worth"] = "TWLP";
		wTWLP= CheckBox(attachMovie("CheckBox", "mTWLP", this.getNextHighestDepth(),initObject));
		mWorths.push(wTWLP);
		initObject["_y"] += 25;
		initObject["label"] = "Toegevoegde waarde: Constante prijzen";
		initObject["worth"] = "TWCP";
		wTWCP= CheckBox(attachMovie("CheckBox", "mTWCP", this.getNextHighestDepth(),initObject));
		mWorths.push(wTWCP);
		initObject["label"] = "Productie waarde: Lopende prijzen";
		initObject["_y"] += 25;
		initObject["worth"] = "PWLP";
		wPWLP= CheckBox(attachMovie("CheckBox", "mPWLP", this.getNextHighestDepth(),initObject));
		mWorths.push(wPWLP);
		initObject["label"] = "Productie waarde: Constante prijzen";
		initObject["_y"] += 25;
		initObject["worth"] = "PWCP";
		wPWCP= CheckBox(attachMovie("CheckBox", "mPWCP", this.getNextHighestDepth(),initObject));
		mWorths.push(wPWCP);
		y += 110;
		
		mPublications = new Array();
		var pubTitle:TextField = createTextField("mPubLevelTitle",this.getNextHighestDepth(),x,y,this._width,20);
		pubTitle.text = _global.flamingo.getString(this,"titlePubLevel");
		pubTitle.setTextFormat(textFormat);
		pubTitle.selectable = false;
		y += 20;
		initObject["groupName"]="pubLevel"
		initObject["_y"] = y;
		initObject["label"] = "Totaal van het gebied";
		initObject["publication"]="TOTAAL";
		pTotaal = RadioButton(attachMovie("RadioButton", "mTotaal", this.getNextHighestDepth(),initObject));
		mPublications.push(pTotaal);
		initObject["_y"] += 20;
		initObject["label"] = "Per CBS Bedrijfstak";
		initObject["publication"]="BEDRIJFSTAKKEN";
		pBedrijfstak = RadioButton(attachMovie("RadioButton", "mBedrijfstak", this.getNextHighestDepth(),initObject));
		mPublications.push(pBedrijfstak);
		initObject["_y"] += 20;
		initObject["label"] = "Per CBS bedrijfsklasse";
		initObject["publication"]="BEDRIJFSKLASSEN";
		pBedrijfsklasse = RadioButton(attachMovie("RadioButton", "mBedrijfsklasse", this.getNextHighestDepth(),initObject));
		mPublications.push(pBedrijfsklasse);
	}
	
	function addPeriodControls(x:Number, y:Number):Void {
		var periodTitle:TextField = createTextField("mPeriodTitle",this.getNextHighestDepth(),x,y,this._width,20);
		periodTitle.text = _global.flamingo.getString(this,"titlePeriod");
		periodTitle.setTextFormat(textFormat);
		periodTitle.selectable = false;
		y+=20;
		var periods:Array = valData.getYears();
		 mPeriods =  new Array();
		var initObject:Object = new Object();
		initObject["_x"] = x;
		initObject["_width"] = 250;
		initObject["_y"] = y;
		initObject["selected"] = false;
		for (var i:Number = 0; i<periods.length; i++){
			initObject["label"] = periods[i];
			var period:CheckBox = CheckBox(attachMovie("CheckBox", "mPeriod" + i, this.getNextHighestDepth(),initObject));
			initObject["_y"] += 18;
			mPeriods.push(period);
		}
		
	}


	private function onClickRequestButton():Void{
		var sWorths:Array =  getSelectedValues(mWorths,"worth");
		if(sWorths.length == 0){
			setStatusText(_global.flamingo.getString(this,"warningInformation"),"warning",false);
			return;
		}	
		var sPublications:Array = getSelectedValues(mPublications,"publication");
		if(sPublications.length == 0){
			setStatusText(_global.flamingo.getString(this,"warningPubLevel"),"warning",false);
			return;
		}	
		var iYears:Array = getSelectedValues(mPeriods,"label");
		if(iYears.length == 0){
			setStatusText(_global.flamingo.getString(this,"warningPeriod"),"warning",false);
			return;
		}
		var busyText:String = _global.flamingo.getString(this,"busy");
		if(busyText==null||busyText==""){
			busyText="Ophalen gegevens....";
		}
		setStatusText(busyText,"info",true);
		this["mSendRequestButton"].enabled = false;
		var sWKTArea:String = "POLYGON(("  + wktCoords + "))";

		dataConnector.retrieveWKT(sWKTArea,sWorths,iYears,sPublications);			

	}
	
	private function getSelectedValues(movieArray:Array, valueField:String):Array{
		var sValues:Array = new Array();
		for (var i:Number = 0; i< movieArray.length; i++) {
			if(movieArray[i].selected){
				sValues.push(movieArray[i][valueField]);
			}
		}
		return sValues;
	}
	

	
	
	

		

}
