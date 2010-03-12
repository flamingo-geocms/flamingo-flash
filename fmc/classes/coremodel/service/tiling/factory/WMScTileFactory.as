import coremodel.service.tiling.factory.TileFactoryInterface;
import coremodel.service.tiling.factory.AbstractTileFactory;
import coremodel.service.tiling.Tile;

import geometrymodel.Envelope;

class coremodel.service.tiling.factory.WMScTileFactory extends AbstractTileFactory implements TileFactoryInterface{
	
	/*Constructor*/
	function WMScTileFactory(r:Array,e:Envelope,url:String,map:Object){			
		super(r,e,url,map);		
	}	
	/*Create a WMSc tile
	@param xIndex the x index of this tile
	@param yIndex the y index of this tile
	@param zoomLevel the zoomlevel index (index to resolution) of this tile.
	*/
	public function createTile(xIndex:Number, yIndex:Number, zoomLevel:Number):Tile{				
		var tile = super.createTile(xIndex,yIndex,zoomLevel);
		
		var url:String=this.getServiceUrl();
		if (url.indexOf("?")!=url.length-1 && url.indexOf("&")!=url.length-1){
			url+=url.indexOf("?")>=0 ? "&" : "?";
		}
		for (var paramName in extraUrlParams){
			url+=paramName+"="+extraUrlParams[paramName];
			url+="&";
		}		
		url+="WIDTH="+this.getTileWidth();
		url+="&";
		url+="HEIGHT="+this.getTileHeight();
		url+="&";
		url+="BBOX="+tile.getBbox().getMinX()+","+tile.getBbox().getMinY()+","+tile.getBbox().getMaxX()+","+tile.getBbox().getMaxY();
		url+="&";
		
		tile.setImageUrl(url);
		tile=setTileScreenLocation(tile);
		
		return tile;
	}
}