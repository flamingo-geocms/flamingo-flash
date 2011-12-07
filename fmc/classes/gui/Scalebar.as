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
/** @component Scalebar
* Scalebar.
* @file Scalebar.fla (sourcefile)
* @file Scalebar.swf (compiled component, needed for publication on internet)
* @file Scalebar.xml (configurationfile, needed for publication on internet)
* @configstyle .label Fontstyle of the scalenumbers.
* @configstyle .units Fontstyle of the unitstring.
*/
/** @tag <fmc:Scalebar>  
	* This tag defines a scalebar
	* The positioning tags (top, left, width etc.) affects only the size and position of the bar exclusive labels. 
	* Use multiple scalebars  and their min- and maxscale properties to support multi units.
	* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
	* @example
	* <fmc:Scalebar left="222" top="bottom -20" width="150" listento="map" minscale="50" units=" km" magicnumber="1000"/>
	* <fmc:Scalebar left="222" top="bottom -20" width="150" listento="map" maxscale="50" units=" m" skin="f1"/>
	* @attr labelcount  (defaultvalue = 2)  Number of scalelabels.
	* @attr barposition  (defaultvalue = "LEFT") LEFT, CENTER or RIGHT  Aligning of the bar.
	* @attr labelposition  (defaultvalue = "CENTER") TOP, CENTER or BOTTOM
	* @attr unitposition  (defaultvalue = "LASTLABEL") TOP, CENTER, BOTTOM or LASTLABEL
	* @attr units  (defaultvalue = "m") Any string representing units.
	* @attr magicnumber  (defaultvalue = "1") a number by which the mapscale is divided in order to present the correct scale-units. 
	* @attr skin  (defaultvalue = "") Skin. Available: "", "f1", "line", "style1", "style2"
	* @attr maxscale  (defaultvalue = "") When the map reaches this scale the bar will be shown.
	* @attr minscale  (defaultvalue = "") When the map reaches this scale the bar will be hidden.
	*/
import core.ComponentInterface;
import gui.button.AbstractButton;
import tools.Logger;
class gui.Scalebar extends AbstractButton {
	
	//-------------------------------
	var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<Scalebar>" +
							"<style id='.label' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
							"<style id='.units' font-family='verdana' font-size='11px' color='#333333' display='block' font-weight='normal'/>" +
							"</Scalebar>";
	var visible:Boolean;
	var labelcount:Number = 2;
	var labelposition:String = "CENTER";
	var unitstring:String = "m";
	var unitposition:String = "LASTLABEL";
	var barposition:String = "LEFT";
	var magicnumber:Number = 1;
	var minscale:Number;
	var maxscale:Number;
	
	
	//the movieclip loader
	var _mcloader:MovieClipLoader;
	
	//the movieclips that are shown.
	var _mBar:MovieClip;
	var _mHolder:MovieClip;
		var lMap:Object = new Object();
	
	public function Scalebar(id:String, container:MovieClip) {
		super(id, container);
		var thisObj = this;
		
		mHolder = this.container;
		mBar = mHolder.createEmptyMovieClip("mBar", this.container.getNextHighestDepth());
		
		this.mcloader = new MovieClipLoader();		
		
		this.mcloader.loadClip(_global.flamingo.correctUrl("/assets/img/scalebar.png"), this.mBar);	
		
		lMap.onChangeExtent = function(map:MovieClip):Void  {
			thisObj.resize();
		};

		//---------------------------------------
		var lParent:Object = new Object();
		lParent.onResize = function(mc:MovieClip) {
			thisObj.resize();
		};
		flamingo.addListener(lParent, flamingo.getParent(this), this);
		//---------------------------------------
		//---------------------------------------
		init();
	}
	
	//var tScale:TextField = null;

	//---------------------------------
	
	
	private function init():Void {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Scalebar "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;
	  
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
		this.container.useHandCursor = false;
		this._visible = visible;
		resize()
		flamingo.raiseEvent(this, "onInit", this);


	}
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			var val:String = xml.attributes[attr];
			switch (attr.toLowerCase()) {
			case "labelcount" :
				labelcount = Number(val);
				break;
			case "barposition" :
				barposition = val.toUpperCase();
				break;
			case "labelposition" :
				labelposition = val.toUpperCase();
				break;
			case "units" :
				unitstring = val;
				break;
			case "minscale" :
				minscale = Number(val);
				break;
			case "maxscale" :
				maxscale = Number(val);
				break;
			case "unitposition" :
				unitposition = val.toUpperCase();
				break;
			case "magicnumber" :
				magicnumber = Number(val);
				break;
			/*case "skin" :
				skin = val;
				break;*/
			}
		}

		
		var mc = mBar;
		for (var i = 0; i<labelcount; i++) {
			var t = mHolder.createTextField("tLabel"+i, i+1, 0, 0, 0, 0);
			t.styleSheet = flamingo.getStyleSheet(this);
			t.multiline = false;
			t.wordWrap = false;
			t.html = true;
			t.selectable = false;
			t.autoSize = true;
		}
		if (unitposition != "LASTLABEL") {
			var t = mHolder.createTextField("tUnit", labelcount+2, 0, 0, 0, 0);
			t.styleSheet = flamingo.getStyleSheet(this);
			t.multiline = false;
			t.wordWrap = false;
			t.html = true;
			t.selectable = false;
			t.autoSize = true;
		}
	/*
		tScale = mHolder.createTextField("tScale", labelcount+3, 0, 0, 0, 0);
		tScale.styleSheet = flamingo.getStyleSheet(this);
		tScale.multiline = false;
		tScale.wordWrap = false;
		tScale.html = false;
		tScale.selectable = false;
	*/	
		flamingo.addListener(lMap, listento[0], this);

		resize();
	}
	
	function resize() {

	/*	
		if (! visible) {
			this._visible = false;
			return;
		}*/
		var map = flamingo.getComponent(listento[0]);

		if (map == undefined) {
			this._visible = false;
			return
		}
		if (! map.hasextent) {
			this._visible = false;
			return;
		}

		var r = flamingo.getPosition(this);
		var w = r.width;

		var ms = map.getScale();
		if (minscale != undefined) {
			if (ms<minscale) {
				this._visible = false;
				return;
			}
		}
		if (maxscale != undefined) {
			if (ms>maxscale) {
				this._visible = false;
				return;
			}
		}
		var exactlength = Math.round(ms/magicnumber*w);
		//just round exactlength on whole numbers
		var d = Math.pow(10, (String(exactlength).length-1));
		var barlength = Math.floor(exactlength/d)*d;
		if (barlength == 0) {
			//barlength = exactlength;
			//if (barlength == 0) {
			//barlength = ms*w;
			//}
			this._visible = false;
			return;
		}
		this._visible = true;
		//Logger.console("width:", (barlength/(ms/magicnumber)));
		mBar._width = 400;// barlength / (ms / magicnumber);
		mBar._x = 100;

		if (barposition == "CENTER") {
			mBar._x = r.width/2-mBar._width/2;
		} else if (barposition == "RIGHT") {
			mBar._x = r.width-mBar._width;
		}
	/*
		tScale.text = String(Math.round(ms*1000)/1000);
		tScale._width = tScale.textWidth+5;
		tScale._height = tScale.textHeight+5;
		tScale._x = mBar._x - tScale._width - 20;
		tScale._y = mBar._y;	
	*/	
		if (labelcount == 1) {
			var l = barlength;
			if (unitposition == "LASTLABEL") {
				l = l+unitstring;
			}
			mHolder["tLabel0"].htmlText = "<span class='label'>"+l+"</span>";
			mHolder["tLabel0"]._width = mHolder["tLabel0"].textWidth+5;
			mHolder["tLabel0"]._height = mHolder["tLabel0"].textHeight+5;
			var xcenter = mBar._x+(mBar._width/2);
			mHolder["tLabel0"]._x = xcenter-(mHolder["tLabel0"]._width/2);
			if (labelposition == "TOP") {
				mHolder["tLabel0"]._y = mBar._y-mHolder["tLabel0"]._height;
			} else {
				mHolder["tLabel0"]._y = mBar._y+mBar._height;
			}
		} else {
			for (var i = 0; i<labelcount; i++) {
				var l = barlength/(labelcount-1)*i;
				mHolder["tLabel"+i].htmlText = "<span class='label'>"+l+"</span>";
				mHolder["tLabel"+i]._width = mHolder["tLabel"+i].textWidth+5;
				mHolder["tLabel"+i]._height = mHolder["tLabel"+i].textHeight+5;
				var xcenter = mBar._x+(mBar._width/(labelcount-1)*(i));
				mHolder["tLabel"+i]._x = xcenter-(mHolder["tLabel"+i]._width/2);
				if (labelposition == "TOP") {
					mHolder["tLabel"+i]._y = mBar._y-mHolder["tLabel"+i]._height;
				} else if (labelposition == "CENTER") {
					mHolder["tLabel"+i]._y = mBar._y+(mBar._height/2)-(mHolder["tLabel"+i]._height/2);
					if (i == 0) {
						mHolder["tLabel"+i]._x = mBar._x-mHolder["tLabel"+i]._width;
					}
					if (i == (labelcount-1)) {
						mHolder["tLabel"+i]._x = mBar._x+mBar._width;
					}
				} else {
					mHolder["tLabel"+i]._y = mBar._y+mBar._height;
				}
				if (unitposition == "LASTLABEL" && i == (labelcount-1)) {
					mHolder["tLabel"+i].htmlText = "<span class='label'>"+l+unitstring+"</span>";
					mHolder["tLabel"+i]._width = mHolder["tLabel"+i].textWidth+5;
					mHolder["tLabel"+i]._height = mHolder["tLabel"+i].textHeight+5;
				}
			}
		}
		if (mHolder["tUnit"] != undefined) {
			mHolder["tUnit"].htmlText = "<span class='units'>"+unitstring+"</span>";
			mHolder["tUnit"]._width = mHolder["tUnit"].textWidth+5;
			mHolder["tUnit"]._height = mHolder["tUnit"].textHeight+5;
			mHolder["tUnit"]._x = (mBar._x+(mBar._width/2))-(mHolder["tUnit"]._width/2);
			if (unitposition == "TOP") {
				mHolder["tUnit"]._y = mBar._y-mHolder["tUnit"]._height;
			} else if (unitposition == "CENTER") {
				mHolder["tUnit"]._y = mBar._y+(mBar._height/2)-(mHolder["tUnit"]._height/2);
			} else {
				mHolder["tUnit"]._y = mBar._y+mBar._height;
			}
		}
		/*
		var ra = flamingo.getPosition(this);
		mHolder._x = ra.x;
		mHolder._y = ra.y;*/
		flamingo.position(this);
	}
	
	public function get mBar():MovieClip 
	{
		return _mBar;
	}
	
	public function set mBar(value:MovieClip):Void 
	{
		_mBar = value;
	}
	
	public function get mHolder():MovieClip 
	{
		return _mHolder;
	}
	
	public function set mHolder(value:MovieClip):Void 
	{
		_mHolder = value;
	}
	
	public function get mcloader():MovieClipLoader 
	{
		return _mcloader;
	}
	
	public function set mcloader(value:MovieClipLoader):Void 
	{
		_mcloader = value;
	}
/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}
}