/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

This file is part of Flamingo MapComponents.

Flamingo MapComponents is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------*/
/** @component Legend
* This component will show a legend of a map.
* @file Legend.fla (sourcefile)
* @file legend.swf (compiled component, needed for publication on internet)
* @file legend.xml (configurationfile, needed for publication on internet)
* @change	2009-03-04 NEW attribute stickylabel for tag <item>
* @configstring outofscale String showed when layer is visible, but the mapextent is not in the layer's scalerange.
* @configstyle .group Fontsyle of group.
* @configstyle .group_mouseover Fontstyle of group when the mouse hoovers over the group.
* @configstyle .item Fontstyle of item.
* @configstyle .item_link Fontstyle of item, when item is a link.
* @configstyle .symbol Fontstyle of symbollabel.
* @configstyle .symbol_link Fontstyle of symbollabe, when label is a link. 
* @configstyle .outofscale Fontstyle of outofscale string.
* @configstyle .text Fontstyle of text.
*/
import flash.geom.ColorTransform;
import flash.geom.Transform;
var version:String = "2.0";


//-------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<Legend>" +
							"<string id='outofscale' nl='buiten schaalbereik&lt;br&gt;zoom naar deze laag...' en='zoom to layer'/>" +
							"<style id='.group' font-family='verdana' font-size='12px' color='#6666cc' display='block' font-weight='bold'/>" +
							"<style id='.group_mouseover' font-family='verdana' font-size='12px' color='#666699' display='block' font-weight='bold'/>" +
							"<style id='.item' font-family='verdana' font-size='10px' color='#333333' display='block' font-weight='normal'/>" +
							"<style id='.item_link' font-family='verdana' font-size='10px' color='#333333' display='block' font-weight='normal' text-decoration='underline'/>" +
							"<style id='.symbol' font-family='verdana' font-size='10px' color='#333333' display='block' font-weight='normal' />" +
							"<style id='.symbol_link' font-family='verdana' font-size='10px' color='#333333' display='block' font-weight='normal' text-decoration='underline'/>" +
							"<style id='.outofscale' font-family='verdana' font-size='10px' color='#0066cc' display='block' font-style='italic'/>" +
							"<style id='.text' font-family='verdana' font-size='10px' color='#333333' display='block' font-style='italic'/>"
						"</Legend>";
var __width:Number;
var __height:Number;
var shadowsymbols:Boolean = false;
var symbolpath:String = "";
var backgroundalpha:Number = 100;
var backgroundcolor:Number = 0x55dd00;
var indent:Number = 14;
var legenditems:Array;
var allLegenditems:Array;
var itemclips:Array;
var scales:Object = new Object();
var hit:Boolean = false;
var thisObj = this;
var scalebehaviour = "";
var updatedelay:Number = 1000;
var groupdy = 0;
var groupdx = 0;
var hrdy = 0;
var hrdx = 0;
var textdy = 0;
var textdx = 0;
var itemdy = 0;
var itemdx = 0;
var symboldy = 0;
var symboldx = 0;
var skin = "";
var updatelayers:Object = new Object();
var updateid:Number;
var configObjId:String;
//----------------------------------
var lLayer:Object = new Object();
lLayer.onShow = function(layer:MovieClip) {
	var id = flamingo.getId(layer)
	//var mapid = flamingo.getId(layer.map)
	//var id = id.substring(mapid.length+1, layerid.length)
	//remember scale of layer in scales object
	scales[id] = layer.getScale();
	thisObj.refresh();
};
lLayer.onHide = function(layer:MovieClip) {
	var id = flamingo.getId(layer)
	//var mapid = flamingo.getId(layer.map)
	//var id = id.substring(mapid.length+1, layerid.length)
	//remember scale of layer in scales object
	scales[id] = layer.getScale();
	thisObj.refresh();
};
lLayer.onUpdateComplete = function(layer:MovieClip) {
	var id = flamingo.getId(layer)
	//var mapid = flamingo.getId(layer.map)
	//var id = id.substring(mapid.length+1, layerid.length)
	//remember scale of layer in scales object
	scales[id] = layer.getScale();
	thisObj.refresh();
};
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip ) {
	thisObj.refresh();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function( lang:String ) {
	thisObj.refresh();
};
flamingo.addListener(lFlamingo, "flamingo", this);
//----------------
init();
/** @tag <fmc:Legend>  
* This tag defines a legend. The legend (tag) itself listens to a map. 
* Items (tags) listen to maplayers. And with a dot notation sublayers can be configured. See example.
* the groups open attribute can also be set from the url example(http://www.bla.nl/flamingo?groupsopen=group1,group2 or 
* http://www.bla.nl/flamingo?groupsclosed=all)
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example 
<fmc:Window left="10" top="10" width="200" height="200" canresize="true" title="identify" visible="true" skin="g">
<fmc:Legend width="100%" height="100%" symbolpath="assets"  listento="map">
<item label="Worldmap"  listento="OG3" canhide="true"  /> 
<group label="Layers" open="false">
<item label="Coastlines"  listento="OG3.Coastlines" canhide="true"/>
<item label="Waterbodies"  listento="OG3.Waterbodies" canhide="true" /> 
<item label="Inundated"  listento="OG3.Inundated" canhide="true" /> 
<item label="Rivers"  listento="OG3.Rivers" canhide="true" /> 
<item label="Streams"  listento="OG3.Streams" canhide="true" /> 
<item label="Railroads"  listento="OG3.Railroads" canhide="true" /> 
<item label="Highways"  listento="OG3.Highways" canhide="true" /> 
<item label="Roads"  listento="OG3.Roads" canhide="true" /> 
<item label="Trails"  listento="OG3.Trails" canhide="true" /> 
<item label="Borders"  listento="OG3.Borders" canhide="true" /> 
<item label="Cities"  listento="OG3.Cities" canhide="true" /> 
<item label="Settlements"  listento="OG3.Settlements" canhide="true" /> 
<item label="Spot elevations"  listento="OG3.Spot elevations" canhide="true" /> 
<item label="Airports"  listento="OG3.Airports" canhide="true" /> 
<item label="Ocean features"  listento="OG3.Ocean features" canhide="true" /> 
</group>
</fmc:Legend>
</fmc:Window>
* @attr shadowsymbols (defaultvalue = "false") True or false. True: a dropshadow will be applied to symbols.
* @attr updatedelay (defaultvalue = "1000") Time in milliseconds (1000 = 1 second) between (un)checking a item and performing an layerupdate.
* @attr skin (defaultvalue = "") Skin. Available skins: "", "f1", "f2" 
* @attr symbolurl the url where the symbol can be found (might be an swf or png etc.)
* @attr liblinkage the library linkage of a symbol, this can only be used when the symbolurl points to an swf with symbols in the library. 
* The first frame of the swf must contain the following code: function attachSymbol(symbolName:String,depth:Number):Void{this.attachMovie(symbolName,"mSymbol",depth);} 
* @attr symbolpath (defaultvalue = "") Path prefix that will be attached to the symbolurl.
* @attr groupdx (defaultvalue = "0") General x-offset of groups.
* @attr groupdy (defaultvalue = "0") General y-offset of groups.
* @attr itemdx (defaultvalue = "0") General x-offset of items.
* @attr itemdy (defaultvalue = "0") General y-offset of items.
* @attr symboldx (defaultvalue = "0") General x-offset of symbols.
* @attr symboldy (defaultvalue = "0") General y-offset of symbols.
* @attr hrdx (defaultvalue = "0") General x-offset of hr.
* @attr hrdy (defaultvalue = "0") General y-offset of hr.
* @attr textdx (defaultvalue = "0") General x-offset of text.
* @attr textdy (defaultvalue = "0") General y-offset of text.
*/
function init():Void {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Legend "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	this.createClassObject(mx.containers.ScrollPane, "mScrollPane", 1);
	mScrollPane.contentPath = skin+"_legend";
	mScrollPane.vLineScrollSize = 50;
	mScrollPane.setStyle("borderStyle", "none");
	mScrollPane.setStyle("borderColor", "none");
	mScrollPane.drawFocus = "";
	
	//initialize itemclips in init()
	itemclips = new Array();
	//allLegendItems keeps the model of the legend for later reference by the DDEDownloadLegend 
	allLegenditems = new Array();
	
	//defaults
	this.setConfig(defaultXML);
	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig(xmls[i]);
	}
	//LV:Do not remove the xmls because of re-use by the legend(s) in the printtemplate(s)
	//delete xmls;
	//remove xml from repository
	//flamingo.deleteXML(this);
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
	//LV: parse the custom attributes in a seperate function, to prevent parsing the default
	// attributes again for the Legend(s) in the printTemplate (with a configObj attribute).
	
	//parse custom attributes
	parseCustomAttr(xml);
}

function parseCustomAttr(xml:Object){
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "configobject" :
				configObjId = val;
				//_global.flamingo.tracer(_global.flamingo.getId(this) + " Legend set configObj " + _global.flamingo.getId(configObj) + flamingo.getXMLs(configObj).length);
				//parsing of xml is done when printTemplate becomes visible
				break;
		case "shadowsymbols" :
			if (val.toLowerCase() == "true") {
				shadowsymbols = true;
			} else {
				shadowsymbols = false;
			}
			break;
		case "updatedelay" :
			updatedelay = Number(val);
			break;
		case "skin" :
			skin = val;
			break;
		case "symbolpath" :
			symbolpath = val+"/";
			break;
		case "groupdx" :
			groupdx = Number(val);
			break;
		case "groupdy" :
			groupdy = Number(val);
			break;
		case "itemdx" :
			itemdx = Number(val);
			break;
		case "itemdy" :
			itemdy = Number(val);
			break;
		case "symboldx" :
			symboldx = Number(val);
			break;
		case "symboldy" :
			symboldy = Number(val);
			break;
		case "hrdx" :
			hrdx = Number(val);
			break;
		case "hrdy" :
			hrdy = Number(val);
			break;
		case "textdx" :
			textdx = Number(val);
			break;
		case "textdy" :
			textdy = Number(val);
			break;
		}
	}

	legenditems = new Array();
	addItem(xml);
	//delete legenditems;
	refresh();
	//open or close groups when arguments groupsopen/groupsclosed exists in flamingo  
	var groupsopen:Array = _global.flamingo.getArgument(this, "groupsopen").split(",");
	var groupsclosed:Array = _global.flamingo.getArgument(this, "groupsclosed").split(",");
	for (var a in groupsopen){
		if(groupsopen[a].toUpperCase() == "ALL"){
			setAllCollapsed(legenditems,false);
		} else {	
			setGroupCollapsed(groupsopen[a],legenditems,false)
		}	
	}
	for (var a in groupsclosed){
		if(groupsclosed[a] == "ALL"){
			setAllCollapsed(legenditems,true);
		} else {
			setGroupCollapsed(groupsclosed[a],legenditems,true)
		}
	}
	for(var i:Number = 0;i<legenditems.length; i++){
		 allLegenditems.push(legenditems[i]);
	}
	drawLegend(legenditems, mScrollPane.content, 0);
	refresh();

}
/** @tag <group>  
* This tag defines a group. A group can contain 1 or more 'group', 'item', 'hr' or 'text' tags.
* @hierarchy childnode of <fmc:Legend> or <group> 
* @example
<group label="Layers" open="false">
 <string id="label" en="Layers" nl="Lagen"/>
 <item/>
 <item/>
 <item/>
<group>
* @attr dx (defaultvalue = "0") Extra x-offset for this group.
* @attr dy (defaultvalue = "0") Extra y-offset for this group.
* @attr open  (defaultvalue = "true") True or false. Open or close state of group.
* @attr hideallbutone (defaultvalue = "false") True or false. True; only one item can be visible at a time.
* @attr label Label of group. With a string tag (id="label") multi-language support can be added. See example.
*/
//
/** @tag <item>  
* This tag defines an item. An item listens to 1 or more maplayers and responds on their state. An item can contain 1 or more symbols.
* If an item is invisible, the symbols are hidden. When an item is out of scale, the out of scale string is visible.
* @hierarchy childnode of <fmc:Legend> or <group> 
* @example
<item label="Coastlines"  listento="OG3.Coastlines" canhide="true">
 <string id="label" en="Coastlines" nl="Kust"/>
<item>
* @attr dx (defaultvalue = "0") Extra x-offset for this item.
* @attr dy (defaultvalue = "0") Extra y-offset for this item.
* @attr listento Comma seperated list of (map)layers. With a dot notation you can point to sublayers of a maplayer.
* @attr label Label of item. With a string tag (id="label") multi-language support can be added.
* @attr canhide (defaultvalue="false") If true a checkbox is visible.
* @attr infourl An url to extra information. With a string tag (id="infourl") multi-language support can be added.
* @attr minscale  Item is invisible when the scale of the maplayer is smaller than minscale.
* @attr maxscale  Item is invisible when the scale of the maplayer is greater than maxscale.
* @attr stickylabel  If true and item has no label but first symbol of item has a label then the symbol label
* will be displayed when the checkbox is unchecked (symbol is hidden).
*/
//
/** @tag <symbol>  
* This tag defines a symbol.
* @hierarchy childnode of <item>
* @example
      <item listento="risicokaart">
        <symbol label="Gemeentegrens"  url="symbol.swf" outline_dash_2="#b4b4b4"  />
        <symbol label="Spoorlijn"  url="symbol.swf" line_4="#808080"  line_dash_2="#ffffff"  />
        <symbol label="Autosnelweg"  url="symbol.swf" line_5="#aaabde" line_2="#ffffff"  dx="10" dy="40" maxscale="1325" minscale="2.64" />
        <symbol label="Autosnelweg"  url="symbol.swf" line_5="#aaabde"  maxscale="2.64" minscale="0"/>
        <symbol label="Hoofdweg"  url="symbol.swf" line_4="#ffc564" maxscale="79.5" minscale="2.64" />
        <symbol label="Hoofdweg"  url="symbol.swf" line_2="#ffc564" maxscale="2.64" minscale="0" />
        <symbol label="Doorgaande weg"  url="symbol.swf" line_4="#f6d0b2" line="#ffffff"  maxscale="79.5" minscale="2.64" />
        <symbol label="Doorgaande weg"  url="symbol.swf" line_2="#f6d0b2" maxscale="2.64" minscale="0" />
        <symbol label="Bebouwd"  url="symbol.swf" fill="#dbdbdb"  />
        <symbol label="Overig"  url="symbol.swf" fill="#f9fce8"  maxscale="2.64" minscale="0"/>
        <symbol label="Bos"  url="symbol.swf" fill="#dfffb9" />
        <symbol label="Bouwland"  url="symbol.swf" fill="#ffffff"  maxscale="2.64" minscale="0"/>
        <symbol label="Weiland"  url="symbol.swf" fill="#f9fce8"  />
        <symbol label="Heide"  url="symbol.swf" fill="#efdaed"  maxscale="2.64" minscale="0"/>
        <symbol label="Zand"  url="symbol.swf" fill="#ffffbf"  maxscale="2.64" minscale="0"/>
        <symbol label="Overig gebruik"  url="symbol.swf" fill="#dbdbdb"  maxscale="2.64" minscale="0" />
        <symbol label="Water"  url="symbol.swf" fill="#ccf6ff"  />
      </item>

* @attr url The url of any symbol Flash supports (jpg, png, swf)
* @attr minscale Symbol is invisible when the scale of the maplayer is smaller than minscale.
* @attr maxscale Symbol is invisible when the scale of the maplayer is greater than maxscale.
* @attr dx (defaultvalue = "0") Extra x-offset for this symbol.
* @attr dy (defaultvalue = "0") Extra y-offset for this symbol.
* @attr label Label of symbol. With a string tag (id="label") multi-language support can be added.
* @attr {...} Define your own tags, these are treated as variables and are set to the loaded symbol. After the variables are set, the Legend will try to call the 'init' method of the loaded symbol.
*/
//
/** @tag <hr>  
* This tag defines a horizontal ruler. 
* @hierarchy childnode of <fmc:Legend> or <group> or <item>
* @example
<hr/>
* @attr dx (defaultvalue = "0") Extra x-offset for this ruler.
* @attr dy (defaultvalue = "0") Extra y-offset for this ruler.
*/
//
/** @tag <text>  
* This tag defines a text. With a standard string tag (id="text") you can add (HTML) content to the text. See example.
* @hierarchy childnode of <fmc:Legend> or <group> or <item>
* @example
<text>
    <string id="text">
       <en>This is <b>english</b>...</en>
       <nl>Dit is <b>nederlands</b>...</nl>
    </string>
</text>
* @attr dx (defaultvalue = "0") Extra x-offset for this group.
* @attr dy (defaultvalue = "0") Extra y-offset for this group.
*/


function addItem(xml:Object, items:Array, insertIndex:Number):Void {
	if (insertIndex != undefined && (insertIndex == null || insertIndex < 0 || insertIndex >= items.length)) {
		//if insertIndex is wrong then make undefined
		insertIndex=undefined;
	}
	if (items == undefined) {
		items = this.legenditems;
	}
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	var xnode:Array = xml.childNodes;
	if (xnode.length>0) {
		for (var i:Number = 0; i<xnode.length; i++) {
			switch (xnode[i].nodeName.toLowerCase()) {
			case "group" :
				//recursive unit
				var group:Object = new Object();
				group.type = "group";
				//get language strings by using default flamingo functions
				group.language = new Object();
				flamingo.parseString(xnode[i], group.language);
				group.items = new Array();
				if (insertIndex == undefined) {
					items.push(group);
				} else {
					items.splice(insertIndex, 0, group);
				}	
				//add next branch of items in 
				addItem(xnode[i], group.items);
				for (var attr in xnode[i].attributes) {
					var val:String = xnode[i].attributes[attr];
					switch (attr.toLowerCase()) {
					case "dx" :
						group.dx = Number(val);
						break;
					case "dy" :
						group.dy = Number(val);
						break;
					case "id" :
						group.id = val;	
						break;	
					case "open" :
						group.cancollapse = true;
						if (val.toLowerCase() == "true") {
							group.collapsed = false;
						} else {
							group.collapsed = true;
						}
						break;
					case "hideallbutone" :
						if (val.toLowerCase() == "true") {
							group.hideallbutone = true;
						} else {
							group.hideallbutone = false;
						}
						break;
					case "label" :
						group.label = val;
						break;
					case "styleid" :
						group.styleid = val;
						break;
					case "mouseover_styleid" :
						group.mouseover_styleid = val;
						break;
						//case "maxscale" :
						//group.maxscale = Number(val);
						//break;
						//case "minscale" :
						//group.minscale = Number(val);
						//break;
					}
				}
				break;
			case "item" :
				var item:Object = new Object();
				item.type = "item";
				item.canhide = false;
				//get language strings by using default flamingo functions
				item.language = new Object();
				flamingo.parseString(xnode[i], item.language);
				//
				item.items = new Array();
				if (insertIndex == undefined) {
					items.push(item);
				} else {
					items.splice(insertIndex, 0, item);
				}
				addItem(xnode[i], item.items);
				// parse the attributes
				for (var attr in xnode[i].attributes) {
					var val:String = xnode[i].attributes[attr];
					switch (attr.toLowerCase()) {
					case "symbolposition" :
						item.position = val.toLowerCase();
						break;
					case "dx" :
						item.dx = Number(val);
						break;
					case "dy" :
						item.dy = Number(val);
						break;
					case "id" :
						item.id = val;
					case "listento" :
						item.listento = new Object();
						if (item.listentoLayers == null) {
							item.listentoLayers = new Array();
						}	
						var a:Array = flamingo.asArray(val);
						for (var j = 0; j<a.length; j++) {
							if (a[j].indexOf(".", 0) == -1) {
								var layer = thisObj.listento[0]+"_"+a[j];
								var sublayer = "";
							} else {
								var layer = thisObj.listento[0]+"_"+a[j].split(".")[0];
								var sublayer = a[j].split(".")[1];
							}
							if (item.listento[layer] == undefined) {
								item.listento[layer] = sublayer;
							} else {
								item.listento[layer] += ","+sublayer;
							}
							//remember listener's listento object. 
							item.listentoLayers.push(layer);
							flamingo.addListener(lLayer, layer, thisObj);
						}
						break;
					case "label" :
						item.label = val;
						break;
					case "canhide" :
						if (val.toLowerCase() == "true") {
							item.canhide = true;
						} else {
							item.canhide = false;
						}
						break;
					case "stickylabel" :
						if (val.toLowerCase() == "true") {
							item.stickylabel = true;
						} else {
							item.stickylabel = false;
						}
						break;	
					case "url" :
					case "infourl" :
						item.infourl = val;
						break;
					case "styleid" :
						item.styleid = val;
						break;
					case "link_styleid" :
						item.link_styleid = val;
						break;
					case "maxscale" :
						item.maxscale = Number(val);
						break;
					case "minscale" :
						item.minscale = Number(val);
						break;
					}
				}
				break;
			case "hr" :
				var hr:Object = new Object();
				hr.type = "hr";
				if (insertIndex == undefined) {
					items.push(hr);
				} else {
					items.splice(insertIndex, 0, hr);
				}
				break;
			case "text" :
				var text:Object = new Object();
				text.type = "text";
				//get language strings by using default flamingo functions
				text.language = new Object();
				flamingo.parseString(xnode[i], text.language);
				if (insertIndex == undefined) {
					items.push(text);
				} else {
					items.splice(insertIndex, 0, text);
				}
				for (var attr in xnode[i].attributes) {
					var val:String = xnode[i].attributes[attr];
					switch (attr.toLowerCase()) {
					case "dx" :
						text.dx = Number(val);
						break;
					case "dy" :
						text.dy = Number(val);
						break;
					case "id" :
						text.id = val;	
						break;	
					case "styleid" :
						text.styleid = val;
						break;
					}
				}
				//for (j=0; j<xnode[i].childNodes.length; j++) {
				//text[xnode[i].childNodes[j].nodeName.toLowerCase()] = xnode[i].childNodes[j].childNodes[0].nodeValue;
				//}
				break;
			case "symbol" :
				var sym:Object = new Object();
				sym.type = "symbol";
				//get language strings by using default flamingo functions
				sym.language = new Object();
				flamingo.parseString(xnode[i], sym.language);
				if (insertIndex == undefined) {
					items.push(sym);
				} else {
					items.splice(insertIndex, 0, sym);
				}
				for (var attr in xnode[i].attributes) {
					var val:String = xnode[i].attributes[attr];
					switch (attr.toLowerCase()) {
					case "url" :
					case "symbolurl" :
						sym.url = val;
						break;
					case "liblinkage" :
						sym.linkage = val;
						break;	
					case "minscale" :
						sym.minscale = Number(val);
						break;
					case "maxscale" :
						sym.maxscale = Number(val);
						break;
					case "dx" :
						sym.dx = Number(val);
						break;
					case "dy" :
						sym.dy = Number(val);
						break;
					case "id" :
						sym.id = val;	
						break;	
					case "symbol_styleid" :
						sym.symbol_styleid = val;
						break;
					case "symbol_link_styleid" :
						sym.symbol_link_styleid = val;
						break;
					case "label" :
						sym.label = val;
						break;
					default :
						sym[attr] = val;
						break;
					}
				}
				break;
			}
		}
	}
}

/**
* Adds a node object described by xml to the legend. The object can be a single legend item
* or a tree of legend items.
* @param xml Object XML description of the node.
* @param idNextSib id of next sibling
* @param idParent id of parent
* @return Boolean True or false. Indicates succes or failure. 
*/					
function addNodeObject(xml:Object, idNextSib:String, idParent:String):Boolean {
	//add a dummy first node to xml because the addItem method removes it.
	xml = "<dummy>"+xml+"</dummy>";
	var items:Array;
	items = this.legenditems;	//root
	
	if (idParent == null || idParent == "") {
		if (idNextSib == null || idNextSib == "") {
			//Append the object as a child at the end of the child items of the root.
			addItem(xml, items.items);
		} else {
			//search for idNextSib item
			var nextSibItem:Object = itemById(idNextSib, items, null);
			if (nextSibItem == null) {
				return false;	//indicates failure
			} else {
				//Insert the object as a child before the idNextSib child item.
				addItem(xml, nextSibItem.parentObject.items, nextSibItem.arrIndex);
			}
		}
	} else {
		//search for idParent item
		var parentItem:Object = itemById(idParent, items, null);
		if (parentItem == null) {
			return false;	//indicates failure
		} else {
			//parent found. Now insert the object as a child at the correct position
			if (idNextSib == null || idNextSib == "") {
				//No idNextSib provided. Append the object as a child at the end of the child items of the parent.
				addItem(xml, parentItem.items);
			} else {
				//search for idNextSib item in the parent found
				var nextSibItem:Object = itemById(idNextSib, parentItem.items, parentItem);
				if (nextSibItem == null) {
					return false;	//indicates failure
				} else {
					//Insert the object as a child before the idNextSib child item.
					addItem(xml, nextSibItem.parentObject.items, nextSibItem.arrIndex);
				}
			}
		}
	}
	redrawLegend();
	return true;	//indicates success
}

/**
* Removes a node object and it's tree. The object is designated by it's id.
* @param id String id of the node object.
* @return Boolean True or false. Indicates succes or failure.
*/
function removeNodeObject(id:String):Boolean {
	var items:Array;
	items = this.legenditems;
	var itemToRemove:Object = itemById(id, items, null);
	if (itemToRemove == null) {
		return false;	//indicates failure
	} else {
		var arrIndexOfItemToRemove:Number = itemToRemove.arrIndex;
		if (arrIndexOfItemToRemove != null || arrIndexOfItemToRemove != undefined) {
			//remove item tree and it's potential listeners
			if (itemToRemove.parentObject != undefined || itemToRemove.parentObject != null) {
				removeListenersOfNodeObjectTree(itemToRemove);
				itemToRemove.parentObject.items.splice(arrIndexOfItemToRemove,1);
			} else {
				removeListenersOfNodeObjectTreeItems(this.legenditems);
				this.legenditems.splice(arrIndexOfItemToRemove,1);
			}
			redrawLegend();
			return true;	//indicates success
		} else {
			return false;	//indicates failure
		}
	}
}

/**
* Removes all node objects of the legend
* @return Boolean True or false. Indicates succes or failure.
*/					
function removeAllNodeObjects():Boolean {
	removeListenersOfNodeObjectTreeItems(this.legenditems);
	this.legenditems = new Array();
	redrawLegend();
	return true;
}

function itemById(id2m:String, items:Array, parentItem:Object):Object {
	for (var i:Number = 0; i<items.length; i++) {
		if (items[i].id == id2m) {
			items[i].arrIndex = i;
			items[i].parentObject = parentItem;
			return items[i];
		} else {
			//make recursive if needed
			if (items[i].items != null && items[i].items != undefined && items[i].items.length > 0) {
				var itemObj:Object = itemById(id2m, items[i].items, items[i]);
				if (itemObj != null) {
					return itemObj;
				}
			}	
		}
	}
	return null;
}

/**
* Find node object of the legend by id
* @return Boolean True or false. Indicates found or not found.
*/
function legendItemExists(id2m:String):Boolean {
	var fItem:Object = itemById(id2m, this.legenditems, null);
	if (fItem != null) {
		return true;
	}
	return false;
}


function removeListenersOfNodeObjectTree(item:Object):Void {
	//delete listener of item if existing
	if (item.type == "item") {
		for (var j:Number = 0; j<item.listentoLayers.length; j++) { 
			flamingo.removeListener(lLayer, item.listentoLayers[j], thisObj);
		}
	}
	
	//delete if existing all listeners from the tree of the item
	if (item.items != undefined || item.items != null) {
		removeListenersOfNodeObjectTreeItems(item.items);
	}
}

function removeListenersOfNodeObjectTreeItems(items:Array):Object {
	for (var i:Number = 0; i<items.length; i++) {
		if (items[i].type == "item") {
			for (var j:Number = 0; j<items[i].listentoLayers.length; j++) { 
				flamingo.removeListener(lLayer, items[i].listentoLayers[j], thisObj);
			}
		}
		//make recursive if needed
		if (items[i].items != null && items[i].items != undefined && items[i].items.length > 0) {
			var itemObj:Object = removeListenersOfNodeObjectTreeItems(items[i].items);
			if (itemObj != null) {
				return itemObj;
			}
		}
	}
	return null;
}

function redrawLegend():Void {
	refresh();
	deleteLegendMcs(this.mScrollPane.content);
	drawLegend(this.legenditems, this.mScrollPane.content, 0);
	refresh();
}

function deleteLegendMcs(mcParent:MovieClip):Void{
	for (var prop in mcParent) {
		if (typeof mcParent[prop] == "movieclip") {
			mcParent[prop].removeMovieClip();
		}
	}
}


function _refreshItems(mc:MovieClip, animate:Boolean) {
	_refreshItem(mc, animate);
	var nextitem = mc._parent[Number(mc._name)+1];
	if (nextitem != undefined) {
		_refreshItems(nextitem, animate);
	} else {
		var nextparent = mc._parent._parent._parent[Number(mc._parent._parent._name)+1];
		if (nextparent != undefined) {
			_refreshItems(nextparent, animate);
		} else {
			resize();
		}
	}
}
function refresh() {
	for (var i = 0; i<itemclips.length; i++) {
		_refreshItem(itemclips[i]);
	}
	resize();
	resize();
}
function _refreshItem(mc:MovieClip, animate:Boolean) {
	if (not mc._parent._visible) {
		return;
	}
	mc.clear();
	//quit if _parent is invisible
	// determine y position 
	var pscale = mc._parent._xscale;
	mc._parent._xscale = mc._parent._yscale=100;
	var ypos = 0;
	var previtem = mc._parent[Number(mc._name)-1];
	if (previtem != undefined) {
		ypos = previtem._y+previtem._height;
	}
	var dy = mc.item.dy;
	var dx = mc.item.dx;
	if (dy == undefined) {
		dy = 0;
	}
	if (dx == undefined) {
		dx = 0;
	}
	mc._y = ypos+dy;
	mc._x = dx;
	// determine if item is visible
	if (mc.item.type == "symbol") {
		//listento belonging to symbol is stored at parent item
		var mapscale = _getScale(mc._parent._parent.item.listento);
	} else {
		var mapscale = _getScale(mc.item.listento);
	}
	if (mapscale != undefined) {
		if (mapscale<mc.item.minscale) {
			mc._yscale = mc._xscale=0;
			mc._visible = false;
			return;
		}
		if (mapscale>mc.item.maxscale) {
			mc._yscale = mc._xscale=0;
			mc._visible = false;
			return;
		}
	}
	mc._visible = true;
	mc._xscale = mc._yscale=100;
	// at this point item is visible and at the correct yposition   
	var x = 0;
	var y = 0;
	var h = 0;
	switch (mc.item.type) {
	case "group" :
		mc._y += groupdy;
		mc._x += groupdx;
		var left = mc.mHeader.getBounds(thisObj)["xMin"];
		var w = this.__width-left-20;
		//_fill(mc.mHeader, 0xcccccc, 100, w);
		if (mc.item.collapsed) {
			mc.mHeader.attachMovie(skin+"_group_close", "skin", 1);
			mc.mItems._yscale = mc.mItems._xscale=0;
			mc.mItems._visible = false;
		} else {
			mc.mHeader.attachMovie(skin+"_group_open", "skin", 1);
			mc.mItems._yscale = mc.mItems._xscale=100;
			mc.mItems._visible = true;
		}
		_drawGroupLabel(mc, false);
		/*
		var url = getString(mc.item, "infourl");
		var label = getString(mc.item, "label");
		if (url.length>0) {
		var styleid = mc.item.styleid;
		if (styleid == undefined) {
		styleid = "group_link";
		}
		mc.mHeader.mLabel.htmlText = "<span class='"+styleid+"'><a href='"+url+"'>"+label+"</a></span>";
		} else {
		var styleid = mc.item.styleid;
		if (styleid == undefined) {
		styleid = "group";
		}
		mc.mHeader.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
		}
		*/
		mc.mHeader.mLabel._height = 5000;
		mc.mHeader.mLabel._width = w-mc.mHeader.skin._width;
		mc.mHeader.mLabel._height = mc.mHeader.mLabel.textHeight+5;
		if (mc.mItems != undefined) {
			mc.mItems._x = mc.mHeader.skin._width;
			mc.mItems._y = mc.mHeader._height;
		}
		break;
	case "item" :
		mc._y += itemdy;
		mc._x += itemdx;
		mc.item.itemvisible = _getVisible(mc.item.listento);
		if (mc.item.stickylabel){
			if(mc.item.itemvisible <= 0){
				mc.item.language["label"] = mc.item.items[0].language["label"];
				mc.item.language["infourl"] = mc.item.items[0].language["infourl"];
			} else {
				mc.item.language["label"] = "";
				mc.item.language["infourl"] = "";
			}
		}
				
		if (mc.mLabel != undefined) {
			var url = getString(mc.item, "infourl");
			var label = getString(mc.item, "label");
			if (url.length>0) {
				var styleid = mc.item.link_styleid;
				if (styleid == undefined) {
					styleid = "item_link";
				}
				mc.mLabel.htmlText = "<span class='"+styleid+"'><a href=\""+url+"\">"+label+"</a></span>";
				//mc.mLabel.htmlText = "<span class='item_link'><a href=\"javascript:openNewWindow('legend/info/kaartondergrond.html', 'legwin','width=350,height=400,top=20,left=70,toolbar=no,scrollbars=yes,resizable=yes');\">Kaartondergrond</a></span>"
			} else {
				var styleid = mc.item.styleid;
				if (styleid == undefined) {
					styleid = "item";
				}
				mc.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
			}
			mc.mLabel._x = 0;
			mc.mLabel._y = 0;
			mc.mLabel._width = mc.mLabel.textWidth+5;
			mc.mLabel._height = mc.mLabel.textHeight+5;
			y = h=mc.mLabel._height;
		}
		//checkbox                                                                                 
		//items
		if (mc.mCheck != undefined) {
			mc.chkButton.setEnabled(true);
			if (mc.item.itemvisible>0) {
				mc.chkButton.setChecked(true);
				if (mc.item.itemvisible>1) {
					mc.chkButton.setSkin(skin+"_checkedgrey", skin+"_checkedgreydown", skin+"_checkedgreyover");
				} else {
					mc.chkButton.setSkin(skin+"_checked", skin+"_checkeddown", skin+"_checkedover");
				}
			} else if (mc.item.itemvisible == 0) {
				mc.chkButton.setChecked(false);
				//mc.chkButton.setEnabled(false);
			} else {
				mc.chkButton.setChecked(false);
			}
			mc.mCheck._x = x;
			mc.mCheck._y = Math.max(0, ((h/2)-(mc.mCheck._height/2)));
			x = mc.mCheck._x+mc.mCheck._width;
			mc.mLabel._x = x;
		}
		if (mc.mItems != undefined) {
			mc.mItems._x = x;
			mc.mItems._y = y;
			 if (mc.item.itemvisible == 1 or mc.item.itemvisible ==undefined) {
				mc.mItems._yscale = mc.mItems._xscale=100;
				mc.mItems._visible = true;
			} else {
				mc.mItems._yscale = mc.mItems._xscale=0;
				mc.mItems._visible = false;
			}
		}
		if (mc.item.itemvisible == 2) {
			mc._zoomToLayer = function() {
				for (var maplayer in this.item.listento) {
					var comp = flamingo.getComponent(maplayer);
					var layers = this.item.listento[maplayer];
					comp.moveToLayer(layers, undefined, 0);
				}
			};
			mc.mScale._x = x;
			mc.mScale._y = y;
			mc.mScale._visible = true;
			mc.mScale._yscale = mc.mScale._xscale=100;
			mc.mScale.htmlText = "<span class='outofscale'><a href='asfunction:_zoomToLayer'>"+flamingo.getString(this, "outofscale")+"</a></span>";
			mc.mScale._width = mc.mScale.textWidth+5;
			mc.mScale._height = mc.mScale.textHeight+5;
		} else {
			mc.mScale._visible = false;
			mc.mScale._yscale = mc.mScale._xscale=0;
		}
		break;
	case "symbol" :
		mc._y += symboldy;
		mc._x += symboldx;
		if (mc.mLabel != undefined) {
			var url = getString(mc.item, "infourl");
			var label = getString(mc.item, "label");
			if (url.length>0) {
				var styleid = mc.item.link_styleid;
				if (styleid == undefined) {
					styleid = "symbol_link";
				}
				mc.mLabel.htmlText = "<span class='"+styleid+"'><a href=\""+url+"\">"+label+"</a></span>";
			} else {
				var styleid = mc.item.styleid;
				if (styleid == undefined) {
					styleid = "symbol";
				}
				mc.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
			}
			mc.mLabel._width = mc.mLabel.textWidth+5;
			mc.mLabel._height = mc.mLabel.textHeight+5;
			mc.mLabel._x = 0;
			//mc.mSymbol._x+mc.mSymbol._width;
			//mc.mLabel._y =Math.max(0, ((mc.mSymbol._height/2)-(mc.mLabel._height/2)));;
		}
		if (mc.mSymbol == undefined && mc.item.url != undefined && _getVisible(mc._parent._parent.item.listento)==1) {
				loadSymbol(mc);
				break;
		}		
		if (mc.mSymbol != undefined) {
			mc.mSymbol._x = 0;
			mc.mSymbol._y = 0;
			//mc.mSymbol._x += mc.item.dx;
			//mc.mSymbol._y += mc.item.dy;
			mc.mLabel._x = mc.mSymbol._x+mc.mSymbol._width;
			mc.mSymbol._y = Math.max(0, ((mc.mLabel._height/2)-(mc.mSymbol._height/2)));
			mc.mLabel._y = Math.max(0, ((mc.mSymbol._y+mc.mSymbol._height/2)-(mc.mLabel._height/2)));
			if (_getVisible(mc._parent._parent.item.listento) == 1 or mc._parent._parent.item.itemvisible ==undefined) {
				_clear(mc.mSymbol);
				if (shadowsymbols) {
					_dropShadow(mc.mSymbol);
				}
			} else {
				_grayOut(mc.mSymbol);
			}
		}
		if (mc._parent._parent.mLabel == undefined) {
			mc._parent._parent.mCheck._y = Math.max(0, ((mc.mLabel._height/2)-(mc._parent._parent.mCheck._height/2)));
		}
		var tx = mc.mLabel._x;
		var mcprev = mc._parent[Number(mc._name)-1];
		while (mcprev != undefined) {
			mcprev.mLabel._x = Math.max(mcprev.mLabel._x, tx);
			mc.mLabel._x = Math.max(mcprev.mLabel._x, tx);
			mcprev = mc._parent[Number(mcprev._name)-1];
		}
		//
		break;
	case "text" :
		mc._y += textdy;
		mc._x += textdx;
		if (mc.mLabel != undefined) {
			var txt = getString(mc.item, "text");
			var left = mc.getBounds(thisObj)["xMin"];
			var w = this.__width-left-20;
			var styleid = mc.styleid;
			if (styleid == undefined) {
				styleid = "text";
			}
			mc.mLabel.htmlText = "<span class='"+styleid+"'>"+txt+"</span>";
			mc.mLabel._width = w;
			//mc.mLabel.textWidth+5;
			mc.mLabel._height = 100000;
			mc.mLabel._height = mc.mLabel.textHeight+5;
			mc.mLabel._x = 0;
			mc.mLabel._y = 0;
		}
		break;
	case "hr" :
		mc._y += hrdy;
		mc._x += hrdx;
		var left = mc.mHr.getBounds(thisObj)["xMin"];
		var w = this.__width-left-20;
		mc.mHr._width = w;
		break;
	}
	mc._parent._xscale = mc._parent._yscale=pscale;
}
function _getScale(listento:Object):Number {
	if (listento == undefined) {
		return;
	}
	var scale:Number = undefined;
	for (var layer in listento) {
		if(scale == undefined || scale < scales[layer]){
			scale = scales[layer];
		}
	}
	return scale;
}
function _getVisible(listento:Object):Number {
	//_global.flamingo.tracer("in _getVisible " + listento);
	if (listento == undefined) {
		return;
	}
	var vis:Number = -3; //not visible
	for (var maplayer in listento) {
		//if one is visible (vis == 1) return
		var mc:MovieClip = flamingo.getComponent(maplayer);	
		if (listento[maplayer].length == 0) {
			if(mc.getVisible(lyrs[i])==1 || mc.getVisible()==true){
				return 1;
			}
			if(mc.getVisible(lyrs[i]) > vis){
				vis = mc.getVisible();
			}		
		} else {
			//1 or more sublayers, examine all if one is visible (vis == 1) return
			var lyrs:Array = listento[maplayer].split(",");
			for(var i:Number=0;i<lyrs.length;i++){
				if(mc.getVisible(lyrs[i])==1){
					return 1;
				} 
				if(mc.getVisible(lyrs[i]) > vis){
					vis = mc.getVisible(lyrs[i]);
				}
			}
			//1 or more sublayers, examine the first one
			
			//var layer = listento[maplayer].split(",")[0];
			//return mc.getVisible(layer);
			//if (vis>0) {
			// sublayer is visible, but is the maplayer visible
			//var mapvis = mc.getVisible();
			//if (mapvis == 0) {
			//maplayer is invisible, layer is visible
			//return 5;
			//}
			//}
			//return vis;
		}
	}
	//_global.flamingo.tracer("in _getVisible return " + vis);
	return vis;
}
function _drawGroupLabel(mc:MovieClip, mouseover:Boolean) {
	var url = getString(mc.item, "infourl");
	var label = getString(mc.item, "label");
	var styleid = mc.item.styleid;
	if (styleid == undefined) {
		if (mouseover) {
			var styleid = mc.item.mouseover_styleid;
			if (styleid == undefined) {
				styleid = "group_mouseover";
			}
		} else {
			var styleid = mc.item.styleid;
			if (styleid == undefined) {
				styleid = "group";
			}
		}
	}
	mc.mHeader.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
}
function drawLegend(list:Array, parent:MovieClip, _indent:Number) {
	//this function translates the item collection into a structure of movies
	// all items are drawn, regardless if they are visible or not
	// this function doesn't border size and position > see 
	for (var i = 0; i<list.length; i++) {
		var item = list[i];
		var nr = parent.getNextHighestDepth();
		var mc:MovieClip = parent.createEmptyMovieClip(nr, nr);
		mc.item = item;
		//keep a referenc of an item (can be group, item , text, symbol or hr) at itemclips
		itemclips.push(mc);
		//mc.indent = _indent;
		switch (item.type) {
		case "group" :
			//this movie will act as a group
			mc.createEmptyMovieClip("mHeader", 1);
			mc.mHeader.useHandCursor = false;
			mc.mHeader.attachMovie(skin+"_group_open", "skin", 1);
			mc.mHeader.onPress = function() {
				this._parent.item.collapsed = not this._parent.item.collapsed;
				refresh();
				if (this._parent.item.collapsed) {
					this.attachMovie(skin+"_group_close_over", "skin", 1);
				} else {
					this.attachMovie(skin+"_group_open_over", "skin", 1);
				}
			};
			mc.mHeader.onRollOver = function() {
				_drawGroupLabel(this._parent, true);
				if (this._parent.item.collapsed) {
					this.attachMovie(skin+"_group_close_over", "skin", 1);
				} else {
					this.attachMovie(skin+"_group_open_over", "skin", 1);
				}
			};
			mc.mHeader.onRollOut = function() {
				_drawGroupLabel(this._parent, false);
				if (this._parent.item.collapsed) {
					this.attachMovie(skin+"_group_close", "skin", 1);
				} else {
					this.attachMovie(skin+"_group_open", "skin", 1);
				}
			};
			if (item.label != undefined) {
				mc.mHeader.createTextField("mLabel", 2, mc.mHeader.skin._x+mc.mHeader.skin._width, 0, 1, 1);
				
				mc.mHeader.mLabel.styleSheet = flamingo.getStyleSheet(this);
				mc.mHeader.mLabel.multiline = true;
				mc.mHeader.mLabel.wordWrap = true;
				mc.mHeader.mLabel.html = true;
				mc.mHeader.mLabel.selectable = false;
			}
			mc.createEmptyMovieClip("mItems", 2);
			drawLegend(item.items, mc.mItems, space);
			break;
		case "item" :
			if (item.canhide == true and item.listento != undefined) {
				mc.chkButton = new FlamingoCheckButton(mc.createEmptyMovieClip("mCheck", 1), skin+"_checked", skin+"_checkeddown", skin+"_checkedover", skin+"_unchecked", skin+"_uncheckeddown", skin+"_uncheckedover", skin+"_checked", mc, false);
				mc.chkButton.onPress = function(checked:Boolean) {
					clearInterval(updateid);
					//mc.item.itemvisible;
					for (var maplayer in this.item.listento) {
						var layers = this.item.listento[maplayer];
						var comp = flamingo.getComponent(maplayer);
						if (layers.length == 0) {
							if (checked) {
								if (comp instanceof gui.layers.AbstractLayer){
									comp.setVisible(true);
								}else{
									//do not use comp.show() to avoid double updating								
									comp.visible = true;
									comp.updateCaches();
								}
								_global.flamingo.raiseEvent(comp, "onShow", comp);
							} else {
								if (comp instanceof gui.layers.AbstractLayer){
									comp.setVisible(false);
								}else{
									comp.visible = false;
								}
								flamingo.raiseEvent(comp, "onHide", comp);
							}
						} else {
							//if checked the component must be set visible
							if (checked) {
								//do not use comp.show() to avoid double updating
								comp.visible = true;
								comp.updateCaches();
								_global.flamingo.raiseEvent(comp, "onShow", comp);
							}
							comp.setLayerProperty(layers, "visible", checked);
						}
						//do update here to make sure that show/hide and setLayerProperty is done before update.
						updatelayers[maplayer] = 1;
						updateid = setInterval(thisObj, "update", thisObj.updatedelay);
						if (not checked) {
							this.chkButton.setSkin(skin+"_checked", skin+"_checkeddown", skin+"_checkedover");
						}
					}
					var parentgroup = this._parent._parent;
					if (parentgroup.item.hideallbutone and checked) {
						for (var item in parentgroup.mItems) {
							if (parentgroup.mItems[item] != this) {
								parentgroup.mItems[item].chkButton.uncheck();
							}
						}
					}
				};
			}
			if (item.label != undefined) {
				mc.createTextField("mLabel", 2, 0, 0, 1, 1);
				//mc.mLabel.border = true;
				mc.mLabel.styleSheet = flamingo.getStyleSheet(this);
				mc.mLabel.multiline = true;
				mc.mLabel.wordWrap = false;
				mc.mLabel.html = true;
				mc.mLabel.selectable = false;
			}
			mc.createEmptyMovieClip("mItems", 3);
			mc.createTextField("mScale", 4, 0, 0, 1, 1);
			mc.mScale.styleSheet = flamingo.getStyleSheet(this);
			mc.mScale.multiline = true;
			mc.mScale.wordWrap = false;
			mc.mScale.html = true;
			mc.mScale.selectable = false;
			drawLegend(item.items, mc.mItems, space);
			break;
		case "hr" :
			mc.attachMovie("_hr", "mHr", 0);
			break;
		case "text" :
			mc.createTextField("mLabel", 1, 0, 0, 1, 1);
			//mc.mLabel.border = true;
			mc.mLabel.styleSheet = flamingo.getStyleSheet(this);
			mc.mLabel.wordWrap = true;
			mc.mLabel.multiline = true;
			mc.mLabel.html = true;
			mc.mLabel.selectable = false;
			var styleid = item.styleid;
			if (styleid == undefined) {
				styleid = "text";
			}
			//mc.mLabel.htmlText = "<span class='"+styleid+"'>"+item.text+"</span>";                                                                                            
			break;
		case "symbol" :
			//label
			if (item.label != undefined) {
				mc.createTextField("mLabel", 1, 0, 0, 1, 1);
				//mc.mLabel.border = true;
				mc.mLabel.styleSheet = flamingo.getStyleSheet(this);
				mc.mLabel.wordWrap = false;
				mc.mLabel.html = true;
				mc.mLabel.multiline = true;
				mc.mLabel.selectable = false;
			}
			//symbol   
                                          
			if (item.url != undefined && _getVisible(mc._parent._parent.item.listento)==1) {
				loadSymbol(mc);
			}
			break;
		}
	}
}

function loadSymbol(mc:MovieClip):Void{
		mc.createEmptyMovieClip("mSymbol", 2);
		var listener:Object = new Object();
		listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
		};
		listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
		};
		listener.onLoadInit = function(mcsymbol:MovieClip) {
			//mc.init();
			for (var attr in mcsymbol._parent.item) {
				switch (attr) {
				case "mSymbol" :
				case "mLabel" :
				case "url" :
				case "indent" :
				case "type" :
				case "minscale" :
				case "maxscale" :
				case "dx" :
				case "dy" :
					break;
				default :
					mcsymbol[attr] = mcsymbol._parent.item[attr];
				}	
			}
			if(mcsymbol["linkage"] != null){
					mcsymbol.attachSymbol(mcsymbol["linkage"],1);
				
			}
			mcsymbol.init();
			_refreshItems(mcsymbol._parent);
		};
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener(listener);
		mcl.loadClip(flamingo.correctUrl(symbolpath+ mc.item.url), mc.mSymbol);
}
		

function _checkChildrenOf(mc:MovieClip, checked:Boolean) {
	for (var item in mc.mItems) {
		if (mc.mItems[item].chkButton != undefined) {
			if (checked) {
				mc.mItems[item].chkButton.check();
			} else {
				mc.mItems[item].chkButton.uncheck();
			}
		}
		_checkChildrenOf(mc.mItems[item], checked);
	}
}
function resize() {
	var r = flamingo.getPosition(this);
	this._x = r.x;
	this._y = r.y;
	__width = r.width;
	__height = r.height;
	mScrollPane.setSize(__width, __height);
	if (mScrollPane.vScroller == undefined) {
		var sb = 0;
	} else {
		var sb = 20//mScrollPane.vScroller._width;
	}
	//_fill(mScrollPane.content.mBG, 0x33ccff, 100, __width-sb, Math.max(mScrollPane.content._height, __height));
	for (var i = 0; i<itemclips.length; i++) {
		switch (itemclips[i].item.type) {
			//case "group" :
			//var left = itemclips[i].getBounds(thisObj)["xMin"];
			//var w = Math.max(this.__width-left-sb, mScrollPane.content._width)-1;
			//_fill(itemclips[i], 0xcccccc, 0, w);
			//break;
		case "hr" :
			var left = itemclips[i].getBounds(thisObj)["xMin"];
			var w = Math.max(this.__width-left-sb, mScrollPane.content._width)-1;
			itemclips[i].mHr._width = w;
			break;
		}
	}
	mScrollPane.content.clear()
	if (sb>0) {
		//var w = Math.max(this.__width-sb, mScrollPane.content._width)-1;
		var w = mScrollPane.content._width-25;
	} else {
		var w = mScrollPane.content._width-1;
	}
	_fill(mScrollPane.content, 0xcccccc, 0, w);
}
function _fill(mc:MovieClip, color:Number, alpha:Number, w:Number, h:Number) {
	mc.clear();
	mc.beginFill(color, alpha);
	mc.moveTo(0, 0);
	if (w == undefined) {
		w = mc._width;
	}
	if (h == undefined) {
		h = mc._height;
	}
	mc.lineTo(w, 0);
	mc.lineTo(w, h);
	mc.lineTo(0, h);
	mc.lineTo(0, 0);
	mc.endFill();
}
function _dropShadow(mc:MovieClip) {
	//return;
	import flash.filters.DropShadowFilter;
	var distance:Number = 2;
	var angleInDegrees:Number = 45;
	var color:Number = 0x333333;
	var alpha:Number = .8;
	var blurX:Number = 3;
	var blurY:Number = 3;
	var strength:Number = 0.8;
	var quality:Number = 3;
	var inner:Boolean = false;
	var knockout:Boolean = false;
	var hideObject:Boolean = false;
	var filter:DropShadowFilter = new DropShadowFilter(distance, angleInDegrees, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
	//var filterArray:Array = mc.filters;
	//filterArray.push(filter);
	mc.filters = [filter];
	//filterArray;
}
function update() {
	clearInterval(updateid);
	for (var layername in updatelayers) {
		flamingo.getComponent(layername).update();
	}
	updatelayers = new Object();
}
function _clear(mc:MovieClip) {
	var colort:ColorTransform = new ColorTransform();
	var trans:Transform = new Transform(mc);
	trans.colorTransform = colort;
	mc.filters = [];
	mc._alpha = 100;
}
function _grayOut(mc:MovieClip) {
	//var my_color:Color = new Color(mc);
	//mc.setRGB(0xcccccc);
	//mc._alpha = 50;
	//import flash.filters.BlurFilter;
	//var blurX:Number = 4;
	//var blurY:Number = 4;
	//var quality:Number = 3;
	//var filter:BlurFilter = new BlurFilter(blurX, blurY, quality);
	//mc.filters = [filter];
	var colort:ColorTransform = new ColorTransform();
	colort.rgb = 0xffffff;
	var trans:Transform = new Transform(mc);
	trans.colorTransform = colort;
	mc._alpha = 20;
}
function getString(item:Object, stringid:String):String {

	var lang = flamingo.getLanguage();

	var s = item.language[stringid][lang];
	if (s.length > 0) {
		//option A
		return s;
	}
	s = item[stringid];
	if (s.length > 0) {
		//option B
		return s;
	}
	for (var attr in item.language[stringid]) {
		//option C
		return item.language[stringid][attr];
	}
	//option D
	return "";
}

/**
 * Set the collapsed property of a group 
 * @param id:groupid, collapsed (true or false)
 */	
function setGroupCollapsed(groupid:String,items:Array,collapsed:Boolean):Void{
	var group:Object = itemById(groupid, items, null);
	group.collapsed = collapsed;
}

function setAllCollapsed(list:Array, collapsed:Boolean) {
	for (var i = 0; i<list.length; i++) {
		var item = list[i];
		if(item.type == "group"){
			item.collapsed = collapsed;
			setAllCollapsed(item.items, collapsed);
		}
	}
}

function getGroups(collapsed:Boolean):Array {
	var groupsClosed:Array = new Array();
	var groupsOpened:Array = new Array();
	fillGroupArrays(legenditems);
	function fillGroupArrays(list:Array) {
		for (var i = 0; i<list.length; i++) {
			var item = list[i];
			if(item.type == "group"){
				if(item.id != undefined){
					if(item.collapsed){
						groupsClosed.push(item.id);
					} else {
						groupsOpened.push(item.id);
					}
				}
				fillGroupArrays(item.items);
			}
		}
		  
	}
	if(collapsed){
		return groupsClosed;
	} else {
		return groupsOpened;
	}
}



/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}