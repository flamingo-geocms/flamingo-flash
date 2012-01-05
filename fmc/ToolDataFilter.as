/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems BV
* email: Abeer.Mahdi@realworld-systems.com
-----------------------------------------------------------------------------*/
/** @component ToolDataFilter
* Tool for filtering features in a map.
* @file ToolDataFilter.as (sourcefile)
* @file ToolDataFilter.fla (sourcefile)
* @file ToolDataFilter.swf (compiled component, needed for publication on internet)
* @file ToolDataFilter.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
*/
var version:String = "3.0";
//-------------------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolDataFilter>" +
						"<string id='tooltip' nl='Selecteren' en='Select'/>" +
						  "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
						  "<string id='alertWindowTitle' nl='Melding' en='Message'/>" +
						  "<string id='alertMessage' nl='De vorige selectie wordt verwijderd. Weet u zeker of u door wilt gaan?' en='The previous selection will be removed, do you want to continue?'/>" +
						  "<string id='yes' nl='Ja' en='Yes'/>" +
						  "<string id='no' nl='Nee' en='No'/>" +
						  "<string id='windowTitle' nl='Selectie' en='Selection'/>" +
						  "<string id='layerLabel' nl='Selecteer onderwerp' en='Select layer'/>" +
						  "<string id='conditionLabel' nl='waarvoor geldt' en='where'/>" +
						  "<string id='clear' nl='wissen' en='clear'/>" +
						  "<string id='cancel' nl='annuleren' en='cancel'/>" +
						  "<string id='ok' nl='Ok' en='Ok'/>" +
						  "<string id='notvalidLabel' >" +
								"<nl><![CDATA[<font color='#ff0000' family ='Verdana' size='9'><b>niet juist of onvolledig ingevuld</b></font>]]></nl>" +
								"<en><![CDATA[<font color='#ff0000' family ='Verdana' size='9'><b>parameters not correct</b></font>]]></en>" +
							"</string>" +
							"</ToolDataFilter>";
var clickdelay:Number = 1000;
var xold:Number;
var yold:Number;
var thisObj:MovieClip = this;
var zoomscroll:Boolean = true;
var skin = "_datafilter";
var enabled = true;
var layers:Array = new Array();
var query:String;
var queryLabel:String;
var layerLabel:String;
var mapServiceId:String;
var valueString:String = "";
var addedText = "\n\n";
var bufferToolid:String;
var between:Boolean = false;
//hide windows
window.visible = false;
alert_window.visible = false;
//---------------------
var lMap:Object = new Object();
lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
	if (thisObj.zoomscroll) {
		if (not _parent.updating) {
			_parent.cancelAll();
			if (delta<=0) {
				var zoom = 80;
			} else {
				var zoom = 120;
			}
			var w = map.getWidth();
			var h = map.getHeight();
			var c = map.getCenter();
			var cx = (w/2)-((w/2)/(zoom/100));
			var cy = (h/2)-((h/2)/(zoom/100));
			var px = (coord.x-c.x)/(w/2);
			var py = (coord.y-c.y)/(h/2);
			coord.x = c.x+(px*cx);
			coord.y = c.y+(py*cy);
			map.moveToPercentage(zoom,coord,500,0);
			_parent.updateOther(map,500);
		}
	}
};
lMap.onChangeExtent = function(map:MovieClip):Void  {
	if (map.hasextent && window.visible == true) {
		var rect = map.extent2Rect(map._extent);
		//change the location of the window and rectangular if its opened
		showWindow(rect.width,rect.height);
	}
};

var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function( lang:String ) {
	setWindowLabels();
	refresh();
};
flamingo.addListener(lFlamingo, "flamingo", this);
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolDataFilter>  
* This tag defines a tool that filters the data from the layer according to specific attributes. When the tool is clicked a window is shown where the attributes can be selected, after that the map is refreshed. 
* This tool works only with an ArcIMS mapservices.
* @hierarchy childnode of <fmc:ToolGroup> 
* @example 
*	 <fmc:ToolGroup>
*		<fmc:ToolDataFilter id="datafilter" mapServiceId="samenleving" bufferToolid="buffer">
*			 <layer id="basisscholen" label="basisscholen">
*				 <field id="gemeente" label="gemeente" operations="=" includeValues="../config/PZH_gemeenten.xml"/>
*			 </layer>
*		 </fmc:ToolDataFilter>
*	</fmc:ToolGroup>
*
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr mapServiceId The id of the mapservice where the filter is applied to
* @attr bufferToolid The id of the toolBuffer if existing.
*
* @tag <layer>  
* This defines the layer where the buffer is applied to
* @attr id  layerid, same as in the mxd. layerid can also be configered as [mapServiceId].[layerId] than the mapServiceId is ommited. 
* In this way layerids from different services can be combined in one tooldatafilter. 
* @attr label label of the layer that will be shown in the selection window
*
* @tag <field>  
* This defines the layer where the buffer is applied to
* @attr id  id of the field as defined in the database.
* @attr label label of the field that will be shown in the selection window
* @attr operations A comma seperated list of the operations that can be applied to the field 
* (possible values "=","&gt;","&lt;") When both "&gt" and "&lt" are present a between operation can be issued
* by filling in a second constraint. 
* @attr includeValues the path to the field where the attribute values are defined.
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolDataFilter "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
	//defaults
	this.setConfig(defaultXML);
	//custom
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this,"onInit",this);
	//this.noSelection = true;
}
/**
* Configurates a component by setting a xml.
* @attr xml:Object Xml or string representation of a xml.
*/
function setConfig(xml:Object) {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	//load default attributes, strings, styles and cursors         
	flamingo.parseXML(this,xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
			case "zoomfactor" :
				zoomfactor = Number(val);
				break;
			case "zoomdelay" :
				zoomdelay = Number(val);
				break;
			case "clickdelay" :
				clickdelay = Number(val);
				break;
			case "zoomscroll" :
				if (val.toLowerCase() == "true") {
					zoomscroll = true;
				} else {
					zoomscroll = false;
				}
				break;
			case "skin" :
				skin = val+"_zoomin";
				break;
			case "enabled" :
				if (val.toLowerCase() == "true") {
					enabled = true;
				} else {
					enabled = false;
				}
				break;
			case "id" :
				id = val;
				break;
			case "mapserviceid" :
				mapServiceID = val;
				break;
			case "buffertoolid" :
				bufferToolid = val;
				break;
			default :
				break;
		}
	}	
	var layerXml = xml.childNodes;
	for (var i = 0; i<layerXml.length; i++) {
		var layer = layerXml[i];
		layers[i] = new Object();
		for (var attr in layer.attributes) {
			var layerAtt:String = attr.toLowerCase();
			var val:String = layer.attributes[attr];
			switch (layerAtt) {
				case "label" :
					layers[i].layerName = val;
					break;
				case "id" :
					if(val.indexOf(".")!=-1){
						layers[i].mapServiceID = val.substring(0,val.indexOf("."));
						layers[i].layerID =val.substring(val.indexOf(".") + 1);
					} else {
						layers[i].mapServiceID = mapServiceID;	
						layers[i].layerID =val;
					}
				break;		
				default :
					break;
			}
		}
		var subfieldXml = xml.childNodes[i].childNodes;
		var fields:Array = new Array();
		for (var j = 0; j<subfieldXml.length; j++) {
			var subfield = subfieldXml[j];
			var field:Object = new Object();
			for (var attr in subfield.attributes) {
				var subfieldAtt:String = attr.toLowerCase();
				var val:String = subfield.attributes[attr];
				switch (subfieldAtt) {
					case "label" :
						field.fieldName = val;
						break;
					case "id" :
						field.fieldID = val;
						break;
					case "operations" :
						field.operations = val;
						if(val.indexOf("<")!=-1&&val.indexOf(">")!=-1){
							field.between = true;
						} else {
							field.between = false;
						}	 
						break;
					case "includevalues" :
						field.valuesFile = val;
						break;
					default :
						break;
				}
			}
			loadXML(field.valuesFile,j,i);
			fields[j] = field;
		}
		layers[i].field = fields;
	}
	
	initTool(skin+"_up",skin+"_over",skin+"_down",skin+"_up",lMap,"cursor","tooltip");
	parent.addOldTool(this);
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}


function initTool( uplink:String, overlink:String, downlink:String, hitlink:String, maplistener:Object, cursorid:String, tooltipid:String) {
	flamingo.getParent(this).resize();
	this._pressed = false;
	this._enabled = true;
	this.attachMovie(uplink, "mSkin", 1);
	this.attachMovie(hitlink, "mHit", 0, {_alpha:0});
	this.mHit.useHandCursor = false;
	var thisObj = this;
	this.setVisible = function(b:Boolean) {
		thisObj.visible = b;
		thisObj._visible = b;
	};
	this.setEnabled = function(b:Boolean) {
		if (b) {
			thisObj._alpha = 100;
		} else {
			thisObj._alpha = 20;
			if (thisObj._pressed) {
				setCursor(undefined);
				thisObj._releaseTool();
			}
		}
		thisObj._enabled = b;
		thisObj.enabled = b;
	};
	this._releaseTool = function() {
		if (thisObj._enabled) {
			thisObj._pressed = false;
			thisObj.attachMovie(uplink, "mSkin", 1);
			flamingo.removeListener(maplistener, listento, thisObj);
			thisObj.releaseTool();
		}
	};
	//
	this._pressTool = function() {
		if (thisObj._enabled) {
			thisObj._pressed = true;
			thisObj.attachMovie(downlink, "mSkin", 1);
			setCursor(thisObj.cursors[cursorid]);
			flamingo.addListener(maplistener, listento, thisObj);
			thisObj.pressTool();
		}
	};
	//
	this.mHit.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(mc, tooltipid), thisObj);
		if (thisObj._enabled) {
			if (! thisObj._pressed) {
				thisObj.attachMovie(overlink, "mSkin", 1);
			}
		}
	};
	//
	this.mHit.onRollOut = function() {
		if (! thisObj._pressed) {
			thisObj.attachMovie(uplink, "mSkin", 1);
		}
	};
	//
	this.mHit.onPress = function() {
		if (thisObj._enabled) {
			thisObj.parent.setTool(flamingo.getId(thisObj));
		}
	};
}


function loadXML(file:String, fieldIndex:Number, layerIndex:Number) {
	if (file == undefined) {
		return;
	}
	file = flamingo.correctUrl(file);
	var xml:XML = new XML();
	xml.ignoreWhite = true;
	xml.onLoad = function(success:Boolean) {
		var values:String = "";
		if (success) {
			if (this.firstChild.nodeName.toLowerCase() == "flamingo") {
				var valueXml = this.firstChild.childNodes;
				var firstTime:Boolean = true;
				for (var j = 0; j<valueXml.length; j++) {
					var singelValue = valueXml[j];
					for (var attr in singelValue.attributes) {
						var valueAtt:String = attr.toLowerCase();
						var val:String = singelValue.attributes[attr];
						switch (valueAtt) {
							case "label" :
								if (firstTime) {
									values += val;
									firstTime = false;
								} else {
									values += ","+val;
								}
								break;
							default :
								break;
						}
					}
				}
			}
			thisObj.layers[layerIndex].field[fieldIndex].values = values;
		}
	};
	xml.load(file);
}
//-------------------------------
function initWindow() {
	//if (noSelection) {
		window.content.cmb_layers.removeAll();
		window.content.btn_clear.visible = false;
		window.content.cmb_layers.addItem("",-1);
		for (var i = 0; i<this.layers.length; i++) {
			//show only visible layers!
			if (isVisible(i)) {
				window.content.cmb_layers.addItem(this.layers[i].layerName,i);
				window.content.cmb_fields.removeAll();
				window.content.cmb_operations.removeAll();
				window.content.cmb_values.removeAll();
			}
		}
	//} else {
		//window.content.btn_clear.visible = true;
	//}
	//LV
	window.content.cmb_fields.removeAll();
	
	window.content.lbl_error.visible = false;
	setWindowLabels();	
	initControls();
}

function initControls() {
	window.content._lockroot = true;
	//Initialize controls
	window.content.lbl_error.visible = false;

	//set style cmb_layers
	window.content.cmb_layers.themeColor = 0x999999;
	window.content.cmb_layers.rollOverColor = 0xE6E6E6;
	window.content.cmb_layers.selectionColor = 0xCCCCCC;
	window.content.cmb_layers.textSelectedColor = 0x000000;
	window.content.cmb_layers.drawFocus = "";
	window.content.cmb_layers.getDropdown().drawFocus = "";
	window.content.cmb_layers.onKillFocus = function() {
	};
	window.content.cmb_layers.setFocus();

	//set style cmb_fields
	window.content.cmb_fields.themeColor = 0x999999;
	window.content.cmb_fields.rollOverColor = 0xE6E6E6;
	window.content.cmb_fields.selectionColor = 0xCCCCCC;
	window.content.cmb_fields.textSelectedColor = 0x000000;
	window.content.cmb_fields.drawFocus = "";
	window.content.cmb_fields.getDropdown().drawFocus = "";
	window.content.cmb_fields.onKillFocus = function() {
	};

	//set style cmb_operations
	window.content.cmb_operations.themeColor = 0x999999;
	window.content.cmb_operations.rollOverColor = 0xE6E6E6;
	window.content.cmb_operations.selectionColor = 0xCCCCCC;
	window.content.cmb_operations.textSelectedColor = 0x000000;
	window.content.cmb_operations.drawFocus = "";
	window.content.cmb_operations.getDropdown().drawFocus = "";
	window.content.cmb_operations.onKillFocus = function() {
	};

	//set style cmb_values
	window.content.cmb_values.themeColor = 0x999999;
	window.content.cmb_values.rollOverColor = 0xE6E6E6;
	window.content.cmb_values.selectionColor = 0xCCCCCC;
	window.content.cmb_values.textSelectedColor = 0x000000;
	window.content.cmb_values.drawFocus = "";
	window.content.cmb_values.getDropdown().drawFocus = "";
	window.content.cmb_values.onKillFocus = function() {
	};

	window.content.btn_plus.visible = false;
	between = false; 
	
	//set style cmb_operations2
	window.content.lbl_operations._visible = false;
	window.content.btn_min.visible = false;

	//set style cmb_values2
	window.content.cmb_values2.visible = false;
	window.content.cmb_values2.themeColor = 0x999999;
	window.content.cmb_values2.rollOverColor = 0xE6E6E6;
	window.content.cmb_values2.selectionColor = 0xCCCCCC;
	window.content.cmb_values2.textSelectedColor = 0x000000;
	window.content.cmb_values2.drawFocus = "";
	window.content.cmb_values2.getDropdown().drawFocus = "";
	window.content.cmb_values2.onKillFocus = function() {
	};

	//Set control events
	var Listener_cmbLayers:Object = new Object();
	Listener_cmbLayers.change = function(evt_obj:Object) {
		updateFields(window.content.cmb_layers.value);
	};
	window.content.cmb_layers.addEventListener("change",Listener_cmbLayers);

	var Listener_cmbFields:Object = new Object();
	Listener_cmbFields.change = function(evt_obj:Object) {
		updateOperations(window.content.cmb_layers.value,window.content.cmb_fields.value);
	};
	window.content.cmb_fields.addEventListener("change",Listener_cmbFields);


	

	var Listener_cmbOperations:Object = new Object();
	Listener_cmbOperations.change = function(evt_obj:Object) {	
		if((window.content.cmb_operations.value == "&lt;" || window.content.cmb_operations.value == "&gt;") && layers[window.content.cmb_layers.value].field[window.content.cmb_fields.value].between){
			window.content.btn_plus.visible = true;	
		} else {
			window.content.btn_plus.visible = false;
		}
		between=false;
		window.content.lbl_operations.visible = false;
		window.content.cmb_values2.visible = false;	
		updateValues(window.content.cmb_layers.value,window.content.cmb_fields.value);
	};
	window.content.cmb_operations.addEventListener("change",Listener_cmbOperations);

	var Listener_cmbValues:Object = new Object();
	Listener_cmbValues.change = function(evt_obj:Object) {
		if(between){
			updateValues2(window.content.cmb_layers.value,window.content.cmb_fields.value);
		}
	};
	window.content.cmb_values.addEventListener("change",Listener_cmbValues);


	window.content.btn_plus.onRelease = function() {
		if(window.content.cmb_operations.value == "&lt;"){
			window.content.lbl_operations.text = ">";
		} else {
			window.content.lbl_operations.text = "<";
		}
		updateValues2(window.content.cmb_layers.value,window.content.cmb_fields.value);
		between = true;	 
		window.content.btn_min.visible = true;
		window.content.lbl_operations.visible = true;
		window.content.cmb_values2.visible = true;
	};
	
	window.content.btn_min.onRelease = function() {		
		between = false;	 
		window.content.btn_min.visible = false;
		window.content.lbl_operations.visible = false;
		window.content.cmb_values2.visible = false;
		
	};

	window.content.btn_clear.onRelease = function() {
		removeSelectQuery(window.content.cmb_layers.value);
		//reset values
		window.content.cmb_layers.removeAll();
		window.content.cmb_fields.removeAll();
		window.content.cmb_operations.removeAll();
		window.content.cmb_values.removeAll();
		window.visible = false;
	};

	window.content.btn_cancel.onRelease = function() {
		window.visible = false;
	};

	window.content.btn_ok.onRelease = function() {
		if (window.content.cmb_fields.text == "" || window.content.cmb_operations.value == "" || window.content.cmb_layers.value == -1 || window.content.cmb_values.text == "") {
			window.content.lbl_error.visible = true;
		} else {
			var query:String;
			query = layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldID;
			query += window.content.cmb_operations.value;
			query += "&apos;"+window.content.cmb_values.value+"&apos;";
			if(between){
				query += " AND "
				query += layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldID;
				query += (window.content.lbl_operations.text == "<") ? "&lt;" : "&gt;" ;
				query += "&apos;"+window.content.cmb_values2.value+"&apos;";
			}	
			//nothing is done with this querylabel
			var queryLabel:String;
			queryLabel = layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldName;
			queryLabel += window.content.cmb_operations.value;
			queryLabel += "&apos;"+window.content.cmb_values.value+"&apos;";
			if(between){
				queryLabel += " AND ";
				queryLabel += layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldName;
				queryLabel += (window.content.lbl_operations.text == "<") ? "&lt;" : "&gt;" ;
				queryLabel += "&apos;"+window.content.cmb_values2.value+"&apos;";
			}	
			setSelectQuery(window.content.cmb_layers.value,query,queryLabel);
		}
	};

	alert_window.content.btn_yes.onRelease = function() {
		alert_window.visible = false;
		window.visible = false;
		//removeSelectQuery(window.content.cmb_layers.value);
		selectQuery(window.content.cmb_layers.value);
	};

	alert_window.content.btn_no.onRelease = function() {
		alert_window.visible = false;
	};
}

function setWindowLabels()
{
	alert_window.title = flamingo.getString(this, "alertWindowTitle", "Melding");
	alert_window.content.lbl_alertMelding.text = flamingo.getString(this, "alertMessage", "De vorige selectie wordt verwijderd. Weet u zeker of u door wilt gaan?");
	alert_window.content.btn_yes.label = flamingo.getString(this, "yes", "Ja");
	alert_window.content.btn_no.label = flamingo.getString(this, "no", "Nee");

	window.title = flamingo.getString(this, "windowTitle", "Selectie");
	window.content.lbl_layer.text = flamingo.getString(this, "layerLabel", "Selecteer onderwerp");	
	window.content.lbl_condition.text = flamingo.getString(this, "conditionLabel", "waarvoor geldt");
	window.content.btn_clear.label = flamingo.getString(this, "clear", "Wissen");
	window.content.btn_cancel.label = flamingo.getString(this, "cancel", "Annuleren");
	window.content.btn_ok.label = flamingo.getString(this, "ok", "Selecteren");
	window.content.lbl_error.text = flamingo.getString(this, "notvalidLabel");		
}
function isVisible(layerIndex:String):Boolean {
	//get the mapserver from the layer
	var layerComponent:String = this.parent.listento[0]+"_"+this.layers[layerIndex].mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);
	if (mapService == undefined) {
		trace("map service is undefined");
	}
	if (mapService.getVisible(this.layers[layerIndex].layerID)<0) {
		return false;
	} else if (mapService.getVisible(this.layers[layerIndex].layerID)>0) {
		return true;
	}
}
function updateFields(layerIndex:String) {
	var layerComponent:String = this.parent.listento[0]+"_"+this.layers[layerIndex].mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);
	if (mapService.getLayerProperty(this.layers[layerIndex].layerID,"query")!="") {
		window.content.btn_clear.visible = true;
	}	
	window.content.cmb_fields.removeAll();
	window.content.cmb_operations.removeAll();
	var fields:Array = this.layers[layerIndex].field;
	window.content.cmb_fields.addItem("",-1);
	for (var i = 0; i<fields.length; i++) {
		window.content.cmb_fields.addItem(fields[i].fieldName,i);
	}
}
function updateOperations(layerIndex:String, fieldIndex:String) {
	window.content.cmb_operations.removeAll();
	var fields:Array = this.layers[layerIndex].field;
	var operationArray:Array = fields[fieldIndex].operations.split(",");

	window.content.cmb_operations.addItem("");
	for (var i = 0; i<operationArray.length; i++) {
		//change to htmlescapes
		if (operationArray[i] == "<") {
			window.content.cmb_operations.addItem(operationArray[i],"&lt;");
		} else if (operationArray[i] == ">") {
			window.content.cmb_operations.addItem(operationArray[i],"&gt;");
		} else {
			window.content.cmb_operations.addItem(operationArray[i],operationArray[i]);
		}
	}
}
function updateValues(layerIndex:String, fieldIndex:String) {
	window.content.cmb_values.removeAll();
	var fields:Array = this.layers[layerIndex].field;
	var valueArray:Array = fields[fieldIndex].values.split(",");
	window.content.cmb_values.addItem("");
	for (var i = 0; i<valueArray.length; i++) {
		window.content.cmb_values.addItem(valueArray[i]);
	}		
}

function updateValues2(layerIndex:String, fieldIndex:String) {
	window.content.cmb_values2.removeAll();
	var fields:Array = this.layers[layerIndex].field;
	var valueArray:Array = fields[fieldIndex].values.split(",");
	window.content.cmb_values.addItem("");
	for (var i = 0; i<valueArray.length; i++) {
		if((window.content.cmb_operations.value == "&lt;" && Number(valueArray[i]) < Number(window.content.cmb_values.value)) ||
			(window.content.cmb_operations.value == "&gt;" && Number(valueArray[i]) > Number(window.content.cmb_values.value))){
			window.content.cmb_values2.addItem(valueArray[i]);
		}
	}
}

function setSelectQuery(layerIndex:String, query:String, queryLabel:String) {
	this.query = query;
	this.queryLabel = queryLabel;
	var layerComponent:String = this.parent.listento[0]+"_"+this.layers[layerIndex].mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);
	if (mapService.getLayerProperty(this.layers[layerIndex].layerID,"query")=="") {
		window.visible = false;
		selectQuery(layerIndex);
	} else {
		alert_window.visible = true;
	}
}

function selectQuery(layerIndex:String) {
	//get the mapserver from the layer
	var layerComponent:String = this.parent.listento[0]+"_"+this.layers[layerIndex].mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	if (mapService == undefined) {
		trace("map service is undefined");
	}
	mapService.setLayerProperty(this.layers[layerIndex].layerID,"queryable",true);
	mapService.setLayerProperty(this.layers[layerIndex].layerID,"query",this.query);
	flamingo.getComponent(this.parent.listento[0]).refresh();
}
function removeSelectQuery(layerIndex:String) {
	//get the mapserver from the layer       
	var layerComponent:String = this.parent.listento[0]+"_"+this.layers[layerIndex].mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	if (mapService == undefined) {
		trace("map service is undefined");
	}
	mapService.setLayerProperty(this.layers[layerIndex].layerID,"query","");
	mapService.setLayerProperty(this.layers[layerIndex].layerID,"queryable",true);
	flamingo.getComponent(this.parent.listento[0]).refresh();
}


//shows the window in the center of the map
function showWindow(screenWidth:Number, screenHeight:Number) {
	var oldX = window._x;
	var oldY = window._y;
	
	var oldX_alert = alert_window._x;
	var oldY_alert = alert_window._y;

	window._x = ((screenWidth/2 - window._width))-screenWidth/(1+3/4);
	window._y = (screenHeight/2-window._height/4);
	
	alert_window._x = ((screenWidth/2 - alert_window._width))-screenWidth/(1+1/2);
	alert_window._y = (screenHeight/2-alert_window._height/4);

	window.visible = true;
}

//default functions-------------------------------
function startIdentifying() {
}
function stopIdentifying() {
}
function startUpdating() {
	_parent.setCursor(this.cursors["busy"]);
}
function stopUpdating() {
	_parent.setCursor(this.cursors["pan"]);
}
function releaseTool() {
	window.visible = false;
}
function pressTool() {
	//the toolgroup sets default a cursor
	//override this default if a map is busy
	if (_parent.updating) {
		_parent.setCursor(this.cursors["busy"]);
	}
	initWindow();
	var map = flamingo.getComponent(this.parent.listento[0]);
	var rect = map.extent2Rect(map._extent);
	showWindow(rect.width,rect.height);
}
//---------------------------------
/**
* Disable or enable a tool.
* @param enable:Boolean true or false
*/
//public function setEnabled(enable:Boolean):Void {
//}
/**
* Shows or hides a tool.
* @param visible:Boolean true or false
*/
//public function setVisible(visible:Boolean):Void {
//}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}