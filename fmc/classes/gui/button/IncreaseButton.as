import gui.SliderHor;
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/**
 * @author Meine Toonen
 */
class gui.button.IncreaseButton extends AbstractButton
{
	
	var _sliderHor:SliderHor;
	
	public function IncreaseButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(143, 1093, 20, 20, -4, -9, true, 100);
		toolOverSettings = new SpriteSettings(185, 1093, 20, 20, -4, -9, true, 100);
		toolUpSettings = new SpriteSettings(229, 1094, 16, 17, -4, -9, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	
	public function onPress () {
		sliderHor.cancelUpdate();
	}
	
	public function onRelease () {
		sliderHor.stepSlider(true);
	}
	
	public function onReleaseOutside () {
		sliderHor.stepSlider(true);
	}
	
	public function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_increase"), this);
	}	
	
	function resize():Void {
		//don't do anything on resize. The parent is positioning this object.
	}
	public function get sliderHor():SliderHor 
	{
		return _sliderHor;
	}
	
	public function set sliderHor(value:SliderHor):Void 
	{
		_sliderHor = value;
	}
}