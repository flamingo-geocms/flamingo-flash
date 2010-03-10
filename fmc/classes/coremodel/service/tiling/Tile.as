import geometrymodel.Envelope;
import tools.Logger;

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
	
	function Tile(){
		super();
		this.log = new Logger("coremodel.service.tiling.Tile",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());		
	}
			
	/*Getters and setters*/
	public function getTileId():String{
		return ""+zoomLevel+"_"+xIndex+"_"+yIndex;
	}
	public function setTileWidth(w:Number):Void{
		this.tileWidth=w;
	}	
	public function getTileWidth():Number{
		return this.tileWidth;
	}
	public function setTileHeight(h:Number):Void{
		this.tileHeight=h;
	}
	public function getTileHeight():Number{
		return this.tileHeight;
	}
	public function setZoomLevel(zoomLevel:Number):Void{
		this.zoomLevel=zoomLevel;
	}
	public function getZoomLevel():Number{
		return this.zoomLevel;
	}
	public function setXIndex(xIndex:Number):Void{
		this.xIndex=xIndex;
	}
	public function getXIndex():Number{
		return this.xIndex;
	}
	public function setYIndex(yIndex:Number):Void{
		this.yIndex=yIndex;
	}
	public function getYIndex():Number{
		return this.yIndex;
	}
	public function setBbox(e:Envelope):Void{
		this.bbox=e;
	}
	public function getBbox():Envelope{
		return this.bbox;
	}
	public function setImageUrl(imageUrl:String){
		this.imageUrl=imageUrl;
	}
	public function getImageUrl():String{
		return this.imageUrl;
	}
	public function setScreenX(screenX:Number){
		this.screenX=screenX;
	}
	public function getScreenX():Number{
		return screenX;
	}
	public function setScreenY(screenY:Number){
		this.screenY=screenY;
	}
	public function getScreenY():Number{
		return screenY;
	}
	public function setScreenWidth(screenWidth:Number){
		this.screenWidth=screenWidth;
	}
	public function getScreenWidth():Number{
		return screenWidth;
	}
	public function setScreenHeight(screenHeight:Number){
		this.screenHeight=screenHeight;
	}
	public function getScreenHeight():Number{
		return screenHeight;
	}
	
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