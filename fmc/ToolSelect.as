/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems BV
* email: Abeer.Mahdi@realworld-systems.com
 -----------------------------------------------------------------------------*/
/** @component ToolSelect
* Tool for selecting features on the map by dragging a rectangle on the map
* @file ToolSelect.as (sourcefile)
* @file ToolSelect.fla (sourcefile)
* @file ToolSelect.swf (compiled component, needed for publication on internet)
* @file ToolSelect.xml (configurationfile, needed for publication on internet)
*/
var version:String = "3.0";
//----------------------------
var zoomscroll:Boolean = true;
var skin = "";
var enabled = true;
hideGrid();
//----------------------------
var ext:Object = new Object();
var rectClip:MovieClip;

var mapServiceId:String;
var mapService;
var selectLayer:Object = new Object();
var fields:Array = new Array();
	
var selectExtent:Object
var thisObj:MovieClip = this;
var lMap:Object = new Object();

lMap.onChangeExtent = function(map:MovieClip):Void  {
	if (map.hasextent) {
		var rect = map.extent2Rect(ext);
		rectClip.mRect1234.clear();
		if(map.mAcetate == undefined){
			map.createEmptyMovieClip("mAcetate", 10);
		}
		rectClip = map.mAcetate;
		drawRect(rectClip, {x:rect.x, y:rect.y, width:rect.width, height:rect.height});
	}
};
lMap.onMouseWheel = function(map:MovieClip, delta:Number) {
	if (zoomscroll) {
		if (not _parent.updating) {
			_parent.cancelAll();
			if (delta<=0) {
				var zoom = 80;
			} else {
				var zoom = 120;
			}
			map.moveToPercentage(zoom, undefined, 500, 0);
			_parent.updateOther(map, 500);
		}
	}
};
lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
	var x:Number;
	var y:Number;
	var xCoord:Number;
	var yCoord:Number;

	if(map.mAcetate == undefined){
		map.createEmptyMovieClip("mAcetate", 10);
	}
	if (not _parent.updating) {
		_parent.cancelAll();
		x = xmouse;
		y = ymouse;
		xCoord = coord.x;
		yCoord = coord.y;
		
		rectClip = map.mAcetate;
			
		lMap.onMouseMove = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			drawRect(rectClip, {x:x, y:y, width:xmouse-x, height:ymouse-y});
		};
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {

			var dx:Number = Math.abs(xmouse-x);
			var dy:Number = Math.abs(ymouse-y);
			if (dx>10 and dy>10) {
				var r:Object = new Object();
				r.x = Math.min(x, xmouse);
				r.y = Math.min(y, ymouse);		
				r.width = rectClip.mRect1234._width;
				r.height = rectClip.mRect1234._height;

				thisObj.selectExtent = map.rect2Extent(r);
				
				map.select(mapServiceId, thisObj.selectExtent, selectLayer);		
			}
			delete lMap.onMouseMove;
			delete lMap.onMouseUp;
		};
	}
};
var selectResultArray:Array;
var featureData:Array;
lMap.onSelectData = function(map:MovieClip, maplayer:MovieClip, data:Object, selectextent:Object, beginrecord:Number) {
	if (map.isEqualExtent(thisObj.selectExtent, selectextent)) {
		var dataArray = data[selectLayer];
		
		if(beginrecord == 1) {
			selectResultArray = new Array();
			featureData = new Array();
		}
			
		for (var i = 0; i<dataArray.length; i++) {
			var r = new Object();
			var dataRow = dataArray[i];
			for(var field:String in dataRow) {
				switch (field) {
				case "#SHAPE#" :
					break;
				case "SHAPE.ENVELOPE" :
					featureData[i + beginrecord - 1] = new Object();
					featureData[i + beginrecord - 1].extent = dataArray[i][field];
					break;
				default :
					var a = field.split(".");
					var fieldname = a[a.length-1];
						
					if(arrayContains(fieldname, fields) == true)
					{
						var fieldvalue = dataArray[i][field];
						r[fieldname] = fieldvalue;
					}
					break;
				}
			}
			featureData[i + beginrecord - 1].data = r;
			selectResultArray.push(r);
		}
		showGrid(selectResultArray);
	}
}
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function( lang:String ) {
	setLabels();
	refresh();
};
flamingo.addListener(lFlamingo, "flamingo", this);				
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolSelect>  
* This tag defines a tool for selecting features within a layer. By dragging a rectangle on the map, the features are selected and the results are shown in a window. 
* This tool works only with an ArcIMS mapservices.
* @hierarchy childnode of <fmc:ToolGroup> 
* @example 
*	 <fmc:ToolGroup>
*    	<fmc:ToolSelect left="450" id="select" selectlayer="ziekenhuizen" mapserviceid="samenleving" listento="map" >
*			<field name="NAAM" label="naam" />
*			<field name="STRAAT" label="straat" />
*			<field name="HUISNR" label="huisnr" />
*			<field name="CAPACITEITEN" label="Capaciteit" />
* 		</fmc:ToolSelect>
*	 </fmc:ToolGroup>
* @attr mapserviceid Id of the mapservice layer component
* @attr selectlayer Layer which can be selected
*
* @tag <field>  
* This defines the field that will be shown in the results grid
* @attr name name of the field as in axl.
* @attr label label of the field that wil be shown in the grid

*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 500, 400);
		var tf:TextFormat = new TextFormat();
		tf.font = "Arial";
		tf.size = 12;
		tf.color = 0x33333;
		t.setNewTextFormat(tf);
		t.text = readme;
		return;
	}
	delete readme;
	var xml = flamingo.getXML(this);
    this.setConfig(xml)
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
			skin = val;
			break
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		case "mapserviceid" :
			mapServiceId = val;
			var layerComponent:String = this._parent.listento[0]+"_"+mapServiceId;
			mapService = flamingo.getComponent(layerComponent);
			break;
		case "selectlayer" :
			selectLayer = val;
			break;
		default :
			break;
		}
	}
	//read field tags	
	var xfields:Array = xml.childNodes;
	if(xfields.length > 0)
	{
		for (var j:Number = 0; j < xfields.length; j++)
		{
			fields[j] = new Array();
			if(xfields[j].nodeName.toLowerCase() == "field")
			{
				for (var fieldattr in xfields[j].attributes)
				{
					var fieldattr:String = fieldattr.toLowerCase();
					var fieldval:String = xfields[j].attributes[fieldattr];
					switch (fieldattr.toLowerCase()) 
					{
						case "name":
							fields[j].name = fieldval;
						break;
						case "label":
							fields[j].label = fieldval;
						break;
					}
				}
			}
		}
	}
	_parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.deleteXML(this);
	flamingo.position(this);
}

function initControls() {
	window.content.btn_close.onRelease = function() {
		hideGrid();	
	};
	setLabels();
	
	// Grid listener
	myGridListener = new Object();
	myGridListener.change = function(eventObj) {
		var eventSource = eventObj.target;
		//selected item here, you can later do something with it!
		var theSelectedIndex = eventSource.selectedIndex
		var theSelectedItem = eventSource.selectedItem;
		
		highlightPoint(featureData[theSelectedIndex].extent.minx, featureData[theSelectedIndex].extent.miny);
	};
	window.content.myGrid.addEventListener("change", myGridListener);	
}
function setLabels()
{
	window.content.btn_close.label = flamingo.getString(this, "closewindow", "sluit venster");
	window.title = flamingo.getString(this, "windowTitle", "Informatie");
}
//default functions-------------------------------
function startIdentifying() {
}
function stopIdentifying() {
}
function startUpdating() {
	_parent.setCursor(flamingo.getCursorId(this, "busy"));
}
function stopUpdating() {
	_parent.setCursor(flamingo.getCursorId(this, "cursor"));
}
function releaseTool() {
	hideGrid();
}
function pressTool() {
	//the toolgroup sets default a cursor
	//override this default if a map is busy
	if (_parent.updating) {
		_parent.setCursor(flamingo.getCursorId(this, "busy"));
	}
	initControls();
}
//---------------------------------

function drawCircle(mc:MovieClip, x:Number, y:Number, r1:Number, r2:Number){
	var mc = mc.createEmptyMovieClip("mDonut", 0);
	mc.beginFill(0x000000, 90);

    var TO_RADIANS:Number = Math.PI/180;
    mc.moveTo(0, 0);
    mc.lineTo(r1, 0);

   // draw the 30-degree segments
   var a:Number = 0.268;  // tan(15)
   for (var i=0; i < 12; i++) {
      var endx = r1*Math.cos((i+1)*30*TO_RADIANS);
      var endy = r1*Math.sin((i+1)*30*TO_RADIANS);
      var ax = endx+r1*a*Math.cos(((i+1)*30-90)*TO_RADIANS);
      var ay = endy+r1*a*Math.sin(((i+1)*30-90)*TO_RADIANS);
      mc.curveTo(ax, ay, endx, endy);	
   }
  
   // cut out middle (draw another circle before endFill applied)
   mc.moveTo(0, 0);
   mc.lineTo(r2, 0);

   for (var i=0; i < 12; i++) {
      var endx = r2*Math.cos((i+1)*30*TO_RADIANS);
      var endy = r2*Math.sin((i+1)*30*TO_RADIANS);
      var ax = endx+r2*a*Math.cos(((i+1)*30-90)*TO_RADIANS);
      var ay = endy+r2*a*Math.sin(((i+1)*30-90)*TO_RADIANS);
      mc.curveTo(ax, ay, endx, endy);	
   }

   mc._x = x;
   mc._y = y;
   mc.endFill();
}

function arrayContains(input:String, arrayData:Array):Boolean
{
	for (i=0; i<arrayData.length; i++) 
	{
		if (arrayData[i].name.toString() == input) 
		{
			return true;
		}
	}
	return false;
}


function drawRect(mc:MovieClip, rect:Object){
	var mc = mc.createEmptyMovieClip("mRect1234", 0);
	with (mc) {
		lineStyle(0, "0xffffff", 40);
		beginFill(0x000000, 15);
		moveTo(rect.x, rect.y);
		lineTo(rect.x+rect.width, rect.y);
		lineTo(rect.x+rect.width, rect.y+rect.height);
		lineTo(rect.x, rect.y+rect.height);
		lineTo(rect.x, rect.y);
		endFill();
	}
}
function hideGrid(){
	window.visible = false;
	rectClip.mRect1234.removeMovieClip();
}
function showGrid(dataArray:Array){
	setXYComponents(rect.width, rect.height);
	window.visible = true;

	window.content.myGrid.dataProvider = dataArray;
	window.content.myGrid.Columns.resizable = true;

	for (i = 0; i < window.content.myGrid.dataProvider.length; i++) {
		if (window.content.myGrid.getItemAt(i).uuid < 0.5) {
			window.content.myGrid.setPropertiesAt(i, {backgroundColor:0xFF0000});
		}
	}
	}
function highlightPoint(x:Number, y:Number){
	drawCircle(rectClip, x, y, 10 , 12);
}

function setXYComponents(screenWidth:Number, screenHeight:Number){
	var oldX = window._x;
	var oldY = window._y;
	
	window._x = (screenWidth/2 - window._width);
	window._y = (screenHeight/2 - window._height/4) ;
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