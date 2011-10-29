import display.spriteloader.SpriteSettings;
import display.spriteloader.Sprite;
import display.spriteloader.SpriteMap;
import display.spriteloader.SpriteMapFactory;
import mx.utils.Delegate;
/**
 * ...
 * @author 
 */

class SpriteMapDemo extends MovieClip
{
	 
	
	
	public function SpriteMapDemo(mc:MovieClip) {
		
		
		super();
		//grab the factory (singleton)
		var spriteMapFactory:SpriteMapFactory = SpriteMapFactory.getInstance();
		
		var toolSpritesUrl:String = "iconMapTest_1.png";
		//let the factory provide you with a new spritemap by calling obtainSpriteMap() on it with a url
		//if you call obtainSpriteMap anywhere else with the same image url, it won't spoil bandwith requests and will only load it once..
		var spriteMap:SpriteMap = spriteMapFactory.obtainSpriteMap(toolSpritesUrl);
		//Use the spritemap to create a sprite by calling attachSpriteTo() on it with a target MovieClip and SpriteSettings ( see SpriteSettings class for documentation)
		//Here we grab six 14x14 icons from the spritemap, and project them on our target mc, and spread the on the _y axis every 20 pixels.
		//They are all visible (true) we alter the alpha within the 30 - 100 range.
		spriteMap.attachSpriteTo(mc, new SpriteSettings(138, 69 , 14, 14, 0, 0, true, 30));
		spriteMap.attachSpriteTo(mc, new SpriteSettings(153, 69, 14, 14, 20, 7, true, 40));
		spriteMap.attachSpriteTo(mc, new SpriteSettings(138, 84, 14, 14, 40, 14, true, 50));
		spriteMap.attachSpriteTo(mc, new SpriteSettings(153, 84, 14, 14, 60, 21, true, 68));
		spriteMap.attachSpriteTo(mc, new SpriteSettings(138, 99, 14, 14, 80, 28, true, 85));
		spriteMap.attachSpriteTo(mc, new SpriteSettings(153, 99, 14, 14, 100, 35, true, 100));
		
		
		
		//here we illustrate the usage of the spriteMapFactory that produces a new spritemap, because it is assigned a new url.
		//we also see that the attachSpriteTo() function returns a ref. to the sprite that was created, we assign that ref to smileSprite here...
		var otherToolSpritesUrl:String = "iconMapTest_2.png";
		var secondMap:SpriteMap = spriteMapFactory.obtainSpriteMap(otherToolSpritesUrl);
		var smileSprite:Sprite = secondMap.attachSpriteTo(mc, new SpriteSettings(49, 33, 14, 14));
		// ...so we can easily use it to alter some more setters on that clip afterwards:
		smileSprite._rotation = -25;
		smileSprite._y = 75;
		smileSprite._xscale = smileSprite._yscale = 250;
		
		
		
		
		
		//here we apply brand new sprite settings on the same sprite, without recreating the sprite.
		//we could use this for example ineractively for a button with 3 states: upon new button states we can easily 
		//display a new state image by just assigning new settings:
		var repaintableSprite:Sprite = spriteMap.attachSpriteTo(mc); //first we create a sprite without any settings, only the target
		//illustartive loop:
		var hIndex:Number = 0;
		var vIndex:Number = 0;
		var repaintLoop:Function = function()
		{
			var xoffset:Number = hIndex * 20;
			var yoffset:Number = vIndex * 20 +132;
			//on the 'map' icons are 20 px wide and high, the projected sprite will be positioned on 50 x and 50 y of our target mc.
			var settings:SpriteSettings = new SpriteSettings(xoffset, yoffset, 20, 20, 50, 50);
			////the magic, we apply (different) settings after the sprite was long done and keep updating it with new graphics:
			repaintableSprite.applyNewSettings(settings);
			
			hIndex++;
			if (hIndex  == 8) { hIndex = 0; vIndex++ };
			if (vIndex  == 4) { vIndex=0 };
		}
		setInterval(repaintLoop, 333);
		
	}
	
	
	
	/*mtasc entry*/
	static function main(mc:MovieClip) {
		var t:SpriteMapDemo = new SpriteMapDemo(mc);
	}
	
}