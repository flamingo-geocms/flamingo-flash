﻿// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.

/** @component Print 
* A user interface component intended to prepair a map and/or other components to be sent to a printer. 
* A set of components to print is called a template. Please refer to the PrintTemplate component.
*
* With the print component a user can select a template and change its make-up. 
* Two settings of a template are set outside the print component. 
* The user can use the “main map” for that. These settings are: the rough zoom area, and optionally an identify location. 
* The first map in every template will react to these events from Flamingo's “main map”. 
* All other settings are done using the print component. 
* These settings are: the exact scale, which components within the template be visible (using a “container inspector” with check boxes), 
* which layers be visible in the map (using a dedicated legend in the “legend container”), and, finally, whether identify results be visible.
*
* By default, the print component shows a scaled preview of the selected templates. 
* The user can choose to see the preview in the original size. 
* Every single pixel that will be sent to the printer is also as one pixel on screen then.
*
*
* @file flamingo/tpc/classes/flamingo/gui/Print.as  (sourcefile)
* @file flamingo/tpc/Print.fla (sourcefile)
* @file flamingo/tpc/Print.swf (compiled component, needed for publication on internet)
* @configstring previewSize Label text for the check box that makes the current template preview show original size.
* @configstring toPrinter Text on the button that sends the current template to the printer.
* @configstring choseTemplate Text shown in the template comboBox.
*/

/** @tag <tpc:Print> 
* This tag defines a print component instance. Print extends AbstractContainer and as such can hold child components. 
* Every print component should hold one “legend container” and one or more print templates. 
* The “legend container” holds the several legend components to control the maps within the templates. 
* It should be positioned at (220, 35). 
* Every legend within the container must be given an id and its corresponding template should be registered as listener to that legend. 
* That way the visibility of a legend will follow that of its template. The print listens to the “main map”. 
* It is this map that informs the maps in the templates about its zoom en pan events and its identify events.
* @class flamingo.gui.Print extends AbstractContainer
* @hierarchy child node of Flamingo or a container component. 
* @example
	<fmc:Window id="printWindow" top="60" left="60" width="585" height="680" visible="false" skin="g"
        canresize="true" canclose="true">
        <string id="title" en="Print Settings and Preview" nl="Printinstellingen en printvoorbeeld"/>
        <tpc:Print id="print" width="100%" height="100%" visible="false"  borderwidth="0" listento="map">
			<string id="previewSize" en="Preview at Original Size" nl="Printvoorbeeld op ware grootte"/>
            <string id="toPrinter" en="Send to Printer" nl="Afdrukken"/>
            <string id="choseTemplate" en="--Chose Template--" nl="-- Kies Template --"/>
            <tpc:BaseContainer left="220" right="right" top="35" height="100">
                <fmc:Legend id="printLegend0" top = " 0" width="100%" height="100%" listento="printMap0"  configobject="legend" />
            </tpc:BaseContainer>
            <tpc:BaseContainer left="130" top="183" borderwidth="0">
                <fmc:MonitorLayer id="printMonitor1" listento="printMap1">
                    <style id=".text" font-family="courier" font-size="12px" color="#666666" display="block" font-weight="normal"/>
                </fmc:MonitorLayer>
            </tpc:BaseContainer>
            <tpc:PrintTemplate id="printTemplate1" name="verticaal A4" dpi="200" format="A4" orientation="portrait"
                listento="printMonitor1" maps="printMap1">
                <fmc:Map id="printMap1" name="kaartbeeld" width="100%" height="100%" movequality="HIGH" configobject="map"/>
                <tpc:EditMap id="editMap2" name="redlining"  width="100%" height="100%"  listento="gis,printMap1" editable="false"/>
                <tpc:BitmapClone name="legenda" width="30%" height="25%" listento="legend" refreshrate="2500"/>
                <tpc:BitmapClone name="identify resultaten" width="40%" height="30%" right="right" listento="identify" refreshrate="2500"/>
                <tpc:PrintLabel name="identifylabel" top="0" width="40%" right="right"  text="Identify resultaten" fontfamily="arial" fontsize="18"/>
            </tpc:PrintTemplate>
		</tpc:Print>
	</fmc:Window>	
*/

import flamingo.gui.*;

import flash.display.BitmapData;
import mx.containers.ScrollPane;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.utils.Delegate;
import flash.geom.Matrix;

class flamingo.gui.Print extends AbstractContainer {
    
    private var componentID:String = "Print 1.0";
	
    
    private var map:MovieClip = null;
    private var printTemplates:Array = null;
    private var currentPrintTemplate:MovieClip = null;
    private var mapPrintAdapter:MapPrintAdapter = null;
    private var scaleComboBox:ComboBox = null;
    private var scrollPane:ScrollPane = null;
    private var checkBox:CheckBox = null;
	private var templateComboBox:ComboBox = null;
    
    private var intervalID:Number = null;
    
    function init():Void {
        map = _global.flamingo.getComponent(listento[0]);
        var componentIDs:Array = getComponents();
        var component:MovieClip = null;
        var dpiFactor:Number = null;
        printTemplates = new Array();
        for (var i:String in componentIDs) {
            component = _global.flamingo.getComponent(componentIDs[i]);
            if (component.getComponentName() != "PrintTemplate") {
                continue;
            }
            component.hide();
            dpiFactor = component.getDPIFactor();
            component.setScale(50 / dpiFactor);
            
            printTemplates.push(component);
        }
        if (printTemplates.length == 0) {
            _global.flamingo.tracer("Exception in flamingo.gui.Print.<<init>>()\nNo print templates configured.");
            return;
        }
        
        mapPrintAdapter = new MapPrintAdapter(this);
        
        addTemplateSelector();
        addScaleComponents();
        addScrollPane();
        //addIdentifyButton();
        addCheckBox();
        addPrintButton();

        templateComboBox.selectedIndex = 0;


    }
	
	
	function setVisible(vis:Boolean):Void{
		super.setVisible(vis);
		setCurrentPrintTemplate(null);
		templateComboBox.selectedIndex = 0;
	}

    function getMap():MovieClip {
        return map;
    }
    
    function setScale(scale:Number):Void {
        scale = Math.round(scale / (0.0254 / 72) * currentPrintTemplate.getDPIFactor());
        scaleComboBox.text = String(scale);
    }
    
    private function addTemplateSelector():Void {
        var item:Object = null;
        var items:Array = new Array();
		item = new Object();
		item["label"] = _global.flamingo.getString(this, "choseTemplate");;
		item["data"] = null;
		items.push(item);
        for (var i:Number = 0; i < printTemplates.length; i++) {
            item = new Object();
            item["label"] = printTemplates[i].name;
            item["data"] = printTemplates[i];
            items.push(item);
        }
        
        var initObject:Object = new Object();
        initObject["_width"] = 200;
        initObject["dataProvider"] = items;
        
        var comboBoxContainer:MovieClip = createEmptyMovieClip("mTemplateComboBoxContainer", 9);
        comboBoxContainer._lockroot = true; // Without this line comboboxes wouldn't open.
        templateComboBox = ComboBox(comboBoxContainer.attachMovie("ComboBox", "mTemplateComboBox", 0, initObject));
        templateComboBox.getDropdown().drawFocus = ""; // Without this line the green focus would remain after selecting from the combobox.
        templateComboBox.addEventListener("change", Delegate.create(this, onChangeTemplateComboBox));
    }
    
    private function addScaleComponents():Void {
        var initObject:Object = null;
        
        initObject = new Object();
        initObject["_x"] = 220;
        initObject["_y"] = 2;
        initObject["text"] = "1 :";
        attachMovie("Label", "mScaleLabel", 8, initObject);
        
        initObject = new Object();
        initObject["_x"] = 235;
        initObject["_width"] = 150;
        initObject["dataProvider"] = new Array("500000", "250000", "100000", "50000", "20000", "10000", "5000", "2000");
        initObject["editable"] = true;
        initObject["rowCount"] = 8;
        
        var comboBoxContainer:MovieClip = createEmptyMovieClip("mScaleComboBoxContainer", 7);
        comboBoxContainer._lockroot = true; // Without this line comboboxes wouldn't open.
        scaleComboBox = ComboBox(comboBoxContainer.attachMovie("ComboBox", "mScaleComboBox", 0, initObject));
        scaleComboBox.getDropdown().drawFocus = ""; // Without this line the green focus would remain after selecting from the combobox.
        scaleComboBox.restrict = "0-9";
        scaleComboBox.addEventListener("close", Delegate.create(this, onChangeScaleComboBox));
        scaleComboBox.addEventListener("enter", Delegate.create(this, onChangeScaleComboBox));
    }
    
    private function addScrollPane():Void {
        scrollPane = ScrollPane(attachMovie("ScrollPane", "mScrollPane", 6, {_y: 35}));
        scrollPane.setSize(200, 100);
    }
    
    //private function addIdentifyButton():Void {
      //  var initObject:Object = new Object();
        //initObject["_y"] = 150;
        //initObject["_width"] = 110;
        //initObject["label"] = _global.flamingo.getString(this, "resetIdentify");
        //var button:Button = Button(attachMovie("Button", "mIdentifyButton", 5, initObject));
        //button.addEventListener("click", Delegate.create(this, onClickIdentifyButton));
    //}
    
    private function addCheckBox():Void {
        var initObject:Object = new Object();
        initObject["_x"] = 130;
        initObject["_y"] = 150;
        initObject["_width"] = 200;
        initObject["label"] = _global.flamingo.getString(this, "previewSize");
        checkBox = CheckBox(attachMovie("CheckBox", "mCheckBox", 4, initObject));
        checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
    }
    
    private function addPrintButton():Void {
        var initObject:Object = new Object();
        initObject["_y"] = 150;
        initObject["_width"] = 110;
        initObject["label"] = _global.flamingo.getString(this, "toPrinter");
        var button:Button = Button(attachMovie("Button", "mPrintButton", 3, initObject));
        button.addEventListener("click", Delegate.create(this, onClickPrintButton));
    }
    
    function onChangeTemplateComboBox(eventObject:Object):Void {
        setCurrentPrintTemplate(eventObject.target.selectedItem.data);
    }
    
    function onChangeScaleComboBox(eventObject:Object):Void {
        var scale:Number = Number(scaleComboBox.text);
        scale = scale / currentPrintTemplate.getDPIFactor() * (0.0254 / 72);
        var maps:Array = currentPrintTemplate.getMaps();
        for (var i:String in maps) {
            maps[i].moveToScale(scale, null, 0);
        }
    }
    

   // function onClickIdentifyButton(eventObject:Object):Void {
		//var test:Array = _global.flamingo.getXML(map);
       // var maps:Array = currentPrintTemplate.getMaps();
       // if (maps.length > 0) {
            //maps[0].identify();
       // }
   // }
    
    function onClickCheckBox(eventObject:Object):Void {
        currentPrintTemplate.setSemiscaled(checkBox.selected);
    }
    
    function onClickPrintButton(eventObject:Object):Void {
        sendToPrinter();
        
     /*   var screenshotData:BitmapData = new BitmapData(400, 300);
        screenshotData.draw(currentPrintTemplate);
        attachBitmap(screenshotData, 101);
        
        var p:Number = null;
        var r:Number = null;
        var g:Number = null;
        var b:Number = null;
        var a:Number = null;
        var sub:String = "";
        var s:String = "";
        var a:Array = new Array();
        for(var i:Number=0;i < screenshotData.height;i++) {
            for(var j:Number=0;j < screenshotData.width;j++) {
                p = screenshotData.getPixel32(j,i);
                r = g = b = a = p;
                b &= 0xFF;
                if (b == 0) { b = 1;}
                g >>= 8;
                g &= 0xFF;
                if (g == 0) { g = 1;}
                r >>= 16;
                r &= 0xFF;
                if (r == 0) { r = 1;}
                a >>= 24;
                a &= 0xFF;
                if (a == 0) { a = 1;}
                sub = String.fromCharCode(r) + String.fromCharCode(g) + String.fromCharCode(b) + String.fromCharCode(a);
                if (sub.length <> 4) {
                    _global.flamingo.tracer("FOUT " + sub.length + p + " " + r + " " + g + " " + b + " " + a);
                }
                s += sub;
            }
        }
        var b64s:String = flamingo.tools.Base64.encode(s);
        
        var env = this;
	var xml:XML = new XML("<yay>" + b64s + "</yay>");
	var xml2:XML = new XML();
	xml2.ignoreWhite = true;
	xml2.onLoad = function(successful:Boolean):Void {
	    if (successful) {
	        env.getURL("http://localhost:8080/btmp64/newimage.png", "_blank");
	    } else {
                _global.flamingo.tracer("Exception in flamingo.gui.Print\nCould not create a bitmap file.");
	    }
	
	}
	xml.sendAndLoad("http://localhost:8080/btmp64/servlet", xml2);*/
    }
    
    private function setCurrentPrintTemplate(currentPrintTemplate:MovieClip):Void {
        if (this.currentPrintTemplate == currentPrintTemplate) {
            return;
        }
        
        if (this.currentPrintTemplate != null) {
            var maps:Array = this.currentPrintTemplate.getMaps();
            this.currentPrintTemplate.hide();
        }
        this.currentPrintTemplate = currentPrintTemplate;
        if (currentPrintTemplate != null) {
            currentPrintTemplate.show();
            
            var maps:Array = currentPrintTemplate.getMaps();
            if (maps.length > 0) {
                //_global.flamingo.addListener(mapPrintAdapter, maps[0], this);
                
                setScale(maps[0].getCurrentScale());
            }
            
            scrollPane.contentPath = "ContainerInspector";
            scrollPane.content.container = currentPrintTemplate;
            
            checkBox.selected = currentPrintTemplate.isSemiscaled();
        }
    }
    
    private function sendToPrinter():Void {
        checkBox.selected = false;
        currentPrintTemplate.setSemiscaled(false);
        
        intervalID = setInterval(this, "toPrinter", 500);
    }
    
    function toPrinter():Void {
        clearInterval(intervalID);
        
        var printJob:PrintJob = new PrintJob();
        if (printJob.start()) {
            var printPage:MovieClip = currentPrintTemplate.getContentPane();
            
            if (currentPrintTemplate.getOrientation() != printJob.orientation) {
                _global.flamingo.showError("Orientation Error", "The chosen printer orientation is " + printJob.orientation + ", whereas the template orientation is " + currentPrintTemplate.getOrientation() + ".");
                delete printJob;
                return;
            }
            if (printPage._width * 2 > printJob.pageWidth + 5) { // 5 is for fault tolerance.
                _global.flamingo.showError("Print Size Error", "The chosen paper size is not wide enough for the template. Is " + printJob.pageWidth + ", should be " + (printPage._width * 2) + ".");
                delete printJob;
                return;
            }
            if (printPage._height * 2 > printJob.pageHeight + 5) { // 5 is for fault tolerance.
                _global.flamingo.showError("Print Size Error", "The chosen paper size is not high enough for the template. Is " + printJob.pageHeight + ", should be " + (printPage._height * 2) + ".");
                delete printJob;
                return;
            }
        
            var dpiFactor:Number = currentPrintTemplate.getDPIFactor();
            currentPrintTemplate.setScale(100 / dpiFactor);
            
			var width:Number = printPage._width;
            var height:Number = printPage._height;
            var xMargin:Number = (width - (printJob.pageWidth)) / 2;
            var yMargin:Number = (height - (printJob.pageHeight)) / 2;
            var printArea:Object = new Object();
            printArea["xMin"] = xMargin;
            printArea["yMin"] = yMargin;
            printArea["xMax"] = xMargin + (printJob.pageWidth * dpiFactor);
            printArea["yMax"] = yMargin + (printJob.pageHeight * dpiFactor);
			
			// first draw the printPage to a bitmap data (transparancy will remain)
			// fill a new MovieClip with this bitmap and print this MovieClip to the printer
			// with printAsBitMap = false;
			
			var bitmap:BitmapData = new BitmapData(2880, 2880, false, 0xffffff);;
			bitmap.draw(printPage);
			var tmp:MovieClip = _root.createEmptyMovieClip("rasterPage", _root.getNextHighestDepth());
			tmp.beginBitmapFill(bitmap);
			tmp.moveTo(xMargin, yMargin);
			tmp.lineTo(2880, yMargin);
			tmp.lineTo(2880, 2880);
			tmp.lineTo(xMargin, 2880);
			tmp.lineTo(xMargin, yMargin);
			tmp._x = -tmp._width;
			tmp._xscale =(1/dpiFactor) * 100;
			tmp._yscale =(1/dpiFactor) * 100;
			
            if (printJob.addPage(tmp, printArea, {printAsBitmap: false})) {
                printJob.send();
            }
            
            currentPrintTemplate.setScale(50 / dpiFactor);
        }
        delete printJob;
    }
    
}