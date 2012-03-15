/*-----------------------------------------------------------------------------
 Copyright (C) Roy Braam
 
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
import geometrymodel.Envelope;
import coremodel.service.tiling.Tile;
import tools.Logger;
/**
 * Abstract class TileFactory
 * @author Roy Braam
 * @author Herman Assink
 */
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
    private var tileExtension:String="";
        
    private var serviceBBox:Envelope=null;
    
    private var serviceUrl:String=null;
    
    private var map:Object=null;
            
	/**
	 * Constructor
	 * @param	r resolution array
	 * @param	b Envelope of service
	 * @param	url the url of the service
	 * @param	map the map
	 */
    public function AbstractTileFactory(r:Array,b:Envelope,url:String,map:Object){
        this.log = new Logger("coremodel.service.tiling.factory.AbstractTileFactory",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        setResolutions(r);
        setServiceBBox(b);      
        setServiceUrl(url);
        setMap(map);
    }
    
    /*********************** Getters and Setters ***********************/
    /**
     * setter ServiceBBox
     * @param	b
     */
	public function setServiceBBox(b:Envelope){
        this.serviceBBox=b;
    }
	/**
	 * getter ServiceBBox
	 * @return
	 */
    public function getServiceBBox():Envelope{
        return serviceBBox;
    }
	/**
	 * setter ServiceUrl
	 * @param	url
	 */
    public function setServiceUrl(url:String){
        this.serviceUrl=url;
    }
	/**
	 * getter ServiceUrl
	 * @return
	 */
    public function getServiceUrl():String{
        return this.serviceUrl;
    }
	/**
	 * setter Resolutions
	 * @param	r
	 */
    public function setResolutions(r:Array):Void{
        this.resolutions=r;
    }
	/**
	 * getResolutions
	 * @return
	 */
    public function getResolutions():Array{
        return resolutions;
    }
	/**
	 * setTileWidth
	 * @param	w
	 */
    public function setTileWidth(w:Number):Void{
        this.tileWidth=w;
    }
	/**
	 * getTileWidth
	 * @return
	 */
    public function getTileWidth():Number{
        return this.tileWidth;
    }
	/**
	 * setTileHeight
	 * @param	h
	 */
    public function setTileHeight(h:Number):Void{
        this.tileHeight=h;
    }
	/**
	 * getTileHeight
	 * @return
	 */
    public function getTileHeight():Number{
        return this.tileHeight;
    }
	/**
	 * setTileExtension
	 * @param	ext
	 */
    public function setTileExtension(ext:String):Void{
        this.tileExtension= ext;
    }
	/**
	 * getTileExtension
	 * @return
	 */
    public function getTileExtension():String{
        return this.tileExtension;
    }
	/**
	 * setMap
	 * @param	map
	 */
    public function setMap(map:Object):Void{
        this.map=map;
    }
	/**
	 * getMap
	 * @return
	 */
    public function getMap():Object{
        return this.map;
    }
	/**
	 * setExtraParams
	 * @param	paramsObject
	 */
    public function setExtraParams(paramsObject:Object):Void{
        this.extraUrlParams=paramsObject;
    }
	/**
	 * getExtraParams
	 * @return
	 */
    public function getExtraParams():Object{
        return this.extraUrlParams;
    }
    /** Create a 'empty' tile: A tile without url and screen coordinates. (setTileScreen location not called)
     * @param xIndex the x index of this tile
     * @param yIndex the y index of this tile
     * @param zoomLevel the zoomlevel index (index to resolution) of this tile.
     * @return the Tile.
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#createTile
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
    
    /** Get the index number X of the tile on coordinate 'xCoord'.
     * @param xCoord The x coord.
     * @param zoomLevel the zoomLevel of the server.
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#getTileIndexX
    */
    public function getTileIndexX(xCoord:Number,zoomLevel:Number):Number{
        var tileRes=resolutions[zoomLevel];
        var tileSpanX:Number= tileRes*getTileWidth();
        var tileIndexX:Number = Math.floor((xCoord - serviceBBox.getMinX()) / (tileSpanX+epsilon));
        if (tileIndexX < 0) {
            tileIndexX=0;
        }
        var maxBboxX = Math.floor(( serviceBBox.getMaxX() - serviceBBox.getMinX() ) / (tileSpanX+epsilon));
        if (tileIndexX > maxBboxX) {
            tileIndexX = maxBboxX;
        }
        return tileIndexX;
    }
    /** Get the index number Y of the tile on coordinate 'yCoord' on zoomlevel 'zoomLevel'.
     * @param yCoord The y coord.
     * @param zoomLevel the zoomLevel of the server.
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#getTileIndexY
    */
    public function getTileIndexY(yCoord:Number,zoomLevel:Number):Number{
        var tileRes=resolutions[zoomLevel];
        var tileSpanY:Number= tileRes*getTileHeight();
        var tileIndexY:Number = Math.floor((yCoord - serviceBBox.getMinY()) / (tileSpanY+epsilon));
        if (tileIndexY < 0) {
            tileIndexY=0;
        }
        var maxBboxY = Math.floor(( serviceBBox.getMaxY() - serviceBBox.getMinY() ) / (tileSpanY+epsilon));
        if (tileIndexY > maxBboxY) {
            tileIndexY = maxBboxY;
        }
        return tileIndexY
    }
    
	
	/** Get the fixed zoomlevel of the given Resolution from this service: 'res'
     * @param res The resolution resolution
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#getZoomLevel
     */	
    public function getZoomLevel(res:Number, maxresfactor:Number, intervalfactor:Number):Number { 
		/*
		 * previous code open to various mis configurations, which made flamingo crash. The zoomlevel was incorrectly calculated when intervalfactor (or maxresfactor) was not/not properly configured. 
		 * Besides: resolutions are not bound to logic, so no constant buffer can be defined over all resolutions (if wanted, they can be calculated in relation to the next/previous resolution)
		*/
        //previous code.... To make use of the maxresfactor and the intervalfactor
		if (maxresfactor != undefined && intervalfactor != undefined) {
			var maxres = this.resolutions[0] * maxresfactor;
			var minres = maxres / intervalfactor;
			if (res >= maxres) {
				return 0;
			}
			maxres = this.resolutions[this.resolutions.length - 1] * maxresfactor;
			minres = maxres / intervalfactor;
			if (res <= minres) {
				return this.resolutions.length - 1;
			}
			for (var i:Number = 0; i < this.resolutions.length; i++) {
				maxres = this.resolutions[i] * maxresfactor;
				minres = maxres / intervalfactor;            
				if (res > minres && res <= maxres) {
					return i;
				}
			}
			//log.debug("found none, return last zoomlevel (smallest)");
			//return (this.resolutions.length-1);
		}
		
		//_global.flamingo.tracer("res = " + res + " maxresfactor = " + maxresfactor + " intervalfactor " + intervalfactor);
        for (var i:Number = 0; i < this.resolutions.length; i++) {
			if (res > this.resolutions[i] || ((res-this.resolutions[i] < 0.0000000001) && (res-this.resolutions[i] > -0.0000000001))){
				return i;
			}
        }
		log.debug("found none, return last zoomlevel (smallest)");
		return (this.resolutions.length-1);
    }
    
    
    /**
     * Calculates the given worldExtent to the current mapRect Object (.x,.y,.width and .height)
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
    /**
     * Set the tile screen locations (screenX,screenY,screenWidth and screenHeight)
	 * @see coremodel.service.tiling.factory.TileFactoryInterface#setTileScreenLocation
     */
    public function setTileScreenLocation(tile:Tile,mapExtent:Object):Tile{     
        var rect:Object=worldExtent2screenRect(tile.getBbox(),mapExtent);
        /*
        if (tile.getImageUrl().indexOf("anno") > 0) {
          _global.flamingo.tracer("imageUrl = " + tile.getImageUrl());
          _global.flamingo.tracer("res = " + map.getCurrentScale() + " r.x = " + rect.x + " r.y = " + rect.y  + " r.width = " + rect.width   + " r.height = " + rect.height);
        }
        */
        var roundMinX:Number = Math.round(rect.x);
        var roundMaxX:Number = Math.round(rect.x + rect.width);
        var roundWidth = roundMaxX - roundMinX;
        var roundMinY:Number = Math.round(rect.y);
        var roundMaxY:Number = Math.round(rect.y + rect.height);
        var roundHeight = roundMaxY - roundMinY;
        
        tile.setScreenX(roundMinX);
        tile.setScreenY(roundMinY);
        tile.setScreenWidth(roundWidth);
        tile.setScreenHeight(roundHeight);
        
        return tile;
    }
    
}