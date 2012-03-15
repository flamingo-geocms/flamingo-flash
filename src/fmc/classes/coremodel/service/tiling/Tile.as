import geometrymodel.Envelope;
import tools.Logger;

/**
 * coremodel.service.tiling.Tile
 */
class coremodel.service.tiling.Tile extends MovieClip{
	//logging:
	private var log:Logger=null;
	//the extent
	private var bbox:Envelope=null;
	
	private var zoomLevel:Number=null;
	private var xIndex:Number=null;
	private var yIndex:Number=null;
	
	private var tileWidth:Number=null;
	private var tileHeight:Number=null;
	
	private var imageUrl:String=null;
	
	private var screenX:Number=null;
	private var screenY:Number=null;
	private var screenWidth:Number=null;
	private var screenHeight:Number=null;
	/**
	 * constructor
	 */
	function Tile(){
		super();
		this.log = new Logger("coremodel.service.tiling.Tile",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());		
	}
			
	/**
	 * getter tileId
	 * @return
	 */
	public function getTileId():String{
		return ""+zoomLevel+"_"+xIndex+"_"+yIndex;
	}
	/**
	 * setter TileWidth
	 * @param	w
	 */
	public function setTileWidth(w:Number):Void{
		this.tileWidth=w;
	}	
	/**
	 * getter TileWidth
	 * @return
	 */
	public function getTileWidth():Number{
		return this.tileWidth;
	}
	/**
	 * setter TileHeight
	 * @param	h
	 */
	public function setTileHeight(h:Number):Void{
		this.tileHeight=h;
	}
	/**
	 * getter TileHeight
	 * @return
	 */
	public function getTileHeight():Number{
		return this.tileHeight;
	}
	/**
	 * setter ZoomLevel
	 * @param	zoomLevel
	 */
	public function setZoomLevel(zoomLevel:Number):Void{
		this.zoomLevel=zoomLevel;
	}
	/**
	 * getter ZoomLevel
	 * @return
	 */
	public function getZoomLevel():Number{
		return this.zoomLevel;
	}
	/**
	 * setter XIndex
	 * @param	xIndex
	 */
	public function setXIndex(xIndex:Number):Void{
		this.xIndex=xIndex;
	}
	/**
	 * getter XIndex
	 * @return
	 */
	public function getXIndex():Number{
		return this.xIndex;
	}
	/**
	 * setter YIndex
	 * @param	yIndex
	 */
	public function setYIndex(yIndex:Number):Void{
		this.yIndex=yIndex;
	}
	/**
	 * getter YIndex
	 * @return
	 */
	public function getYIndex():Number{
		return this.yIndex;
	}
	/**
	 * setter Bbox
	 * @param	e
	 */
	public function setBbox(e:Envelope):Void{
		this.bbox=e;
	}
	/**
	 * getter Bbox
	 * @return
	 */
	public function getBbox():Envelope{
		return this.bbox;
	}
	/**
	 * setter ImageUrl
	 * @param	imageUrl
	 */
	public function setImageUrl(imageUrl:String){
		this.imageUrl=imageUrl;
	}
	/**
	 * getter ImageUrl
	 * @return
	 */
	public function getImageUrl():String{
		return this.imageUrl;
	}
	/**
	 * setter ScreenX
	 * @param	screenX
	 */
	public function setScreenX(screenX:Number){
		this.screenX=screenX;
	}
	/**
	 * getter ScreenX
	 * @return
	 */
	public function getScreenX():Number{
		return screenX;
	}
	/**
	 * setter ScreenY
	 * @param	screenY
	 */
	public function setScreenY(screenY:Number){
		this.screenY=screenY;
	}
	/**
	 * getter ScreenY
	 * @return
	 */
	public function getScreenY():Number{
		return screenY;
	}
	/**
	 * setter ScreenWidth
	 * @param	screenWidth
	 */
	public function setScreenWidth(screenWidth:Number){
		this.screenWidth=screenWidth;
	}
	/**
	 * getter ScreenWidth
	 * @return
	 */
	public function getScreenWidth():Number{
		return screenWidth;
	}
	/**
	 * setter ScreenHeight
	 * @param	screenHeight
	 */
	public function setScreenHeight(screenHeight:Number){
		this.screenHeight=screenHeight;
	}
	/**
	 * getter ScreenHeight
	 * @return
	 */
	public function getScreenHeight():Number{
		return screenHeight;
	}
	/**
	 * toString
	 * @return
	 */
	function toString():String{
		return "xIndex: "+xIndex+
			" yIndex: "+yIndex+
			" tileWidth: "+tileWidth+
			" tileHeight: "+tileHeight+
			" imageUrl: "+imageUrl+
			" screenX: "+screenX+
			" screenY: "+screenY+
			" screenWidth: "+screenWidth+
			" screenHeight: "+screenHeight;
	}
}