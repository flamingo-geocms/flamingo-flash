/**

 * @author Meine Toonen
 */
import gui.button.AbstractButton;
import tools.Logger;
import display.spriteloader.SpriteSettings;
import gui.SliderHor;

class gui.button.HorSliderButton extends AbstractButton
{
	var _sliderHor:SliderHor;	
	var bSlide:Boolean = false;
	
	public function HorSliderButton(id:String, container:MovieClip, sliderHor:SliderHor) 
	{
		super(id, container);
		toolOverSettings = new SpriteSettings(102, 762, 13, 20,-5, -5, true, 100);
		toolDownSettings  = new SpriteSettings(69, 762, 13, 20, -5, -5, true, 100);
		toolUpSettings = new SpriteSettings(136, 764, 9, 16, -5, -5, true, 100);
		this.sliderHor = sliderHor;
		this.parent = sliderHor;
	}

	function onPress() {
		sliderHor.cancelUpdate();
		/*
		 * var l = mSliderbar._x;
		var t = mSlider._y;
		var r = mSliderbar._x+mSliderbar._width;
		var b = mSlider._y;*/
		var l = sliderHor.sliderBar._x;
		var t = this.container._y;
		var r = sliderHor.sliderBar._width + sliderHor.sliderBar._x;
		var b = this.container._y;
		this.container.startDrag( false, l, t, r, b);
		var thisObj:HorSliderButton = this;
		this.container.onMouseMove = function() {
			thisObj.bSlide = true;
			thisObj.slide();
		};
	}
	
	function onRelease () {
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		slide();
	}
	
	function slide() {

		sliderHor.currentValue = sliderHor.minimum + ((this.container._x-sliderHor.sliderBar._x) / sliderHor.sliderBar._width) * (sliderHor.maximum - sliderHor.minimum);
		sliderHor.updateListeners();
	}
	
	function onReleaseOutside() {
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		slide();
	}
	
	function onRollOver () {
		flamingo.showTooltip(flamingo.getString(sliderHor, "tooltip_slider"), this);
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