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
/** @component cmc:Window
* Container component for other components.
* @version 2.0.1
* @file Window.fla (sourcefile)
* @file Window.swf (compiled component, needed for publication on internet)
* @file Window.xml (configurationfile, needed for publication on internet)
* @configstring title Title of window
* @configstring tooltip_close Tooltip of the close button.
* @configstyle .title  Fontsyle of windowtitle of windows that are not infocus.
* @configstyle .titlefocus Fontstyle of windowtitle.
* @configcursor sizens Cursor for upper and lower border.
* @configcursor sizewe Cursor for left and right border.
* @configcursor sizenesw  Cursor for corners.
* @configcursor sizenwse  Cursor for corners
* @change 2008-02-18 FIX - The attributes canclose, canresize and showresizebutton didn't work properly.
* @change 2008-02-18 CHANGE - The resize button is positioned on top of the window's content.
*/
var version:String = "2.0.1";
//--------------------------------------------------------
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

//defaults
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<Window>" +
						"<string id='tooltip_close'  en='close' nl='sluiten'/>" +
						"<style id='.title' font-family='verdana' font-size='13px' color='#666666' display='block' font-weight='normal'/>" +
						"<style id='.titlefocus' font-family='verdana' font-size='13px' color='#666666' display='block' font-weight='bold'/>" +
						"<cursor id='sizens' url='fmc/CursorsWindow.swf' linkageid='sizens'/>" +
						"<cursor id='sizewe' url='fmc/CursorsWindow.swf' linkageid='sizewe'/>" +
						"<cursor id='sizenesw' url='fmc/CursorsWindow.swf' linkageid='sizenesw'/>" +
						"<cursor id='sizenwse' url='fmc/CursorsWindow.swf' linkageid='sizenwse'/>" +
						"</Window>"; 
var minwidth:Number;
var minheight:Number;
var contentid:String;
var stitle:String = "";
var canresize:Boolean = true;
var canclose:Boolean = true;
var showresize:Boolean = true;
//make this component a flamingo component
var focus:Boolean = false;
var defocusalpha = 100;
var minimized:Boolean = false;
var thisObj = this;
var skin = "";
//---------------------------------------
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(lang:String) {
	setTitle(flamingo.getString(thisObj, "title", stitle));
};
lFlamingo.onLoadComponent = function(mc:MovieClip) {
	if (thisObj.mWindow.mContent[mc._name] == mc) {
		flamingo.raiseEvent(thisObj, "onAddComponent", thisObj, mc);
	}
};
flamingo.addListener(lFlamingo, "flamingo", this);
//---------------------------------------
init();
//---------------------------------------
/** @tag <cmc:Window>  
* This tag defines a window.
* The components in the window are positioned relative to window.
* A width of 100% means the same width as the window.
* @hierarchy childnode of <flamingo> or a container component. e.g. <cmc:Window>
* @example
* <cmc:Window top="100" left="100" width="300" bottom="bottom" canresize="true" canclose="true" title="Identify results">
*    <string id="tooltip_close"  en="close" nl="sluiten"/>
*    <style id=".title" font-family="verdana" font-size="13px" color="#666666" display="block" font-weight="normal"/>
*    <style id=".titlefocus" font-family="verdana" font-size="13px" color="#666666" display="block" font-weight="bold"/>
*    <cursor id="sizens"   url="fmc/CursorsWindow.swf" linkageid="sizens"/>
*    <cursor id="sizewe"   url="fmc/CursorsWindow.swf"  linkageid="sizewe" />
*    <cursor id="sizenesw" url="fmc/CursorsWindow.swf"  linkageid="sizenesw" />
*    <cursor id="sizenwse" url="fmc/CursorsWindow.swf"  linkageid="sizenwse" />
*    <cmc:IdentifyResults width="100%" height="100%" listento="map"/>
* </cmc:Window>
* @attr title  Title of the window. With a String tag you can add multilanguage support.
* @attr canclose  (defaultvalue = "false") True or false. If set to true a close button will appear.
* @attr canresize  (defaultvalue = "false") True or false. If set to true the window can resized by dragging the borders.
* @attr defocusalpha  (defaultvalue = "100") Transparency of windows that are not in focus.
* @attr showresizebutton (defaultvalue = "true") True or false. If set to true a resizebutton in the lowerrightcorner is shown.
* @attr skin (defaultvalue = "") Skin. Available skins: "", "f1", f2", "g"
* @attr clear  (defaultvalue = "true") True or false. True: all existing components will be removed from the window.
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true
		t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Window "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
		return;
	}
	this._visible = false
	//execute init() when the movieclip is realy loaded and in the timeline
	if (!flamingo.isLoaded(this)) {
		var id = flamingo.getId(this, true);
		flamingo.loadCompQueue.executeAfterLoad(id, this, init);
		return;
	}
	//move this window to a position below 20000
	//20000 is the top window
	var parent = flamingo.getParent(this);
	var newpos = 20000;
	var mc = parent.getInstanceAtDepth(newpos);
	while (mc != undefined) {
		newpos--;
		mc = parent.getInstanceAtDepth(newpos);
	}
	this.swapDepths(newpos);
	//
	//add some movies, later on in drawWindow the rest will be added
	var mcw:MovieClip = this.createEmptyMovieClip("mWindow", 1);
	var mc:MovieClip = mcw.createEmptyMovieClip("mContent", 20);
	//
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
	setFocus();
	this._visible = this.visible
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

	//parse custom attributes
	if (flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
		return;
	}
	var clearcomponents = true;
	//load default attributes, strings, styles and cursors   
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "clear" :
			if (val.toLowerCase() == "false") {
				clearcomponents = false;
			}
			break;
		case "skin" :
			skin = val;
			break;
		case "title" :
			stitle = val;
			break;
		case "defocusalpha" :
			defocusalpha = Number(val);
			break;
		case "showresizebutton" :
			if (val.toLowerCase() == "true") {
				showresize = true;
			} else {
				showresize = false;
			}
			break;
		case "canresize" :
			if (val.toLowerCase() == "true") {
				canresize = true;
			} else {
				canresize = false;
			}
			break;
		case "canclose" :
		case "canhide" :
			if (val.toLowerCase() == "true") {
				canclose = true;
			} else {
				canclose = false;
			}
			break;
		default :
		}
	}
	//
	if (clearcomponents) {
		this.clear();
	}
	if (stitle == "") {
		stitle = thisObj._name;
	}
	if (minimized == undefined) {
		minimized = false;
	}
	drawWindow();
	//By default flamingo will load guides from the xml to the window movie
	//the guides should be attached to mContent
	if (this.guides != undefined) {
		mWindow.mContent.guides = this.guides;
	}
	//minwidth = Math.max(mWindow.mBorderL._width,mWindow.mCornerTR._width)+Math.max(mWindow.mBorderR._width,mWindow.mCornerBR._width)  
	//minheight = Math.max(mWindow.mBorderT._height,mWindow.mCornerTR._height)+Math.max(mWindow.mBorderB._height,mWindow.mCornerBR._height)+mWindow.mTitleBar._height
	var r = flamingo.getPosition(this);
	setSize(r.width, r.height, r.x, r.y);
	//set title
	setTitle(flamingo.getString(this, "title", stitle));

	this.addComponents(xml);
}



/**
* Adds 1 or more components to the window.
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
* Adds a component to a window.
* @param xml:Object Xml or string representation of a xml defining a component.
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
			var mc:MovieClip = this.mWindow.mContent.createEmptyMovieClip(id, this.mWindow.mContent.getNextHighestDepth());
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
	for (var id in this.mWindow.mContent) {
		if (typeof (this.mWindow.mContent[id]) == "movieclip") {
			comps.push(id);
		}
	}
	return comps;
}
/**
* Removes all components from a window
* This will raise the onRemoveComponent event.
*/
function clear() {
	for (var id in this.mWindow.mContent) {
		if (typeof (this.mWindow.mContent[id]) == "movieclip") {
			this.removeComponent(id);
		}
	}
}
/**
* Removes a component from a Window.
* This will raise the onRemoveComponent event.
* @param id:String Componentid
*/
function removeComponent(id:String) {
	flamingo.killComponent(id);
	flamingo.raiseEvent(this, "onRemoveComponent", this, id);
}
function drawWindow() {
	_visible = visible;
	var mcw:MovieClip = this.mWindow;
	var mc:MovieClip = mcw.attachMovie(skin+"_background", "mBackground", 18);
	mc.useHandCursor = false;
	mc.onPress = function() {
	};
	mc.onMouseDown = function() {
		_focus();
	};
	if (canresize and showresize) {
		var mc:MovieClip = mcw.attachMovie(skin+"_resize", "mResize", 21);
		_initBorder(mc, "sizenwse", 1, 1);
	} else {
		mcw.mResize.removeMovieClip()
	}
	var mc:MovieClip = mcw.attachMovie(skin+"_titlebar", "mTitleBar", 25);
	mc.useHandCursor = false;
	mc.onPress = function() {
		this._parent._parent.setFocus();
		this._parent._parent.startDrag();
	};
	mc.onRelease = function() {
		stopDrag();
	};
	var mc:MovieClip = mcw.attachMovie(skin+"_cornertopleft", "mCornerTL", 4);
	_initBorder(mc, "sizenwse", -1, -1);
	var mc:MovieClip = mcw.attachMovie(skin+"_bordertop", "mBorderT", 5);
	_initBorder(mc, "sizens", 0, -1);
	var mc:MovieClip = mcw.attachMovie(skin+"_cornertopright", "mCornerTR", 6);
	_initBorder(mc, "sizenesw", 1, -1);
	var mc:MovieClip = mcw.attachMovie(skin+"_borderright", "mBorderR", 7);
	_initBorder(mc, "sizewe", 1, 0);
	var mc:MovieClip = mcw.attachMovie(skin+"_cornerbottomright", "mCornerBR", 8);
	_initBorder(mc, "sizenwse", 1, 1);
	var mc:MovieClip = mcw.attachMovie(skin+"_borderbottom", "mBorderB", 9);
	_initBorder(mc, "sizens", 0, 1);
	var mc:MovieClip = mcw.attachMovie(skin+"_cornerbottomleft", "mCornerBL", 10);
	_initBorder(mc, "sizenesw", -1, 1);
	var mc:MovieClip = mcw.attachMovie(skin+"_borderleft", "mBorderL", 11);
	_initBorder(mc, "sizewe", -1, 0);
	//
	var t:TextField = mcw.createTextField("tTitle", 26, 0, 0, 100, 100);
	t.selectable = false;
	t.html = true;
	t.multiline = false;
	t.wordWrap = false;
	t.styleSheet = flamingo.getStyleSheet(this);

	//
	if (canclose) {
		mcw.createEmptyMovieClip("mButtons", 27);
		//var b1:FlamingoButton = new FlamingoButton(mcw.mButtons.createEmptyMovieClip("bMinimize", 1), "minimizeup", "minimizeover", "minimizedown", "minimizehit", this);
		var b2:FlamingoButton = new FlamingoButton(mcw.mButtons.createEmptyMovieClip("bClose", 2), skin+"_close_up", skin+"_close_over", skin+"_close_down", skin+"_close_up", this);
		b2.onRelease = function() {
			flamingo.hideTooltip();
			hide();
		};
		b2.onRollOver = function() {
			flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_close"), mcw.mButtons.bClose);
		};
		b2.move(b1.getRight()-2, 0);
		//
		minheight = mWindow.mTitleBar._height+mWindow.mBorderT._height+mWindow.mBorderB._height;
		minwidth = mWindow.mButtons._width+mWindow.mBorderL._width+mWindow.mBorderR._width+20;
	} else {
		mcw.mButtons.removeMovieClip()
		minheight = mWindow.mTitleBar._height+mWindow.mBorderT._height+mWindow.mBorderB._height;
		minwidth = mWindow.mBorderL._width+mWindow.mBorderR._width+20;
	}
}
/**
* Sets the focus of a window.
*/
function setFocus() {
	if (not focus) {
		this._alpha = 100;
		focus = true;
		flamingo.raiseEvent(this, "onSetFocus", this);
		this.swapDepths(20000);
		var windows:Object;
		windows = flamingo.getSameComponents(this, true, true);
		for (var w in windows) {
			windows[w].killFocus();
		}
		refresh();
		//dropShadow();
		delete windows;
	}
}
function killFocus() {
	this._alpha = defocusalpha;
	this.filters = new Array();
	focus = false;
	flamingo.raiseEvent(this, "onKillFocus", this);
	refresh();
}
function setSize(w:Number, h:Number, x:Number, y:Number) {
	w = Math.max(minwidth, w);
	h = Math.max(minheight, h);
	__width = w;
	__height = h;
	if (x != undefined) {
		_x = x;
	}
	if (y != undefined) {
		_y = y;
	}
	//                             
	this.mWindow.mBorderL._x = 0;
	this.mWindow.mCornerTL._x = 0;
	this.mWindow.mCornerBL._x = 0;
	this.mWindow.mContent._x = mWindow.mBorderL._width;
	this.mWindow.mBackground._x = mWindow.mBorderL._width;
	this.mWindow.mBackground._width = w-mWindow.mBorderR._width-mWindow.mBorderL._width;
	this.mWindow.mCornerTR._x = w-mWindow.mCornerTR._width;
	this.mWindow.mCornerBR._x = w-mWindow.mCornerBR._width;
	this.mWindow.mBorderT._x = mWindow.mCornerTL._width;
	this.mWindow.mBorderT._width = w-mWindow.mCornerTL._width-mWindow.mCornerTR._width;
	this.mWindow.mBorderB._x = mWindow.mCornerBL._width;
	this.mWindow.mBorderB._width = w-mWindow.mCornerBL._width-mWindow.mCornerBR._width;
	this.mWindow.mBorderR._x = w-mWindow.mBorderR._width;
	this.mWindow.mTitleBar._x = mWindow.mBorderL._width;
	this.mWindow.mTitleBar._width = w-mWindow.mBorderL._width-mWindow.mBorderR._width;
	//
	this.mWindow.mBorderT._y = 0;
	this.mWindow.mCornerTR._y = 0;
	this.mWindow.mCornerTL._y = 0;
	mWindow.mBackground._y = mWindow.mBorderT._height+mWindow.mTitleBar._height;
	mWindow.mContent._y = mWindow.mBackground._y;
	mWindow.mBackground._height = h-mWindow.mBorderT._height-mWindow.mBorderB._height-mWindow.mTitleBar._height;
	mWindow.mCornerBL._y = h-mWindow.mCornerBL._height;
	mWindow.mCornerBR._y = h-mWindow.mCornerBR._height;
	mWindow.mBorderB._y = h-mWindow.mBorderB._height;
	mWindow.mBorderL._y = mWindow.mCornerTL._height;
	mWindow.mBorderL._height = h-mWindow.mCornerTL._height-mWindow.mCornerBL._height;
	mWindow.mBorderR._y = mWindow.mCornerTR._height;
	mWindow.mBorderR._height = h-mWindow.mCornerTR._height-mWindow.mCornerBR._height;
	mWindow.mTitleBar._y = mWindow.mBorderT._height;
	//
	var window:Rectangle = new Rectangle(0, 0, mWindow.mBackground._width, mWindow.mBackground._height);
	mWindow.mContent.scrollRect = window;
	//
	mWindow.mResize._x = (mWindow.mBackground._x+mWindow.mBackground._width)-mWindow.mResize._width;
	mWindow.mResize._y = (mWindow.mBackground._y+mWindow.mBackground._height)-mWindow.mResize._height;
	//
	mWindow.tTitle._x = mWindow.mBorderL._width;
	mWindow.tTitle._y = ((mWindow.mBorderT._height+mWindow.mTitleBar._height)/2)-(mWindow.tTitle.textHeight/2);
	mWindow.tTitle._width = Math.min(mWindow.tTitle.textWidth+5, (mWindow.mTitleBar._width-10));
	//
	mWindow.mButtons._x = this.mWindow.mCornerTR._x-mWindow.mButtons._width;
}
function showCursor(cursor:String) {
	flamingo.showCursor(this.cursors[cursor]);
}
function resizeContent() {
	flamingo.raiseEvent(this, "onResize", this);
}
/**
* Shows or hides a container.
* This will raise the onSetVisible event.
* @param vis:Boolean True or false.
*/
function setVisible(vis:Boolean):Void {
	this.visible = vis;
	if (vis) {
		_visible = true;
		this.setFocus();
	} else {
		this.onEnterFrame = function() {
			this._alpha = this._alpha-20;
			if (this._alpha<=0) {
				this._visible = false;
				this._alpha = 100;
				delete this.onEnterFrame;
			}
		};
	}
	flamingo.raiseEvent(this, "onSetVisible", this, vis);
}
/**
* returns the visibility of this object
* @return boolean True if visible false if not visible
*/
function getVisible():Boolean{
	return this.visible;
}
	
function hide() {
	visible = false;
	flamingo.raiseEvent(this, "onHide", this);
	onEnterFrame = function () {
		this._alpha = this._alpha-20;
		if (this._alpha<=0) {
			_visible = false;
			this._alpha = 100;
			delete this.onEnterFrame;
		}
	};
}
function miniMe() {
	setSize(__width, mWindow.mTitleBar._height+mWindow.mBorderT._height+mWindow.mBorderB._height);
}
function show() {
	visible = true;
	_visible = true;
	this.setFocus();
	flamingo.raiseEvent(this, "onShow", this);
}
function getTitle():String {
	return (title);
}
function setTitle(txt:String):Void {
	title = txt;
	refresh();
}
function refresh() {
	var t:TextField = mWindow.tTitle;
	if (focus) {
		t.htmlText = "<span class='titlefocus'>"+title+"</span>";
	} else {
		t.htmlText = "<span class='title'>"+title+"</span>";
	}
	t._x = mWindow.mBorderL._width;
	t._y = ((mWindow.mBorderT._height+mWindow.mTitleBar._height)/2)-(t.textHeight/2);
	t._width = Math.min(t.textWidth+5, (mWindow.mTitleBar._width-10));
}
function dropShadow() {
	var distance:Number = 0;
	//5
	var angleInDegrees:Number = 45;
	var color:Number = 0x000000;
	var alpha:Number = 0.5;
	//.3;
	var blurX:Number = 11;
	//6;
	var blurY:Number = 11;
	//6;
	var strength:Number = 1.5;
	var quality:Number = 1;
	var inner:Boolean = false;
	var knockout:Boolean = false;
	var hideObject:Boolean = false;
	var filter:DropShadowFilter = new DropShadowFilter(distance, angleInDegrees, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
	var filterArray:Array = new Array();
	filterArray.push(filter);
	this.filters = filterArray;
}
function _initBorder(mc:MovieClip, cursor:String, dx:Number, dy:Number) {
	mc.useHandCursor = false;
	if (canresize) {
		mc.onPress = function() {
			var x = this._xmouse;
			var y = this._ymouse;
			this._parent._parent.setFocus();
			this.onMouseMove = function() {
				var windowwidth = thisObj.__width;
				var windowheight = thisObj.__height;
				var windowx = thisObj._x;
				var windowy = thisObj._y;
				if (dx != 0) {
					if (x>=0 and x<=this._width) {
						var stepx = this._xmouse-x;
						mc._x = mc._x+stepx;
						windowwidth = thisObj.__width+(stepx*dx);
						if (windowwidth<minwidth) {
							windowwidth = minwidth;
						} else {
							if (dx<0) {
								windowx = thisObj._x+stepx;
							}
						}
					}
				}
				if (dy != 0) {
					if (y>=0 and y<=this._height) {
						var stepy = this._ymouse-y;
						mc._y = mc._y+stepy;
						windowheight = thisObj.__height+(stepy*dy);
						if (windowheight<minheight) {
							windowheight = minheight;
						} else {
							if (dy<0) {
								windowy = thisObj._y+stepy;
							}
						}
					}
				}
				this._parent._parent.setSize(windowwidth, windowheight, windowx, windowy);
				x = this._xmouse;
				y = this._ymouse;
			};
		};
		mc.onReleaseOutside = function() {
			this._parent._parent.resizeContent();
			flamingo.hideCursor();
			delete this.onMouseMove;
		};
		mc.onRelease = function() {
			this._parent._parent.resizeContent();
			delete this.onMouseMove;
		};
		mc.onRollOver = function() {
			this._parent._parent.showCursor(cursor);
		};
		mc.onRollOut = function() {
			flamingo.hideCursor();
		};
	} else {
		mc.onPress = function() {
			this._parent._parent.setFocus();
			this._parent._parent.startDrag();
		};
		mc.onRelease = function() {
			stopDrag();
		};
	}
}
function _focus() {
	if (focus) {
		var a:Array = new Array();
		a.push({window:thisObj, depth:thisObj.getDepth()});
		var windows = flamingo.getSameComponents(thisObj, true, true);
		for (var w in windows) {
			var window:MovieClip = windows[w];
			if (flamingo.isVisible(window)) {
				a.push({window:window, depth:window.getDepth()});
			}
		}
		a.sortOn("depth", Array.NUMERIC | Array.DESCENDING);
		for (var i = 0; i<a.length; i++) {
			if (a[i].window.hitTest(_root._xmouse, _root._ymouse, true)) {
				a[i].window.setFocus();
				break;
			}
		}
		delete a;
		delete windows;
	}
}
/** 
* Dispatched when a window resizes.
* @param window:MovieClip a reference to the window.
*/
//public function onResize(window:MovieClip):Void {
//}
/** 
* Dispatched when a window gets focus.
* @param window:MovieClip a reference to the window.
*/
//public function onSetFocus(window:MovieClip):Void {
//}
/** 
* Dispatched when a window loses focus.
* @param window:MovieClip a reference to the window.
*/
//public function onKillFocus(window:MovieClip):Void {
//}
/** 
 * Dispatched when a component is removed.
 * @param window:MovieClip a reference to the window.
 * @param id:String id of component that has been removed.
 */
//public function onRemoveComponent(window:MovieClip, id:String):Void {
//}
/** 
 * Dispatched when a component is added.
 * @param window:MovieClip a reference to the window
 * @param comp:MovieClip a reference to the component.
 */
//public function onAddComponent(window:MovieClip, comp:MovieClip):Void {
//}
/**
* Dispatched when a window is hidden or shown.
* @param window:MovieClip a reference to the window.
* @param visible:Boolean True or false.
*/
//public function onSetVisible(window:MovieClip, visible:Boolean):Void {
//}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}
/**
* Dispatched when the window is hidden.
* @param window:MovieClip a reference to the window.
*/
//public function onHide(window:MovieClip):Void {
//}
/**
* Dispatched when the window is shown.
* @param window:MovieClip a reference to the window.
*/
//public function onShow(window:MovieClip):Void {
//}