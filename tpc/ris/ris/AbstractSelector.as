
/**
 * @author Velsll
 */

import geometrymodel.dde.*;
import mx.utils.Delegate;
import mx.controls.RadioButton;
import mx.controls.ComboBox;
import mx.controls.TextInput;

import core.AbstractComponent;

import gui.dde.TraceLayer;

import ris.BridgisConnectorListener;

import tools.XMLTools;



import flash.external.ExternalInterface;

class ris.AbstractSelector  extends AbstractComponent implements GeometryListener,BridgisConnectorListener{

    private var areaSelector:Boolean;
    private var boxSelector:Boolean;
   	private var geometrySelector:Boolean;
    private var dataConnector : Object;
    private var map:Object = null;
    private var thisObj:Object = null;
	private var textFormatUrl:TextFormat;
	private var textFormatWarning:TextFormat;
	private var textFormatInfo:TextFormat;
	private var textFormat:TextFormat;
    private var statusDelayIntervalID:Number = 0;
	private var sendRequestButton:Button;
	private var infoButton:Button;
	private var closeButton:Button;
	
	
	private var geometry:Geometry;
	private var wktCoords:String = "";
	private var coords:String = null;
	private var inAreaChoser; 
	private var llX:TextInput;
	private var llY:TextInput;
	private var urX:TextInput;
	private var urY:TextInput;
	private var setExtentButton;
	private var statusLine:TextField;

	private var areaSelectionType : String;
	private var inArea:Object = new Object;

	private var resultCompId = "populationresults";

	
	function onLoad():Void {
		super.onLoad();
	}
	
	function init():Void{
		map = _global.flamingo.getComponent(listento[0]);
		thisObj = this;
		textFormat = new TextFormat();
    	textFormat.font = "_sans";
		textFormat.underline = false;
		textFormatUrl = new TextFormat();
		textFormatUrl.font = "_sans";
		textFormatUrl.color = 0x0000ff;
		textFormatUrl.underline = true;
		textFormatWarning = new TextFormat();
		textFormatWarning.underline = false;
		textFormatWarning.font = "_sans";
		textFormatWarning.color = 0xff0000;
		textFormatInfo = new TextFormat();
		textFormatInfo.underline = false;
		textFormatInfo.font = "_sans";
		textFormatInfo.color = 0x0000ff;

	}



   function setVisible(visible:Boolean):Void {
    	super.setVisible(visible);
		if(!visible){
			if(map["mTraceSheet"]!=null){
				map["mTraceSheet"].removeMovieClip();
			}
		} else {
			resetControls();
		}
		
    }

	
	
    private function addAreaControls(x:Number,y:Number):Void { 
    	var currentY:Number = y;    	
    	var title:String = _global.flamingo.getString(this,"titleReportArea");
		if(title != undefined){
			var reportAreaTitle:TextField = createTextField("mReportAreaTitle",this.getNextHighestDepth(),0,currentY,150,20);
			reportAreaTitle.text = title;
			reportAreaTitle.setTextFormat(textFormat);	
			reportAreaTitle.selectable = false;
			currentY+=25;
		}	
		
		if(areaSelector){     
	        var inArea:RadioButton = RadioButton(attachMovie("RadioButton", "mInAreaRadioButton", this.getNextHighestDepth()));
			inArea.move(20,currentY);
			currentY += 20;
			inArea.data = "inArea";
			inArea.groupName = "inWhat";
			inArea.label =_global.flamingo.getString(this,"inArea");
			inArea.selected = true;
			inArea.setSize(200,20);
			this.createEmptyMovieClip("mHolder",100);
			inAreaChoser = ComboBox(this["mHolder"].attachMovie("ComboBox", "cmbInAreaChoser", 1));
			inAreaChoser.addEventListener("close", Delegate.create(this, onChangeInArea));
	        inAreaChoser.drawFocus = function() {};
			inAreaChoser.getDropdown().drawFocus = "";
			// to prevent the list to close after scrolling
			inAreaChoser.onKillFocus = function(newFocus:Object) {
				super.onKillFocus();
			};
			inAreaChoser.move(20, currentY);
			currentY += 40;
			inAreaChoser.setSize(170,25);
		}
		if(boxSelector){
	        var inBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInBoxRadioButton", this.getNextHighestDepth()));
			inBox.move(20,currentY);
			currentY+=20;
			inBox.data = "inBox";
			inBox.groupName = "inWhat";
			inBox.selected = true;
			inBox.label = _global.flamingo.getString(this,"inBox");
			inBox.setSize(200,20);
			var bBox:MovieClip = this.createEmptyMovieClip("mbBox", this.getNextHighestDepth());
			bBox._x = 20;
			bBox._y = currentY;
			currentY += 115;
			var xLabel:TextField = bBox.createTextField("tXLabel",1,25,0, 90,20);
			xLabel.setNewTextFormat(textFormat);
			xLabel.text = "X:";
		 	var yLabel:TextField = bBox.createTextField("tYLabel",2,110,0,90, 20);
			yLabel.setNewTextFormat(textFormat);
			yLabel.text = "Y:";
			var llLabel:TextField = bBox.createTextField("tLlLabel",3,0,20,25,20);
			llLabel.setNewTextFormat(textFormat);
			llLabel.text = "LL:";
			var urLabel:TextField = bBox.createTextField("tUrLabel",4,0,50,25,20);
			urLabel.setNewTextFormat(textFormat);
			urLabel.text = "UR:";
			llX = TextInput(bBox.attachMovie("TextInput","llX",5));
			llX.setSize(80,25);
			llX.move(25,20);
			llX.restrict = "0-9";
			llX.addEventListener("change", Delegate.create(this, onChangeBox));
			llX.enabled = false;
			llY = TextInput(bBox.attachMovie("TextInput","llY",6));
			llY.setSize(80,25);
			llY.move(110,20);
			llY.restrict = "0-9";
			llY.addEventListener("change", Delegate.create(this, onChangeBox));
			llY.enabled = false;
			urX = TextInput(bBox.attachMovie("TextInput","urX",7));
			urX.setSize(80,25);
			urX.move(25,50);
			urX.restrict = "0-9";
			urX.addEventListener("change", Delegate.create(this, onChangeBox));
			urX.enabled = false;
			urY = TextInput(bBox.attachMovie("TextInput","urY",8));
			urY.setSize(80,25);
			urY.move(110,50);
			urY.restrict = "0-9";
			urY.addEventListener("change", Delegate.create(this, onChangeBox));
			urY.enabled = false;
			setExtentButton = bBox.createClassObject(mx.controls.Button, "mSetExtentButton", 9);
			setExtentButton.move(25,80); 
			setExtentButton.label = _global.flamingo.getString(this,"extentButtonLabel");
			setExtentButton.enabled = false;
			setExtentButton.onRelease = function(){_parent._parent.onClickGetExtentButton();};
			setExtent();
		}
		if(geometrySelector){
			var inGeometryLabel:TextField = createTextField("mInGeometryLabel",this.getNextHighestDepth(),20,currentY,200,20);
			currentY += 20;
			inGeometryLabel.setNewTextFormat(textFormat);
			inGeometryLabel.text = _global.flamingo.getString(this,"inGeometry");
			
	        var inGeometryPoly:RadioButton  = RadioButton(attachMovie("RadioButton", "mInGeometryPolyRadioButton", this.getNextHighestDepth()));
			inGeometryPoly.move(20,currentY);
			inGeometryPoly.data = "inGeometryPoly";
			inGeometryPoly.groupName = "inWhat";
			var poly:MovieClip  = attachMovie("DrawPolyImage", "mDrawPolyImage", this.getNextHighestDepth()); 
			poly._x = 10;
			poly._y = currentY + 20;
			
	        var inGeometryBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryBoxRadioButton", this.getNextHighestDepth()));
			inGeometryBox.move(90,currentY);
			inGeometryBox.data = "inGeometryBox";
			inGeometryBox.groupName = "inWhat";
			var box:MovieClip = attachMovie("DrawBoxImage", "mDrawBoxImage", this.getNextHighestDepth());
			box._x = 80; 
			box._y = currentY + 20;
			
	        var inGeometryCircle:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryCircleRadioButton", this.getNextHighestDepth()));
			inGeometryCircle.move(160,currentY);
			inGeometryCircle.data = "inGeometryCircle";
			inGeometryCircle.groupName = "inWhat";
			var circle:MovieClip = attachMovie("DrawCircleImage", "mDrawCircleImage", this.getNextHighestDepth()); 
			circle._x = 155;
			circle._y = currentY + 20;
			currentY += 70;
		}
    }

	private function addButtons(x:Number, y:Number){	
			sendRequestButton = Button(attachMovie("Button", "mSendRequestButton", this.getNextHighestDepth()));
	    		this["mSendRequestButton"].onRelease = function(){_parent.onClickRequestButton();};
				this["mSendRequestButton"].move(x,y);
				this["mSendRequestButton"].setSize(180,20);
				var label:String = _global.flamingo.getString(this,"requestButtonLabel");
			if(label == undefined){
				label = "OK";
			}	
			y += 25;
			this["mSendRequestButton"].label = label;
			infoButton = Button(attachMovie("Button", "mInfoButton", this.getNextHighestDepth()));
		  	this["mInfoButton"].onRelease = function(){_parent.onClickInfoButton();};
			this["mInfoButton"].move(x,y);
			this["mInfoButton"].setSize(180,20);
			label = _global.flamingo.getString(this,"infoButtonLabel");
			if(label == undefined){
				label = "Information";
			}
			this["mInfoButton"].label = label;
			y += 25;
			closeButton = Button(attachMovie("Button", "mCloseButton", this.getNextHighestDepth()));
		  	this["mCloseButton"].onRelease = function(){_parent.onClickCloseButton();};
			this["mCloseButton"].move(x,y);
			this["mCloseButton"].setSize(180,20);
			label = _global.flamingo.getString(this,"closeButtonLabel");
			if(label == undefined){
				label = "Close";
			}
			this["mCloseButton"].label = label;
	}
	
	function addStatusLine(x:Number, y:Number){
			statusLine = createTextField("mCommandLine",this.getNextHighestDepth(),x,y,this._width,60);
			statusLine.multiline = true;
			statusLine.wordWrap = true;
			this["inWhat"].addEventListener("click", Delegate.create(this, onClickRadioButton));
	}
	
	
	private function onChangeInArea(evtObj:Object) : Void {
		inArea = evtObj.target.selectedItem;
	}

	function resetControls():Void{
		if(this._visible){
			removeStatusText();
			enableInBox(true);
		}
	}
	
	private function enableInBox(enable:Boolean){
			RadioButton(this["mInBoxRadioButton"]).selected = enable;
			onChangeBox();
			if(enable){
				//RadioButton(this["mInBoxRadioButton"]).setFocus();
				this.setAreaSelectionType("inBox");
			}	
			llX.enabled = enable;
			llY.enabled = enable;
			urX.enabled = enable;
			urY.enabled = enable;
			setExtent();
			setExtentButton.enabled = enable;	
	}
	
	
	
	function setStatusText(statusText:String, type:String, permanent:Boolean):Void{
		if(type=="url"){
			statusLine.html = true;
			statusLine.setNewTextFormat(textFormatUrl);
			statusLine.htmlText = statusText
		} else {
			if(type=="warning"){
				statusLine.setNewTextFormat(textFormatWarning);	
			} else {
			if(type=="info"){
				statusLine.setNewTextFormat(textFormatInfo);	
				} else {
					statusLine.setNewTextFormat(textFormat);	
				}
			}
			statusLine.html = false;	
			statusLine.text = statusText;
		}
		if(permanent != true && statusText != ""){
			statusDelayIntervalID = setInterval(this, "removeStatusText", 5000);
		}
		
    }
	
	function removeStatusText():Void{
		clearInterval(statusDelayIntervalID);
      	statusDelayIntervalID = 0;
		setStatusText("");
	}
    
	
    private function onClickRadioButton(evtObj:Object):Void {
		removeStatusText();
		var selectedOption:String = evtObj.target.selectedRadio.data;
		if(map["mTraceSheet"]!=null){
			map["mTraceSheet"].removeMovieClip();
		}
		enableInBox(false);
		inAreaChoser.enabled = false;
		switch (selectedOption){
			case "inArea" :
         		inAreaChoser.enabled = true;
				this.setAreaSelectionType("inArea");
				break;
			case "inBox" :
				enableInBox(true);
				break;	
			case "inGeometryPoly" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"tracePoly");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;
			case "inGeometryBox" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceBox");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);	
				break;	
			case "inGeometryCircle" :
				this.setAreaSelectionType("inGeometry");
         		var traceLayer:TraceLayer = new TraceLayer(map,"traceCircle");
				geometry = traceLayer.getGeometry();
				geometry.addGeometryListener(this);
				break;	
	
		}     
    }
	
	private function onClickGetExtentButton(evtObj:Object):Void {
		setExtent();
	}
	
	private function setExtent():Void{
		if (map.getMapExtent() != undefined){
			if(map.getMapExtent().minx < map.getFullExtent().minx) {
				llX.text = Math.round(map.getFullExtent().minx).toString();
			} else {
				llX.text = Math.round(map.getMapExtent().minx).toString();	
			}
			if( map.getMapExtent().miny < map.getFullExtent().miny) {
				llY.text = Math.round(map.getFullExtent().miny).toString();
			} else {
				llY.text = Math.round(map.getMapExtent().miny).toString();
			}
			if(map.getFullExtent().maxx <= map.getMapExtent().maxx){
				urX.text = Math.round(map.getFullExtent().maxx).toString();
			} else {
				urX.text = Math.round(map.getMapExtent().maxx).toString();
			}
			if(map.getFullExtent().maxy <= map.getMapExtent().maxy){
				urY.text = Math.round(map.getFullExtent().maxy).toString();
			} else {
				urY.text = Math.round(map.getMapExtent().maxy).toString();
			}
			onChangeBox();
		} 
	}
	
	private function onClickRequestButton():Void{	
	}
	
	private function onClickCloseButton():Void{
		this.setVisible(false);
	}
	
	private function onClickInfoButton():Void{
    	var url:String =_global.flamingo.getString(this,"infoButtonUrl");
    	ExternalInterface.call("popWin",url);  
	}
	
	function onChangeBox(evtObj:Object):Void{
		coords = llX.text + "," + llY.text + "," +  urX.text + "," + urY.text;
		wktCoords = llX.text + " " + llY.text + "," +  llX.text + " " + urY.text + "," +  urX.text + " " + urY.text + "," +  urX.text + " " + llY.text + "," + llX.text + " " + llY.text;
		if(areaSelectionType=="inBox"){
			var crds:Array = coords.split(",");
			setStatusText("Opp.van de rechthoek: " + Math.round((crds[2]-crds[0]) * (crds[3]-crds[1])/10000)/100 + " km2", "info", true);
		}
	}
	
	function onChangeGeometry(geometry:Geometry):Void{
		var crds:Array = geometry.getCoords();
		wktCoords = "";
		coords = "";
		for (var n:Number = 0; n<crds.length; n++){
			this.wktCoords += crds[n].getX() + " " + crds[n].getY() + ",";
			this.coords += crds[n].getX() + "," + crds[n].getY() + ",";
		}
		wktCoords = wktCoords.substr(0,wktCoords.length-1);
		coords = coords.substr(0,coords.length-2);	
	}
	
	function onFinishGeometry(geometry:Geometry):Void{
		setStatusText("Opp.van de geometrie: " + Math.round(getArea(coords)/10000)/100 + " km2", "info", true);
	}
	
	
	
	private  function getArea(coords):Number {
		var crds:Array = coords.split(",");
   		var area:Number = 0;
   		var points:Array = new Array();
		for (var i:Number = 0; i < crds.length; i++) {
			var point:Point = new Point(crds[i],crds[i++]);
			points.push(point);
		}
		for (var i:Number = 0; i < points.length-1; i++) {	
			area += ( points[i].getX() * points[i+1].getY() - points[i+1].getX() * points[i].getY() );
		}
		area /= -2.0;
		return Math.abs(area);
	}
	
	
	
    function setAttribute(name:String, value:String):Void {	
        switch (name) {
        	case "url":
				dataConnector.setUrl(value);
				break;
			case "reporturl":
				dataConnector.setReportUrl(value);
				break;
			case "areasurl":
				dataConnector.setAreasUrl(value);
				break;	
			case "resulttext":
				resultCompId = value;
				break;
        }
    }
	
	function onUpdate(map:MovieClip):Void{
	}
	
	public function onAreaLoad(result : XML) : Void {
	}

	public function onReportLoad(result : XML) : Void {
	}
	
	function showReport(text:String){
		removeStatusText();
		this["mSendRequestButton"].enabled = true;
		var resultComp:Object =_global.flamingo.getComponent(this.resultCompId);
		resultComp.ta.border_mc.setStyle("borderStyle", "none");
		resultComp.setText( text);
		resultComp._visible =true;
		if (resultComp._parent._parent._name == "mWindow") {
            resultComp._parent._parent._parent.setVisible(true);
        }
	}
	
	function showResults(result: XML){
	}
	
	function onLoadResult(result :XML):Void {
		//var statusNodes:Array =  XMLTools.getElementsByTagName("Status", result);
		//if(statusNodes[0].firstChild.nodeValue == "FAILED"){
			//onLoadFail(result);
		//} else {
			showResults(result);
		//}			
	}
	
	function onLoadFail(result : XML) : Void {
		this["mSendRequestButton"].enabled = true;
		setStatusText("Er is een fout opgetreden.", "warning", true);
	}
	
	private function setAreaSelectionType(areaSelectionType : String) : Void {
		this.areaSelectionType = areaSelectionType;
	}
	

}

