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
/** @component TilingLayer
* A component that shows a tiling service
* @file flamingo/fmc/classes/gui/layers/TilingLayer.as (sourcefile)
* @file flamingo/fmc/classes/gui/layers/AbstractLayer.as (sourcefile)
* @file flamingo/fmc/classes/core/AbstractConfigurable.as
* @file flamingo/fmc/classes/core/AbstractPositionable.as
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
* @attr tilingType (optional,default: TMS) the type of tiling service. Possible values(for now): WMSc, TMS, OSM, ArcGisRest
* @attr serviceenvelope the envelope/bbox from the server. For example: "12000,304000,280000,620000"
* @attr extratiles (optional, default: 1) the number of extra tiles that are loaded when a user start panning (changing the extent)
* A circle of x tiles wil be loaded around the visible extent. This is not done when zooming! only when panning.
* A floating number is posible. For example: 0.5 when you want the next tile to be loaded when the user is halfway a previous tile.
* @attr minscale the minscale of visibility of this layer.
* @attr maxscale the maxscale of visibility of this layer.
* @attr showmaptips: if the maptips should be retrieved, only applicable with WMSc
* @attr maxresfactor: threshold to determine zoomlevel of tiles for given resolution, default 1.4142135623=sqrt(2)
* @attr intervalfactor: is resolution[level] / resolution[level+1], default 2 (maxscalefactor = intervalfactor / maxresfactor)
* @attr extension: the extension of the tiles.
* @attr tileheight: the height of the tiles in pixels (default 256)
* @attr tilewidth: the width of the tiles in pixels (default 256)
* @attr visible: (optional, default true) sets the layer visible (true) invisible (false)
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
import gui.Map;

import coremodel.service.tiling.connector.WMScConnector;
/**
 * A component that shows a tiling service
 * @author Roy Braam
 * @author Herman Assink
 * @author Meine Toonen 
 */
class gui.layers.TilingLayer extends AbstractLayer{ 
    /*Statics*/
    private static var RESOLUTIONS_ATTRNAME:String="resolutions";
    private static var TILINGTYPE_ATTRNAME:String="type";
    private static var SERVICEENVELOPE_ATTRNAME:String="serviceenvelope";
    private static var EXTRATILES_ATTRNAME:String="extratiles";
    private static var TILE_HEIGHT_ATTRNAME:String="tileheight";
    private static var TILE_WIDTH_ATTRNAME:String="tilewidth";
    private static var TILE_EXTENSION_ATTRNAME:String="extension";
    
    public static var TMS_TILINGTYPE:String="TMS";
    public static var WMSC_TILINGTYPE:String="WMSc";
	public static var ARCGISREST_TILINGTYPE:String="ArcGisRest";
	public static var OSM_TILINGTYPE:String="OSM";

    private static var SHOWMAPTIPS_ATTRNAME:String="showmaptips";
    private static var MAXRESFACTOR_ATTRNAME:String="maxresfactor";
    private static var INTERVALFACTOR_ATTRNAME:String="intervalfactor";
    
    
    /*attributes*/
    private var resolutions:Array=null;
    private var tilingType:String=TMS_TILINGTYPE;
    private var tileFactory:TileFactoryInterface=null;
    private var serviceEnvelope:Envelope=null;
    private var serviceExtentStr:String=null;
    private var serviceExtent:Object=null;
    private var extraTiles:Number=1;
    
    private var newTiles:Array= null;
    
    //private var processId:Number=1;
    private var intervalId:Number=0;
    //the stage where all the tiles are shown on.
    private var tileStage:MovieClip=null;
    private var tileLoader:MovieClipLoader=null;    
    private var tileListener:TileListener=null;
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
    private var mcTiles:Array = null; 
    //tracker for keeping the tiles to process
    private var tilesToProcess:Number=null;
    //all the tilefactory options are stored in this object
    private var tileFactoryOptions:Object= null;
    //this object will find the correct tilefactory
    private var tileFactoryFinder:TileFactoryFinder;
    
    //tileproperties
    private var tileHeight:Number = 256;
    private var tileWidth:Number= 256;
    private var tileExtension:String = "";
    
    
    var identifyextent:Object;


    private var showmaptip:Boolean;
    private var showmaptips:Boolean;
    private var canmaptip:Boolean = false;
    private var maptipEnabled:Boolean = true;
    private var maptipextent:Object = null;
    
    private var maxresfactor:Number;
    private var intervalfactor:Number;
    
    private var loadStartTime:Date = null;
   /**
	 * Constructor for creating this layer
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @param 	map reference to the map where this layer is placed
	 * @see 	gui.layers.AbstractLayer
	 */
    public function TilingLayer(id:String, container:MovieClip, map:Map) {		
		super(id, container, map);
        this.log = new Logger("gui.layers.TilingLayer",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        tileListener=new TileListener(this);
        tileLoader=new MovieClipLoader();       
        tileLoader.addListener(tileListener);
        tileFactoryFinder= new TileFactoryFinder(this);
        tileFactoryOptions = new Object();
        mcTiles = new Array();
        newTiles =new Array();
        tilesToProcess = 0;
        intervalId = 0;
		init();

    }
    /*Getters and setters for configurable params*/
	/**
	 * getResolutions
	 * @return
	 */
    public function getResolutions():Array{
        return this.resolutions;
    }
	/**
	 * setResolutions
	 * @param	resolutions
	 */
    public function setResolutions(resolutions:Array):Void{
        this.resolutions=resolutions;
    }
	/**
	 * getTilingType
	 * @return
	 */
    public function getTilingType():String{
        return this.tilingType;
    } 
	/**
	 * setTilingType
	 * @param	tt
	 */
    public function setTilingType(tt:String):Void{
        if (tt.toLowerCase()==TMS_TILINGTYPE.toLowerCase()){
            this.tilingType=TMS_TILINGTYPE;         
        }else if (tt.toLowerCase()==WMSC_TILINGTYPE.toLowerCase()){
            this.tilingType=WMSC_TILINGTYPE;
		}else if (tt.toLowerCase()==ARCGISREST_TILINGTYPE.toLowerCase()){
			this.tilingType=ARCGISREST_TILINGTYPE;
        }else if (tt.toLowerCase()==OSM_TILINGTYPE.toLowerCase()){
			this.tilingType=OSM_TILINGTYPE;
		}else{              
            this.tilingType=TMS_TILINGTYPE;
            log.error("TilingType value not supported: "+tt+" the default: "+TMS_TILINGTYPE+" is used");
        }       
    }
	/**
	 * getExtraTiles
	 * @return
	 */
    public function getExtraTiles():Number{
        return this.extraTiles;
    }
	/**
	 * setExtraTiles
	 * @param	extraTiles
	 */
    public function setExtraTiles(extraTiles:Number):Void{
        if (!isNaN(extraTiles)){
            this.extraTiles=extraTiles;
        }
    }
    /**
     * getTileHeight
     * @return
     */
	public function getTileHeight():Number{
		return this.tileHeight;
	}
	/**
	 * setTileHeight
	 * @param	tileHeight
	 */
	public function setTileHeight(tileHeight:Number):Void{
		this.tileHeight=tileHeight;
	}
	/**
	 * getTileWidth
	 * @return
	 */
	public function getTileWidth():Number{
		return this.tileWidth;
	}
	/**
	 * setTileWidth
	 * @param	tileWidth
	 */
	public function setTileWidth(tileWidth:Number):Void{
		this.tileWidth=tileWidth;
	}
	/**
	 * setLayers
	 * @param	layers
	 */
    public function setLayers(layers:String):Void {
    	
        var extraParams:Object = tileFactory.getExtraParams();
        
        // Chech whether the layers array has changed. No changes are made
        // if the layers list doesn't change:
        var modified: Boolean = false;
        if (extraParams["LAYERS"]) {
        	var oldLayers: Array = String (extraParams["LAYERS"]).split (','),
                newLayers: Array = String (layers).split(",");
                
            oldLayers.sort ();
            newLayers.sort ();
            if (oldLayers.length != newLayers.length) {
            	modified = true;
            } else {
            	for (var i: Number = 0; i < oldLayers.length; ++ i) {
            		if (oldLayers[i] != newLayers[i]) {
            			modified = true;
            		}
            	}
            }
        } else {
            // TODO: Deze hack moet er uit, ergens wordt de null value getypecast naar een string.
        	modified = !!layers && layers != 'null';
        }
        if (!modified) {
        	return;
        }
        
        extraParams["LAYERS"]=layers;
        tileFactory.setExtraParams(extraParams);
        clearAllTiles();
    }
    /**
     * getLayers
     * @return
     */
    public function getLayers(): String {
    	var params: Object = tileFactory.getExtraParams ();
    	if (params["LAYERS"]) {
    		return params["LAYERS"];
    	}
    	return "";
    }
    /**
     * getLayersString
     * @return
     */
    public function getLayersString (): String {
    	return getLayers ();
    }
    /**
     * getProperty
     * @param	propertyName
     * @return
     */
    public function getProperty (propertyName: String): Object {
    	return _global.flamingo.getProperty (_global.flamingo.getId (this), propertyName);
    }
    
   /**
    * ReInitialize the AbstractLayer.
	* @see AbstractLayer#init
    */
    function reinit():Void {    
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
        this.tileFactory = tileFactoryFinder.findFactory(tileFactoryOptions);
        this.tileFactory.setTileHeight(this.tileHeight);
        this.tileFactory.setTileWidth(this.tileWidth);
        this.tileFactory.setTileExtension(this.tileExtension);
        this.layerDepth = this.container.getNextHighestDepth();// map.getNextDepth() + 100;
        this.tileDepth=layerDepth;
        this.tileStage = this.container.createEmptyMovieClip("tileStage", layerDepth);
        //start with the mapExtent as the loadedTileExtent (later it will be made greater anyways)
        this.loadedTileExtent=map.getMapExtent();
        //do the first update.
        update();       
    }
	/**
	 * The setAttribute is called for al custom layer attributes.
	 * @param	name
	 * @param	value
	 * @return
	 */
    function setAttribute(name:String, value:String):Boolean {
		super.setAttribute(name, value);
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
                serviceEnvelope = new Envelope(Number(coords[0]),Number(coords[1]),Number(coords[2]),Number(coords[3]));
                serviceExtentStr = value;
            }
        }else if (lowerName==EXTRATILES_ATTRNAME){          
            setExtraTiles(Number(value));
        } else if (lowerName==TILE_HEIGHT_ATTRNAME){            
            this.tileHeight = Number(value);
        } else if (lowerName==TILE_WIDTH_ATTRNAME){         
            this.tileWidth = Number(value); 
        } else if (lowerName == TILE_EXTENSION_ATTRNAME) {
			if (value.indexOf(".")!=0 && value.indexOf("?")!=0){
				this.tileExtension = ("." + value);     
			}else {
				this.tileExtension = (value);
			}
        } else if(lowerName == SHOWMAPTIPS_ATTRNAME) {
            this.canmaptip = true;
            if (value.toLowerCase() == "true") {
                showmaptips = true;
            } else {
                showmaptips = false;
            }
        } else if(lowerName == MAXRESFACTOR_ATTRNAME) {
            this.maxresfactor = Number(value);
        } else if(lowerName == INTERVALFACTOR_ATTRNAME) {
            this.intervalfactor = Number(value);
        }else{
            return false;
        }
        return true;
    }
    /**
     * Adds a new composite
     * @param	nodeName the name of the node of the composite
     * @param	config the configuration for the composites
	 * @see gui.layer.AbstractLayer#addComposite
     */
    public function addComposite(nodeName:String, config:XMLNode):Void { 
        //super.addComposite(nodeName,config);
        if (nodeName=="TilingParam"){
            if (config.firstChild.nodeValue==undefined){
                tileFactoryOptions[(config.attributes.name).toUpperCase()]="";
            }else{
                tileFactoryOptions[(config.attributes.name).toUpperCase()]=config.firstChild.nodeValue;         
            }           
        }
    }
    /**
    * the update function
	* @param map the map
    */
    function update(map):Void {		
        if (tileFactory == undefined) { //not initialzed yet
            return;
        }
        if (map == undefined) {
          map = this.map
        }
        super.update(map);   

        if (isWithinScaleRange()) {
			this._visible = this.visible;
        } else {
			this._visible = false;
            _global.flamingo.raiseEvent(this, "onUpdate", this, 1);
            _global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
        }

        //_global.flamingo.tracer("update.layer = " + this._name + " _visible = " + this._visible + " getVisible = " + this.getVisible() + " mapRes = " + map.getScale(this.map.getMapExtent()));
		if (!this._visible) {
			clearAllTiles();
            return;
        }

        var extent=this.map.getMapExtent();

        var mapResUpd = map.getScale(extent);
        /*
        if (mapResUpd != this.currentMapRes) {
            clearAllTiles();
        }
        */
        this.currentMapRes=mapResUpd
        
        //get the zoomlevel for this resolution
        //_global.flamingo.tracer("update.layer = " + this._name + " currentMapRes = " + currentMapRes);
        this.currentZoomLevel = tileFactory.getZoomLevel(currentMapRes, this.maxresfactor, this.intervalfactor);


        //new processId
        //this.processId++;
        //create the tiles
        //_global.flamingo.tracer("extent = " + extent + " getVisible = " + this.getVisible() + " currentZoomLevel = " + currentZoomLevel);
        if (this.getVisible()){
            loadNewTiles(extent,currentZoomLevel);      
        }
        correctPosition(extent);
    }
    
    /**
     * changeExtent function. called when the extent is changed (panning)
	 * @param map the map on which the extent must be changed
     */
    function changeExtent(map:Object):Void{         
        log.debug("changeExtent.layer = " + this);

        if(isWithinScaleRange()){
            this._visible = this.visible;
        } else {
            this._visible = false;
            _global.flamingo.raiseEvent(this, "onUpdate", this, 1);
            _global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
        }

        log.debug("changeExtent.layer = " + this + " _visible = " + _visible + " mapRes = " + map.getScale());

        if(!this._visible){
            clearAllTiles();
            return;
        }


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
    /**
     * Do a identify
     * @param	extent the extent of the identify
     */
    function identify(extent:Object):Void{
        log.debug("identify, tilingType = " + tilingType + ", visible = " + getVisible() + ", TilingLayer = " + this);
        if(tilingType!=WMSC_TILINGTYPE){
            return;
        }
        if (getVisible() == false ) {
            return;
        }
        
        var starttime:Date = new Date();
        this.identifyextent = extent;
        var lConn:Object = new Object();
        var wmscConnector = new WMScConnector();
        var thisObj:Object = this;;

        lConn.onResponse = function(connector:WMScConnector) {
            _global.flamingo.raiseEvent(thisObj, "onResponse", thisObj, "identify", connector);
        };
        lConn.onRequest = function(connector:WMScConnector) {
            _global.flamingo.raiseEvent(thisObj, "onRequest", thisObj, "identify", connector);
        };
        lConn.onError = function(error:String, obj:Object, requestid:String) {
            _global.flamingo.raiseEvent(thisObj, "onError", thisObj, "identify", error);
        };
        lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
            if (thisObj.map.isEqualExtent(thisObj.identifyextent, obj)) {
				var newDate:Date = new Date();
                var identifytime = (newDate.getTime()-starttime.getTime())/1000;
                for (var layer in features) {
                    var realname = thisObj.aka[layer];
                    if (realname != undefined) {
                        features[realname] = features[layer];
                        delete features[layer];
                    }
                }
                _global.flamingo.raiseEvent(thisObj, "onIdentifyData", thisObj, features, obj);
                _global.flamingo.raiseEvent(thisObj, "onIdentifyComplete", thisObj, identifytime);
            }
        };
        wmscConnector.addListener(lConn);

        var args:Object = new Object();
        args.WIDTH = Math.ceil(map.__width);
        args.HEIGHT = Math.ceil(map.__height);
        var ext:Object = map.getMapExtent();
        args.BBOX = ext.minx+","+ext.miny+","+ext.maxx+","+ext.maxy;
        var extraParams:Object = tileFactory.getExtraParams();
        for (var paramName in extraParams){
            args[paramName] = extraParams[paramName];
        }       
        var rect = map.extent2Rect(identifyextent);
        args.X = String(Math.round(rect.x+(rect.width/2)));
        args.Y = String(Math.round(rect.y+(rect.height/2)));
        //args.REQUESTID = roo.tools.RequestIdGenerator.getRequestId(args.BBOX);
        _global.flamingo.raiseEvent(thisObj, "onIdentify", thisObj, identifyextent);
        wmscConnector.getFeatureInfo(this.serviceUrl, args, this.map.copyExtent(identifyextent));

        //log.debug("identify called");                                                         
    }
    /**
     * cancelIdentify
     */
    function cancelIdentify():Void{
        this.identifyextent = undefined;
        //log.debug("cancelIdentify called");
    }
	/**
	 * enableMaptip
	 * @param	onOff
	 */
    function enableMaptip(onOff:Boolean) {
      this.maptipEnabled = onOff;
    }
	/**
	 * stopMaptip
	 */
    function stopMaptip() {
        this.showmaptip = false;
        this.maptipextent = undefined;
    }
    /**
     * Start the maptip
     * @param	x
     * @param	y
     */
    function startMaptip(x:Number, y:Number) {
        if(tilingType!=WMSC_TILINGTYPE){
            return;
        }
        if (!this.canmaptip || !maptipEnabled) {
            return;
        }
        
        if (!getVisible()) {
            return;
        }

        var r:Object = new Object();
        r.x = x;
        r.y = y;
        r.width = 0;
        r.height = 0;
        this.maptipextent = this.map.rect2Extent(r);
        if (this.serviceExtent == undefined && this.serviceExtentStr != undefined) {
            this.serviceExtent = this.map.string2Extent(this.serviceExtentStr);
        }
        if (this.serviceExtent != undefined) {
            if (!this.map.isHit(this.serviceExtent, this.maptipextent)) {
                return;
            }
        }
        this.showmaptip = true;
        var lConn:Object = new Object();
        var wmscConnector = new WMScConnector();
        var thisObj:Object = this;;
        lConn.onGetFeatureInfo = function(features:Object, obj:Object, requestid:String) {
            //_global.flamingo.tracer(" thisObj = " + thisObj + " showmaptip = " + thisObj.showmaptip + " features = " + features );
            _global.flamingo.raiseEvent(thisObj, "onMaptipFeatures", thisObj, features);
        };
        wmscConnector.addListener(lConn);

        var args:Object = new Object();
        args.WIDTH = Math.ceil(map.__width);
        args.HEIGHT = Math.ceil(map.__height);
        var ext:Object = map.getMapExtent();
        args.BBOX = ext.minx+","+ext.miny+","+ext.maxx+","+ext.maxy;
        for (var a in tileFactoryOptions){
            if(a!=AbstractTileFactory.BBOX_KEY){
                log.debug("a = " + a + " tileFactoryOptions[a] = " + tileFactoryOptions[a]);
                args[a] = tileFactoryOptions[a];
            }
        }
        var rect = map.extent2Rect(maptipextent);
        args.X = String(Math.round(rect.x+(rect.width/2)));
        args.Y = String(Math.round(rect.y+(rect.height/2)));
        //args.REQUESTID = roo.tools.RequestIdGenerator.getRequestId(args.BBOX);

        wmscConnector.getFeatureInfo(this.serviceUrl, args, this.map.copyExtent(maptipextent));
    }
	/**
	 * doHide
	 */
    function doHide():Void{ 
        log.debug("doHide called");
        this.visible=false;
        _global.flamingo.raiseEvent(this, "onHide", this);
    }
	/**
	 * doShow
	 */
    function doShow():Void{     
        log.debug("doShow called");
        this.visible=true;
    }
    
    private function registerProgressMonitor (): Void {
    	
    	// Bail out if a progress monitor is already running:
    	if (this.intervalId > 0) {
    		return;
    	}
    	
    	this.intervalId = setInterval (this, "checkLoadProgress");
    }
    
    private function clearProgressMonitor (): Void {
    	if (this.intervalId == 0) {
    		return;
    	}
    	
    	clearInterval (this.intervalId);
    	this.intervalId = 0;
    }
    /**
     * Load the new tiles for the extent and zoomlevel
     * @param	extent the extent for which the tiles must be loaded
     * @param	zoomLevel the zoomlevel
     */
    function loadNewTiles(extent:Object,zoomLevel:Number){  
        this.newTiles = createNewTiles(extent,zoomLevel);
        log.debug("number of new tiles created: "+newTiles.length);
        //_global.flamingo.tracer("layer = " + this + " newTiles.length = " + newTiles.length);
        //if new tiles needs to be loaded start the interval for loading tiles.
        if (this.newTiles.length > 0){

            registerProgressMonitor ();
            this.loadStartTime = new Date();

            if (this.tilesToProcess == 0) {
                _global.flamingo.raiseEvent(this, "onUpdate", this, 1);
            }
            //_global.flamingo.tracer("layer = " + this._name + " tilesToProcess = " + tilesToProcess + " newTiles.length " + newTiles.length);
            this.tilesToProcess += newTiles.length;
            var tilesToLoad:Number = newTiles.length;
            for (var i:Number=0; i < tilesToLoad; i++) {
                loadTiles();
            }
        } else {
            removeAllButZoomLevel(this.currentZoomLevel);
        }
    }
    /*
     * Create the new tile objects. Tiles that already exist won't be created again.
     * @param	viewExtent the tiles that hit this extent are loaded.
     * @param	zoomLevel the zoomlevel
     * @return 	a array of tiles.
     */
	private function createNewTiles(viewExtent:Object,zoomLevel:Number):Array{		
		log.debug("CreateTiles with extent: "+viewExtent.minx +","+ viewExtent.miny +","+ viewExtent.maxx +","+ viewExtent.maxy);
		var extent=copyExtent(viewExtent);
		//make sure the extent is in the serviceEnvelope.
		if (serviceEnvelope!=null){
			if (extent.minx < serviceEnvelope.getMinX()){
				extent.minx=serviceEnvelope.getMinX();
			}
			if (extent.maxx > serviceEnvelope.getMaxX()){
				extent.maxx = serviceEnvelope.getMaxX();
			}
			if (extent.miny < serviceEnvelope.getMinY()){
				extent.miny=serviceEnvelope.getMinY();
			}
			if (extent.maxy > serviceEnvelope.getMaxY()){
				extent.maxy = serviceEnvelope.getMaxY();
			}
			log.debug("Correct extent with serviceEnvelope: "+extent.minx +","+ extent.miny +","+ extent.maxx +","+ extent.maxy);
		}
        var minXIndex:Number=tileFactory.getTileIndexX(extent.minx,zoomLevel);
        var minYIndex:Number=tileFactory.getTileIndexY(extent.miny,zoomLevel);
        var maxXIndex:Number=tileFactory.getTileIndexX(extent.maxx,zoomLevel);
        var maxYIndex:Number=tileFactory.getTileIndexY(extent.maxy,zoomLevel);
        
        if (isNaN(minXIndex) || isNaN(minYIndex) || isNaN(maxXIndex) || isNaN(maxYIndex)){
            log.error("one of the tileindexes is not a number: \n MinxIndex: "+minXIndex+"\n MinYIndex: "+minYIndex+"\n MaxXIndex: "+maxXIndex+"\n MaxYIndex: "+maxYIndex);
            return new Array();
        }
		//Make sure max is bigger then min
		if (minXIndex > maxXIndex){
			var temp=minXIndex;
			minXIndex=maxXIndex;
			maxXIndex=temp;
		}
		if (minYIndex > maxYIndex){
			var temp= minYIndex;
			minYIndex=maxYIndex;
			maxYIndex=temp
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
                }
                
            }
        }       
        return tiles;
    }
    
    /**
     * Get a already existing movieTile (a MovieClip from a tile)
     * @param	xIndex the x index of the tile
     * @param	yIndex the y index of the tile
     * @param	zoomLevel the zoomlevel for the tile
     * @return	the tile
     */
    public function getMovieTile(xIndex:Number,yIndex:Number,zoomLevel:Number):MovieClip{
        if (this.mcTiles){
            for (var m in this.mcTiles){                
                var tile:Tile= Tile(mcTiles[m].tile);
                if (tile.getZoomLevel()==zoomLevel && tile.getXIndex()==xIndex && tile.getYIndex()==yIndex){
                    //log.debug("MovieTile exists, zoomLevel = " + zoomLevel + " xIndex = " + xIndex + " yIndex = " + yIndex);
                    return mcTiles[m];
                }
            }
        }
        return null;
    }
    
     /**
      * Get a already existing movieTiles (an Array of MovieClips from a tile)
      */
     public function getTilesArray():Array{
     	var tiles:Array = new Array();
     	for (var m in this.tileStage){
     		var tile:Tile= Tile(this.tileStage[m].tile); 
     		if(tile.getImageUrl()!=null){
     			var tileObj:Object = new Object();
	     		tileObj.url = tile.getImageUrl();
	     		tileObj.screenX = tile.getScreenX();
	     		tileObj.screenY = tile.getScreenY();
	     		tileObj.screenWidth = tile.getScreenWidth();
	     		tileObj.screenHeight = tile.getScreenHeight();
     			tiles.push(tileObj);
     		}
     	}
     	return tiles;
     	
     }
     
	/**
	 * Remove all tiles and clear the tilestage
	 */
    public function clearAllTiles():Void{
        log.debug("clearAllTiles is called");
        this.newTiles= new Array();     
        for (var m in this.tileStage){
            this.tileStage[m].removeMovieClip();            
        }
        this.tileStage.clear();
    }
    
    /**
     * Removes all tiles accept the tiles with zoomLevel
     * @param	zoomLevel the zoomlevel that must stay
     */
    public function removeAllButZoomLevel(zoomLevel:Number){
        //_global.flamingo.tracer("layer = " + this + " removeAllButZoomLevel");
        var newLoadedTileExtent:Object = new Object();
        log.debug("Remove all but zoomLevel: "+ zoomLevel);
        var newTileArray:Array=new Array();
        for (var m in this.mcTiles){
            log.debug("tile = " + m + " tile.zoomLevel = "+ mcTiles[m].zoomLevel + " zoomLevel = "+ zoomLevel);
            if (mcTiles[m].zoomLevel != zoomLevel){
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
     * Function that correct the extents of the loaded tiles
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
    /*
     * This function loads the image and creates the movieclips
     */
    private function loadTiles(){   
        var tile:Tile=Tile(this.newTiles.pop());    
                        
        var mcTile= this.tileStage.createEmptyMovieClip(tile.getTileId()+"("+this.currentZoomLevel+")",this.tileDepth++);
        
        mcTile.tile=tile;
        mcTile.zoomLevel=this.currentZoomLevel;
        mcTile.finishedLoading=false;
        var holder=mcTile.createEmptyMovieClip("holder" ,0);
        if(grayscale){
             applyGrayscale(mcTile);
        }
        mcTiles.push(mcTile);
        //_global.flamingo.tracer("tile.getImageUrl() = " + tile.getImageUrl());
        var url:String = tile.getImageUrl();
        if (url.indexOf("?")!=url.length-1 && url.indexOf("&")!=url.length-1){
            url+=url.indexOf("?")>=0 ? "&" : "?";
        }
        var idStr:String = null;
        if (this.tilingType == WMSC_TILINGTYPE) { 
            idStr = tile.getBbox().getMinX() + "," + tile.getBbox().getMinY() + "," + tile.getBbox().getMaxX() + "," + tile.getBbox().getMaxY();
        } else {
            idStr = tile.getZoomLevel() + "/" + tile.getXIndex() + "/" + tile.getYIndex();
        }
        //url += "REQUESTID=" + roo.tools.RequestIdGenerator.getRequestId(idStr);
        this.tileLoader.loadClip(url,holder); 
        //_global.flamingo.tracer("load tile = " + tile.getTileId() );               
    }
	/**
	 * 
	 */
	public function getLastRequests() {
		var request:Array = new Array();
		for (var m in this.mcTiles) {
			var tile:Tile= Tile(mcTiles[m].tile);
			var req:Object = new Object();
			req.url = tile.getImageUrl();
			req.extent = tile.getBbox().toObject();
			request.push(req);
		}
		return request;
	}
    /*
     * Stops the loading of the tiles.
     */
    private function stopLoading(){
        log.debug("StopLoading");
        //clear the current interval:
        //clearInterval(this.intervalId);
        _global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
        //reconstruct the MovieClipLoader, forces to stop loading the clips
        //this.tileLoader=new MovieClipLoader();      
        //this.tileLoader.addListener(this.tileListener);
    }
    
    /**
	 * called when a tile is completly loaded
	 * @param tileMc the tile
	 * @param error if a error occured
	 */
    public function finishedLoadingTile(tileMc:MovieClip,error:String){     
        var tile=Tile(tileMc._parent.tile);
        tile=tileFactory.setTileScreenLocation(tile,map.getCurrentExtent());
        tileMc._x=tile.getScreenX();
        tileMc._y=tile.getScreenY();
        tileMc._width=tile.getScreenWidth();
        tileMc._height=tile.getScreenHeight();
        this.tilesToProcess--;
        /* Don't show this error to the end-user
        if (error!=undefined){
            log.error("Error loading tile: "+error);
        }
        */
        //if there are no tiles to process, clear al the old tiles.
        //_global.flamingo.tracer("layer = " + this._name + " finishedLoadingTile: " + tile.getTileId() + " tilesToProcess = " + this.tilesToProcess);
        if (this.tilesToProcess==0){
            clearProgressMonitor ();            
            removeAllButZoomLevel(this.currentZoomLevel);
            _global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
        }           
    }
    
    /*
     * This function is added because not all tiles doe fire a onLoadInit and onLoadComplete event
     */
    private function checkLoadProgress():Void {
        var allLoaded:Boolean = true;
        for (var m in this.mcTiles) {
            var progress:Object = this.tileLoader.getProgress(mcTiles[m].holder);
            //_global.flamingo.tracer("layer = " + this._name + " tile = " + mcTiles[m].tile.getTileId() + "bytesLoaded: " + progress.bytesLoaded + " bytesTotal: " + progress.bytesTotal);
            if (progress.bytesLoaded == 0 || progress.bytesLoaded < progress.bytesTotal ) {
                allLoaded = false;
            } else if (!mcTiles[m].finishedLoading) {
                var tile:Tile= Tile(mcTiles[m].tile);
                //_global.flamingo.tracer("layer = " + this._name + " mcTiles[m] = " + mcTiles[m] + " tile = " + tile.getTileId() + " finished by checkLoadProgress()");
                var holder:MovieClip = Tile(mcTiles[m].holder);
                holder._x = tile.getScreenX();
                holder._y = tile.getScreenY();
                holder._width  = tile.getScreenWidth();
               
                holder._height = tile.getScreenHeight();              
                mcTiles[m].finishedLoading=true;
            }
        }
        var currentTime = new Date();
        //use a timeout to remove a pending progress bar (is a hack)
        if (allLoaded || (currentTime.getTime() - this.loadStartTime.getTime()) > 30000) {
            //if ((currentTime - this.loadStartTime) > 30000) {
            //    _global.flamingo.tracer("layer = " + this._name + "currentTime - this.loadStartTime = " + (currentTime - this.loadStartTime) );
            //}
            clearProgressMonitor ();            
            _global.flamingo.raiseEvent(this, "onUpdateComplete", this, 0, 0, 0);
            removeAllButZoomLevel(this.currentZoomLevel);
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
	/*Copy the extent*/
	private function copyExtent(obj:Object):Object {
		var extent = new Object();
		for (var attr in obj) {
			extent[attr] = obj[attr];
		}
		extent.minx = Number(extent.minx);
		extent.miny = Number(extent.miny);
		extent.maxx = Number(extent.maxx);
		extent.maxy = Number(extent.maxy);
		return extent;
	}
	
}