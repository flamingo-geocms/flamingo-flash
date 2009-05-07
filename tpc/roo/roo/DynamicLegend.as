/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Herman Assink.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component DynamicLegend 
* This component is developed for the RO-online project. The component shows only the legend
* items of the objects that are visible in the mapviewer. Navigating in the map results in refreshing the
* legend. The component works only in combination with an OGC WFS. The component is not a layer control.  
* @file flamingo/tpc/roo/roo/DynamicLegend.as  (sourcefile)
* @file flamingo/tpc/roo/DynamicLegend.fla (sourcefile)
* @file flamingo/tpc/roo/DynamicLegend.xml (configurationfile)
* @file flamingo/tpc/roo/DynamicLegend.swf (compiled component, needed for publication on internet)
*/

/** @tag <roo:DynamicLegend>  
* This tag defines a dynamiclegend. The dynamiclegend (tag) itself listens to a map.
* DynamicLegendLayer(tags)listen to LayerOGWMS layers.
* @class roo.DynamicLegend extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component. 
* @example
*	<Flamingo>
*	  ...
*  	  <fmc:Window id="dynamicLegendWindow" top="15" left="15" width="255" height="295" skin="F1" canresize="true" canclose="true" visible="false">
*        <string id="title" en="Legend" nl="Legenda"/>
*        <roo:DynamicLegend id="dynamicLegend" width="230" height="260" listento="map,filterLayer" fileurl="${assetlocation}" wmsurl="${ogcplanservice}?service=WMS" wfsurl="${ogcplanservice}">
*          	<roo:DynamicLegendHeading listento="bgLayer,boLayer" title="Best./Inp.plan"/>
*          	<roo:DynamicLegendLayer listento="bgLayer,boLayer,bpAgrarischLayer,bpBedrijfLayer,bpBedrijventerreinLayer,bpBosLayer,bpCentrumLayer,bpDetailhandelLayer,bpDienstverleningLayer,bpGemengdLayer,bpWonenLayer" graphicuri="file://provinciaal-plan/p-plangebied.png" title="best.plangebied" featuretype="app:Bestemmingsplangebied;app:geometrie;app=&quot;http://www.deegree.org/app&quot;" whereclause="app:typeplan;*bestemmingsplan*"/>
*          	<roo:DynamicLegendLayer listento="bgLayer,boLayer,bpAgrarischLayer,bpBedrijfLayer,bpBedrijventerreinLayer,bpBosLayer,bpCentrumLayer,bpDetailhandelLayer,bpDienstverleningLayer,bpGemengdLayer,bpWonenLayer" graphicuri="file://provinciaal-plan/p-plangebied.png" title="inp.plangebied" featuretype="app:Bestemmingsplangebied;app:geometrie;app=&quot;http://www.deegree.org/app&quot;" whereclause="app:typeplan;*inpassingsplan*"/>
*   		....
*        </roo:DynamicLegend>
*    </fmc:Window>
*	 ...
*	</Flamingo>	 
* @attr fileurl
* @attr wmsurl
* @attr	wfsurl
*/
/** @tag	<roo:DynamicLegendHeading>  
* This tag defines a title that will be shown in the Dynamic legend. 
* @hierarchy childnode of roo:DynamicLegend 
* @attr title (no defaultvalue) the title text to be used as title
*/

/** @tag	<roo:DynamicLegendLayer>
* @attr 
* 
 */

import mx.controls.CheckBox;
import mx.utils.Delegate;

import roo.AbstractComponent;
import roo.FeatureType;
import roo.WhereClause;
import roo.DynamicLegendItem;

class roo.DynamicLegend extends AbstractComponent {
    
    private var dynamik:Boolean = true;
    private var graphicWidth:Number = 25;
    private var graphicHeight:Number = 12;
    private var horiSpacing:Number = 100;
    private var vertiSpacing:Number = 3;
    private var fileURL:String = null;
    private var wmsURL:String = null;
    private var wfsURL:String = null;
    private var dynamicLegendItems:Array = null;
    private var layoutNeeded:Boolean = false;
    
    function onLoad():Void {
        super.onLoad();
        
        addCheckBox();
        var refreshId:Number = setInterval(this, "layout", 1000);        
    }
    
    function setAttribute(name:String, value:String):Void {
        //_global.flamingo.tracer("DynamicLegend.setAttribute, name = " + name + " value = " + value);
        if (name == "horispacing") {
            horiSpacing = Number(value);
        } else if (name == "vertispacing") {
            vertiSpacing = Number(value);
        } else if (name == "fileurl") {
            fileURL = value;
        } else if (name == "wmsurl") {
            wmsURL = value;
        } else if (name == "wfsurl") {
            wfsURL = value;
        }
    }
    
    function addComponent(name:String, value:XMLNode):Void {
    	var names:Array = name.split(":");
    	if(names.length==1){
    		name = name;
    	} else {
    		name = names[1];
    	}
        if (name == "DynamicLegendLayer") {
            addDynamicLegendLayer(value.attributes["listento"].split(","), value.attributes["graphicuri"], value.attributes["title"], value.attributes["featuretype"], value.attributes["whereclause"]);
        } else if (name == "DynamicLegendHeading") {
            addDynamicLegendHeading(value.attributes["listento"], value.attributes["title"]);
        }
    }
    
    function getMap():String {
        return listento[0];
    }
    
    function isDynamic():Boolean {
        return dynamik;
    }
    
    function getGraphicWidth():Number {
        return graphicWidth;
    }
    
    function getGraphicHeight():Number {
        return graphicHeight;
    }
    
    function getFileURL():String {
        return fileURL;
    }
    
    function getWMSURL():String {
        return wmsURL;
    }
    
    function getWFSURL():String {
        return wfsURL;
    }
    
    private function addCheckBox():Void {
        var initObject:Object = new Object();
        initObject["_x"] = graphicWidth / 2 - 8;
        initObject["_y"] = graphicHeight - 8;
        initObject["label"] = "toon alles";
        initObject["labelPlacement"] = "right";
        initObject["selected"] = false;
        var checkBox:CheckBox = CheckBox(attachMovie("CheckBox", "mCheckBox", getNextHighestDepth(), initObject));
        checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
        checkBox.setStyle("fontSize", 11);
    }
    
    function onClickCheckBox(eventObject:Object):Void {
        dynamik = !eventObject.target.selected;
        
        for (var i:Number = 0; i < dynamicLegendItems.length; i++) {
            DynamicLegendItem(dynamicLegendItems[i]).setVisible();
        }
        this.layoutNeeded = true;
    }
    
    private function addDynamicLegendLayer(layers:Array, graphicURI:String, title:String, featureTypeString:String, whereClauseString:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["filterLayer"] = listento[1];
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["graphicURI"] = graphicURI;
        initObject["title"] = title;
        var split:Array = featureTypeString.split(";");
        initObject["featureType"] = new FeatureType(split[0], split[1], split[2]);
        if (whereClauseString != null) {
            split = whereClauseString.split(";");
            initObject["whereClause"] = new WhereClause(split[0], split[1], WhereClause.EQUALS);
        }
        dynamicLegendItems.push(attachMovie("DynamicLegendLayer", "mDynamicLegendLayer" + depth, depth, initObject));
    }
    
    private function addDynamicLegendHeading(layers:String, title:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["title"] = title;
        dynamicLegendItems.push(attachMovie("DynamicLegendHeading", "mDynamicLegendHeading" + depth, depth, initObject));
    }
    
    //function onSetVisible() {
    //    _global.flamingo.tracer("onSetVisible, arguments = " + arguments);
    //}


    function refresh():Void {
        this.layoutNeeded = true;
    }
    
    private function layout():Void {

        if (!_parent._parent._parent._parent.visible) { //dynamicLegendWindow
            return;
        }

        //_global.flamingo.tracer("this.layoutNeeded = " + this.layoutNeeded);
        if (!this.layoutNeeded) {
            return;
        }

        var numPosPerColumn:Number = -1;
        if (__height < graphicHeight * 2 + vertiSpacing) {
            numPosPerColumn = 1;
        } else {
            numPosPerColumn = Math.floor((__height - graphicHeight) / (graphicHeight + vertiSpacing) + 1);
        }
        
        var dynamicLegendItem:DynamicLegendItem = null;
        var pos:Number = 2;
        for (var i:Number = 0; i < dynamicLegendItems.length; i++) {
            dynamicLegendItem = DynamicLegendItem(dynamicLegendItems[i]);
            //_global.flamingo.tracer("i = " + i + " dynamicLegendItem = " + dynamicLegendItem.getTitle() + " visible = " + dynamicLegendItem.isVisible() + " numPosPerColumn = " + numPosPerColumn);
            //_global.flamingo.tracer("graphicWidth = " + graphicWidth + " horiSpacing = " + horiSpacing + " pos = " + pos + " numPosPerColumn = " + numPosPerColumn);
            if (dynamicLegendItem.isVisible()) {
                dynamicLegendItem._x = (graphicWidth + horiSpacing) * Math.floor(pos / numPosPerColumn);
                dynamicLegendItem._y = (graphicHeight + vertiSpacing) * (pos % numPosPerColumn);
                pos++;
            } else {
                dynamicLegendItem._x = 0;
                dynamicLegendItem._y = 0;
            }
        }
        this.layoutNeeded = false;
    }
    
}
