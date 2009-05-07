/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
import gui.*;
import coremodel.service.dde.*;
import mx.utils.Delegate;
import mx.events.EventDispatcher;
import mx.containers.ScrollPane;
import mx.controls.CheckBox;


class gui.dde.DownloadLegend extends MovieClip implements DDEConnectorListener{
	private var legend:Object = null;
	private var map:Object = null;
	private var legenditems:Array;
	private var ddeLayers:Array;
	private var layers:Array;
	private var itemclips:Array;
	private var skin:String = "f1";
	private var mScrollPane:ScrollPane;
	private var groupdy = 3;	
	private var groupdx = 2;
	private var ddeConnector:DDEConnector;
	private var __width:Number;
	private var __height:Number;
	private var debug:Boolean = false;
	
	function setMap(map:Object):Void{
		this.map = map;
		_global.flamingo.addListener(this,map,this);
		var mapLayers:Array = new Array();
		mapLayers = map.getLayers();
		layers = new Array();
		for (var i:Number = 0; i < mapLayers.length; i++){
			var mapLayer:MovieClip = _global.flamingo.getComponent( mapLayers[i].toString());
			//_global.flamingo.addListener(this,mapLayer,this);
			
			var mapService:String = mapLayer.mapservice;
			
			if(mapService != undefined){
				var ids:Array = mapLayer.getLayerIds();
				for (var j:Number = 0; j < ids.length; j++){
						layers[ids[j]] = {mapService:mapService,vis:mapLayer.getLayerProperty(ids[j],"visible"),id:ids[j]}
				}
			}
		}	
	}
	
	function setLegend(legend:Object, debug:Boolean):Void{
		if(debug!=undefined){
			this.debug = debug;
		}
		this.legend = legend;
		if(legend.skin!=undefined){
			this.skin = legend.skin;
		}

	}
	
	function setDDEConnector(ddeConnector:DDEConnector){
		this.ddeConnector = ddeConnector;
		ddeConnector.addListener(this);
		ddeConnector.sendRequest("getDDELayers");
	}
		
	function onDDELoad(result:XML):Void{
		var resultType:String = result.firstChild.nodeName;
		if(resultType=="DDELayers"){
			ddeLayers = new Array();
			var list:Array = result.firstChild.childNodes;
			for (var i = 0; i<list.length; i++) {
				if(list[i].nodeName == "DDELayer"){
					ddeLayers.push({label:list[i].attributes["label"],name:list[i].attributes["name"],dataLayerId:list[i].attributes["dataLayerId"],dataService:list[i].attributes["dataService"]});
				}
			}			
		} 
		if(itemclips==undefined || itemclips.length == 0){
			itemclips = new Array();
			drawLegend(legend.legenditems, this, 0);
			refresh();
		}
	}
	
	function onGroupEvent(evtObj){
		if(evtObj.type == "press"){
			var item = evtObj.target._parent.item
			item.collapsed = !item.collapsed;
			refresh();
		}
	}
	
	function onClickCheck(evtObj){
		for (var i = 0; i<itemclips.length; i++) {
			if(itemclips[i]["mCheck"] != undefined){
				CheckBox(itemclips[i]["mCheck"]).selected = false;
			}
		}
		evtObj.target.selected = true;
		ddeConnector.setuserSelectedThemes(evtObj.target._parent.item.downloadableLayers);
	}
	
	private function drawGroupLabel(mc:MovieClip, mouseover:Boolean) {
		var label = getString(mc.item.legItem, "label");
		
		var styleid = mc.item.legItem.styleid;
		if (styleid == undefined) {
			styleid = "group";
		}
		mc.mHeader.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
	}

	private function getString(item:Object, stringid:String):String {
		var lang = _global.flamingo.getLanguage();
		var s = item.language[stringid][lang];
		if (s.length > 0) {
			//option A
			return s;
		}
		s = item[stringid];
		if (s.length > 0) {
			//option B
			return s;
		}
		for (var attr in item.language[stringid]) {
			//option C
			return item.language[stringid][attr];
		}
		//option D
		return "";
	}


		
	private function drawLegend(list:Array,parent:MovieClip) {
	for (var i = 0; i<list.length; i++) {
		
		//create clone from item otherwise interference with the legend component
		var item:Object = new Object();
		item["type"] = list[i].type;
		item["items"] = list[i].items;
		item["label"] = getString(list[i], "label");
		item["collapsed"] = list[i].collapsed;
		item["listento"] = list[i].listento;
		item["legItem"] = list[i];
		item["vis"] = true;
		var nr = parent.getNextHighestDepth();
		var mc:MovieClip = parent.createEmptyMovieClip(nr, nr);
		mc.item = item;
		//keep a reference of an item (can be group, item , text, symbol or hr) at itemclips
		itemclips.push(mc);
		switch (item.type) {
			case "group" :
				//this movie will act as a group
				mc.createEmptyMovieClip("mHeader", 1);
				mc.mHeader.useHandCursor = false;
				mc.mHeader.attachMovie(skin+"_group_open", "skin", 1);
				EventDispatcher.initialize(mc.mHeader);
				mc.mHeader.addEventListener("press", Delegate.create(this,onGroupEvent));
				mc.mHeader.onPress = function()
				{
					var obj = {type:"press", target:this};
					this.dispatchEvent(obj);
				}
				if (item.label != undefined) {
					mc.mHeader.createTextField("mLabel", 2, mc.mHeader.skin._x+mc.mHeader.skin._width, 0, 150, 20);
					mc.mHeader.mLabel.styleSheet = _global.flamingo.getStyleSheet(legend);
					mc.mHeader.mLabel.multiline = true;
					mc.mHeader.mLabel.wordWrap = true;
					mc.mHeader.mLabel.html = true;
					mc.mHeader.mLabel.selectable = false;
				}
				mc.createEmptyMovieClip("mItems", 2);
				drawLegend(item.items, mc.mItems, 0);
				break;
			 case "item" :
				if (item.listento != undefined) {
					
					for (var maplayer in item.listento) {			
						if(item.listento[maplayer]!= undefined && item.listento[maplayer]!= ""){
							var sublayers:Array = item.listento[maplayer].split(",");
							var downloadableLayers:Array = new Array();
							var downloadableLayersLabel:String = "";
							for(var l:Number=0;l<sublayers.length;l++){
								var service = layers[sublayers[l]].mapService;
								if(service == undefined) {
								    _global.flamingo.tracer("service undefined for sublayer '" + sublayers[l] + "'");
								}
								item.vis = layers[sublayers[l]].vis;
								item.id = layers[sublayers[l]].id;
								for(var k:Number=0;k<ddeLayers.length;k++){
									if(sublayers[l] == ddeLayers[k].dataLayerId && service == ddeLayers[k].dataService){
										downloadableLayers.push({name:ddeLayers[k].name, service:service, label:ddeLayers[k].label, id:ddeLayers[k].dataLayerId});
										downloadableLayersLabel += "<br><font size='10' color='#0000FF'>" + ddeLayers[k].label + "</font></br>"
									}
								}
							}
							if(downloadableLayers.length > 0){
								item.downloadableLayers = downloadableLayers;
								item.downloadableLayersLabel = downloadableLayersLabel;
								var check:CheckBox = CheckBox(mc.attachMovie("CheckBox","mCheck",1, 0,0,10,10));
								check.addEventListener("click",Delegate.create(this, onClickCheck));	
							}
							item.sublayers = sublayers;
						}
					}
				}
				mc.createTextField("mLabel", 2, 0, 0, 150, 20);
				mc.mLabel.styleSheet = _global.flamingo.getStyleSheet(legend);
				mc.mLabel.multiline = true;
				mc.mLabel.wordWrap = false;
				mc.mLabel.html = true;
				mc.mLabel.selectable = false;
				mc.createEmptyMovieClip("mItems", 3);
				drawLegend(item.items, mc.mItems);
				break;
			case "symbol" :
				//label
				
				if (item.label != undefined && (mc._parent._parent.item.label == undefined||mc._parent._parent.item.label == "")) {
					mc._parent._parent.item.label = item.label;
				}
				
				
				break;
		}
			
		}

				
	}

	function refresh() {
		for (var i = 0; i<itemclips.length; i++) {
			_refreshItem(itemclips[i]);
		}
		this._parent.vScrollPolicy = "auto";
		if(debug){
			for(var k:Number=0;k<ddeLayers.length;k++){
				var found:Boolean = false;
				for (var i:Number = 0; i<itemclips.length; i++) {
					var mc:MovieClip = itemclips[i];
					if(mc.item.downloadableLayers!=undefined){
						for (var j = 0; j< mc.item.downloadableLayers.length; j++) {
							var lyr:Object = mc.item.downloadableLayers[j];
							if(lyr.name == ddeLayers[k].name && lyr.service == ddeLayers[k].dataService){
							  found = true;
							}
						}
					}
				}
				if(!found){
					_global.flamingo.tracer("For ddelayer " + ddeLayers[k].dataService + ":" + ddeLayers[k].name + 
												" no corresponding legend item found");
				}
				
			}

		}
		
		
	}
	
	public function onSetLayerProperty(layer:MovieClip, ids:String):Void{
		var ids:Array = layer.getLayerIds();
		for(var i:Number=0;i<ids.length;i++){
			var vis:Boolean = layer.getLayerProperty(ids[i], "visible");
			for(var j:Number=0;j<itemclips.length;j++){
				if(itemclips[j].item["id"]==ids[i]){
					itemclips[j].item["vis"] = vis;
				}
			}
			//LV: switching on and off layers in the legend used to switch on and 
			//and off layers in the DDEDonwloadlegend, this feature is now disabled
			//refresh();
		}
	}
	
	public function onAddLayer(map:MovieClip, layer:MovieClip):Void{
		_global.flamingo.addListener(this,layer,this);
	}
	
	function _refreshItem(mc:MovieClip) {
		if (!mc._parent._visible) {
			return;
		}
		//quit if _parent is invisible
		// determine y position 
		//var pscale = mc._parent._xscale;
		//mc._parent._xscale = mc._parent._yscale=100;
		var ypos = 0;
		var previtem = mc._parent[Number(mc._name)-1];
		if (previtem != undefined ) {
				ypos = previtem._y+previtem._height;
		}
	
		mc._y = ypos;
		mc._x = 0;
		// determine if item is visible
		var mapscale = map.getCurrentScale();
		if (mapscale != undefined) {
			if (mapscale< mc.item.legItem.minscale) {
				mc._yscale = mc._xscale=0;
				mc._visible = false;
				return;
			}
			if (mapscale>mc.item.legItem.maxscale) {
				mc._yscale = mc._xscale=0;
				mc._visible = false;
				return;
			}
		}
		mc._visible = true;
		mc._xscale = mc._yscale=100;
		// at this point item is visible and at the correct yposition   
		var x = 0;
		var y = 0;
		var h = 0;
	
		switch (mc.item.type) {
			case "group" :
				mc._y += groupdy;
				mc._x += groupdx;
				var left = mc.mHeader.getBounds(this)["xMin"];
				var w = this.__width-left-20;
				if (mc.item.collapsed) {
					mc.mHeader.attachMovie(skin+"_group_close", "skin", 1);
					mc.mItems._yscale = mc.mItems._xscale=0;
					mc.mItems._visible = false;
				} else {
					mc.mHeader.attachMovie(skin+"_group_open", "skin", 1);
					mc.mItems._yscale = mc.mItems._xscale=100;
					mc.mItems._visible = true;
				}
				drawGroupLabel(mc, false);
				mc.mHeader.mLabel._width = w-mc.mHeader.skin._width;
				mc.mHeader.mLabel._height = mc.mHeader.mLabel.textHeight+5;
				if (mc.mItems != undefined) {
					mc.mItems._x = mc.mHeader.skin._width;
					mc.mItems._y = mc.mHeader._height;
				}
				break;
			case "item" :
				if (mc.item.label != undefined){ //&& label != "") {
					var styleid = mc.item.legItem.styleid;
					if (styleid == undefined) {
						styleid = "item";
					}
					mc.mLabel.htmlText = "<span class='"+styleid+"'>"+mc.item.label
					if(mc.item.downloadableLayersLabel!=undefined && mc.mLabel!=undefined){
						mc.mLabel.htmlText += mc.item.downloadableLayersLabel;
						mc["mCheck"]._y = 4;
						mc["mCheck"]._x = 0;
						mc.mLabel._x = 12;
					}
					mc.mLabel.htmlText += "</span>"
					mc.mLabel._width = mc.mLabel.textWidth+5;
					mc.mLabel._height = mc.mLabel.textHeight+5;
					y = h=mc.mLabel._height;
				} 
	
				if (mc.mItems != undefined) {
					mc.mItems._x = x;
					mc.mItems._y = y;
					 if (mc.item.itemvisible == 1 || mc.item.itemvisible ==undefined) {
						mc.mItems._yscale = mc.mItems._xscale=100;
						mc.mItems._visible = true;
					} else {
						mc.mItems._yscale = mc.mItems._xscale=0;
						mc.mItems._visible = false;
					}
				}
				if(mc.item.vis!=undefined){
					if(!mc.item.vis){
						//LV: switching on and off layers in the legend used to switch on and 
						//and off layers in the DDEDonwloadlegend, this feature is now disabled
						//mc.mLabel.textColor = 0xbbbbbb;		
						//CheckBox(mc.mCheck).enabled = false;
					}
				}			
					
				break;
			case "symbol" :
				break; 
		}
	}


}