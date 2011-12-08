import gui.SliderHor;
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
/**
 * @author Meine Toonen
 */
class gui.button.DecreaseButton extends AbstractButton
{
	
	var _sliderHor:SliderHor;
	
	public function DecreaseButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolDownSettings = new SpriteSettings(269, 1092, 20, 20, 0, 0, true, 100);
		toolOverSettings = new SpriteSettings(311, 1092, 20, 20, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(353, 1094, 16, 17, 0, 0, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}
	
	function onPress() {
		sliderHor.cancelUpdate();
	}
	
	function onRelease() {
		sliderHor.stepSlider(false);
	}
	
	function onReleaseOutside() {
		sliderHor.stepSlider(false);
	}
	
	function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_min"), this);
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