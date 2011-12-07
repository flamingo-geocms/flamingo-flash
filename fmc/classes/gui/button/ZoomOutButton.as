import gui.tools.ToolZoomerV;
import tools.Logger;
import gui.button.AbstractButton;
import display.spriteloader.SpriteSettings;

/**
 * ...
 * @author Meine Toonen
 */


class gui.button.ZoomOutButton extends AbstractButton
{
	private var zoomerV:ToolZoomerV;
	private var _zoomid:Number;
	
	public function ZoomOutButton(id:String, container:MovieClip, zoomerV:ToolZoomerV)
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(269, 1092, 20, 20, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(311, 1092, 20, 20, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(353, 1094, 16, 17, 0, 0, true, 100);
		this.zoomerV = zoomerV;
		this.parent = zoomerV;
	}
	
		/**
	 * Gets the real parent object 
	 * @return the real parent. In this case its always the zoomerV
	 */
	public function getParent():Object {
		return this.zoomerV;
	}
	
	public function onPress()
	{
		Logger.console("zoomoutpress");
		zoomerV.cancelUpdate();
		_zoomid = setInterval(zoomerV, "_zoom", 10, map, 95);
	}
	
	public function onRelease()
	{
		clearInterval(_zoomid);
		zoomerV.updateMaps();
	}
	
	public function onReleaseOutside()
	{
		clearInterval(_zoomid);
		zoomerV.updateMaps();
	}
	
	public function onRollOver()
	{
		flamingo.showTooltip(flamingo.getString(zoomerV, "tooltip_zoomout"), this);
	}
	
	public function get map():Object
	{
		return flamingo.getComponent(this.zoomerV.listento[0]);
	}
}