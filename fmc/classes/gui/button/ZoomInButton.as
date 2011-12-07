import gui.ZoomerV;
import tools.Logger;
import gui.button.AbstractButton;
import display.spriteloader.SpriteSettings;

/**
 * 
 * @author Meine Toonen
 */


class gui.button.ZoomInButton extends AbstractButton
{
	private var zoomerV:ZoomerV;
	private var _zoomid:Number;
	
	public function ZoomInButton(id:String, container:MovieClip, zoomerV:ZoomerV)
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(143, 1092, 20, 20, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(185, 1092, 20, 20, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(229, 1094, 16, 17, 0, 0, true, 100);
		this.zoomerV = zoomerV;
		this.parent = zoomerV;
	}
	
	public function onPress()
	{
		zoomerV.cancelUpdate();
		
		//var map = flamingo.getComponent(listento[0]);
		
		Logger.console("zoominpress", map);
		_zoomid = setInterval(zoomerV, "_zoom", 10, map, 105);
	}
	
	public function onRelease()
	{
		clearInterval(_zoomid);
		this.zoomerV.updateMaps();
	}
	
	public function onReleaseOutside()
	{
		clearInterval(_zoomid);
		this.zoomerV.updateMaps();
	}
	
	public function onRollOver()
	{
		flamingo.showTooltip(flamingo.getString(zoomerV, "tooltip_zoomin"), this);
	}
	
	public function get map():Object
	{
		return flamingo.getComponent(this.zoomerV.listento[0]);
	}
}