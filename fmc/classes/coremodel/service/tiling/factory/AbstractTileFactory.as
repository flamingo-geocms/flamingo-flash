import geometrymodel.Envelope;
import coremodel.service.tiling.Tile;
import tools.Logger;
/*Abstract class TileFactory*/
class coremodel.service.tiling.factory.AbstractTileFactory{
	private var extraUrlParams:Object=null;	
	private var log:Logger=null;
	/*Static epsilon*/
	private static var epsilon=0.00001;
	
	public static var TILINGTYPE_KEY:String="type";
	public static var BBOX_KEY:String="bbox";
	public static var MAP_KEY:String="map";
	public static var RESOLUTIONS_KEY:String="resolutions";	
	public static var SERVICEURL_KEY:String="serviceUrl";
	
	private var resolutions:Array=null;
	
	private var tileWidth:Number=256;
	private var tileHeight:Number=256;
		
	private var serviceBBox:Envelope=null;
	
	private var serviceUrl:String=null;
	
	private var map:Object=null;
			
	public function AbstractTileFactory(r:Array,b:Envelope,url:String,map:Object){
		this.log = new Logger("coremodel.service.tiling.factory.AbstractTileFactory",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
		setResolutions(r);
		setServiceBBox(b);		
		setServiceUrl(url);
		setMap(map);
	}
	
	/*Getters and setters*/
	public function setServiceBBox(b:Envelope){
		this.serviceBBox=b;
	}
	public function getServiceBBox():Envelope{
		return serviceBBox;
	}
	public function setServiceUrl(url:String){
		this.serviceUrl=url;
	}
	public function getServiceUrl():String{
		return this.serviceUrl;
	}
	public function setResolutions(r:Array):Void{
		this.resolutions=r;
	}
	public function getResolutions():Array{
		return resolutions;
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
	public function setMap(map:Object):Void{
		this.map=map;
	}
	public function getMap():Object{
		return this.map;
	}	
	public function setExtraParams(paramsObject:Object):Void{
		this.extraUrlParams=paramsObject;
	}
	public function getExtraParams():Object{
		return this.extraUrlParams;
	}
	/*Create a 'empty' tile: A tile without url and screen coordinates. (setTileScreen location not called)
	@param xIndex the x index of this tile
	@param yIndex the y index of this tile
	@param zoomLevel the zoomlevel index (index to resolution) of this tile.
	@return the Tile.
	*/
	public function createTile(xIndex:Number, yIndex:Number, zoomLevel:Number):Tile{		
		var tile = new Tile();
		tile.setZoomLevel(zoomLevel);
		tile.setXIndex(xIndex);
		tile.setYIndex(yIndex);
		tile.setTileWidth(tileWidth);
		tile.setTileHeight(tileHeight);
		
		var tileRes=resolutions[zoomLevel];
		tile.setResolution(tileRes);
		
		//specifiek:
		var tileSpanX=tileWidth*tileRes;
		var tileSpanY=tileHeight*tileRes;
		var minx=serviceBBox.getMinX()+(xIndex*tileSpanX);
		var maxx=minx+tileSpanX;
		var miny=serviceBBox.getMinY()+(yIndex*tileSpanY);
		var maxy=miny+tileSpanY;
				
		var tileBbox:Envelope= new Envelope(minx,miny,maxx,maxy);
		tile.setBbox(tileBbox);		
		
		return tile;
	}	
	
	/*Get the index number X of the tile on coordinate 'xCoord'.
	@param xCoord The x coord.
	@param zoomLevel the zoomLevel of the server.
	*/
	public function getTileIndexX(xCoord:Number,zoomLevel:Number):Number{
		var tileRes=resolutions[zoomLevel];
		var tileSpanX:Number= tileRes*getTileWidth();
		var tileIndexX:Number = Math.floor((xCoord - serviceBBox.getMinX()) / (tileSpanX+epsilon));
		if (tileIndexX < 0)
			tileIndexX=0;
		return tileIndexX;
	}
	/*Get the index number Y of the tile on coordinate 'yCoord' on zoomlevel 'zoomLevel'.
	@param yCoord The y coord.
	@param zoomLevel the zoomLevel of the server.
	*/
	public function getTileIndexY(yCoord:Number,zoomLevel:Number):Number{
		var tileRes=resolutions[zoomLevel];
		var tileSpanY:Number= tileRes*getTileHeight();
		var tileIndexY:Number = Math.floor((yCoord - serviceBBox.getMinY()) / (tileSpanY+epsilon));
		if (tileIndexY < 0)
			tileIndexY=0;
		return tileIndexY
	}
	/*Get the fixed zoomlevel of the given Resolution from this service: 'res'
	@param res The resolution resolution
	*/
	public function getZoomLevel(res:Number):Number{
		for (var i:Number =0; i < this.resolutions.length; i++){
			//if the map res is larger then the service resolution or equal to (almost equal to, to fix the double inaccuracy problem)
			if (res > this.resolutions[i] || ((res-this.resolutions[i] < 0.0000000001) && (res-this.resolutions[i] > -0.0000000001))){
				return i;
			}
		}
		log.debug("found none, return last zoomlevel (smallest)");
		return (this.resolutions.length-1);
	}
	/*
	Calculates the given worldExtent to the current mapRect Object (.x,.y,.width and .height)
	*/
	private function worldExtent2screenRect(worldExtent:Envelope,mapExtent:Object):Object {		
		if (mapExtent==undefined){
			mapExtent= map.getMapExtent();
		}
		var msx = (mapExtent.maxx-mapExtent.minx)/map.__width;
		var msy = (mapExtent.maxy-mapExtent.miny)/map.__height;
		var r:Object = new Object();
		r.x = (worldExtent.getMinX()-mapExtent.minx)/msx;
		r.y = (mapExtent.maxy-worldExtent.getMaxY())/msy;
		r.width = (worldExtent.getMaxX()-worldExtent.getMinX())/msx;
		r.height = (worldExtent.getMaxY()-worldExtent.getMinY())/msy;
		return (r);
	}
	/*Set the tile screen locations (screenX,screenY,screenWidth and screenHeight)*/
	public function setTileScreenLocation(tile:Tile,mapExtent:Object):Tile{		
		var rect:Object=worldExtent2screenRect(tile.getBbox(),mapExtent);
		tile.setScreenX(Math.round(rect.x+0.25));
		tile.setScreenY(Math.round(rect.y+0.25));
		tile.setScreenWidth(Math.round(rect.width+0.25));
		tile.setScreenHeight(Math.round(rect.height+0.25));
		return tile;
	}
	
}