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
import ris.PopulatorConnector;


import flash.external.ExternalInterface;

import ris.AbstractSelector;
import ris.PopulationData;

class ris.PopulatorSelector extends AbstractSelector {
    var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<PopulatorSelector>" + 
							"<string id='layers' en='Layers' nl='Kaartlagen'/>" +
						      "<string id='inGeometry' en='Within Geometry' nl='Binnen geometrie'/>"+
						      "<string id='inBox' en='Within Box' nl='Binnen rechthoek'/>" +
						      "<string id='inAll' en='Whole file' nl='Gehele bestand'/>" +
						      "<string id='warningOutOfExtent' en='Requested extent outside the fullextent of the map' nl='Ingevulde coördinaten vallen buiten bereik van de kaart'/>" +
						      "<string id='warningErrorInBox' en='Error in box coördinates' nl='Fouten in coördinaten van rechthoek'/>" +
						      "<string id='extentButtonLabel' en='from map' nl='van kaart'/>" + 
						      "</PopulationDataSelector>";

    
	private var maxPop:CheckBox = null;
	private var werkdag:CheckBox = null;
	private var werknacht:CheckBox = null;
	private var weekenddag:CheckBox = null;
	private var weekendnacht:CheckBox = null;
	var perPopType:CheckBox = null;
	private var buttonsX:Number = 250;
	private var popData:PopulationData = null;
	private var wktCoords:String = "";

	
	function onLoad():Void {
		areaSelector = false;
   		boxSelector = true;
   		geometrySelector = true;
		dataConnector = new PopulatorConnector();
		dataConnector.addListener(this);
		this.setAreaSelectionType("inBox");
		
		super.onLoad();
	}
	
	function init():Void{
		super.init();
		addAreaControls(0,0);
		addReportSettingsControls(250,0);
		addButtons(240,200);
		addStatusLine(0,275);
		resetControls();
		popData = new PopulationData(this);
	}
	
	private function addAreaControls(x:Number, y:Number):Void {
		super.addAreaControls(0,25);	
		var reportAreaTitle:TextField = createTextField("mReportAreaTitle",this.getNextHighestDepth(),0,y,this._width,20);
		reportAreaTitle.text = _global.flamingo.getString(this,"titleReportArea");
		reportAreaTitle.setTextFormat(textFormat);	
		reportAreaTitle.selectable = false;
	}

	private function addReportSettingsControls(x:Number, y:Number):Void {
		var reportSettingsTitle:TextField = createTextField("mReportSettingsTitle",this.getNextHighestDepth(),x,y,this._width,20);
		reportSettingsTitle.text = _global.flamingo.getString(this,"titleReportSettings");
		reportSettingsTitle.setTextFormat(textFormat);
		reportSettingsTitle.selectable = false;
		var initObject:Object = new Object();
		initObject["_x"] = x;
		initObject["_width"] = 250;
		initObject["_y"] = y + 25;
		initObject["selected"] = false;
		initObject["label"] = " " + _global.flamingo.getString(this,"maxpop");
		maxPop = CheckBox(attachMovie("CheckBox", "mMaxPop", this.getNextHighestDepth(),initObject));
		initObject["_y"] += 25;
		initObject["label"] = " " + _global.flamingo.getString(this,"werkdag");
		werkdag = CheckBox(attachMovie("CheckBox", "mDag", this.getNextHighestDepth(),initObject));
		initObject["_y"] += 25;
		initObject["label"] = " " + _global.flamingo.getString(this,"werknacht");
		werknacht = CheckBox(attachMovie("CheckBox", "mNacht", this.getNextHighestDepth(),initObject));
		initObject["_y"] += 25;
		initObject["label"] = " " + _global.flamingo.getString(this,"weekenddag");
		weekenddag = CheckBox(attachMovie("CheckBox", "mWeekenddag", this.getNextHighestDepth(),initObject));
		initObject["_y"] += 25;
		initObject["label"] = " " + _global.flamingo.getString(this,"weekendnacht");
		weekendnacht = CheckBox(attachMovie("CheckBox", "mWeekendnacht", this.getNextHighestDepth(),initObject));
		initObject["_y"] += 25;
		initObject["label"] = " " +  _global.flamingo.getString(this,"perpoptype");
		perPopType = CheckBox(attachMovie("CheckBox", "mPerPopType", this.getNextHighestDepth(),initObject));	
	}

	function resetControls():Void{
		if(this._visible){
			removeStatusText();
			enableInBox(true);
		}
	}
	

	
	private function onClickRequestButton():Void{
		var busyText:String = _global.flamingo.getString(this,"busy");
		if(maxPop.selected||werkdag.selected||werknacht.selected||weekendnacht.selected){
			if(busyText==null||busyText==""){
				busyText="Ophalen gegevens....";
			}
			setStatusText(busyText,"info",true);
			this["mSendRequestButton"].enabled = false;
			var activities:String = ""; 
			if(perPopType.selected){
				activities = popData.getPopActivities();
			} else {
				activities = popData.getTotalActivities();
			}
			PopulatorConnector(dataConnector).getReport(areaSelectionType, wktCoords, getAnalyzeTypes(),activities);
		} else {
			var warning:String = _global.flamingo.getString(this,"warning");
			if(busyText==null||busyText==""){
				busyText="Foutieve request....";
			}
			setStatusText(warning,"warning",false);
		}
	}
	

	private function getAnalyzeTypes():String {
		var analyzeTypes:String="";
		if (maxPop.selected){
			analyzeTypes += "&eAnalyzeTypes=MAXIMUM";
		}
		if(werkdag.selected){
			analyzeTypes += "&eAnalyzeTypes=WEEKDAG";
		}
		if(werknacht.selected){
			analyzeTypes += "&eAnalyzeTypes=WEEKNACHT";
		}
		if(weekenddag.selected){
			analyzeTypes += "&eAnalyzeTypes=EINDDAG";
		}
		if(weekendnacht.selected){
			analyzeTypes += "&eAnalyzeTypes=EINDNACHT";
		}
		return analyzeTypes;	
	}
	
	
	function onUpdate(map:MovieClip):Void{
	}
	
	function onChangeBox(evtObj:Object):Void{
		super.onChangeBox(evtObj);coords = llX.text + "," + llY.text + "," +  urX.text + "," + urY.text;
		wktCoords = llX.text + " " + llY.text + "," +  llX.text + " " + urY.text + "," +  urX.text + " " + urY.text + "," +  urX.text + " " + llY.text + "," + llX.text + " " + llY.text;
	}
	
	function onChangeGeometry(geometry:Geometry):Void{
		super.onChangeGeometry(geometry);
		var crds:Array = geometry.getCoords();
		wktCoords = "";
		for (var n:Number = 0; n<crds.length; n++){
			this.wktCoords += crds[n].getX() + " " + crds[n].getY() + ",";
		}
		wktCoords = wktCoords.substr(0,wktCoords.length-1);	
	}
	
	

	public function onReportLoad(result : XML):Void {
		var txt:String = popData.getReportString(result);
		showReport(txt);
	}	
	
	
		

}
