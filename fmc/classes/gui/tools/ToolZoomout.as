/**
 * Tool Test
 * @author Roy Braam
 */

import gui.tools.AbstractTool;
import gui.tools.ToolInterface;
import tools.Logger;

class gui.tools.ToolZoomout extends AbstractTool implements ToolInterface
{	
	private var toolDownLink:String = "assets/img/ToolZoomout_down.png";
	private var toolUpLink:String = "assets/img/ToolZoomout_up.png";
	private var toolOverLink:String = "assets/img/ToolZoomout_over.png";
	
	public function ToolZoomout(id:String, container:MovieClip) {
		super(id, container);		
		Logger.console("Test tool constructor");	
		Logger.console(typeof(this));
	}	
}