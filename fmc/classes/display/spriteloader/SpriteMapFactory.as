import display.spriteloader.SpriteMap;
/**
 * ...
 * @author ...
 */
class display.spriteloader.SpriteMapFactory
{
	static private var _instance:SpriteMapFactory;
	static private var _tempClip:MovieClip;
	private var _mapDictionary:Array = [];
	/**
	 * 
	 * @param	stage: Any existing staged MovieClip where we can create temporary childclips on.
	 */
	public function SpriteMapFactory()
	{		
			if (!Boolean(arguments[0].internalCreation))
			{
				trace('This is a [Class SpriteMap]: is a Singleton Class: use SpriteMap.getInstance() to use the instance');
			}
	}
	
	/**
	 * Staic singleton entrypoint to receive the SpriteMap instance.
	 * @return
	 */
	public static function getInstance():SpriteMapFactory
	{
		if (_instance == null) {
			_tempClip = _root.createEmptyMovieClip("SpriteMapFactory_TempClip", _root.getNextHighestDepth());
			_tempClip._visible = false;
			_instance = new SpriteMapFactory( { internalCreation:true } );
			
		}
		return _instance;
	}
	
	
	public function obtainSpriteMap(spriteMapUrl:String):SpriteMap
	{
		var map:SpriteMap = _mapDictionary[spriteMapUrl];
		if ( ! (map instanceof SpriteMap) ) 
		{
			 map = new SpriteMap(spriteMapUrl, _tempClip);
			 _mapDictionary[spriteMapUrl] = map;
		}
		return map;
	}
}
