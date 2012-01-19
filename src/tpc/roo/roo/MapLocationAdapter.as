import roo.Location;

class roo.MapLocationAdapter {

	private var location:Location = null;
    
    function MapLocationAdapter(location:Location) {
        this.location = location;
    }
    
    function onChangeExtent(map:MovieClip):Void {
        location.setXY();
    }
    
}
