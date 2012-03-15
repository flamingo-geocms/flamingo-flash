/** 
 * display.spriteloader.SpriteSettings
 * @author Stijn De Ryck 
 */
class display.spriteloader.SpriteSettings extends Object
{
	public var _x:Number = 0;
	public var _y:Number = 0;
	public var mapOffsetX:Number = 0;
	public var mapOffsetY:Number = 0;
	public var mapAreaWidth:Number = 0;
	public var mapAreaHeight:Number = 0;
	static public var sliderSize = 22;
	static public var buttonSize = 28;
	
	/**
	 * SpriteSettings
	 * @param	mapOffsetX The horizontal position (of the top-left corner) of the Sprite's area located on the sprite map image. 
	 * @param	mapOffsetY The vertical position (of the top-left corner) of the Sprite's area located on the sprite map image. 
	 * @param	mapAreaWidth The width of the Sprite area the map-image.
	 * @param	mapAreaHeight The height of the Sprite area on map-image.
	 * @param	_x (optional) position attached sprite vertically to _x position
	 * @param	_y (optional)position attached sprite horizontally to _y position
	 * @param	_visible (optional) set sprite's visible state
	 * @param	_alpha (optional) set sprite's _alpha
	 */
	public function SpriteSettings(mapOffsetX:Number,mapOffsetY:Number,mapAreaWidth:Number,mapAreaHeight:Number,_x:Number,_y:Number,_visible:Boolean, _alpha:Number) 
	{
		
		var props:Array = ['mapOffsetX', 'mapOffsetY', 'mapAreaWidth', 'mapAreaHeight','_x', '_y','_visible','_alpha'];
		var argIndex:Number = arguments.length-1;
		while (argIndex > -1)
		{
			
			if (arguments[argIndex] != undefined) {
				this[props[argIndex]] = arguments[argIndex];
				//trace(props[argIndex]+':'+arguments[argIndex])
			}
			argIndex--;
		}
	}
	
}