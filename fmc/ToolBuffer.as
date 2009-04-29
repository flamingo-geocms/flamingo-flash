/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems BV
* email: Abeer.Mahdi@realworld-systems.com
* -----------------------------------------------------------------------------*/
/** @component ToolBuffer
* Tool for buffering objects in a map.
* @file ToolBuffer.fla (sourcefile)
* @file ToolBuffer.swf (compiled component, needed for publication on internet)
* @file ToolBuffer.xml (configurationfile, needed for publication on internet)
* @configstring tooltip Tooltip.
* @configcursor busy Cursor shown when a map is updating and holdonidentify(attribute of Map) is set to true.
*/
var version:String = "3.0";
//-------------------------------------------
var defaultXML:String = "<string id='tooltip' nl='Zone aangeven' en='Buffer generator'/>" +
						"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
						"<string id='maplayerLabel' nl='onderwerp' en='subject' />" +
						"<string id='radiusLabel' nl='straal van de zone' en='radius of the buffer' />" +
						"<string id='unitLabel' nl='meters' en='meters' />" +
						"<string id='clearLabel' nl='wissen' en='clear' />" +
						"<string id='cancelLabel' nl='annuleren' en='cancel' />" +		
						"<string id='okLabel' nl='ok' en='ok' />" +		
						"<string id='notvalidLabel' >" +
							"<nl><![CDATA[<font color='#ff0000' family ='Verdana' size='9'><b>niet juist of onvolledig ingevuld</b></font>]]></nl>" +
							"<en><![CDATA[<font color='#ff0000' family ='Verdana' size='9'><b>parameters not correct</b></font>]]></en>" +
						"</string>" +
						"<string id='title' nl='Zone opgeven' en='Generate buffer'/>";
var thisObj:MovieClip = this;
var zoomscroll:Boolean = true;
var skin = "_buffer";
var enabled = true;
var layers:Array = new Array();
var mapServiceId:String;
var layerLabel:String;
var datafiltertoolid:String;
//hide window
window.visible = false;
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
			map.moveToPercentage(zoom, coord, 500, 0);
			_parent.updateOther(map, 500);
		}
	}
};
lMap.onChangeExtent = function(map:MovieClip):Void  {
	if (map.hasextent && window.visible == true) {
		var rect = map.extent2Rect(map._extent);
		//change the location of the window and rectangular if its opened
		showWindow(rect.width, rect.height);
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
/** @tag <fmc:ToolBuffer>  
* This tag defines a tool for buffering features in a map. 
* This tool works only with an ArcIMS mapservices.
* @hierarchy childnode of <fmc:ToolGroup> 
* @example 
*	 <fmc:ToolGroup>
*		 <fmc:ToolBuffer id="buffer" mapServiceId="samenleving" >
*			<layer id="gemeente" label="gemeente" fillcolor="0,255,255" filltransparency=".3" boundarycolor="0,0,0" boundarywidth="1" />
*			</layer>
*		</fmc:ToolBuffer>
*	 <fmc:ToolGroup>
*
* @attr zoomscroll (defaultvalue "true")  Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr mapServiceId The id of the mapservice where the buffer is applied to
* @attr datafilterToolid The id of the datafilter tool if existing.
*/
/** @tag <layer>  
* This defines the layer where the buffer is applied to
* @attr id  layerid, same as in the mxd.
* @attr label label of the layer that will be shown in the selection window
* @attr fillcolor (default value="0,255,255") the fill color of the buffer
* @attr filltransparency (default value="0.3") the transparency of the buffer
* @attr boundarycolor (default value="0,0,0") the color of the border of the buffer
* @attr boundarywidth (default value="1") the width of the border of the buffer
*/

function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolBuffer "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;

	//defaults
	var xml:XML = new XML(defaultXML);
	this.setConfig(xml);
	delete xml;

	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig2(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
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
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var attr:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (attr) {
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "skin" :
			skin = val+"_buffer";
			break;
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		default :
			break;
		}
	}
	//
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "pan", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}
function setConfig2(xml:Object) {
		if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	//load default attributes, strings, styles and cursors  
	flamingo.parseXML(this,xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var att:String = attr.toLowerCase();
		var val:String = xml.attributes[attr];
		switch (att) {
			case "id" :
				id = val;
				break;
			case "mapserviceid" :
				mapServiceID = val;
				break;
			case "datafiltertoolid":
				datafiltertoolid = val;
				break;
			default :
				break;
		}
	}
	var layerXml = xml.childNodes;
	for (var i = 0; i<layerXml.length; i++) {
		var layer = layerXml[i];
		layers[i] = new Object();
		var buffer:Object = new Object();
		for (var attr in layer.attributes) {
			var layerAtt:String = attr.toLowerCase();
			var val:String = layer.attributes[attr];
			switch (layerAtt) {
				case "label" :
					layers[i].layerName = val;
					break;
				case "id" :
					layers[i].layerID =val;
					break;
				case "fillcolor" :
					buffer.fillcolor = val;
					break;
				case "filltransparency" :
					buffer.filltransparency =val;
					break;					
				case "boundarycolor" :
					buffer.boundarycolor =val;
					break;										
				case "boundarywidth" :
					buffer.boundarywidth =val;
					break;					
				case "filltype" :
					buffer.filltype =val;
					break;					
				default :
					break;
			}
		
			//set default values
			if(buffer.fillcolor==undefined)
				buffer.fillcolor="0, 255, 255";
			if(buffer.filltransparency==undefined)
				buffer.filltransparency="0.3";
			if(buffer.boundarycolor==undefined)
				buffer.boundarycolor="0,0,0";
			if(buffer.boundarywidth==undefined)
				buffer.boundarywidth="1";
			if(buffer.filltype==undefined)
				buffer.filltype="solid"

			layers[i].buffer = buffer;
			layers[i].hasBuffer = false;
		}
	}
	//
	_parent.initTool(this,skin+"_up",skin+"_over",skin+"_down",skin+"_up",lMap,"pan","tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}
function generateBuffer(layerIndex:String, radius:Number){
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);
	
	if(mapService == undefined){
		trace("map service is undefined");
	}	
	this.layers[layerIndex].buffer.radius = radius
	this.layers[layerIndex].hasBuffer = true;

	mapService.setLayerProperty(this.layers[layerIndex].layerID ,"buffer",this.layers[layerIndex].buffer);

	//refresh map
	mapService.refresh();
	flamingo.getComponent(this._parent.listento[0]).refresh();
}

function removeBuffer(layerIndex:String){	
	
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var mapService = flamingo.getComponent(layerComponent);

	this.layers[layerIndex].hasBuffer = false;

	mapService.setLayerProperty(this.layers[layerIndex].layerID ,"buffer");
	flamingo.getComponent(this._parent.listento[0]).refresh();	
}
function initWindow(){
	window.content.cmb_layers.removeAll();
	window.content.ta_radius.text =" ";
	window.content.cmb_layers.addItem("", -1);
	
	setWindowLabels();
	
	for(var i=0; i<layers.length; i++){
		if(isVisible(this.layers[i].layerID)){
			window.content.cmb_layers.addItem(layers[i].layerName, i);
		}
	}
	initControls();
}

function initControls() {
	//Initialize controls
	window.content.lbl_error.visible = false;
	window.content.btn_clear.visible = false;

	//set style cmb_layers
	window.content.cmb_layers.themeColor = 0x999999;
	window.content.cmb_layers.rollOverColor = 0xE6E6E6;
	window.content.cmb_layers.selectionColor = 0xCCCCCC;
	window.content.cmb_layers.textSelectedColor = 0x000000;
	window.content.cmb_layers.drawFocus = "";
	window.content.cmb_layers.getDropdown().drawFocus = "";
	window.content.cmb_layers.onKillFocus = function() {
	};	
	
	window.content._lockroot = true;	
	
	//Set control events	
	var Listener_cmbLayers:Object = new Object();
	Listener_cmbLayers.change = function(evt_obj:Object) {
		var hasBuffer:Boolean = layers[window.content.cmb_layers.value].hasBuffer;	
		if(hasBuffer){
			window.content.btn_clear.visible = true;
			window.content.ta_radius.text=layers[window.content.cmb_layers.value].buffer.radius;
		}
		else{
			window.content.btn_clear.visible = false;
		}
	};
	window.content.cmb_layers.addEventListener("change",Listener_cmbLayers);
	
	window.content.btn_clear.onRelease = function() {
		removeBuffer(this._parent.cmb_layers.value);
		window.visible = false;
		window.content.ta_radius.text = "";
		window.content.btn_clear.visible = false;
	};
	
	window.content.btn_cancel.onRelease = function() {
		window.visible = false;	
	};
	
	window.content.btn_ok.onRelease = function() {
		//validate input
		var radius:Number = Number(window.content.ta_radius.text);
		var number:String = radius.toString();
	
		if(window.content.ta_radius.text == "" || window.content.cmb_layers.value ==-1 || number == "NaN" || radius < 0){
			window.content.lbl_error.visible = true;
		}
		else{
			window.content.lbl_error.visible = false;
			generateBuffer(window.content.cmb_layers.value, radius);

			//hide window & show btn_clear button
			window.visible = false;
			window.content.btn_clear.visible = false;
		}
	};
}

//check if the layer is visible
function isVisible(layerIndex:String):Boolean{
	var layerComponent:String = this._parent.listento[0]+"_"+mapServiceID;
	var layer = flamingo.getComponent(layerComponent);
	
	if(layer.getVisible(layerIndex) < 0)
		return false;
	else if(layer.getVisible(layerIndex) > 0)
		return true;
}	
//shows the window in the center of the map
function showWindow(screenWidth:Number, screenHeight:Number){
	var oldX = window._x;
	var oldY = window._y;
	
	window._x = (screenWidth/2 - window._width);
	window._y = (screenHeight/2 - window._height/4) ;

	window.visible = true;
}
function setWindowLabels()
{
	window.content.lbl_mapLayer.text = flamingo.getString(this, "maplayerLabel");
	window.content.lbl_radius.text = flamingo.getString(this, "radiusLabel");
	window.content.lbl_unit.text = flamingo.getString(this, "unitLabel");
	window.content.btn_clear.label = flamingo.getString(this, "clearLabel");
	window.content.btn_cancel.label = flamingo.getString(this, "cancelLabel");
	window.content.btn_ok.label = flamingo.getString(this, "okLabel");
	window.content.lbl_error.text = flamingo.getString(this, "notvalidLabel");	
	window.title = flamingo.getString(this, "title", title);
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
	showWindow(rect.width, rect.height);
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