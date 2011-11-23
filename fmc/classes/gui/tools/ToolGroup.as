import core.AbstractListenerRegister;
import core.AbstractPositionable;
import core.ComponentInterface;
import core.ListenerCreator;
import gui.tools.AbstractTool;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
dynamic class gui.tools.ToolGroup extends AbstractListenerRegister implements ComponentInterface
{	
	private var _tool:String;
	
	//Old vars
	public var tool:String;
	public var defaulttool:String;	
	public var identifying:Boolean = false;
	public var updating:Boolean = false;
	public var lFlamingo:Object = new Object();
	public var lParent:Object = new Object();
	public var lMap:Object = new Object();
	public var version:String = "2.0";
	//-------------------------
	public var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<Toolgroup>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</Toolgroup>";
	
	private var _tools:Array;
	private var _listento:String;
	
	public function ToolGroup(id:String, container:MovieClip){
		super(id, container);
		tools = new Array();		
		init();
	}
	
	function setAttribute(name:String, value:String):Void { 
		var nametoLower = name.toLowerCase();
		switch(nametoLower) {
			case "tool":
				tool = value;
				break;
			case "listento":
				listento = value;
		}
	}
    
    function addComposite(name:String, xmlNode:XMLNode):Void { 
		Logger.console(xmlNode.toString(), name);
		var toolid = xmlNode.attributes.id;
		if (toolid == undefined) {
			toolid = flamingo.getUniqueId();
		}
		if (flamingo.exists(toolid)) {
		//id already exists
			if (flamingo.getParent(toolid) == this) {
				flamingo.addComponent(xmlNode, toolid);
			} else {
				flamingo.killComponent(toolid);
				var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
				flamingo.loadComponent(xmlNode, mc, toolid);
			}
		} else {
			var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
			flamingo.loadComponent(xmlNode, mc, toolid);
		}
	}	
	//old functions
	
	function init() {
		var thisObj = this;
		//----listener objects---------		
		lFlamingo.onConfigComplete = function() {
			thisObj.checkFinishUpdate();
			thisObj.checkFinishIdentify();
			thisObj.setTool(thisObj.tool);
		};
		flamingo.addListener(lFlamingo, "flamingo", this);		
		//-------------------------		
		lParent.onResize = function(mc:MovieClip) {
			thisObj.resize();
		};
		flamingo.addListener(lParent, flamingo.getParent(this), this);
		//-------------------------		
		lMap.onIdentify = function(map:MovieClip) {
			if (map.holdonidentify) {
				thisObj.identiying = true;
				thisObj.flamingo.getComponent(thisObj.tool).startIdentifying();
			}
		};
		lMap.onIdentifyComplete = function(map:MovieClip) {
			if (thisObj.identiying) {
				thisObj.checkFinishIdentify();
			}
		};
		lMap.onMouseUp= function(){
				if (thisObj.defaulttool.length>0) {
				if (thisObj.tool != thisObj.defaulttool) {
					thisObj.setTool(thisObj.defaulttool);
				}
			}
			
		}
		lMap.onUpdate = function(map:MovieClip) {
			if (map.holdonupdate) {
				thisObj.updating = true;
				thisObj.flamingo.getComponent(thisObj.tool).startUpdating();
			}
		};
		lMap.onUpdateComplete = function(map:MovieClip) {
			if (thisObj.updating) {
				thisObj.checkFinishUpdate();
			}
		};
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>ToolGroup "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this.container._visible = false;

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
		this.container._visible = this.visible;
		flamingo.raiseEvent(this, "onInit", this.id);		
	}
		
	/**
	* Configurates a component by setting a xml.

	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		Logger.console("SetConfig", xml);
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors 
		Logger.console("Setconfig after check: "+xml);
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var attr in xml.attributes) {
			attr = attr.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "clear" :
				if (val.toLowerCase() == "true") {
					this.clear();
				}
				break;
			case "tool" :
				tool = val.toLowerCase();
				break;
			case "defaulttool" :
				defaulttool = val.toLowerCase();
				break;
			default :
				break;
			}
		}
		var xTools:Array = xml.childNodes;
		if (xTools.length>0) {
			for (var i:Number = xTools.length-1; i>=0; i--) {
				addTool(xTools[i]);
			}
		}
		flamingo.addListener(lMap, listento, this);
		resize();
		
	}
	function resize() {
		var p = flamingo.getPosition(this);
		this.container._x = p.x;
		this.container._y = p.y;
	}
	function checkFinishUpdate() {
		for (var i:Number = 0; i<listento.length; i++) {
			var c = flamingo.getComponent(listento[i]);
			if (c.updating and c.holdonupdate) {
				updating = true;
				return;
			}
		}
		updating = false;
		flamingo.getComponent(tool).stopUpdating();
	}
	function checkFinishIdentify() {
		for (var i:Number = 0; i<listento.length; i++) {
			var c = flamingo.getComponent(listento[i]);
			if (c.identifying and c.holdonidentify) {
				identifying = true;
				return;
			}
		}
		identifying = false;
		flamingo.getComponent(tool).stopIdentifying();
	}
	function cancelAll() {
		for (var i:Number = 0; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			mc.cancelUpdate();
		}
	}
	function updateOther(map:MovieClip, delay:Number) {
		for (var i:Number = 0; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			if (mc != map) {
				mc.moveToExtent(map.getMapExtent(), delay);
			}
		}
	}
	/**
	* Removes all tools from the toolgroup.
	*/
	function clear() {
		for (var id in this.container) {
			if (typeof (this.container[id]) == "movieclip") {
				this.removeTool(id);
			}
		}
	}
	/**
	* Removes a tool from the toolgroup.
	* @param id:String Toolid
	*/
	function removeTool(id:String) {
		flamingo.killComponent(id);
	}
	/**
	* Gets a list of componentids.
	* @return List of componentids.
	*/
	function getTools():Array {
		var tools:Array = new Array();
		for (var id in this) {
			if (typeof (this[id]) == "movieclip") {
				tools.push(id);
			}
		}
		return tools;
	}
	/** 
	* Adds a tool to the toolgroup.
	* @param xml:Object Xml or string representation of xml, describing tool.
	*/
	function addTool(xml:Object):Void {
		Logger.console("AddTool: ", xml);
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml= xml.firstChild;
		}
		var toolid = xml.attributes.id;
		if (toolid == undefined) {
			toolid = flamingo.getUniqueId();
		}
		if (flamingo.exists(toolid)) {
			//id already exists
			if (flamingo.getParent(toolid) == this) {
				flamingo.addComponent(xml, toolid);
			} else {
				flamingo.killComponent(toolid);
				var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
				flamingo.loadComponent(xml, mc, toolid);
			}
		} else {
			var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
			flamingo.loadComponent(xml, mc, toolid);
		}
	}
	function setCursor(cursor:Object) {
		for (var i:Number = 0; i<listento.length; i++) {
			flamingo.getComponent(listento[i]).setCursor(cursor);
		}
	}
	/** 
	* Sets a tool.
	* @param toolid:String Id of tool that has to be set.
	*/
	function setTool(toolid:String):Void {
		if (toolid == undefined) {
			return;
		}
		flamingo.raiseEvent(this, "onReleaseTool", this, tool);
		flamingo.getComponent(tool)._releaseTool();
		tool = toolid;
		flamingo.getComponent(tool)._pressTool();
		flamingo.raiseEvent(this, "onSetTool", this, tool);
	}
	
	function initTool(mc:AbstractTool, uplink:String, overlink:String, downlink:String, hitlink:String, maplistener:Object, cursorid:String, tooltipid:String) {
		/*var thisObj = this;
		this.resize();
		mc._pressed = false;
		mc._enabled = true;
		mc.attachMovie(uplink, "mSkin", 1);
		mc.attachMovie(hitlink, "mHit", 0, {_alpha:0});
		mc.mHit.useHandCursor = false;
		mc.setVisible = function(b:Boolean) {
			mc.visible = b;
			mc._visible = b;
		};
		mc.setEnabled = function(b:Boolean) {
			if (b) {
				mc._alpha = 100;
			} else {
				mc._alpha = 20;
				if (mc._pressed) {
					thisObj.setCursor(undefined);
					mc._releaseTool();
				}
			}
			mc._enabled = b;
			mc.enabled = b;
		};
		mc._releaseTool = function() {
			if (mc._enabled) {
				mc._pressed = false;
				mc.attachMovie(uplink, "mSkin", 1);
				thisObj.flamingo.removeListener(maplistener, thisObj.listento, this);
				mc.releaseTool();
			}
		};
		//
		mc._pressTool = function() {
			if (mc._enabled) {
				mc._pressed = true;
				mc.attachMovie(downlink, "mSkin", 1);
				thisObj.setCursor(mc.cursors[cursorid]);
				thisObj.flamingo.addListener(maplistener, thisObj.listento, this);
				mc.pressTool();
			}
		};
		//
		mc.mHit.onRollOver = function() {
			thisObj.flamingo.showTooltip(thisObj.flamingo.getString(mc, tooltipid), mc);
			if (mc._enabled) {
				if (! mc._pressed) {
					mc.attachMovie(overlink, "mSkin", 1);
				}
			}
		};
		//
		mc.mHit.onRollOut = function() {
			if (! mc._pressed) {
				mc.attachMovie(uplink, "mSkin", 1);
			}
		};
		//
		mc.mHit.onPress = function() {
			if (mc._enabled) {
				thisObj.setTool(thisObj.flamingo.getId(mc));
			}
		};*/
	}
	/**
	* Dispatched when a tool is released.
	* @param toolgroup:MovieClip a reference or id of the toolgroup.
	* @param toolid:MovieClip Id of tool which is released.
	*/
	//public function onReleaseTool(toolgroup:MovieClip, toolid:String):Void {
	//
	/**
	* Dispatched when a tool is set.
	* @param toolgroup:MovieClip a reference or id of the toolgroup.
	* @param toolid:MovieClip Id of tool which is set.
	*/
	//public function onSetTool(toolgroup:MovieClip, toolid:String):Void {
	//
	/**
	* Dispatched when the component is up and running.
	* @param toolgroup:MovieClip a reference or id of the toolgroup.
	*/
	//public function onInit(toolgroup:MovieClip):Void {
	//
	
	
	public function get tool():String 
	{
		return _tool;
	}
	
	public function set tool(value:String):Void 
	{
		_tool = value;
	}
	
	public function get tools():Array 
	{
		return _tools;
	}
	
	public function set tools(value:Array):Void 
	{
		_tools = value;
	}
	
	public function get listento():String 
	{
		return _listento;
	}
	
	public function set listento(value:String):Void 
	{
		_listento = value;
	}
	
	
}