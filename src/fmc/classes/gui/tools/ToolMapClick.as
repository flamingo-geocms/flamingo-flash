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
	
	public function ToolMapClick(id:String, toolGroup:ToolGroup ) {
		Logger.console("Constructor TMC");
		super(id, toolGroup, null);		
		this.defaultXML = "<?xml version='1.0' encoding='UTF-8'?>" +
						"	" +
				        "</ToolPan>"; 
		
		init();
	}
	
	private function init() {
		var thisObj = this;
		lMap.onMouseUp = function(map:MovieClip, xmouse:Number, ymouse:Number, coord:Object) {
			//Logger.console("lmouseup", map, xmouse, ymouse,coord);
			//Logger.console("lmouseup2",map.id);

			//Logger.console("coord1x", coord.x);
			//Logger.console("coord1y", coord.y);
			thisObj.flamingo.raiseEvent(thisObj, "onMapClicked",thisObj,coord);	
		};
	}
	
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
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
	
	function activate() {
		this.previousTool = toolGroup.tool;
		this.toolGroup.setTool(this.id);
		Logger.console("activeer:");
	}
	
	function deactivate() {
		Logger.console("deactiveer:");
		this.toolGroup.setTool(this.previousTool);
	}
	
}