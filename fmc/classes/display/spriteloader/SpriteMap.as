import display.spriteloader.BitmapUtils;
import display.spriteloader.event.GDispatcher;
import display.spriteloader.event.SpriteMapEvent;
import display.spriteloader.Sprite;
import display.spriteloader.SpriteSettings;
import flash.display.BitmapData;
import tools.Logger;
/**
 * ...
 * @author 
 */
class display.spriteloader.SpriteMap extends Object
{
	private var _matrixSize:Number;
	private var _url:String;
	private var _spriteIndex:Number=0;
	private var _urlName:String;
	private var _tempClip:MovieClip;
	private var _mapImage:MovieClip;
	private var _loaded:Boolean = false;
	private var _bitmapData:BitmapData;
	
	//initialized by GDispather
	public var dispatchEvent:Function;
    public var addEventListener:Function;
    public var removeEventListener:Function;

	
	public function SpriteMap(spriteMapUrl:String,tempClip:MovieClip) 
	{
		_tempClip = tempClip;
		this._url = spriteMapUrl;
		GDispatcher.initialize(this);
		init();
	}
	
	private function init(e:Object):Void 
	{
		addEventListener(SpriteMapEvent.LOAD_COMPLETE, handleEvent);
		addEventListener(SpriteMapEvent.LOAD_ERROR, handleEvent);
		addEventListener(SpriteMapEvent.LOAD_PROGRESS, handleEvent);
		loadSpriteMap();
	}
	
	public function attachSpriteTo(attachTarget:MovieClip,spriteSettings:SpriteSettings,depth:Number, spriteName:String):Sprite 
	{
		if (spriteName == undefined) {
			spriteName = "sprite_" +  createNameFromUrl() + '_' + _spriteIndex;
		}
		var sprite:Sprite = Sprite.create(this, attachTarget, spriteName, spriteSettings, depth);
		_spriteIndex++;
		return sprite;
	}
	
	public function get url():String 
	{
		return _url;
	}
	public function get loaded():Boolean 
	{
		return _loaded;
	}
	public function get bitmapData():BitmapData 
	{
		return _bitmapData;
	}
	
	private function createNameFromUrl():String 
	{
		if (_urlName == undefined)
		{
			var arr:Array;
			var str = _url.split("?")[0];
			str = str.split("&")[0];
			if (str.indexOf('://') > -1) 
			{
				str = str.split("://")[1];
			}
			str = str.split("/").join('|');
			str = str.split(".").join('_');
			str = str.split("%").join('');
			_urlName = str.split("-").join('-');
		}
		return _urlName;
	}
	
	
	private function handleEvent(e:SpriteMapEvent):Void 
	{
		switch(e.type) 
		{	case SpriteMapEvent.LOAD_ERROR:
				//trace("SpriteMap::handleEvent():  " + e.type + ", error: "+e.data.error+ ", errorNumber: "+e.data.errorNumber);
				break;
			case SpriteMapEvent.LOAD_PROGRESS:
				//trace("SpriteMap::handleEvent() :" + e.type + ", progress: "+ e.data.progress);
				break;
			case SpriteMapEvent.LOAD_COMPLETE:
				//trace("SpriteMap::handleEvent() :" + e.type + " COMPLETED: " + e.data.progress);
				break;
			default:
				//trace("SpriteMap::handleEvent() :" + e.type);
				break;
		}
	}
	
	private function loadSpriteMap():Void
	{
		var clazz:SpriteMap = this;
		var imgLoader:MovieClipLoader = new MovieClipLoader();
		var loadHandler:Object = new Object();
		
		loadHandler.onLoadInit=function(target:MovieClip){
			clazz._loaded = true;
			clazz._bitmapData = BitmapUtils.movieClipToBitmapData(target);
			clazz.dispatchEvent(new SpriteMapEvent(SpriteMapEvent.LOAD_COMPLETE, target));
		}
		
		loadHandler.onLoadComplete=function(target:MovieClip){
			//onloadcomplete is called before onloadinit but not all vars are accessible at this moment
		}
		
		loadHandler.onLoadError=function(target:MovieClip,error:String,errorNumber:Number){
			clazz.dispatchEvent(new SpriteMapEvent(SpriteMapEvent.LOAD_ERROR, target, { error:error, errorNumber:errorNumber } ));

		}
		
		loadHandler.onLoadProgress=function(target:MovieClip,loadedBytes:Number,totalBytes:Number){		
			clazz.dispatchEvent(new SpriteMapEvent(SpriteMapEvent.LOAD_PROGRESS, target, { progress: Math.max(0, Math.min(100, loadedBytes / totalBytes * 100))
																						,loadedBytes:loadedBytes
																						, totalBytes:totalBytes } ));
		}
		
		var depth:Number = _tempClip.getNextHighestDepth();
		_mapImage = _tempClip.createEmptyMovieClip("imageMap_" + depth, depth);
		imgLoader.addListener(loadHandler);
		imgLoader.loadClip(url, _mapImage);
	}
	
	
	
}