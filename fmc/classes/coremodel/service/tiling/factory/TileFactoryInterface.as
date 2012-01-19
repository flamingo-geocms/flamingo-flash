/*-----------------------------------------------------------------------------
Copyright (C) 2010 Roy Braam

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
import coremodel.service.tiling.Tile;
import geometrymodel.Envelope;
/**
 * Interface for implementations of the TileFactory
 * @author Roy Braam
 */
interface coremodel.service.tiling.factory.TileFactoryInterface{    
        
	/**
	 * Must set the resolutions.
	 * @param	r A array of numbers
	 */
    public function setResolutions(r:Array):Void;
	/**
	 * Must return the resolutions as Array of numbers
	 * @return the resolutions as a array of numbers
	 */
    public function getResolutions():Array;
    
	/**
	 * Must set the tile Width for a single tile
	 * @param	w width in pixels
	 */
    public function setTileWidth(w:Number):Void;
	/**
	 * Must return the tile Width for a single tile
	 * @return the tileWidth in pixels
	 */
    public function getTileWidth():Number;
	/**
	 * Must set the tile Height for a single tile
	 * @param	h the tile height in pixels
	 */
    public function setTileHeight(h:Number):Void;
	/**
	 * Must return the tile height of a single tile
	 * @return the tile height in pixels
	 */
    public function getTileHeight():Number;
	/**
	 * Must set the tile extension that is added at the back of the url for a tile.
	 * @param	ext the extension. For example .png or .gif
	 */
    public function setTileExtension(ext:String):Void;
	/**
	 * Must return the tile extension
	 * @return the tile extension as a string
	 */
    public function getTileExtension():String;
    
	/**
	 * must return the x index number for the tile from the origin
	 * @param	xCoord x coordinate
	 * @param	mapRes resolution 
	 * @return	the x index from the origin (starts from 0)
	 */
    public function getTileIndexX(xCoord:Number, mapRes:Number):Number;
	/**
	 * must return the y index number for the tile from the origin
	 * @param	yCoord y coordinate
	 * @param	mapRes the resolution
	 * @return the y index from the origin (strats from 0)
	 */
    public function getTileIndexY(yCoord:Number,mapRes:Number):Number;
    
	/**
	 * Must return the zoomLevel
	 * @param	res the resolution
	 * @param	maxresfactor the maxresfactor
	 * @param	intervalfactor the interval factor
	 * @return 	the zoomlevel (0 - N)
	 */
    public function getZoomLevel(res:Number, maxresfactor:Number, intervalfactor:Number):Number;
    
	/**
	 * must set extraParams
	 * @param	extraParams the extra params
	 */
    public function setExtraParams(extraParams:Object):Void;
    /**
     * Get the extra params
     * @return extra params
     */public function getExtraParams():Object;
    
	/**
	 * Must create and return a Tile
	 * @param	xIndex the x index to indicate the tile that must be created.
	 * @param	yIndex the y index to indicate the tile that must be created.
	 * @param	zoomLevel the zoomlevel to indicate the tile that must be created
	 * @return	the created tile.
	 */
    public function createTile(xIndex:Number, yIndex:Number, zoomLevel:Number):Tile;
    
	/**
	 * Must set the screen resolutions for this tile.
	 * @param	tile the tile
	 * @param	mapExtent the mapExtent
	 * @return	The tile with the correct screen resolutions.
	 */
    public function setTileScreenLocation(tile:Tile,mapExtent:Object):Tile;
}