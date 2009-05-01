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
/** @component Container
* Container component for other components. Also suitable for drawing backgrounds and borders.
* @file Container.fla (sourcefile)
* @file Container.swf (compiled component, needed for publication on internet)
* @file Container.xml (configurationfile, needed for publication on internet)
*/
var version:String = "2.0";
//---------------------------------------
var defaultXML:String = "";
var bordercolor:Number;
var borderwidth:Number;
var borderalpha:Number = 100;
var backgroundcolor:Number;
var backgroundalpha:Number = 100;
var alpha:Number = 100;
var __width:Number;
var __height:Number;
var mask:Boolean = false;
var thisObj:MovieClip = this;
//-------------------------------------
//listeners
var lParent = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//
var lFlamingo:Object = new Object();
lFlamingo.onLoadComponent = function(mc:MovieClip) {
	if (thisObj.mContent[mc._name] == mc) {
		flamingo.raiseEvent(thisObj, "onAddComponent", thisObj, mc);
	}
};
flamingo.addListener(lFlamingo, "flamingo", this);
//
init();
/** @tag <fmc:Container>  
* This tag defines a container.
* The positioning of the components in a container are relative to the container.
* When you set a component's width in a container to 100%, the component wil get the same width as the container.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example 
* <fmc:Container borderwidth="0" bordercolor="#003399"  backgroundcolor="#0099ff" right="xcenter -22" bottom="ycenter -6" left="left" top="top">
*   <fmc:Map id="map" width="100%" height="100%" fadesteps="5" movetime="200" movesteps="5" fullextent="110000,539000,282000,610000" nrprevextents="10" extent="110000,539000,282000,610000">
*       <fmc:LayerImage id="nl" imageurl="stuff/nl.png" extent="13562,306839,282000,614073" />
*   </fmc:Map>
* </fmc:Container>
* @attr bordercolor  Color of the border in a hexadecimal notation (bordercolor="#00cc66").
* @attr backgroundcolor  Color of the background in a hexadecimal notation. if undefined the background is transparent.
* @attr borderwidth  Width of the border. 0 means hairline, undefined means noborder
* @attr borderalpha  (defaultvalue = "100") Transparency of the border.
* @attr backgroundalpha  (defaultvalue = "100") Transparency of the background.
* @attr alpha  (defaultvalue = "100") Transparency of complete container and al of its components.
* @attr mask  (defaultvalue = "false") true or false.
* @attr clear  (defaultvalue = "true") True or false. True: all existing components will be removed from the container.
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Container "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//
	this.createEmptyMovieClip("mBG", 0);
	this.createEmptyMovieClip("mContent", 1);
	this.createEmptyMovieClip("mBorder", 2);
	//
	map = flamingo.getParent(this);
	//defaults

	//custom
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
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
* @attr xml:Object Xml or string representation of a xml.
*/
function setConfig(xml:Object) {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
		return;
	}
	//load default attributes, strings, styles and cursors    
	flamingo.parseXML(this, xml);
	//parse custom attributes
	var clearcomponents = true;
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "clear" :
			if (val.toLowerCase() == "false") {
				clearcomponents = false;
			}
			break;
		case "bordercolor" :
			if (val.charAt(0) == "#") {
				bordercolor = Number("0x"+val.substring(1, val.length));
			} else {
				bordercolor = Number(val);
			}
			break;
		case "backgroundcolor" :
			if (val.charAt(0) == "#") {
				backgroundcolor = Number("0x"+val.substring(1, val.length));
			} else {
				backgroundcolor = Number(val);
			}
			break;
		case "borderwidth" :
			borderwidth = Number(val);
			break;
		case "borderalpha" :
			borderalpha = Number(val);
			break;
		case "backgroundalpha" :
			backgroundalpha = Number(val);
			break;
		case "alpha" :
			alpha = Number(val);
			break;
		case "mask" :
			if (val.toLowerCase() == "true") {
				mask = true;
			} else {
				mask = false;
			}
			break;
		}
	}
	if (clearcomponents) {
		this.clear();
	}
	//move guides to movie where components are loaded   
	if (this.guides != undefined) {
		this.mContent.guides = this.guides;
	}
	resize();
	this.addComponents(xml);
}
function resize() {
	var r = flamingo.getPosition(this);
	this._x = r.x;
	this._y = r.y;
	__width = r.width;
	__height = r.height;
	mContent.__width = __width;
	mContent.__height = __height;
	this._alpha = alpha;
	mBG.clear();
	mBG.beginFill(backgroundcolor, backgroundalpha);
	mBG.moveTo(0, 0);
	mBG.lineTo(__width, 0);
	mBG.lineTo(__width, __height);
	mBG.lineTo(0, __height);
	mBG.lineTo(0, 0);
	mBG.endFill();
	mBorder.clear();
	mBorder.lineStyle(borderwidth, bordercolor, borderalpha);
	mBorder.moveTo(0, 0);
	mBorder.lineTo(__width, 0);
	mBorder.lineTo(__width, __height);
	mBorder.lineTo(0, __height);
	mBorder.lineTo(0, 0);
	if (this.mask) {
		mContent.scrollRect = new flash.geom.Rectangle(0, 0, (__width), (__height));
	}
	flamingo.raiseEvent(this, "onResize", this);
}
/**
* set the left attribute of the container
* @param v: the new value of the attribute
*/
function setLeft(v:String){
	this.left=v;
}
/**
* set the left attribute of the container
* @param v: the new value of the attribute
*/
function setWidth(v:String){
	this.width=v;
}
/**
* set the Top attribute of the container
* @param v: the new value of the attribute
*/
function setTop(v:String){
	this.top=v;
}
/**
* set the Height( attribute of the container
* @param v: the new value of the attribute
*/
function setHeight(v:String){
	this.height=v;
}
/**
* set the Right attribute of the container
* @param v: the new value of the attribute
*/
function setRight(v:String){
	this.right=v;
}
/**
* set the Bottom attribute of the container
* @param v: the new value of the attribute
*/
function setBottom(v:String){
	this.bottom=v;
}
/**
* set the Xcenter attribute of the container
* @param v: the new value of the attribute
*/
function setXcenter(v:String){
	this.xcenter=v;
}
/**
* set the Ycenter attribute of the container
* @param v: the new value of the attribute
*/
function setYcenter(v:String){
	this.ycenter=v;
}

/**
* Adds 1 or more components to the container.
* @param xml:Object Xml or string representation of a xml describing the component.
*/
function addComponents(xml:Object):Void {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	var xcomponents:Array = xml.childNodes;
	if (xcomponents.length>0) {
		for (var i:Number = xcomponents.length-1; i>=0; i--) {
			addComponent(xcomponents[i]);
		}
	}
}
/**
* Adds a component to the container.
* @param xml:Object Xml or string representation of a xml describing the component.
* @return String Id of the added component.
*/
function addComponent(xml:Object):String {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	if (xml.prefix.length>0) {
		var id:String;
		for (var attr in xml.attributes) {
			if (attr.toLowerCase() == "id") {
				id = xml.attributes[attr];
				break;
			}
		}
		if (id == undefined) {
			id = flamingo.getUniqueId();
			xml.attributes.id = id;
		}
		if (flamingo.exists(id)) {
			// id already in use let flamingo manage double id's
			flamingo.addComponent(xml, id);
		} else {
			var mc:MovieClip = this.mContent.createEmptyMovieClip(id, this.mContent.getNextHighestDepth());
			flamingo.loadComponent(xml, mc, id);
		}
		return id;
	}
}
/**
* Gets a list of componentids.
* @return List of componentids.
*/
function getComponents():Array {
	var comps:Array = new Array();
	for (var id in this.mContent) {
		if (typeof (this.mContent[id]) == "movieclip") {
			comps.push(id);
		}
	}
	return comps;
}
/**
* Removes all components from the container.
* This will raise the onRemoveComponent event.
*/
function clear() {
	for (var id in this.mContent) {
		if (typeof (this.mContent[id]) == "movieclip") {
			this.removeComponent(id);
		}
	}
}
/**
* Removes a component from the Container.
* This will raise the onRemoveComponent event.
* @param id:String Componentid
*/
function removeComponent(id:String) {
	flamingo.killComponent(id);
	flamingo.raiseEvent(this, "onRemoveComponent", this, id);
}
/**
* Shows or hides a container.
* This will raise the onSetVisible event.
* @param vis:Boolean True or false.
*/
function setVisible(vis:Boolean):Void {
	this._visible = vis;
	this.visible = vis;
	flamingo.raiseEvent(this, "onSetVisible", this, vis);
}
/**
* Hides a container.
* This will raise the onHide event.
*/
function hide():Void {
	this._visible = false;
	this.visible = false;
	flamingo.raiseEvent(this, "onHide", this);
}

/**
* Shows a container.
* This will raise the onShow event.
*/
function show():Void {
	this._visible = true;
	this.visible = true;
	flamingo.raiseEvent(this, "onShow", this);
}
//---------------------------------------
/** 
* Dispatched when a container resizes.
* @param component:MovieClip a reference to the container.
*/
//public function onResize(component:MovieClip):Void {
//}
/** 
 * Dispatched when a component is removed.
 * @param container:MovieClip a reference to the container.
 * @param id:String id of component that has been removed.
 */
//public function onRemoveComponent(container:MovieClip, id:String):Void {
//}
//
/** 
 * Dispatched when a container is up and ready to run.
 * @param container:MovieClip a reference to the container.
 */
//public function onInit(container:MovieClip):Void {
//}
//
/** 
 * Dispatched when a component is added.
 * @param container:MovieClip a reference to the container.
 * @param comp:MovieClip a reference to the component.
 */
//public function onAddComponent(container:MovieClip, comp:MovieClip):Void {
//}
/**
* Dispatched when the container is hidden or shown.
* @param container:MovieClip a reference to the container.
* @param visible:Boolean True or false.
*/
//public function onSetVisible(container:MovieClip, visible:Boolean):Void {
//}
/**
* Dispatched when the container is hidden.
* @param container:MovieClip a reference to the container.
*/
//public function onHide(container:MovieClip):Void {
//}
/**
* Dispatched when the container is shown.
* @param container:MovieClip a reference to the container.
*/
//public function onShow(container:MovieClip):Void {
//}