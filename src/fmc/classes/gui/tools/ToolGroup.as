/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

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
import core.AbstractListenerRegister;
import core.AbstractPositionable;
import gui.tools.AbstractTool;
import tools.Logger;

/** @component Toolgroup
* Container component for tools.
* @file flamingo/classes/gui/tools/ToolGroup.as (sourcefile)
* @file flamingo/classes/core/AbstractPositionable.as
* @file ToolGroup.xml (configurationfile, needed for publication on internet)
*/
/** @tag <fmc:Toolgroup>  
* This tag defines a toolgroup. Listens to 1 or more maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
  <fmc:ToolGroup left="210" top="0" tool="zoom" listento="map">
      <fmc:ToolZoomin id="zoom"/>
      <fmc:ToolZoomout left="30"/>
      <fmc:ToolPan left="60"/>
      <fmc:ToolIdentify left="90"/>
      <fmc:ToolMeasure left="120" unit=" m" magicnumber="1">
         <string id="tooltip" en="measure meters"/>
  	 </fmc:ToolMeasure>
  </fmc:ToolGroup>
* @attr tool  Id of the tool that is set.
* @attr defaulttool  Id of the tool that is set after each update event of a map.
* @attr clear (optional; default false) if set to true the toolgroup is cleared on init.
*/
/**
 * A toolgroup that holds tools
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
dynamic class gui.tools.ToolGroup extends AbstractPositionable
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
	private var _oldTools:Array;
	
	/**
	 * Constructor for ToolGroup
	 * @param	id the id of this toolgroup
	 * @param	container the MovieClip where this Toolgroup is placed
	 * @see AbstractPositionable#Constructor(id:String,container:MovieClip);
	 */
	public function ToolGroup(id:String, container:MovieClip){
		super(id, container);
		tools = new Array();		
		oldTools = new Array();
		init();
	}
		
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
			//deactivate the default tool on the map
			if (this.listento != undefined) {
				for (var i = 0; i < this.listento.length; i++) {
					if (!_global.flamingo.isLoaded(listento[i])) {
						_global.flamingo.loadCompQueue.executeAfterLoad(listento[i], this, deactivateDefaultTool);
					}else {
						_global.flamingo.getComponent(this.listento[i]).activateDefaultTool(false)
					}
					
				}
			}
		}
		flamingo.addListener(lMap, listento, this);
		resize();
		flamingo.position(this.container);
	}
	function deactivateDefaultTool():Void {
		for (var i = 0; i < this.listento.length; i++) {
			_global.flamingo.getComponent(this.listento[i]).activateDefaultTool(false);
		}
	}
	/** 
	* Load the part of the xml in flamingo
	* @param xml:Object Xml or string representation of xml, describing tool.
	*/
	function addComposite(xml:Object):Void {
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
		var tool = flamingo.getComponent(toolid);
		if (! tool instanceof AbstractTool) {
			//tool._parent(this);
			addOldTool(tool);
			
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
	
	function addOldTool(tool):Void {
		this.oldTools.push(tool);
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
		for (var j = 0; j < this.oldTools.length; j++) {
			var t = this.oldTools[j];
			if (t.id == toolId) {
				return t;
			}
		}
		return null;
	}
    /**
	 * Force a resize
	 */
	function resize():Void {
		var p = flamingo.getPosition(this);
		this.container._x = p.x;
		this.container._y = p.y;
	}
	/**
	 * Check if update is finsihed
	 */
	function checkFinishUpdate() {
		for (var i:Number = 0; i<listento.length; i++) {
			var c = flamingo.getComponent(listento[i]);
			if (c.updating && c.holdonupdate) {
				updating = true;
				return;
			}
		}
		updating = false;
		flamingo.getComponent(tool).stopUpdating();
	}
	/**
	 * Check if identify is finsihed
	 */
	function checkFinishIdentify() {
		for (var i:Number = 0; i<listento.length; i++) {
			var c = flamingo.getComponent(listento[i]);
			if (c.identifying && c.holdonidentify) {
				identifying = true;
				return;
			}
		}
		identifying = false;
		flamingo.getComponent(tool).stopIdentifying();
	}
	/**
	 * Cancel all updates
	 */
	function cancelAll() {
		for (var i:Number = 0; i<listento.length; i++) {
			var mc = flamingo.getComponent(listento[i]);
			mc.cancelUpdate();
		}
	}
	/**
	 * Update al the listento's except the map that is given
	 * @param map the map that is not updated
	 * @param delay the delay
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
		
		for (var j = 0; j < this.oldTools.length; j++) {
			var t = this.oldTools[j];
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
		var toolComp = this.getTool(this.tool);
		if(this.tool!=undefined){
			flamingo.raiseEvent(this, "onReleaseTool", this, tool);
			if (toolComp instanceof AbstractTool) {
				toolComp.setActive(false);
			}else {
				toolComp._releaseTool();
			}
		}
		this.tool = toolid;
		toolComp = this.getTool(this.tool);
		if (toolComp instanceof AbstractTool) {
			toolComp.setActive(true);
		}else {
			toolComp._pressTool();
		}
		flamingo.raiseEvent(this, "onSetTool", this, tool);
	}	
	
	/*********************** Getters and Setters ***********************/	
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
	public function get oldTools():Array 
	{
		return _oldTools;
	}
	public function set oldTools(value:Array):Void 
	{
		_oldTools = value;
	}
	/*********************** Events ***********************/
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
}