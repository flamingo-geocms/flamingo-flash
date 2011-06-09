import coremodel.service.tiling.Tile;
import gui.layers.TilingLayer;
import tools.Logger;

class coremodel.service.tiling.TileListener{    
    private var tilingLayer:TilingLayer=null;
    private var log:Logger;
    function TileListener(tilingLayer:TilingLayer){
        new Logger("coremodel.service.tiling.TileListener",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
        this.tilingLayer=tilingLayer;
    }
    function onLoadInit(mc:MovieClip){
        var tile=Tile(mc._parent.tile);
        mc._x=tile.getScreenX();
        mc._y=tile.getScreenY();
        mc._width=tile.getScreenWidth();
        mc._height=tile.getScreenHeight();              
    }
    function onLoadError(mc:MovieClip, error:String, httpStatus:Number){
        log.error(error);       
        var tile=Tile(mc._parent.tile);
        mc._parent.removeMovieClip();
        tilingLayer.finishedLoadingTile(tile,error);
    }
    function onLoadComplete(mc:MovieClip){
        var tile=Tile(mc._parent.tile);
        mc._parent.finishedLoading=true;
        log.debug("layer = " + tilingLayer._name + " onLoadComplete: " + tile.getTileId() );
        tilingLayer.finishedLoadingTile(mc);
    }
}