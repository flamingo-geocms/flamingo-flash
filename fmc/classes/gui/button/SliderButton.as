
/**
 * 
 * @author Meine Toonen
 */
import gui.button.AbstractButton;
import gui.ZoomerV;
import tools.Logger;
import display.spriteloader.SpriteSettings;


class gui.button.SliderButton extends AbstractButton
{
	private var zoomerV:ZoomerV;
	var center:Object;
	var bSlide:Boolean = false;
	var p:Number;
	
	public function SliderButton(id:String, container:MovieClip, zoomerV:ZoomerV)
	{
		super(id, container);
		toolOverSettings = new SpriteSettings(22, 1090, 21, 12, 0, 0, true, 100);
		toolDownSettings  = new SpriteSettings(62, 1089, 21, 12, 0, 0, true, 100);
		toolUpSettings = new SpriteSettings(103, 1091, 17, 8, 0, 0, true, 100);
		this.zoomerV = zoomerV;
		this.parent = zoomerV;
	}
	
	function onPress()	{
		zoomerV.cancelUpdate();
		var l = this.container._x;
		var t = zoomerV.sliderBar._y + (this.height/2);
		var r = this.container._x;
		var b = zoomerV.sliderBar._y + zoomerV.sliderBar._height - (this.height *1.5);
		
		this.container.startDrag(false, l, t, r, b);
		var thisObj = this;
		center = map.getCenter();
		this.container.onMouseMove = function()
		{
			thisObj.bSlide = true;
			thisObj.zoomSlider();
		};
	}
	
	function onRelease()
	{
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		zoomerV.updateMaps();
	}
	
	function onDragOut()	{
		bSlide = true;
		zoomSlider();
	}
	
	function onDragOver()	{
		bSlide = true;
		zoomSlider();
	}
	
	function onReleaseOutside()	{
		bSlide = false;
		delete this.container.onMouseMove;
		this.container.stopDrag();
		zoomerV.updateMaps();
	}
	
	function onRollOver()	{
		flamingo.showTooltip(flamingo.getString(zoomerV, "tooltip_slider"), this);
	}
	
	function zoomSlider()	{
		var max = map.getMaxScale();
		var min = map.getMinScale();
		if(min == undefined)
		{
			min = 0.001;
		}
		
		p = (this.container._y-zoomerV.sliderBar._y)/zoomerV.sliderBar._height*100;
		p = p/21.544347;
		p = p*p*p;
		p = Math.min(100, p);
		p = Math.max(0, p);
		var scale = min + ((max - min) * p / 100);
		map.moveToScale(scale, center, -1, 0);
	}
	
	public function get map():Object
	{
		return flamingo.getComponent(this.zoomerV.listento[0]);
	}
}