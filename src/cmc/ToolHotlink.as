/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Abeer Mahdi
* Realworld Systems BV - Abeer.Mahdi@Realworld-systems.com
 -----------------------------------------------------------------------------*/
/** @component HotlinkResults
* This component shows the response of an hotlink. It just shows the url data the application get's from the server in a new webbrouwser.
* Simple and quick. 
* @file ToolHotlink.as (sourcefile)
* @file ToolHotlink.fla (sourcefile)
* @file ToolHotlink.swf (compiled component, needed for publication on internet)

* @configstring tooltip Tooltip.
* @configcursor cursor Cursor shown when the tool is hoovering over a map.
* @configcursor click Cursor shown when the tool clicks on a map.
* @configcursor busy Cursor shown when a map is updating and holdonhotlink(attribute of Map) is set to true.
* -----------------------------------------------------------------------------*/
var version:String = "3.1";


//-------------------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<ToolHotlink>" +
						"<string id='tooltip' nl='hotlink' en='hotlink'/>" +
				        "<cursor id='cursor' url='fmc/CursorsMap.swf' linkageid='hotlink'/>" +
				        "<cursor id='click'  url='fmc/CursorsMap.swf' linkageid='hotlink_click'/>" +
				        "<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy' />" +
				        "</ToolHotlink>";
						
var thisObj = this;
var skin = "_hotlink";
var enabled = true;
var zoomscroll:Boolean = true;
var identifyall:Boolean = true;
//--------------------------------------------
var lMap:Object = new Object();
lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
	if (zoomscroll) {
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
lMap.onMouseDown = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) 
{
	map.setCursor(thisObj.cursors["click"]);
};
lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) 
{
	if (thisObj._parent.defaulttool==undefined){
		map.setCursor(thisObj.cursors["cursor"]);
	}
	if (map.hit) {
		if (identifyall) {
			for (var i:Number = 0; i<_parent.listento.length; i++) {
				var mc = flamingo.getComponent(_parent.listento[i]);
				mc.hotlink({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
			}
		} else {
			map.hotlink({minx:coord.x, miny:coord.y, maxx:coord.x, maxy:coord.y});
		}
	}
};
//--------------------------------------------------
init();
//--------------------------------------------------
/** @tag <fmc:ToolHotlink>  
* This tag defines a tool for hotlinking the map.
* The positioning of the tool is relative to the position of toolGroup.
* @hierarchy childnode of <fmc:ToolGroup>
* @attr zoomscroll (defaultvalue "true")  True or false. Enables (zoomscroll="true") or disables (zoomscroll="false") zooming with the scrollwheel.
* @attr enabled (defaultvalue="true") True or false.
* @attr identifyall (defaultvalue="true") True: identify all maps. False: identify only the map that's being clicked on.
* @attr skin (defaultvalue="") Available skins: "", "f2" 
*/

/**
 * This tag defines a tool for hotlinking the map.
 */
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolHotlink "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
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
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}
/**
* Configurates a component by setting a xml.
* @param xml:Object Xml or string representation of a xml.
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
		case "skin" :
			skin = val+"_hotlink";
			break;
		case "identifyall" :
			if (val.toLowerCase() == "true") {
				identifyall = true;
			} else {
				identifyall = false;
			}
			break;
		case "zoomscroll" :
			if (val.toLowerCase() == "true") {
				zoomscroll = true;
			} else {
				zoomscroll = false;
			}
			break;
		case "enabled" :
			if (val.toLowerCase() == "true") {
				enabled = true;
			} else {
				enabled = false;
			}
			break;
		}
	}
	this._parent.initTool(this, skin+"_up", skin+"_over", skin+"_down", skin+"_up", lMap, "cursor", "tooltip");
	this.setEnabled(enabled);
	this.setVisible(visible);
	flamingo.position(this);
}
//default functions-------------------------------
/**
 * startIdentifying
 */
function startIdentifying() {
	
		_parent.setCursor(this.cursors["busy"]);
}
/**
 * stopIdentifying
 */
function stopIdentifying() {
	
		_parent.setCursor(this.cursors["cursor"]);
}
/**
 * startUpdating stub
 */
function startUpdating() {
}
/**
 * stopUpdating stub
 */
function stopUpdating() {
}
/**
 * releaseTool stub
 */
function releaseTool() {
}
/**
 * pressTool, the toolgroup sets default a cursor,
 * override this default if a map is busy
 */
function pressTool() {
	if (_parent.identifying) 
	{
		_parent.setCursor(this.cursors["busy"]);
	}
}
