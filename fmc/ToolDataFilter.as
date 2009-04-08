/*-----------------------------------------------------------------------------
Copyright (C) 2008 Abeer Mahdi
Abeer.Mahdi@realworld-systems.com

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
var clickdelay:Number = 1000;
var xold:Number;
var yold:Number;
var thisObj:MovieClip = this;
var zoomscroll:Boolean = true;
var skin = "_datafilter";
var enabled = true;
var layers:Array = new Array();
var noSelection:Boolean;
var selectedID:String;
var query:String;
var queryLabel:String;
var layerLabel:String;
var prev_selectedID:String;
var mapServiceId:String;
var valueString:String = "";
var addedText = "\n\n";
var legendId:String;
var bufferToolid:String;
//hide windows
window.visible = false;
alter_window.visible = false;
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
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolDataFilter>  
* This tag defines a tool that filters the data from the layer according to specific attributes. When the tool is clicked a window is shown where the attributes can be selected, after that the map is refreshed. 
* @hierarchy childnode of <fmc:ToolGroup> 
* @example 
*	 <fmc:ToolGroup>
*		<fmc:ToolDataFilter id="datafilter" mapServiceId="samenleving" legendId="legenda" bufferToolid="buffer">
*			 <layer id="basisscholen" label="basisscholen" legendLabel="voorzieningen.basisscholen">
*				 <field id="gemeente" label="gemeente" operations="=" includeValues="../config/PZH_gemeenten.xml"/>
*			 </layer>
*		 </fmc:ToolDataFilter>
*	</fmc:ToolGroup>
*
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr mapServiceId The id of the mapservice where the filter is applied to
* @attr legendid The id of the legend, this is needed for updating the legend according the filter.
* @attr bufferToolid The id of the toolBuffer if existing.
*
* @tag <layer>  
* This defines the layer where the buffer is applied to
* @attr id  layerid, same as in the mxd.
* @attr label label of the layer that will be shown in the selection window
* @attr legendlabel label for the layer that will be added to the legend
*
* @tag <field>  
* This defines the layer where the buffer is applied to
* @attr id  id of the field as defined in the database.
* @attr label label of the field that will be shown in the selection window
* @attr operations the operations that can be applied to the field.
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

	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
	this.setConfig(xml);
	delete xml;
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
	this.noSelection = true;
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
			case "legendid" :
				legendId = val;
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
					layers[i].layerID = val;
					break;
				case "legendlabel" :
					layers[i].layerLegendLabel = val;
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
	
	_parent.initTool(this,skin+"_up",skin+"_over",skin+"_down",skin+"_up",lMap,"cursor","tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
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
	if (noSelection) {
		window.content.cmb_layers.removeAll();
		window.content.btn_wissen.visible = false;
		window.content.cmb_layers.addItem("",-1);
		for (var i = 0; i<this.layers.length; i++) {
			//show only visible layers!
			if (isVisible(this.layers[i].layerID)) {
				window.content.cmb_layers.addItem(this.layers[i].layerName,i);
				window.content.cmb_fields.removeAll();
				window.content.cmb_operations.removeAll();
				window.content.cmb_values.removeAll();
			}
		}
	} else {
		window.content.btn_wissen.visible = true;
	}
	window.content.lbl_notValid.visible = false;

	initControls();
}

function initControls() {
	//Initialize controls
	window.content.lbl_notValid.visible = false;

	//set style cmb_layers
	window.content.cmb_layers.themeColor = 0x999999;
	window.content.cmb_layers.rollOverColor = 0xE6E6E6;
	window.content.cmb_layers.selectionColor = 0xCCCCCC;
	window.content.cmb_layers.textSelectedColor = 0x000000;
	window.content.cmb_layers.drawFocus = "";
	window.content.cmb_layers.getDropdown().drawFocus = "";
	window.content.cmb_layers.onKillFocus = function() {
	};

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

	window.content._lockroot = true;

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
		updateValues(window.content.cmb_layers.value,window.content.cmb_fields.value);
	};
	window.content.cmb_operations.addEventListener("change",Listener_cmbOperations);


	window.content.btn_wissen.onRelease = function() {
		removeSelectQuery(window.content.cmb_layers.value);
		//reset values
		window.content.cmb_layers.removeAll();
		window.content.cmb_fields.removeAll();
		window.content.cmb_operations.removeAll();
		window.content.cmb_values.removeAll();
		window.visible = false;
	};

	window.content.btn_annuleren.onRelease = function() {
		window.visible = false;
	};

	window.content.btn_selecteren.onRelease = function() {
		if (window.content.cmb_fields.text == "" || window.content.cmb_operations.value == "" || window.content.cmb_layers.value == -1 || window.content.cmb_values.text == "") {
			window.content.lbl_notValid.visible = true;
		} else {
			var query:String;
			query = layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldID;
			query += window.content.cmb_operations.value;
			query += "&apos;"+window.content.cmb_values.value+"&apos;";

			var queryLabel:String;
			queryLabel = layers[this._parent.cmb_layers.value].field[window.content.cmb_fields.value].fieldName;
			queryLabel += window.content.cmb_operations.value;
			queryLabel += "&apos;"+window.content.cmb_values.value+"&apos;";

			setSelectQuery(window.content.cmb_layers.value,query,queryLabel);
		}
	};

	alter_window.content.btn_ja.onRelease = function() {
		alter_window.visible = false;
		window.visible = false;
		removeSelectQuery();
		selectQuery();
	};

	alter_window.content.btn_nee.onRelease = function() {
		alter_window.visible = false;
	};
}

function isVisible(layerIndex:String):Boolean {
	//get the mapserver from the layer
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	if (mapService == undefined) {
		trace("map service is undefined");
	}
	if (mapService.getVisible(layerIndex)<0) {
		return false;
	} else if (mapService.getVisible(layerIndex)>0) {
		return true;
	}
}
function updateFields(layerIndex:String) {
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

function setSelectQuery(layerIndex:String, query:String, queryLabel:String) {
	//save previous selection id
	if (this.selectedID == undefined) {
		this.selectedID = this.layers[layerIndex].layerID;
	}
	this.prev_selectedID = this.selectedID;
	this.selectedID = this.layers[layerIndex].layerID;

	this.query = query;
	this.queryLabel = queryLabel;
	if (noSelection) {
		window.visible = false;
		selectQuery();
	} else {
		alter_window.visible = true;
	}
	noSelection = false;
}

function selectQuery() {
	//get the mapserver from the layer
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	if (mapService == undefined) {
		trace("map service is undefined");
	}
	mapService.setLayerProperty(this.selectedID,"queryable",true);
	mapService.setLayerProperty(this.selectedID,"query",this.query);
	flamingo.getComponent(this._parent.listento[0]).refresh();
	noSelection = false;

	//update Legenda
	var legenda = flamingo.getComponent(this.legendId);
	var index:Number;
	for (var i = 0; i<this.layers.length; i++) {
		if (this.layers[i].layerID == this.selectedID) {
			index = i;
		}
	}
	layerLabel = this.layers[index].layerLegendLabel;
	var labelItems:Array = layerLabel.split(".");
	var stringLength:Number = labelItems[0].length;

	if (labelItems.length == 1) {
		for (var i = 0; i<legenda.legenditems.length; i++) {
			if (legenda.legenditems[i].label.substring(0, stringLength) == layerLabel) {
				var tmp:Array = legenda.legenditems[i].label.split(addedText);
				if (tmp.length == 1) {
					legenda.legenditems[i].label += addedText+queryLabel;
					layerLabel += addedText+query;
					this.layers[index].legendItem = legenda.legenditems[i];
				} else if (tmp.length == 2) {
					legenda.legenditems[i].label = tmp[0]+addedText+queryLabel;
					layerLabel += addedText+query;
					this.layers[index].legendItem = legenda.legenditems[i];
				}
			}
		}
	} else {
		for (var i = 0; i<legenda.legenditems.length; i++) {
			if (legenda.legenditems[i].label.substring(0, stringLength) == labelItems[0]) {
				for (var j = 0; j<legenda.legenditems[i].items.length; j++) {
					for (var k = 0; k<legenda.legenditems[i].items[j].items.length; k++) {
						if (legenda.legenditems[i].items[j].items[k].label.substring(0, labelItems[1].length) == labelItems[1]) {
							legenda.legenditems[i].items[j].items[k].label += addedText+queryLabel;
							layerLabel += addedText+queryLabel;
							this.layers[index].legendItem = legenda.legenditems[i].items[j].items[k];
						}
					}
				}
			}
		}
	}
	legenda.refresh();

}
function removeSelectQuery(layerIndex:String) {
	if (layerIndex != undefined) {
		this.prev_selectedID = this.layers[layerIndex].layerID;
	}
	//get the mapserver from the layer       
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	if (mapService == undefined) {
		trace("map service is undefined");
	}
	mapService.setLayerProperty(this.prev_selectedID,"query","");
	mapService.setLayerProperty(this.prev_selectedID,"queryable",false);

	noSelection = true;
	if (layerIndex != undefined && mapService.type == "LayerArcIMS") {
		flamingo.getComponent(this._parent.listento[0]).refresh();
	}
	//update Legenda       
	var index:Number;
	for (var i = 0; i<this.layers.length; i++) {
		if (this.layers[i].layerID == this.prev_selectedID) {
			index = i;
		}
	}
	var buffer = flamingo.getComponent(bufferToolid);
	var labelArray:Array = this.layers[index].legendItem.label.split(addedText);
	var tmp:Array = labelArray[1].split(buffer.addedText);

	if (tmp.length == 1) {
		//remove old label
		this.layers[index].legendItem.label = labelArray[0];

		this.layers[layerIndex].legendItem.label = labelArray[0];
		layerLabel = labelArray[0];
	} else if (tmp.length == 2) {
		//remove old label
		this.layers[index].legendItem.label = labelArray[0];
		//add new label
		var newLabel:String = labelArray[0]+buffer.addedText+tmp[1];
		this.layers[layerIndex].legendItem.label = newLabel;
		layerLabel = newLabel;

	}
	legenda.refresh();
}
//shows the window in the center of the map
function showWindow(screenWidth:Number, screenHeight:Number) {
	var oldX = window._x;
	var oldY = window._y;

	window._x = (screenWidth/2-window._width);
	window._y = (screenHeight/2-window._height/4);

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
	var map = flamingo.getComponent(this._parent.listento[0]);
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