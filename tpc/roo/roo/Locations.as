import core.AbstractComponent;
import roo.MapLocationsAdapter;
import roo.Location;

class roo.Locations extends AbstractComponent {
    
    private var map:Object = null;
    private var mapLocationsAdapter:MapLocationsAdapter = null;
    
    private var location:Location = null;
    
    function onLoad():Void {
        super.onLoad();
        
        map = _global.flamingo.getComponent(listento[0]);
        mapLocationsAdapter = new MapLocationsAdapter(this);
        _global.flamingo.addListener(mapLocationsAdapter, map, this);
        
        addMask();
    }
    
    private function addMask():Void {
        var mask:MovieClip = createEmptyMovieClip("mMask", 0);
        mask.beginFill(0x000000, 100);
        mask.moveTo(0, 0);
        mask.lineTo(__width - 1, 0);
        mask.lineTo(__width - 1, __height - 1);
        mask.lineTo(0, __height - 1);
        mask.endFill();
        setMask(mask);
    }
    
    function addLocation(x:Number, y:Number):Void {
        var initObject:Object = new Object();
        initObject["x"] = x;
        initObject["y"] = y;
        initObject["map"] = map;
        location = Location(attachMovie("Location", "mLocation", 1, initObject));
    }
    
    function removeLocation():Void {
        location.removeMovieClip();
        location = null;
    }
    
}
