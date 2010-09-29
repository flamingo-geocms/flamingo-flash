
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

import ris.PopDataConnectorListener;



import flash.external.ExternalInterface;

class ris.AbstractSelector  extends AbstractComponent implements GeometryListener,PopDataConnectorListener{
    
    private var areaSelector:Boolean;
    private var boxSelector:Boolean;
   	private var geometrySelector:Boolean;
    private var dataConnector : Object;
    
    private var map:Object = null;
    private var thisObj:Object = null;
    private var depth:Number = 0;

	private var textFormatUrl:TextFormat;
	
	private var textFormatWarning:TextFormat;
	
	private var textFormatInfo:TextFormat;
	
	private var textFormat:TextFormat;
	
    private var statusDelayIntervalID:Number = 0;
		
	private var sendRequestButton:Button;
	private var infoButton:Button;
	private var closeButton:Button;
	
	private var geometry:Geometry;
	
	private var inAreaChoser; 
	private var llX:TextInput;
	private var llY:TextInput;
	private var urX:TextInput;
	private var urY:TextInput;
	private var setExtentButton;
	private var statusLine:TextField;

	private var areaSelectionType : String;
	private var inArea:Object = new Object;
	private var coords:String = null;
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
		addControls();
		resetControls();
		dataConnector.getAreas();
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

	
    private function addControls():Void {
		this.createEmptyMovieClip("mHolder",100);
		this["mHolder"]._lockroot = true; 
		var currentY:Number = 0;  
		if(areaSelector){     
	        var inArea:RadioButton = RadioButton(attachMovie("RadioButton", "mInAreaRadioButton", depth++));
			inArea.move(20,currentY);
			currentY += 20;
			inArea.data = "inArea";
			inArea.groupName = "inWhat";
			inArea.label =_global.flamingo.getString(this,"inArea");
			inArea.selected = true;
			inArea.setSize(200,20);
			inAreaChoser = ComboBox(this["mHolder"].attachMovie("ComboBox", "cmbInAreaChoser", 1));
			inAreaChoser.addEventListener("close", Delegate.create(this, onChangeInArea));
	        inAreaChoser.drawFocus = function() {
				};
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
	        var inBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInBoxRadioButton", depth++));
			inBox.move(20,currentY);
			currentY+=15;
			inBox.data = "inBox";
			inBox.groupName = "inWhat";
			inBox.label = _global.flamingo.getString(this,"inBox");
			inBox.setSize(200,20);
			var bBox:MovieClip = this.createEmptyMovieClip("mbBox", depth++);
			bBox._x = 20;
			bBox._y = currentY;
			currentY += 115;
			var xLabel:TextField = bBox.createTextField("tXLabel",depth++,25,0, 90,20);
			xLabel.setNewTextFormat(textFormat);
			xLabel.text = "X:";
		 	var yLabel:TextField = bBox.createTextField("tYLabel",depth++,110,0,90, 20);
			yLabel.setNewTextFormat(textFormat);
			yLabel.text = "Y:";
			var llLabel:TextField = bBox.createTextField("tLlLabel",depth++,0,20,25,20);
			llLabel.setNewTextFormat(textFormat);
			llLabel.text = "LL:";
			var urLabel:TextField = bBox.createTextField("tUrLabel",depth++,0,50,25,20);
			urLabel.setNewTextFormat(textFormat);
			urLabel.text = "UR:";
			llX = TextInput(bBox.attachMovie("TextInput","llX",depth++));
			llX.setSize(80,25);
			llX.move(25,20);
			llX.restrict = "0-9";
			llX.addEventListener("change", Delegate.create(this, onChangeBox));
			llX.enabled = false;
			llY = TextInput(bBox.attachMovie("TextInput","llY",depth++));
			llY.setSize(80,25);
			llY.move(110,20);
			llY.restrict = "0-9";
			llY.addEventListener("change", Delegate.create(this, onChangeBox));
			llY.enabled = false;
			urX = TextInput(bBox.attachMovie("TextInput","urX",depth++));
			urX.setSize(80,25);
			urX.move(25,50);
			urX.restrict = "0-9";
			urX.addEventListener("change", Delegate.create(this, onChangeBox));
			urX.enabled = false;
			urY = TextInput(bBox.attachMovie("TextInput","urY",depth++));
			urY.setSize(80,25);
			urY.move(110,50);
			urY.restrict = "0-9";
			urY.addEventListener("change", Delegate.create(this, onChangeBox));
			urY.enabled = false;
	
			setExtentButton = bBox.createClassObject(mx.controls.Button, "mSetExtentButton", depth++);
			setExtentButton.move(25,80); 
			setExtentButton.label = _global.flamingo.getString(this,"extentButtonLabel");
			setExtentButton.enabled = false;
			setExtentButton.onRelease = function(){_parent._parent.onClickGetExtentButton();};
			setExtent();
		}
		if(geometrySelector){
			var inGeometryLabel:TextField = createTextField("mInGeometryLabel",depth++,20,currentY,200,20);
			currentY += 20;
			inGeometryLabel.setNewTextFormat(textFormat);
			inGeometryLabel.text = _global.flamingo.getString(this,"inGeometry");
			
	        var inGeometryPoly:RadioButton  = RadioButton(attachMovie("RadioButton", "mInGeometryPolyRadioButton", depth++));
			inGeometryPoly.move(20,currentY);
			inGeometryPoly.data = "inGeometryPoly";
			inGeometryPoly.groupName = "inWhat";
			var poly:MovieClip  = attachMovie("DrawPolyImage", "mDrawPolyImage", depth++); 
			poly._x = 10;
			poly._y = currentY + 20;
			
	        var inGeometryBox:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryBoxRadioButton", depth++));
			inGeometryBox.move(90,currentY);
			inGeometryBox.data = "inGeometryBox";
			inGeometryBox.groupName = "inWhat";
			var box:MovieClip = attachMovie("DrawBoxImage", "mDrawBoxImage", depth++);
			box._x = 80; 
			box._y = currentY + 20;
			
	        var inGeometryCircle:RadioButton = RadioButton(attachMovie("RadioButton", "mInGeometryCircleRadioButton", depth++));
			inGeometryCircle.move(160,currentY);
			inGeometryCircle.data = "inGeometryCircle";
			inGeometryCircle.groupName = "inWhat";
			var circle:MovieClip = attachMovie("DrawCircleImage", "mDrawCircleImage", depth++); 
			circle._x = 155;
			circle._y = currentY + 20;
			currentY += 70;
		}
		
		sendRequestButton = Button(attachMovie("Button", "mSendRequestButton", depth++));
	    this["mSendRequestButton"].onRelease = function(){_parent.onClickRequestButton();};
		this["mSendRequestButton"].move(20,currentY);
		this["mSendRequestButton"].setSize(180,20);
		var label:String = _global.flamingo.getString(this,"requestButtonLabel");
		if(label == undefined){
			label = "OK";
		}	
		currentY += 25;
		this["mSendRequestButton"].label = label;
		infoButton = Button(attachMovie("Button", "mInfoButton", depth++));
	  	this["mInfoButton"].onRelease = function(){_parent.onClickInfoButton();};
		this["mInfoButton"].move(20,currentY);
		this["mInfoButton"].setSize(180,20);
		label = _global.flamingo.getString(this,"infoButtonLabel");
		if(label == undefined){
			label = "Information";
		}
		this["mInfoButton"].label = label;
		currentY += 25;
		closeButton = Button(attachMovie("Button", "mCloseButton", depth++));
	  	this["mCloseButton"].onRelease = function(){_parent.onClickCloseButton();};
		this["mCloseButton"].move(20,currentY);
		this["mCloseButton"].setSize(180,20);
		label = _global.flamingo.getString(this,"closeButtonLabel");
		if(label == undefined){
			label = "Close";
		}
		this["mCloseButton"].label = label;
		currentY += 30;
		statusLine = createTextField("mCommandLine",depth++,0,currentY,this._width,60);
		statusLine.multiline = true;
		statusLine.wordWrap = true;
		this["inWhat"].addEventListener("click", Delegate.create(this, onClickRadioButton));
	}
	
	private function onChangeInArea(evtObj:Object) : Void {
		inArea = evtObj.target.selectedItem;
	}

	function resetControls(){
		if(this._visible){
			removeStatusText();
		}
	}
	
	private function enableInBox(enable:Boolean){
			RadioButton(this["mInBoxRadioButton"]).selected = enable;
			if(enable){
				RadioButton(this["mInBoxRadioButton"]).setFocus();
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
				llX.enabled = true;
				llY.enabled = true;
				urX.enabled = true;
				urY.enabled = true;
				setExtentButton.enabled = true;
				this.setAreaSelectionType("inBox");
				onChangeBox();
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
	
	private function onChangeBox(evtObj:Object):Void{
		coords = llX.text + "," + llY.text + "," +  urX.text + "," + urY.text;
		if(areaSelectionType=="inBox"){
			var crds:Array = coords.split(",");
			setStatusText("Opp.van de rechthoek: " + Math.round((crds[2]-crds[0]) * (crds[3]-crds[1])/10000)/100 + " km2", "info", true);
		}
	}
	
	function onChangeGeometry(geometry:Geometry):Void{
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
		removeStatusText();
		this["mSendRequestButton"].enabled = true;
		var resultComp:Object =_global.flamingo.getComponent(this.resultCompId);
		resultComp.ta.border_mc.setStyle("borderStyle", "none");
		var txt:String = result.toString().split("\\t").join("\t");
		txt = txt.split("\\n").join("\n");
		resultComp.setText( txt);
		resultComp._visible =true;
		if (resultComp._parent._parent._name == "mWindow") {
            resultComp._parent._parent._parent.setVisible(true);
        }
		
	}
	
	function onLoadFail(result : XML) : Void {
		this["mSendRequestButton"].enabled = true;
		setStatusText("Er is een fout opgetreden.", "warning", true);
	}
	
	private function setAreaSelectionType(areaSelectionType : String) : Void {
		this.areaSelectionType = areaSelectionType;
	}
	

}

