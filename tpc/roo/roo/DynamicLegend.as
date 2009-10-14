import mx.controls.CheckBox;
import mx.utils.Delegate;

import core.AbstractComponent;
import roo.DynamicLegendItem;
import roo.DynamicLegendLayer;
import roo.FilterLayer;

class roo.DynamicLegend extends AbstractComponent {
    
    private var dynamik:Boolean = true;
    private var graphicWidth:Number = 25;
    private var graphicHeight:Number = 12;
    private var horiSpacing:Number = 100;
    private var vertiSpacing:Number = 3;
    private var fileURL:String = null;
    private var wmsURL:String = null;
	private var swfLibURL:String = null;
    private var dynLegendServiceURL:String = null;
    private var dynamicLegendItems:Array = null;
    private var refreshNeeded:Boolean = false;
    private var reloadNeeded:Boolean = false;
    private var dynLegendResponse:XML = null;
    private var loading:Boolean = false;
    private var mcSwfLib:MovieClip = null;
    
    function onLoad():Void {
        super.onLoad();      
        addCheckBox();
        var refreshId:Number = setInterval(this, "layout", 300);
        var reloadId:Number = setInterval(this, "getLegendContent", 300);
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
		} else if (name == "swfliburl") {
            swfLibURL = _global.flamingo.correctUrl(value);	
			//mcSwfLib = createEmptyMovieClip("mSwfLib", getNextHighestDepth());
			//mcSwfLib.loadMovie(swfLibURL);
        } else if (name == "dynlegendserviceurl") {
            dynLegendServiceURL = value;
        }
    }
    
    function addComposite(name:String, value:XMLNode):Void {
        if (name == "DynamicLegendLayer") {
            addDynamicLegendLayer(value.attributes["listento"].split(","), value.attributes["graphicuri"], value.attributes["serverids"], value.attributes["legendCriteria"], value.attributes["title"]);
        } else if (name == "DynamicLegendHeading") {
            addDynamicLegendHeading(value.attributes["listento"].split(","), value.attributes["id"], value.attributes["title"]);
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
	
	function getSwfLibURL():String {
        return swfLibURL;
    }
    
	function getSwfLib():MovieClip {
        return mcSwfLib;
    }
    
    function getDynLegendServiceURL():String {
        return dynLegendServiceURL;
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
            var dynamicLegendItem:DynamicLegendItem = DynamicLegendItem(dynamicLegendItems[i]);
            if (dynamicLegendItem.isOneLayerVisible()) {
                dynamicLegendItem.setVisible();
            }
        }

        refresh();
    }
    
    private function addDynamicLegendLayer(layers:Array, graphicURI:String, serverids:String, legendCriteria:String, title:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["filterLayer"] = listento[1];
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["graphicURI"] = graphicURI;
        initObject["serverids"] = serverids;
        initObject["legendCriteria"] = legendCriteria;
        initObject["title"] = title;
        dynamicLegendItems.push(attachMovie("DynamicLegendLayer", "mDynamicLegendLayer" + depth, depth, initObject));
    }
    
    private function addDynamicLegendHeading(layers:String, id:String, title:String):Void {
        if (dynamicLegendItems == null) {
            dynamicLegendItems = new Array();
        }
        
        var depth:Number = getNextHighestDepth();
        var initObject:Object = new Object();
        initObject["layers"] = layers;
        initObject["dynamicLegend"] = this;
        initObject["id"] = id;
        initObject["title"] = title;
        dynamicLegendItems.push(attachMovie("DynamicLegendHeading", "mDynamicLegendHeading" + depth, depth, initObject));
    }
    
    //function onSetVisible() {
    //    _global.flamingo.tracer("onSetVisible, arguments = " + arguments);
    //}


    function refresh():Void {
        if (isDynamic()) {
            this.reloadNeeded = true;
        }
        else {
            this.refreshNeeded = true;
        }
    }
    
    private function getLegendContent():Void {
        if (!this.reloadNeeded || this.loading) {
            return;
        }

        if (!_parent._parent._parent._parent.visible) { //dynamicLegendWindow
            return;
        }
        else {
			this._visible = true;  //set content visible when Window visible
		}

        this.loading = true;
        
        var loadVars:LoadVars = new LoadVars();

		var layersParam:String = "";
        for (var i:Number = 0; i < dynamicLegendItems.length; i++) {
            if (dynamicLegendItems[i] instanceof DynamicLegendLayer) {
            	var dynamicLegendLayer:DynamicLegendLayer = DynamicLegendLayer(dynamicLegendItems[i]);
            	dynamicLegendLayer.doSetVisible(false);
            	if (dynamicLegendLayer.isOneLayerVisible()) {
	            	var layers:Array  = dynamicLegendLayer.getLayers();
	            	for (var j:Number = 0; j < layers.length; j++) {
	            		var layer:MovieClip = _global.flamingo.getComponent(getMap() + "_" + layers[j]);
	            		if (layer.getSLDparam() != undefined && layer.getSLDparam() && layer.getVisible() == 1) {
	            			var namevaluepairsSLD:Array = String(layer.getSLDparam()).split("&");
	            			var legendCriteria:Array = dynamicLegendLayer.getLegendCriteria().split(";");
	            			//_global.flamingo.tracer("sld = " + layer.getSLDparam() + " namevaluepairsSLD = " + namevaluepairsSLD + " legendCriteria = " + legendCriteria);
	            			for (var k:Number = 0; k < namevaluepairsSLD.length; k++) {
		            			var paramSLD:Array = String(namevaluepairsSLD[k]).split("=");
                                for (var l:Number = 0; l < legendCriteria.length; l++) {
		            				var paramCrit:Array = String(legendCriteria[l]).split("=");
		            				//_global.flamingo.tracer("paramSLD[0] = " + paramSLD[0] + " paramCrit[0] = " + paramCrit[0]);
		            				if (paramSLD[0] == paramCrit[0]) {
		            					var valuesSLD:Array = String(paramSLD[1]).split(",");
		            					var valuesCrit:Array = String(paramCrit[1]).split(",");
		            					for (var m:Number = 0; m < valuesSLD.length; m++) {
		            						for (var n:Number = 0; n < valuesCrit.length; n++) {
		            							//_global.flamingo.tracer("valuesSLD[m] = " + valuesSLD[m] + " valuesCrit[n] = " + valuesCrit[n]);
		            							if (valuesSLD[m] == valuesCrit[n] && layersParam.indexOf(dynamicLegendLayer.getServerIds()) == -1) {
            	        							layersParam += dynamicLegendLayer.getServerIds() + ",";
		            							}
		            						}
		            					}
		            				}
                                }
	            			}
	            		}
            	        else if (layer.getVisible() == 1){ //no filter on maplayer so legendlayer must be included
            	        	layersParam += dynamicLegendLayer.getServerIds() + ",";
            	        }
	            	}
            	}
            }
        }
        
        loadVars["layers"] = layersParam;

        var extent:Object = _global.flamingo.getComponent(getMap()).getMapExtent();        
        loadVars["bbox"] = extent.minx + "," + extent.miny + "," + extent.maxx + "," + extent.maxy;


        var filterLayerComp:FilterLayer = FilterLayer(_global.flamingo.getComponent(listento[1]));
        //_global.flamingo.tracer("setVisible, filterLayer = " + filterLayer + " filterLayerComp = " + filterLayerComp);
        var filterconditions:Object = filterLayerComp.getFilterconditions();
		for (var filtername:String in filterconditions) {
    		var filtercondition:String = filterLayerComp.getFiltercondition(filtername);

        	var template:String = filterLayerComp.getFilterTemplate(filtername);
    		//_global.flamingo.tracer("setVisible, template = " + template);

			var namevaluepairActual:Array = filtercondition.split("=");
			var nameParam:String = "[" + namevaluepairActual[0] + "]";
			var value:String = namevaluepairActual[1];
			var namevaluepairFormal:Array = template.split("=");
			value = namevaluepairFormal[1].split(nameParam).join(value);
		    loadVars[namevaluepairFormal[0]] = value;
		}
		
        
        var responseObj:Object = new Object();
        responseObj.parent = this;
        responseObj.onHTTPStatus = function(httpStatus:Number) {
                _global.flamingo.tracer("HTTP Status: " + httpStatus + "!!");
        };
        responseObj.onData = function(str:String) {
                this.parent.dynLegendResponse = new XML();
                this.parent.dynLegendResponse.ignoreWhite = true;
                this.parent.dynLegendResponse.parseXML(str);
                //_global.flamingo.tracer("resp = " + str);
                this.parent.parseDynamicLegendResponse();
        };
        
        loadVars.contentType = "application/x-www-form-urlencoded; charset=utf-8";
        loadVars.sendAndLoad(dynLegendServiceURL, responseObj, "POST");

    }

    private function parseDynamicLegendResponse():Void {
        this.reloadNeeded = false;
        this.loading = false;
        if (dynLegendResponse.firstChild.localName == "DynamicLegendException") {
            _global.flamingo.tracer("Error while retrieving dynamic-legend-response: " );
            var childs:Array = dynLegendResponse.firstChild.childNodes;
						for (var i:Number = 0; i<childs.length; i++) {
                _global.flamingo.tracer(childs[i].localName + ": " + childs[i].firstChild.nodeValue);
            }
            return;
        }
				var layers:Array = dynLegendResponse.firstChild.childNodes;
				for (var i:Number = 0; i<layers.length; i++) {
				    var layerId:String = layers[i].attributes["name"];
				    var hits:String = layers[i].attributes["hits"];
				    var vis:Boolean = (hits == "0" ? false : true);
			        for (var j:Number = 0; j < dynamicLegendItems.length; j++) {
			            if (dynamicLegendItems[j] instanceof DynamicLegendLayer) {
			            	var dynLegendLayer:DynamicLegendLayer = DynamicLegendLayer(dynamicLegendItems[j]);
			            	//if (layerId == "overig_s2006") {
					          //  _global.flamingo.tracer("serverIds = " + dynLegendLayer.getServerIds() + " indexOf = " + dynLegendLayer.getServerIds().indexOf(layerId) + " layerId = " + layerId + " vis = " + vis);
					          //}
			            	if (String("," + dynLegendLayer.getServerIds() + ",").indexOf("," + layerId + ",") > -1 && vis ) {
			            	    dynLegendLayer.doSetVisible(vis);
			            	}
			            }
			        }				    
				}
				
        this.refreshNeeded = true;
    }

    private function layout():Void {

        if (!this.refreshNeeded) {
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
        this.refreshNeeded = false;
    }
    
}
