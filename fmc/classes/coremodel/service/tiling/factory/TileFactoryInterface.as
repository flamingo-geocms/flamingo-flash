import coremodel.service.tiling.Tile;
import geometrymodel.Envelope;
interface coremodel.service.tiling.factory.TileFactoryInterface{    
        
    public function setResolutions(r:Array):Void;
    public function getResolutions():Array;
    
    public function setTileWidth(w:Number):Void;
    public function getTileWidth():Number;
    public function setTileHeight(h:Number):Void;
    public function getTileHeight():Number;
    public function setTileExtension(ext:String):Void;
    public function getTileExtension():String;
    
    public function getTileIndexX(xCoord:Number,mapRes:Number):Number;
    public function getTileIndexY(yCoord:Number,mapRes:Number):Number;
    
    public function getZoomLevel(res:Number, maxresfactor:Number, intervalfactor:Number):Number;
    
    public function setExtraParams(extraParams:Object):Void;
    public function getExtraParams():Object;
    
    public function createTile(xIndex:Number, yIndex:Number, zoomLevel:Number):Tile;
    
    public function setTileScreenLocation(tile:Tile,mapExtent:Object):Tile;
}