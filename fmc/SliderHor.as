/*-----------------------------------------------------------------------------
Author: Herman Assink, IDgis BV

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
/** @component SliderHor
* A horizontal slider.
* @file SliderHor.fla (sourcefile)
* @file SliderHor.swf (compiled component, needed for publication on internet)
* @file SliderHor.xml (configurationfile, needed for publication on internet)
* @configstring minimum Minimum value.
* @configstring maximum Maximum value.
* @configstring initial Initial value.
* @configstring slidestep Value to increase or decrease current setting with every click.
* @configstring setter name of method on listeners to apply new value.
* @configstring tooltip_increase Tooltip of plus button.
* @configstring tooltip_decrease Tooltip of min button.
* @configstring tooltip_slider Tooltip of slider button.
*/
var version:String = "3.0";
//---------------------------------------
var skin = "";
var thisObj = this;
var bSlide:Boolean = false;
var minimum:Number = 0;
var maximum:Number = 100;
var initial:Number = 100;
var slidestep:Number = (maximum - minimum) / 20;
var updatedelay:Number = 500;
var currentValue:Number = 0;
var setter:String = "";
//listeners
//---------------------------------------
var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//---------------------------------------
//---------------------------------------
init();
/** @tag <fmc:SliderHor>  
* This tag defines a horizontal slider. Another component may listen to change events.
* @example
* <fmc:SliderHor left="10" top="10" width="300" minimum="0" maximum="100" initial="100" setter="setAlpha" slidestep="5">
*		    <string id="tooltip_increase" en="opaque" nl="ondoorzichtig"/>
*		    <string id="tooltip_decrease" en="transparent" nl="transparant"/>
*		    <string id="tooltip_slider" en="drag to change transparency" nl="schuif voor transparantie"/>
* </fmc:SliderHor>
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @attr skin (defaultvalue="") Available skins: "", "f2" 
*/
function init() {
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true
		t.htmlText ="<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>SliderHor "+ this.version + "</B> - www.flamingo-mc.org</FONT></P>"
		return;
	}
	this._visible = false

	//defaults
	var xml:XML = flamingo.getDefaultXML(this);
	this.setConfig(xml);
	delete xml;

	//custom
	var xmls:Array= flamingo.getXMLs(this);
	for (var i = 0; i < xmls.length; i++){
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	
	var eventHandler:Object = new Object();
	eventHandler.onSetValue = function (sourceSetter:String, newValue:Number, layer:Object) {
	  if (sourceSetter == setter) {
	    currentValue = newValue;
	    thisObj.refresh();
	  }
	}
	flamingo.addListener(eventHandler, listento, this);
	
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
	//load default attributes, strings, styles and cursors 
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "skin" :
			skin = val;
			break;
		case "minimum" :
			minimum = Number(val);
			break;
		case "maximum" :
			maximum = Number(val);
			break;
		case "initial" :
			initial = Number(val);
			break;
		case "slidestep" :
			slidestep = Number(val);
			break;
		case "setter" :
			setter = val;
			break;
		}
	}

	//build buttons
	//
	bIncrease = new FlamingoButton(createEmptyMovieClip("mIncrease", 1), skin+"_increase_up", skin+"_increase_over", skin+"_increase_down", skin+"_increase_up", this);
	bIncrease.onPress = function() {
		cancelUpdate();
	};
	bIncrease.onRelease = function() {
		stepSlider(true);
	};
	bIncrease.onReleaseOutside = function() {
		stepSlider(true);
	};
	bIncrease.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_increase"), mIncrease);
	};
	//
	bDecrease = new FlamingoButton(createEmptyMovieClip("mDecrease", 2), skin+"_decrease_up", skin+"_decrease_over", skin+"_decrease_down", skin+"_decrease_up", this);
	bDecrease.onPress = function() {
		cancelUpdate();
	};
	bDecrease.onRelease = function() {
		stepSlider(false);
	};
	bDecrease.onReleaseOutside = function() {
		stepSlider(false);
	};
	bDecrease.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_decrease"), mDecrease);
	};
	//
	bSlider = new FlamingoButton(createEmptyMovieClip("mSlider", 4), skin+"_slider_up", skin+"_slider_over", skin+"_slider_down", skin+"_slider_up", this);
	bSlider.onPress = function() {
		cancelUpdate();
		var l = mSliderbar._x;
		var t = mSlider._y;
		var r = mSliderbar._x+mSliderbar._width;
		var b = mSlider._y;
		startDrag(mSlider, false, l, t, r, b);
		this.onMouseMove = function() {
			bSlide = true;
			slide();
		};
	};
	bSlider.onRelease = function() {
		bSlide = false;
		delete this.onMouseMove;
		stopDrag();
		slide();
	};
	bSlider.onReleaseOutside = function() {
		bSlide = false;
		delete this.onMouseMove;
		stopDrag();
		slide();
	};
	bSlider.onRollOver = function() {
		flamingo.showTooltip(flamingo.getString(thisObj, "tooltip_slider"), mSlider);
	};
	//
	this.attachMovie(skin+"_slider_bar", "mSliderbar", 3);
	//
	if (flamingo.getString(this, "label") != undefined && flamingo.getString(this, "label") != "") {
  	createTextField("mLabel", this.getNextHighestDepth(), 0, 0, 100, 25);
  	mLabel.multiline = false;
  	mLabel.wordWrap = false;
  	mLabel.html = true;
  	mLabel.selectable = false;
  	mLabel.styleSheet = flamingo.getStyleSheet(this);
    mLabel.text = "<p class='text'>" + flamingo.getString(this, "label") + "</p>";
  	mLabel._width = mLabel.textWidth+5;
  	mLabel._height = mLabel.textHeight+5;
  }
  
	currentValue = initial;
	resize();
	refresh();
}

function stepSlider(increase:Boolean) {
    if (increase) {
      currentValue += slidestep;
    }
    else {
      currentValue += -slidestep;
    }

    if (minimum < maximum) {
	    if (currentValue < minimum) {
	      currentValue = minimum;
	    }
	    if (currentValue > maximum) {
	      currentValue = maximum;
	    }
	  }
	  else {
	    if (currentValue > minimum) {
	      currentValue = minimum;
	    }
	    if (currentValue < maximum) {
	      currentValue = maximum;
	    }
	  }

	  updateListeners();    
}

function slide() {

	currentValue = minimum + ((mSlider._x-mSliderbar._x) / mSliderbar._width) * (maximum - minimum);
	updateListeners();

}

function refresh() {
	if (bSlide) {
		return;
	}
	mSlider._x = mSliderbar._x + (mSliderbar._width * Math.abs(minimum - currentValue) / Math.abs(maximum - minimum));
}

function resize() {
	var r = flamingo.getPosition(this);
	mIncrease._x = r.x + r.width - mIncrease._width / 2;
	mIncrease._y = r.y;
	mDecrease._x = r.x + mDecrease._width / 2;
	mDecrease._y = r.y;
	mSliderbar._x = r.x + mDecrease._width + mSlider._width/2;
	mSliderbar._y = r.y;
	mSliderbar._width = r.width - mDecrease._width - mIncrease._width  - mSlider._width;
	mSlider._x = mSliderbar._x;
	mSlider._y = mSliderbar._y;
	if (mLabel != undefined) {
  	mLabel._x = r.x + + mDecrease._width;
  	mLabel._y = r.y + 5;
	}
	refresh();
}

function updateListeners() {
	for (var i:Number = 0; i<listento.length; i++) {
		var mc = flamingo.getComponent(listento[i]);
		if (mc[setter]) {
		  mc[setter](currentValue);
		}
		else {
		  flamingo.tracer("Error: method with name '" + setter + "' not found on listener '" + listento[i] + "'");
		}
	}
	refresh();
}

/** 
 * Dispatched when a component is up and ready to run.
 * @param comp:MovieClip a reference to the component.
 */
//public function onInit(comp:MovieClip):Void {
//}