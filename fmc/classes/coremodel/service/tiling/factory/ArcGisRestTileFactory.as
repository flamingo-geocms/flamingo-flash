import coremodel.service.tiling.factory.TileFactoryInterface;
import coremodel.service.tiling.factory.AbstractTileFactory;
import coremodel.service.tiling.Tile;

import geometrymodel.Envelope;

class coremodel.service.tiling.factory.ArcGisRestTileFactory extends AbstractTileFactory implements TileFactoryInterface{
	/*Constructor*/
	function ArcGisRestTileFactory(r:Array,e:Envelope,url:String,map:Object){		
		super(r,e,url,map);
	}
	/** Create a ArcGis tile
	 * @param xIndex the x index of this tile
	 * @param yIndex the y index of this tile
	 * @param zoomLevel the zoomlevel index (index to resolution) of this tile.
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#createTile
	 */
	public function createTile(xIndex:Number, yIndex:Number, zoomLevel:Number):Tile{		
		var tile = super.createTile(xIndex,yIndex,zoomLevel);
		//setbbox
		//calculate bbox:
		var tileRes=resolutions[zoomLevel];
		var tileSpanX=tileWidth*tileRes;
		var tileSpanY=tileHeight*tileRes;
		//other bbox because y starts at top left 
		var minx=serviceBBox.getMinX()+(xIndex*tileSpanX);
		var maxx=minx+tileSpanX;
		var miny=serviceBBox.getMaxY()-((1+yIndex)*tileSpanY);
		var maxy=miny+tileSpanY;
				
		var tileBbox:Envelope= new Envelope(minx,miny,maxx,maxy);
		tile.setBbox(tileBbox);			
		
		//create url
		var url=serviceUrl+zoomLevel+"/"+yIndex+"/"+xIndex;	
		if (this.getExtraParams()!=null){
			url+=url.indexOf("?")>=0 ? "&" : "?";		
			for (var paramName in extraUrlParams){
				url+=paramName+"="+extraUrlParams[paramName];
				url+="&";
			}		
		}
		tile.setImageUrl(url);	
		tile=setTileScreenLocation(tile);		
		return tile;
	}	
	/**
	 * For ArcGis Rest map cache the y is in the other order. (starts at top left)	 
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#getTileIndexY
	 */	
	public function getTileIndexY(yCoord:Number,zoomLevel:Number):Number{
		var tileRes=resolutions[zoomLevel];
		var tileSpanY:Number= tileRes*getTileHeight();
		var tileIndexY:Number = Math.floor((serviceBBox.getMaxY() - yCoord) / (tileSpanY+epsilon));
		//var tileIndexY:Number = Math.floor((yCoord - serviceBBox.getMinY()) / (tileSpanY+epsilon));
		if (tileIndexY < 0)
			tileIndexY=0;
		return tileIndexY
	}
}