/*-----------------------------------------------------------------------------
 Copyright (C)
 
 This file is part of Flamingo MapComponents.
 
 Flamingo MapComponents is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------*/
import coremodel.service.tiling.factory.TileFactoryInterface;
import coremodel.service.tiling.factory.AbstractTileFactory;
import coremodel.service.tiling.Tile;

import geometrymodel.Envelope;
/**
 * Creates OSM tiles
 * @author Roy Braam
 */
class coremodel.service.tiling.factory.OSMTileFactory extends AbstractTileFactory implements TileFactoryInterface{
	/*Constructor*/
	function OSMTileFactory(r:Array,e:Envelope,url:String,map:Object){		
		super(r,e,url,map);
	}
	/** 
	 * Create osm/google/bing tile origin upper left
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
		var url=serviceUrl+zoomLevel+"/"+xIndex+"/"+yIndex + this.getTileExtension();;	
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
	 * for OSM/GOOGLE/BING Origin is top left
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