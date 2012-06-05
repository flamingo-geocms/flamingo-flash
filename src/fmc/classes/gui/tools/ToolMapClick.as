import gui.tools.AbstractTool;
import gui.tools.ToolGroup;
import tools.Logger;
/**
 * ...
 * @author ...
 */
class gui.tools.ToolMapClick extends AbstractTool
{
	var defaultXML:String;
	private var previousTool;
	/**
	 * constructor ToolMapClick
	 * @param	id
	 * @param	toolGroup
	 */
	public function ToolMapClick(id:String, toolGroup:ToolGroup ) {
		super(id, toolGroup, null);		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<fmc:ToolMapClick id='toolmapclick' listento='map'/>" +
				        "</ToolPan>"; 
		init();
	}
	/**
	 * init tool
	 */
	private function init() {
		var thisObj = this;
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			//Logger.console("lmouseup", map, xmouse, ymouse,coord);
			//Logger.console("lmouseup2",map.id);

			//Logger.console("coord1x", coord.x);
			//Logger.console("coord1y", coord.y);
			thisObj.flamingo.raiseEvent(thisObj, "onMapClicked", thisObj, coord);
		};
	}
	
	/**
	* Configurates a component by setting a xml.
	* @param xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors       
		flamingo.parseXML(this, xml);
		//parse custom attributes
		for (var a in xml.attributes) {
			var attr:String = a.toLowerCase();
			var val:String = xml.attributes[attr];
			switch (attr) {
			case "listento" :
				listento[0] = val;
				break;
		
			default :
				break;
			}
		}
		//
		this.setEnabled(enabled);
		flamingo.position(this);
	}	
	/**
	 * activate tool
	 */
	function activate() {
		this.previousTool = toolGroup.tool;
		this.toolGroup.setTool(this.id);
	}
	/**
	 * deactivate tool
	 */
	function deactivate() {
		var tool = this.previousTool;
		if (tool == undefined || tool=="") {
			//if no tool is previous, enable default tool.			
			this.toolGroup.activateDefaultTool(true);
			this.toolGroup.setTool("");
		}else{
			this.toolGroup.setTool(tool);		
		}
	}
	
}