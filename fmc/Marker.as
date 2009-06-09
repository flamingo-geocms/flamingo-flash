// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

class Marker extends MovieClip {
	private var id:String = null;	// Set by init object.
	private var markerIDnr:Number = -1;	// Set by init object.
	private var x:Number = null;	// Set by init object.
	private var y:Number = null;	// Set by init object.
	private var width:Number = null;	// Set by init object.
	private var height:Number = null;	// Set by init object.
	private var type:String = "default";	// Set by init object.
	private var htmlText:String = "";	// Set by init object.
	
	function init():Void{
		this._width = width;
		this._height = height;
	}
	/*
	//example
	function onPress():Void{
		_global.flamingo.tracer("Marker.as onPress() pressed");
	}
	*/
	
	function redraw(extent:Object, __width:Number, __height:Number):Void{
		if (extent == undefined) {
			return;
		}
		var p:Object = new Object();
		var msx = (extent.maxx-extent.minx)/__width;
		var msy = (extent.maxy-extent.miny)/__height;
		this._x = (this.x-extent.minx)/msx;
		this._y = (extent.maxy-this.y)/msy;
		
	}
	
	//getters & setters
	function getId():String{
		return this.id;
	}
	function getMarkerIDnr():Number{
		return this.markerIDnr;
	}
	function getX():Number{
		return this.x;
	}
	function getY():Number{
		return this.y;
	}
	
	function setXY(x:Number, y:Number):Void{
		this.x = x;
		this.y = y;
		this._x = x;
		this._y = y;
	}
	function setType(type:String):Void{
		this.type = type;
		//updateTypeGraphic();
	}
	function setWidth(width:Number):Void{
		this._width = width;
	}
	function setHeight(height:Number):Void{
		this._height = height;
	}
	function setHTMLText(htmlText:String):Void{
		this.htmlText = htmlText;
		//updateHTMLText();
	}
}