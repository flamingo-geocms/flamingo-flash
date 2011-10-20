import core.AbstractPositionable;
import gui.tools.AbstractTool;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class gui.tools.ToolGroup extends AbstractPositionable
{	
	private var _tool:String;	
	
	private var _tools:Array;
	
	public function ToolGroup(id:String, container:MovieClip){
		super(id, container);
		tools = new Array();
	}
	
	function addTool(tool:AbstractTool) {
		Logger.console("Add the tool: ",tool.id);
		tools.push(tool);
	}
	
	/*function setTool(toolid:String):Void {
		if (toolid == undefined) {
			return;
		}
		flamingo.raiseEvent(this, "onReleaseTool", this, tool);
		flamingo.getComponent(tool)._releaseTool();
		tool = toolid;
		flamingo.getComponent(tool)._pressTool();
		flamingo.raiseEvent(this, "onSetTool", this, tool);
	}*/
	
	function setAttribute(name:String, value:String):Void { 
		var nametoLower = name.toLowerCase();
		switch(nametoLower) {
			case "tool":
				tool = value;
				break;			
		}
	}
    
    function addComposite(name:String, xmlNode:XMLNode):Void { 
		Logger.console(xmlNode.toString(), name);
		var toolid = xmlNode.attributes.id;
		if (toolid == undefined) {
			toolid = _global.flamingo.getUniqueId();
		}
		if (_global.flamingo.exists(toolid)) {
		//id already exists
			if (_global.flamingo.getParent(toolid) == this) {
				_global.flamingo.addComponent(xmlNode, toolid);
			} else {
				_global.flamingo.killComponent(toolid);
				var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
				_global.flamingo.loadComponent(xmlNode, mc, toolid);
			}
		} else {
			var mc:MovieClip = this.container.createEmptyMovieClip(toolid, this.container.getNextHighestDepth());
			_global.flamingo.loadComponent(xmlNode, mc, toolid);
		}
	}
	
	
	/*
	 * function addTool(xml:Object):Void {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
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
			var mc:MovieClip = this.createEmptyMovieClip(toolid, this.getNextHighestDepth());
			flamingo.loadComponent(xml, mc, toolid);
		}
	} else {
		var mc:MovieClip = this.createEmptyMovieClip(toolid, this.getNextHighestDepth());
		flamingo.loadComponent(xml, mc, toolid);
	}
}
	 * */
	
	
	
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
	
	
}