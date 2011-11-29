/**
 * ...
 * @author Roy Braam
 */
import core.AbstractPositionable;
import tools.Logger;

class gui.button.AbstractButton extends AbstractPositionable{
	//the movieclip that holds the visible part.
	private var _holder:MovieClip;
	
	//Is the button available to use?
	private var _enabled:Boolean;
	
	//is the button pressed
	private var _pressed:Boolean;
	//the id of the tooltip (default: 'tooltip');
	private var _tooltipId:String;
	
	//the movieclip loader
	private var _mcloader:MovieClipLoader;
	
	//the movieclips that are shown.
	private var _mcUp:MovieClip;
	private var _mcOver:MovieClip;
	private var _mcDown:MovieClip;	
	//the links to the images.
	private var _toolDownLink:String;
	private var _toolUpLink:String;
	private var _toolOverLink:String;
	
	/**
	 * Constructor for abstractButton. Creates a button and loads the images for the button stages.
	 * @param	id the id of the button
	 * @param	container the movieclip that holds this button
	 */
	public function AbstractButton(id:String, container:MovieClip) {					
		super(id, container);
		//make the holder for the movieclip
		this.holder = this.container.createEmptyMovieClip("tool_" + id + "_holder", this.container.getNextHighestDepth());
		
		//set init vars
		this.enabled = true;		
		this.tooltipId = "tooltip";				
		
		//load the button images.
		this.mcDown = this.holder.createEmptyMovieClip("tool_" + id+"_down", this.holder.getNextHighestDepth());
		this.mcOver = this.holder.createEmptyMovieClip("tool" + id + "_over", this.holder.getNextHighestDepth());
		this.mcUp = this.holder.createEmptyMovieClip("tool" + id+"_up", this.holder.getNextHighestDepth());
								
		this.mcloader = new MovieClipLoader();			
				
		this.mcDown._visible = false;
		this.mcOver._visible = false;
		this.mcUp._visible = true;		
		
		this.setEvents();	
	}
	/**
	 * Set the events of this button.
	 */
	public function setEvents():Void {		
		var thisObj:AbstractButton = this;
		this.holder.onRollOver = function() {	
			Logger.console("onRollOver");
			if (thisObj.isClickable()){
				//var id = thisObj.flamingo.getId(thisObj);
				thisObj.flamingo.showTooltip(thisObj.flamingo.getString(thisObj, thisObj.tooltipId), thisObj);
				thisObj.mcOver._visible = true;
				thisObj.mcUp._visible = false;	
				thisObj.onRollOver();
			}
		}
		this.holder.onRollOut = function() {
			Logger.console("onRollOut");			
			if (thisObj.isClickable()) {
				thisObj.mcOver._visible = false;				
				thisObj.mcDown._visible = false;
				thisObj.mcUp._visible = true;
				thisObj.onRollOut();
			}
		}
		this.holder.onPress = function() {
			Logger.console("onPress");
			if (thisObj.isClickable()) {				
				thisObj.pressed = true;
				thisObj.mcOver._visible = false;
				thisObj.mcUp._visible = false;
				thisObj.mcDown._visible = true;
				thisObj.onPress();		
			}
		}
		this.holder.onRelease = function() {
			Logger.console("onRelease");			
			if (thisObj.isClickable()) {	
				thisObj.pressed = false;
				thisObj.mcDown._visible = false;
				thisObj.mcUp._visible = false;
				thisObj.mcOver._visible = true;
				thisObj.onRelease();
			}
		}
		this.holder.onReleaseOutside = function() {
			Logger.console("onReleaseOutside");
			if (thisObj.isClickable()) {
				thisObj.pressed = false;
				thisObj.onReleaseOutside();
			}
		};
		
		this.holder.onDragOver = function() {
			Logger.console("onDragOver");
			if (thisObj.isClickable()) {
				if (thisObj.pressed) {				
					thisObj.mcOver._visible = false;	
					thisObj.mcUp._visible = false;			
					thisObj.mcDown._visible = true;	
					thisObj.onDragOver();
				}
			}
		};
		
		this.holder.onDragOut = function() {
			Logger.console("onDragOver");
			if (thisObj.isClickable()) {						
				thisObj.mcOver._visible = false;		
				thisObj.mcDown._visible = false;		
				thisObj.mcUp._visible = true;	
				
			}
		};
	}
	/**
	 * Enable/disable (grayout) the tool
	 * @param	b true(enable) or false(disable
	 */
	public function setEnabled(b:Boolean):Void{
		if (b) {
			this.container._alpha = 100;
		} else {
			this.mcOver._visible = false;			
			this.mcDown._visible = false;			
			this.mcUp._visible = true;
			this.container._alpha = 20;
		}
		this._enabled = b;
	}	
	/**
	 * Returns true if this button is clickable
	 */
	public function isClickable():Boolean {
		return this.enabled;
	}
	/*****************************************************
	 * Old functions that need to be supported.
	 */
	public function click() {
		this.onPress();
	}
	/*******************************************************
	 * Functions that can be used to handle events on the button.
	 */
	
	/**
	 * Implement this function to handle the press of the button.
	 */
	public function onRelease() { }
	public function onPress() { }
	public function onRollOut() { }
	public function onRollOver() { }
	public function onReleaseOutside() { }
	public function onDragOver() { }
	public function onDragOut() { }
	
	public function setConfig(xml:Object) {
		Logger.console("!!!Function setConfig() needs to be overwritten in: "+this.id);
	}
	/*******************************************************
	 * Getters and Setters
	 */ 
	public function get holder():MovieClip 
	{
		return _holder;
	}
	
	public function set holder(value:MovieClip):Void 
	{
		_holder = value;
	}
	
	public function get enabled():Boolean{
		return _enabled;
	}
	
	public function set enabled(value:Boolean) {
		this._enabled = value;
	}
	
	public function get toolDownLink():String{
		return _toolDownLink;
	}
	
	public function set toolDownLink(value:String):Void {
		_toolDownLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolDownLink), this.mcDown.createEmptyMovieClip("container",0));		
	}
	
	public function get toolUpLink():String 
	{
		return _toolUpLink;
	}
	
	public function set toolUpLink(value:String):Void{
		_toolUpLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolUpLink), this.mcUp.createEmptyMovieClip("container",0));		
	}
	
	public function get toolOverLink():String 
	{
		return _toolOverLink;
	}
	
	public function set toolOverLink(value:String):Void {
		_toolOverLink = value;
		this.mcloader.loadClip(_global.flamingo.correctUrl(this.toolOverLink), this.mcOver.createEmptyMovieClip("container",0));		
	}
	
	public function get tooltipId():String 
	{
		return _tooltipId;
	}
	
	public function set tooltipId(value:String):Void 
	{
		_tooltipId = value;
	}
	
	public function get mcUp():MovieClip 
	{
		return _mcUp;
	}
	
	public function set mcUp(value:MovieClip):Void 
	{
		_mcUp = value;
	}
	
	public function get mcOver():MovieClip 
	{
		return _mcOver;
	}
	
	public function set mcOver(value:MovieClip):Void 
	{
		_mcOver = value;
	}
	
	public function get mcDown():MovieClip 
	{
		return _mcDown;
	}
	
	public function set mcDown(value:MovieClip):Void 
	{
		_mcDown = value;
	}
	
	public function get mcloader():MovieClipLoader {
		return _mcloader;
	}
	
	public function set mcloader(value:MovieClipLoader):Void {
		_mcloader = value;
	}
	
	public function get pressed():Boolean {
		return _pressed;
	}
	
	public function set pressed(value:Boolean):Void {
		_pressed = value;
	}
	
	
	
}