// This file is part of Flamingo MapComponents.
// Author: Roy Braam
import tools.Logger;
import gui.Map;
/**
 * A abstarct marker class. Implement bij all markers
 */
class gui.marker.AbstractMarker extends MovieClip {
	//logging:
	private var log:Logger=null;
	private var mcPrefix="marker";
	
	private var map:Map=null;
	private var x:Number=null;
	private var y:Number=null;
	private var markerUrl:String=null;
	private var id:String=null;
	private var visible=true;
	private var offsetX:Number=0;
	private var offsetY:Number=0;	
	private var height:Number;
	private var width:Number;
	
	private var mapListener:Object=null;
	
	private var mcMarker:MovieClip=null;
	/**
	 * Constructor
	 */
	function AbstractMarker(){
		super();
		this.log = new Logger("gui.marker.AbstractMarker",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());		
		this.onUnload = function(){
			this.destroy();
		}
	}
	/*
	//example
	function onPress():Void{
		_global.flamingo.tracer("Marker.as onPress() pressed");
	}
	*/
	/**
	 * Draw the marker on the map
	 */
	function draw():Void {
		if (this.mcMarker==null){					
			createMarker();
			if (!this.visible){
				this.mcMarker._visible=this.visible;
			}
		}		
		redraw();
		/*var p:Object = new Object();
		var msx = (extent.maxx-extent.minx)/__width;
		var msy = (extent.maxy-extent.miny)/__height;
		this._x = (this.x-extent.minx)/msx;
		this._y = (extent.maxy-this.y)/msy;*/		
	}
	/**
	 * Redraw the marker on the map (reposition)
	*/
	function redraw():Void{
		var p:Object = this.map.coordinate2Point({x:this.x,y:this.y});
		this.mcMarker._x=p.x+this.offsetX;
		this.mcMarker._y=p.y+this.offsetY;
	}
	/**
	 * Create the movieclip that contains the marker
	*/
	public function createMarker(){
		var depth:Number = this.map.getNextDepth()
		this.mcMarker = this.map.container.createEmptyMovieClip(this.mcPrefix+this.id, depth);
		//set init values
		if (this.height){
			this.mcMarker._height=this.height;
		}
		if (this.width){
			this.mcMarker._width=this.width;
		}
		//load icon from markerUrl		
		if (this.getMarkerUrl()!=null){			
			var mcloader=new MovieClipLoader();		;
			mcloader.loadClip(_global.flamingo.correctUrl(this.getMarkerUrl()),this.mcMarker);				
		}
	}
	
	//getters & setters
	/**
	 * setId
	 * @param	id
	 */
	public function setId(id:String){
		this.id=id;
	}
	/**
	 * getId
	 * @return
	 */
	public function getId():String{
		return this.id;
	}
	/**
	 * Set the map. Also sets a listener for onChangeExtent
	 * @param	map
	 */
	public function setMap(map:Map) {
		this.map=map;
		//addListener for redrawing
		var thisObj=this;
		if (this.mapListener!=null){
			_global.flamingo.removeListener(this.mapListener,this.map, this);
		}
		this.mapListener = new Object();
		this.mapListener.onChangeExtent = function(m:MovieClip) {
			thisObj.draw();
		};
		_global.flamingo.addListener(this.mapListener,this.map, this);
		
	}	
	/**
	 * getMap
	 * @return
	 */
	public function getMap():Map{
		return this.map;
	}
	/**
	 * setX
	 * @param	x
	 */	
	public function setX(x:Number):Void{
		this.x=x;
	}
	/**
	 * getX
	 * @return
	 */
	public function getX():Number{
		return this.x;
	}
	/**
	 * setY
	 * @param	y
	 */
	public function setY(y:Number):Void{
		this.y=y;
	}
	/**
	 * getY
	 * @return
	 */
	public function getY():Number{
		return this.y;
	}
	/**
	 * setVisible
	 * @param	visible
	 */
	public function setVisible(visible:Boolean){
		this.visible=visible;
		if (this.mcMarker!=null){
			this.mcMarker._visible=visible;
		}
	}
	/**
	 * getVisible
	 */
	public function getVisible(){		
		if (this.mcMarker!=null){
			return this.mcMarker._visible;
		}else{
			return this.visible;
		}
	}
	/**
	 * setHeight
	 * @param	height
	 */
	public function setHeight(height:Number){
		this.height=height;
		if (this.mcMarker!=null){
			this.mcMarker._height=height;
		}
	}
	/**
	 * getHeight
	 * @return
	 */
	public function getHeight():Number{
		if (this.mcMarker!=null){
			return this.mcMarker._height;
		}else{
			return this.height;
		}
	}
	/**
	 * setWidth
	 * @param	width
	 */
	public function setWidth(width:Number){
		this.width=width;
		if(this.mcMarker!=null){
			this.mcMarker._width=width;
		}
	}
	/**
	 * getWidth
	 * @return
	 */
	public function getWidth():Number{
		if (this.mcMarker!=null){
			return this.mcMarker._width;
		}else{
			return this.width;
		}
	}
	/**
	 * getMarkerUrl
	 * @return
	 */
	public function getMarkerUrl():String{
		return this.markerUrl;
	}
	/**
	 * setMarkerUrl
	 * @param	markerUrl
	 */
	public function setMarkerUrl(markerUrl:String){
		this.markerUrl=markerUrl;
	}
	/**
	 * removeMovieClip
	 */
	public function removeMovieClip(){
		this.destroy();
		super.removeMovieChild();
	}
	/**
	 * Destroy this marker and the listeners
	*/
	public function destroy(){
		_global.flamingo.removeListener(this.mapListener,this.map, this);
		if (this.mcMarker!=null){
			this.mcMarker.removeMovieClip();
		}		
	}
}