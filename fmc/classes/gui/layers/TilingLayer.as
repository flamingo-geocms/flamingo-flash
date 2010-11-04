/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners bv
 -----------------------------------------------------------------------------*/
/** @component TilingLayer
* A component shows a tiling service
* @file flamingo/fmc/classes/gui/layers/TilingLayer.as (sourcefile)
* @file flamingo/fmc/classes/gui/layers/AbstractLayer.as (sourcefile)
*/

/** @tag <fmc:TilingLayer>
* @class gui.layers.TilingLayer extends AbstractLayer
* @hierarchy childnode of Map component.
* @example
	<FLAMINGO>
		...
		<fmc:Map>
		....
			<fmc:TilingLayer id="metacarta" serviceurl="http://labs.metacarta.com/wms-c/Basic.py/1.0.0/basic/" resolutions="0.70312500000000000000,0.35156250000000000000,0.17578125000000000000,0.08789062500000000000,0.04394531250000000000,0.02197265625000000000,0.01098632812500000000,0.00549316406250000000,0.00274658203125000000,0.00137329101562500000,0.00068664550781250000,0.00034332275390625000,0.00017166137695312500,0.00008583068847656250,0.00004291534423828125,0.00002145767211914062,0.00001072883605957031,0.00000536441802978516,0.00000268220901489258,0.00000134110450744629" serviceenvelope="-180.000000,-90.000000,180.000000,90.000000">
			</fmc:TilingLayer>
		...
		<fmc:Map>
		...
	</FLAMINGO>
* @example
<fmc:TilingLayer id="publickb" serviceurl="http://public-wms.kaartenbalie.nl/wms/nederland" resolutions="1234.375,617.1875,308.59375,154.296875,77.1484375,38.57421875,19.287109375,9.6435546875,4.82177734375,2.410888671875,1.2054443359375,0.60272216796875,0.301361083984375,0.1506805419921875,0.07534027099609375,0.037670135498046875,0.018835067749023438,0.0094175338745117188,0.0047087669372558594,0.0023543834686279297" serviceenvelope="12000,304000,280000,620000" type="wmsc">
	<TilingParam name="Layers">basis,wegen,water</TilingParam>
	<TilingParam name="SERVICE">WMS</TilingParam>
	<TilingParam name="VERSION">1.1.1</TilingParam>
	<TilingParam name="REQUEST">GetMap</TilingParam>
	<TilingParam name="STYLES"> </TilingParam>
	<TilingParam name="SRS">EPSG:28992</TilingParam>
</fmc:TilingLayer>
* @attr id the id of the layer.
* @attr serviceUrl the url of the server that is serving tiles. 
* For example for a TMS server http://host/tileservice/1.0.0/tilemapname/ (include the version and tileMap Name)
* @attr resolutions the different resolutions with tiles that are served.
* @attr tilingType (optional,default: TMS) the type of tiling service. Possible values(for now): WMSc, TMS
* @attr serviceenvelope the envelope/bbox from the server. For example: "12000,304000,280000,620000"
* @attr extratiles (optional, default: 1) the number of extra tiles that are loaded when a user start panning (changing the extent)
* A circle of x tiles wil be loaded around the visible extent. This is not done when zooming! only when panning.
* A floating number is posible. For example: 0.5 when you want the next tile to be loaded when the user is halfway a previous tile.
* @attr minscale the minscale of visibility of this layer.
* @attr maxscale the maxscale of visibility of this layer.
**/
/** @tag <TilingParam>
* With this tag you can define extra parameters for the tilingFactory
For example this params are used by the WMSc tiling factory to complete the url. All params are added to the url.
Don't add Widht, Height and Bbox for WMSc tiling. Those are calculated.
For TMS the TilingParams are added after the calculated tile url for example http://host/tiling/0/1/1?name=value
* @hierarchy childnode of TilingLayer.
* @attr name is the name of the tilingparam.
* @example 
<fmc:TilingLayer ......>
.....
	<TilingParam name="Layers">basis,wegen,water</TilingParam>
	<TilingParam name="SERVICE">WMS</TilingParam>
	<TilingParam name="VERSION">1.1.1</TilingParam>
	<TilingParam name="REQUEST">GetMap</TilingParam>
	<TilingParam name="STYLES"> </TilingParam>
	<TilingParam name="SRS">EPSG:28992</TilingParam>
</fmc:TilingLayer>
**/
import core.AbstractComponent;
import gui.layers.*;
import coremodel.service.tiling.factory.TileFactoryInterface;
import coremodel.service.tiling.factory.TMSTileFactory;
import coremodel.service.tiling.factory.TileFactoryFinder;
import coremodel.service.tiling.factory.AbstractTileFactory;
import coremodel.service.tiling.Tile;
import coremodel.service.tiling.TileListener;
import geometrymodel.Envelope;
import tools.Logger;
import tools.Utils;


class gui.layers.TilingLayer extends AbstractLayer{	
	/*Statics*/
	private static var RESOLUTIONS_ATTRNAME:String="resolutions";
	private static var TILINGTYPE_ATTRNAME:String="type";
	private static var SERVICEENVELOPE_ATTRNAME:String="serviceenvelope";
	private static var EXTRATILES_ATTRNAME:String="extratiles";
	
	private static var TMS_TILINGTYPE:String="TMS";
	private static var WMSC_TILINGTYPE:String="WMSc";
	/*attributes*/
	private var resolutions:Array=null;
	private var tilingType:String=TMS_TILINGTYPE;
	private var tileFactory:TileFactoryInterface=null;
	private var serviceEnvelope:Envelope=null;
	private var extraTiles:Number=1;
	
	private var newTiles:Array=new Array();
	
	private var processId:Number=1;
	private var intervalId:Number=0;
	//the stage where all the tiles are shown on.
	private var tileStage:MovieClip=null;
	private	var tileLoader:MovieClipLoader=null;	
	private	var tileListener:TileListener=null;
	//the tile depth
	private var tileDepth:Number=null;
	private var layerDepth:Number=null;	
	//the extent of all the loadedTiles together
	private var loadedTileExtent:Object=null;
	//the zoomlevel of the last reload of tiles.
	private var currentZoomLevel:Number=null;
	//the mapRes of the last reload of tiles
	private var currentMapRes:Number=null;
	//the tile movieClips
	private var mcTiles:Array= new Array();	
	//tracker for keeping the tiles to process
	private var tilesToProcess:Number=null;
	//all the tilefactory options are stored in this object
	private var tileFactoryOptions:Object= new Object();
	//this object will find the correct tilefactory
	private var tileFactoryFinder:TileFactoryFinder;
	
	function TilingLayer(){
		this.log = new Logger("gui.layers.TilingLayer",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
		tileListener=new TileListener(this);
		tileLoader=new MovieClipLoader();		
		tileLoader.addListener(tileListener);
		tileFactoryFinder= new TileFactoryFinder(this);
	}
	/*Getters and setters for configurable params*/
	public function getResolutions():Array{
		return this.resolutions;
	}
	public function setResolutions(resolutions:Array):Void{
		this.resolutions=resolutions;
	}
	public function getTilingType():String{
		return this.tilingType;
	}										 
	public function setTilingType(tt:String):Void{
		if (tt.toLowerCase()==TMS_TILINGTYPE.toLowerCase()){
			this.tilingType=TMS_TILINGTYPE;			
		}else if (tt.toLowerCase()==WMSC_TILINGTYPE.toLowerCase()){
			this.tilingType=WMSC_TILINGTYPE;
		}else{				
			this.tilingType=TMS_TILINGTYPE;
			log.error("TilingType value not supported: "+tt+" the default: "+TMS_TILINGTYPE+" is used");
		}		
	}
	public function getExtraTiles():Number{
		return this.extraTiles;
	}
	public function setExtraTiles(extraTiles:Number):Void{
		if (!isNaN(extraTiles)){
			this.extraTiles=extraTiles;
		}
	}
	
	/**
	Initialize the tilinglayer.
	*/
	function initLayer():Void {    
		log.debug("initialize the layer");
		if (this.resolutions!=null){
			tileFactoryOptions[AbstractTileFactory.RESOLUTIONS_KEY]=this.resolutions;
		}
		if (this.serviceEnvelope!=null){
			tileFactoryOptions[AbstractTileFactory.BBOX_KEY]=this.serviceEnvelope;
		}
		tileFactoryOptions[AbstractTileFactory.TILINGTYPE_KEY]=this.tilingType;
		tileFactoryOptions[AbstractTileFactory.MAP_KEY]=this.map;
		tileFactoryOptions[AbstractTileFactory.SERVICEURL_KEY]=this.serviceUrl;
		//find the correct tileFactory.
		this.tileFactory=tileFactoryFinder.findFactory(tileFactoryOptions);

		this.layerDepth=map.getNextDepth();
		this.tileDepth=layerDepth;
		this.tileStage = this.createEmptyMovieClip("tileStage", layerDepth);
		//start with the mapExtent as the loadedTileExtent (later it will be made greater anyways)
		this.loadedTileExtent=map.getMapExtent();
		//do the first update.
		update();		
	}
	/**
	The setAttribute is called for al custom layer attributes.
	*/
	function setLayerAttribute(name:String, value:String):Boolean {
		var lowerName=name.toLowerCase();
		if (lowerName==RESOLUTIONS_ATTRNAME){
			var resArray:Array=value.split(",");
			if (resArray.length > 0){
				this.resolutions=new Array();
			}
			for (var i in resArray){
				this.resolutions[i]=Number(Utils.trim(resArray[i]));
			}
		}else if (lowerName==TILINGTYPE_ATTRNAME){
			setTilingType(value);
		}else if(lowerName==SERVICEENVELOPE_ATTRNAME){
			var coords= value.split(",");
			if (coords.length!=4){
				log.error("Attribute "+SERVICEENVELOPE_ATTRNAME+" has only "+coords.length+" coordinates. 4 are required");
			}else{
				serviceEnvelope= new Envelope(Number(coords[0]),Number(coords[1]),Number(coords[2]),Number(coords[3]));
			}
		}else if (lowerName==EXTRATILES_ATTRNAME){			
			setExtraTiles(Number(value));
		}else{
			return false;
		}
		return true;
	}
	/*Add a new composite*/
	function addComposite(nodeName:String, config:XMLNode):Void { 
		super.addComposite(nodeName,config);
		if (nodeName=="TilingParam"){
			if (config.firstChild.nodeValue==undefined){
				tileFactoryOptions[config.attributes.name]="";
			}else{
				tileFactoryOptions[config.attributes.name]=config.firstChild.nodeValue;			
			}			
		}
	}
	/*Event 'functions' from map object.*/
	/**
	the update function
	*/
	function update():Void{		
		log.debug("do update");
		//stop loading. (if still loading)
		//stopLoading();
		this.tilesToProcess=0;		
		//get the extent and calculate the scale (pixels per unit/ppu)
		var extent=map.getMapExtent();
		this.currentMapRes=map.getScale(extent);
		//get the zoomlevel for this resolution
		this.currentZoomLevel= tileFactory.getZoomLevel(currentMapRes);
		//new processId
		this.processId++;
		//create the tiles
		if (this.getVisible()){
			loadNewTiles(extent,currentZoomLevel);		
		}
		correctPosition(extent);
	}
	
	/*changeExtent function. called when the extent is changed (panning)*/
	function changeExtent(map:Object):Void{			
		log.debug("changeExtent");
		var ext=map.getMapExtent();
		correctPosition(map.getCurrentExtent());
		//if still in the same zoomlevel. (panning)
		var mapRes=map.getScale();
		if (this.getVisible()){
			//if in the same zoomlevel (panning)
			if(this.currentMapRes == mapRes|| (this.currentMapRes+0.00000000001 > mapRes && this.currentMapRes - 0.00000000001 < mapRes)){
				//check if we need to load a new tile. Load 1 tile more then needed ;)
				var tileWidth:Number= this.currentMapRes* this.tileFactory.getTileWidth()*this.extraTiles;
				var tileHeight:Number= this.currentMapRes* this.tileFactory.getTileHeight()*this.extraTiles;
				ext.minx-=tileWidth;
				ext.miny-=tileHeight;
				ext.maxx+=tileWidth;
				ext.maxy+=tileHeight;
				if (ext.minx<this.loadedTileExtent.minx ||
						ext.miny<this.loadedTileExtent.miny ||
						ext.maxx>this.loadedTileExtent.maxx ||
						ext.maxy>this.loadedTileExtent.maxy){
					loadNewTiles(ext,this.currentZoomLevel);							
				}
			}	
		}
	}
	function identify(identifyextent:Object):Void{
		//log.debug("identify called");
	}
	function cancelIdentify():Void{
		//log.debug("cancelIdentify called");
	}
	function startMaptip(x:Number, y:Number):Void{
		//log.debug("startMaptip called");
	}
	function stopMaptip():Void{
		//log.debug("stopMaptip called");
	}
	function doHide():Void{		
		log.debug("doHide called");
		this.visible=false;
	}
	function doShow():Void{		
		log.debug("doShow called");
		this.visible=true;
	}
	
	function loadNewTiles(extent:Object,zoomLevel:Number){		
		this.newTiles = createNewTiles(extent,zoomLevel);
		log.debug("number of new tiles created: "+newTiles.length);
		//if new tiles needs to be loaded start the interval for loading tiles.
		if (this.newTiles.length > 0){
			//set loading interval. (movies get drawn after the function is processed).
			this.tilesToProcess+=newTiles.length;
			this.intervalId= setInterval(this,"loadTiles",1);		
		}
	}
	/*Create the new tile objects. Tiles that already exist won't be created again.*/
	private function createNewTiles(extent:Object,zoomLevel:Number):Array{		
		var minXIndex:Number=tileFactory.getTileIndexX(extent.minx,zoomLevel);
		var minYIndex:Number=tileFactory.getTileIndexY(extent.miny,zoomLevel);
		var maxXIndex:Number=tileFactory.getTileIndexX(extent.maxx,zoomLevel);
		var maxYIndex:Number=tileFactory.getTileIndexY(extent.maxy,zoomLevel);
		
		if (isNaN(minXIndex) || isNaN(minYIndex) || isNaN(maxXIndex) || isNaN(maxYIndex)){
			log.error("one of the tileindexes is not a number: \n MinxIndex: "+minXIndex+"\n MinYIndex: "+minYIndex+"\n MaxXIndex: "+maxXIndex+"\n MaxYIndex: "+maxYIndex);
			return new Array();
		}
		log.debug("create tiles with zoomlevel "+zoomLevel+" from: "+minXIndex+" "+minYIndex+" to "+maxXIndex+" "+maxYIndex);
		var tiles:Array = new Array();		
		for (var xIndex=minXIndex; xIndex <= maxXIndex; xIndex++){
			for (var yIndex=minYIndex; yIndex <= maxYIndex; yIndex++){
				var movieTile:MovieClip=getMovieTile(xIndex,yIndex,zoomLevel);
				if (movieTile==null){				
					var newTile:Tile= Tile(tileFactory.createTile(xIndex,yIndex,zoomLevel));
					tiles.push(newTile);
					//update the loadedTileExtent.
					if (newTile.getBbox().getMinX() < this.loadedTileExtent.minx){
						this.loadedTileExtent.minx=newTile.getBbox().getMinX();
					}
					if (newTile.getBbox().getMinY() < this.loadedTileExtent.miny){
						this.loadedTileExtent.miny=newTile.getBbox().getMinY();
					}
					if (newTile.getBbox().getMaxX() > this.loadedTileExtent.maxx){
						this.loadedTileExtent.maxx=newTile.getBbox().getMaxX();
					}
					if (newTile.getBbox().getMaxY() > this.loadedTileExtent.maxy){
						this.loadedTileExtent.maxy=newTile.getBbox().getMaxY();
					}
				}else{
					//make sure this movie clip stays in this process.
					movieTile.processId=this.processId;
					//TODO: check for resize! If needed, do a resize.
				}
				
			}
		}		
		return tiles;
	}
	
	/*Get a already existing movieTile (a MovieClip from a tile)*/
	public function	getMovieTile(xIndex:Number,yIndex:Number,zoomLevel:Number):MovieClip{
		if (this.mcTiles){
			for (var m in this.mcTiles){				
				var tile:Tile= Tile(mcTiles[m].tile);
				if (tile.getZoomLevel()==zoomLevel && tile.getXIndex()==xIndex && tile.getYIndex()==yIndex){
					return mcTiles[m];
				}
			}
		}
		return null;
	}
	/*Remove all tiles and clear the tilestage.*/
	public function clearAllTiles():Void{
		log.debug("clearAllTiles is called");
		this.newTiles= new Array();		
		for (var m in this.tileStage){
			this.tileStage[m].removeMovieClip();			
		}
		this.tileStage.clear();
	}
	/*Removes all tiles accept the tiles with process Id: processId*/
	public function removeAllButProcessId(processId:Number){
		var newLoadedTileExtent:Object = new Object();
		log.debug("Remove all but processId: "+processId);
		var newTileArray:Array=new Array();
		for (var m in this.mcTiles){
			if (mcTiles[m].processId!=processId){
				mcTiles[m].removeMovieClip();
			}else{
				newTileArray.push(mcTiles[m]);				
				var tile=Tile(mcTiles[m].tile);
				if (tile.getBbox().getMinX() < newLoadedTileExtent.minx || newLoadedTileExtent.minx==undefined){
					newLoadedTileExtent.minx=tile.getBbox().getMinX();
				}
				if (tile.getBbox().getMiny() < newLoadedTileExtent.miny || newLoadedTileExtent.miny==undefined){
					newLoadedTileExtent.miny=tile.getBbox().getMinY();
				}
				if (tile.getBbox().getMaxX() > newLoadedTileExtent.maxx || newLoadedTileExtent.maxx==undefined){
					newLoadedTileExtent.maxx=tile.getBbox().getMaxX();
				}
				if (tile.getBbox().getMaxY() > newLoadedTileExtent.maxy || newLoadedTileExtent.maxy==undefined){
					newLoadedTileExtent.maxy=tile.getBbox().getMaxY();
				}
			}
		}
		this.loadedTileExtent=newLoadedTileExtent;
		mcTiles=newTileArray;
	}
	/**
    *Function that correct the extents of the loaded tiles
	* @param extent a object with .minx , .miny etc. of the current map
	*/	
	function correctPosition(extent:Object):Void{		
		log.debug("correctPosition of the tiles");
		for (var m in this.mcTiles){
			if (mcTiles[m].finishedLoading){
				var tile:Tile= Tile(mcTiles[m].tile);
				tile=tileFactory.setTileScreenLocation(tile,extent);
				mcTiles[m].holder._x=tile.getScreenX();
				mcTiles[m].holder._y=tile.getScreenY();
				mcTiles[m].holder._width=tile.getScreenWidth();
				mcTiles[m].holder._height=tile.getScreenHeight();				
			}
		}
	}
	/*This function loads the image and creates the movieclip*/
	private function loadTiles(){
		if (newTiles.length==0){			
			clearInterval(this.intervalId);
			return;
		}
		var tile:Tile=Tile(this.newTiles.pop());					
		var mcTile= this.tileStage.createEmptyMovieClip(tile.getTileId()+"("+this.processId+")",this.tileDepth++);
		mcTile.tile=tile;
		mcTile.processId=this.processId;
		mcTile.finishedLoading=false;
		var holder=mcTile.createEmptyMovieClip("holder",0);
		mcTiles.push(mcTile);
		this.tileLoader.loadClip(tile.getImageUrl(),holder);		
	}
	/*Stops the loading of the tiles.*/
	private function stopLoading(){
		log.debug("StopLoading");
		//clear the current interval:
		clearInterval(this.intervalId);
		//reconstruct the MovieClipLoader, forces to stop loading the clips
		this.tileLoader=new MovieClipLoader();		
		this.tileLoader.addListener(this.tileListener);
	}
	/*called when a tile is completly loaded*/
	public function finishedLoadingTile(tileMc:MovieClip,error:String){		
		var tile=Tile(tileMc._parent.tile);
		tile=tileFactory.setTileScreenLocation(tile,map.getCurrentExtent());
		tileMc._x=tile.getScreenX();
		tileMc._y=tile.getScreenY();
		tileMc._width=tile.getScreenWidth();
		tileMc._height=tile.getScreenHeight();
		this.tilesToProcess--;
		if (error!=undefined){
			log.error("Error loading tile: "+error);
		}
		//if there are no tiles to process, clear al the old tiles.
		if (this.tilesToProcess==0){
			_global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
			removeAllButProcessId(this.processId);
		}			
	}
		
	/*DEBUG functions:*/
	
	/*Draw a rectangle on the screen where the tile needs to be.*/
	private function drawTileRect(tile:Tile){
		var rect:Object= new Object();
		rect.x=tile.getScreenX();
		rect.y=tile.getScreenY();
		rect.width=tile.getScreenWidth();
		rect.height=tile.getScreenHeight();
		drawRect(rect);
	}
	/*Draws a extent on the screen*/
	private function drawExtentRect(ext:Object){
		var rect:Object=map.extent2Rect(ext)
		drawRect(rect);
	}
	/*Draw this rectangle (screen coordinates)*/
	private function drawRect(rect:Object){
		var lineWidth:Number=5;
		tileStage.lineStyle(lineWidth, 0x000000, 100);
       // tileStage.beginFill(0xFF0000,0);
        tileStage.moveTo(rect.x, rect.y);
        tileStage.lineTo(rect.x+rect.width-lineWidth, rect.y);
        tileStage.lineTo(rect.x+rect.width-lineWidth, rect.y+rect.height-lineWidth);
        tileStage.lineTo(rect.x, rect.y+rect.height-lineWidth);		
//        tileStage.endFill()
	}
	/*Log the extent:Object*/
	private function logExt(ext:Object){
		log.debug("minx: "+ext.minx+" miny "+ext.miny+" maxx "+ext.maxx+" maxy "+ext.maxy);
	}
}