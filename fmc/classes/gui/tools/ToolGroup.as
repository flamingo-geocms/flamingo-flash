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
	//Old vars
	private var _tool:String;
	private var _defaulttool:String;	
	private var _identifying:Boolean = false;
	private var _updating:Boolean = false;
	private var _lFlamingo:Object = new Object();
	private var _lParent:Object = new Object();
	private var _lMap:Object = new Object();
	private var _version:String = "2.0";
	//-------------------------
	private var _defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<Toolgroup>" +
							"<cursor id='busy' url='fmc/CursorsMap.swf' linkageid='busy'/>" +
							"</Toolgroup>";
	
	private var _tools:Array;
	
	public function ToolGroup(id:String, container:MovieClip){
		super(id, container);
		tools = new Array();		
		init();
	}
	/*
	function setAttribute(name:String, value:String):Void { 
		var nametoLower = name.toLowerCase();
		switch(nametoLower) {
			case "tool":
				tool = value;
				break;
			case "listento":
				listento = value;
		}
	}*/
    
	
	/**
	 * Init function
	 */
	function init() {
		var thisObj:ToolGroup = this;
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
	/**********************************************************************************
	 * Configuration/parsing functions
	 */	
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
				this.tool = val.toLowerCase();
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
				addComposite(xTools[i]);
			}
		}
		flamingo.addListener(lMap, listento, this);
		resize();
		
	}
	/** 
	* Load the part of the xml in flamingo
	* @param xml:Object Xml or string representation of xml, describing tool.
	*/
	function addComposite(xml:Object):Void {
		Logger.console("addComposite: ", xml);
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
	
	/***********************************************************************************
	 * Custom functions
	 */
	/**
	 * Add a tool to this group
	 */
	function addTool(tool:AbstractTool):Void {
		this.tools.push(tool);
	}
	/**
	 * Get the tool with id == toolid
	 * @param	toolId
	 * @return	The tool
	 */
	function getTool(toolId:String):AbstractTool {
		for (var i = 0; i < this.tools.length; i++) {
			var t:AbstractTool = AbstractTool(this.tools[i]);
			if (t.id == toolId) {
				return t;
			}
		}
		return null;
	}
    /**
	 * Force a resize
	 */
	function resize() {
		var p = flamingo.getPosition(this);
		this.container._x = p.x;
		this.container._y = p.y;
	}
	/**
	 * TODO: ?
	 */
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
	/**
	 * TODO:?
	 */
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
	/**
	 * TODO:?
	 */
	function cancelAll() {
		for (var i:Number = 0; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			mc.cancelUpdate();
		}
	}
	/**
	 * TODO:?
	 */
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
	* Gets a list of tool ids.
	* @return List of tool ids.
	*/
	function getTools():Array {
		var toolIds:Array = new Array();
		for (var i = 0; i < this.tools.length; i++) {
			var t:AbstractTool = AbstractTool(this.tools[i]);
			toolIds.push(t.id);
		}
		return toolIds;
	}
	/**
	 * Set the cursor as a cursor
	 * @param	cursor the cursor that must be shown
	 */
	function setCursor(cursor:Object) {
		for (var i:Number = 0; i<listento.length; i++) {
			flamingo.getComponent(listento[i]).setCursor(cursor);
		}
	}
	/** 
	* Activates the tool and sets the active tool inactive.
	* @param toolid:String Id of tool that has to be set.
	*/
	function setTool(toolid:String):Void {
		if (toolid == undefined) {
			return;
		}
		if(this.tool!=undefined){
			flamingo.raiseEvent(this, "onReleaseTool", this, tool);
			this.getTool(this.tool).setActive(false);
		}
		this.tool = toolid;
		this.getTool(this.tool).setActive(true);
		flamingo.raiseEvent(this, "onSetTool", this, tool);
	}
	/********************************************************************
	 * Events
	 */
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
	
	/*******************************************************************************
	 * Getters and setters
	 */
	
	public function get tools():Array 
	{
		return _tools;
	}
	
	public function set tools(value:Array):Void 
	{
		_tools = value;
	}
		
	public function get tool():String 
	{
		return _tool;
	}
	
	public function set tool(value:String):Void 
	{
		_tool = value;
	}
	
	public function get defaulttool():String 
	{
		return _defaulttool;
	}
	
	public function set defaulttool(value:String):Void 
	{
		_defaulttool = value;
	}
	
	public function get identifying():Boolean 
	{
		return _identifying;
	}
	
	public function set identifying(value:Boolean):Void 
	{
		_identifying = value;
	}
	
	public function get updating():Boolean 
	{
		return _updating;
	}
	
	public function set updating(value:Boolean):Void 
	{
		_updating = value;
	}
	
	public function get lFlamingo():Object 
	{
		return _lFlamingo;
	}
	
	public function set lFlamingo(value:Object):Void 
	{
		_lFlamingo = value;
	}
	
	public function get lParent():Object 
	{
		return _lParent;
	}
	
	public function set lParent(value:Object):Void 
	{
		_lParent = value;
	}
	
	public function get lMap():Object 
	{
		return _lMap;
	}
	
	public function set lMap(value:Object):Void 
	{
		_lMap = value;
	}
	
	public function get version():String 
	{
		return _version;
	}
	
	public function set version(value:String):Void 
	{
		_version = value;
	}
	
	public function get defaultXML():String 
	{
		return _defaultXML;
	}
	
	public function set defaultXML(value:String):Void 
	{
		_defaultXML = value;
	}
}