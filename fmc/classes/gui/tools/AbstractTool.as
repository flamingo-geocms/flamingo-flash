/**
 * ...
 * @author Roy Braam
 */
import core.AbstractPositionable;
import gui.tools.ToolGroup;
import tools.Logger;
class gui.tools.AbstractTool extends AbstractPositionable
{
	private var holder:MovieClip;
	private var _toolGroup:ToolGroup;
	
	//Is the tool active (used at the moment)
	private var _active:Boolean = false;
	//Is the tool available to use?
	private var _enabled:Boolean = true;
	
	private var mcUp:MovieClip;
	private var mcOver:MovieClip;
	private var mcDown:MovieClip;	
	
	private var _toolDownLink:String = null;
	private var _toolUpLink:String = null;
	private var _toolOverLink:String = null;
	
	private var _tooltipId:String = null;
	
	private var _lMap:Object = new Object();
	
	public function AbstractTool(id, toolGroup:ToolGroup, container) {			
		super(id, container);
		Logger.console("AbstractTool Construct");
		this.toolGroup = toolGroup;
		
		this.holder = this.container.createEmptyMovieClip("tool_" + id + "_holder", this.container.getNextHighestDepth());
		
		this.mcDown = this.holder.createEmptyMovieClip("tool_" + id+"_down", this.holder.getNextHighestDepth());
		this.mcOver = this.holder.createEmptyMovieClip("tool" + id + "_over", this.holder.getNextHighestDepth());
		this.mcUp = this.holder.createEmptyMovieClip("tool" + id+"_up", this.holder.getNextHighestDepth());
								
		var mcloader = new MovieClipLoader();	
		mcloader.loadClip(_global.flamingo.correctUrl(this.toolDownLink), this.mcDown.createEmptyMovieClip("container",0));
		mcloader.loadClip(_global.flamingo.correctUrl(this.toolOverLink), this.mcOver.createEmptyMovieClip("container",0));
		mcloader.loadClip(_global.flamingo.correctUrl(this.toolUpLink), this.mcUp.createEmptyMovieClip("container",0));
				
		this.mcDown._visible = false;
		this.mcOver._visible = false;
		this.mcUp._visible = true;
		
		
		this.setPosition();
		this.setEvents();		
	}
		
	public function setEvents():Void {		
		var thisObj:AbstractTool = this;
		this.holder.onRollOver = function() {
			Logger.console("onRollOver " + thisObj.active);			
			var id = thisObj.flamingo.getId(thisObj);
			thisObj.flamingo.showTooltip(thisObj.flamingo.getString(thisObj, thisObj.tooltipId), thisObj);
			if (!thisObj.active) {
				thisObj.mcOver._visible = true;
				thisObj.mcUp._visible = false;				
			}
		}
		this.holder.onRollOut = function() {
			Logger.console("onRollOut "+thisObj.active);			
			if (!thisObj.active) {
				thisObj.mcOver._visible = false;
				thisObj.mcUp._visible = true;				
			}
		}
		this.holder.onRelease = function() {
			Logger.console("onRelease "+thisObj.active);
			if (!thisObj.active) {
				thisObj.setActive(true);
				thisObj.mcOver._visible = false;
			}else {
				thisObj.setActive(false);				
			}
		}
	}
	public function setPosition():Void {
		this.container._x = 30;
	}
	
	//getters and setters.
	public function getMcUp():MovieClip {
		return this.mcUp;
	}
	public function setMcUp(mcUp:MovieClip):Void {
		this.mcUp = mcUp;
	}
	public function getMcOver():MovieClip {
		return this.mcOver;
	}
	public function setMcOver(mcOver:MovieClip):Void {
		this.mcOver = mcOver;
	}
	public function getMcDown():MovieClip {
		return this.mcDown;
	}
	public function setMcDown(mcDown:MovieClip) {
		this.mcDown = mcDown;
	}	
	
	public function getId():String {
		return this.id;
	}
	
	public function getHolder():MovieClip {
		return this.holder;
	}	
	
	public function setActive(active:Boolean):Void {
		//turn off
		if (this.active && !active) {
			Logger.console("Turn off button: "+this.id);
			flamingo.removeListener(this.lMap, this.listento, this.toolGroup);			
			this.mcDown._visible = false;
			//TODO: Set correct cursor this.setCursor(mc.cursors[cursorid]);
		}//turn on
		else if (!this.active && active) {
			Logger.console("Turn on button: " + this.id);			
			flamingo.addListener(this.lMap, this.listento, this.toolGroup);			
			this.mcDown._visible = true;		
			//TODO: Set correct cursor this.setCursor(mc.cursors[cursorid]);
			//see toolgroup initTool
		}
		this._active = active;		
		
		/*
		 * mc._releaseTool = function() {
			if (mc._enabled) {
				mc._pressed = false;
				mc.attachMovie(uplink, "mSkin", 1);
				thisObj.flamingo.removeListener(maplistener, thisObj.listento, this);
				mc.releaseTool();
			}
		};
		 */
	}
	public function get active():Boolean {
		return this._active;
	}
	
	public function get toolGroup():ToolGroup 
	{
		return _toolGroup;
	}
	
	public function set toolGroup(value:ToolGroup):Void 
	{
		_toolGroup = value;
	}
	
	public function get enabled():Boolean{
		return _enabled;
	}
	
	public function get lMap():Object 
	{
		return _lMap;
	}
	
	public function set lMap(value:Object):Void 
	{
		_lMap = value;
	}
	/**
	 * Get the listento. Default its the listento of the toolgroup
	 */
	public function get listento():String 
	{
		return this.toolGroup.listento;
	}
	
	public function get toolDownLink():String 
	{
		return _toolDownLink;
	}
	
	public function set toolDownLink(value:String):Void 
	{
		_toolDownLink = value;
	}
	
	public function get toolUpLink():String 
	{
		return _toolUpLink;
	}
	
	public function set toolUpLink(value:String):Void 
	{
		_toolUpLink = value;
	}
	
	public function get toolOverLink():String 
	{
		return _toolOverLink;
	}
	
	public function set toolOverLink(value:String):Void 
	{
		_toolOverLink = value;
	}
	
	public function get tooltipId():String 
	{
		return _tooltipId;
	}
	
	public function set tooltipId(value:String):Void 
	{
		_tooltipId = value;
	}
	
	public function setEnabled(b:Boolean):Void{
		if (b) {
			this.container._alpha = 100;
		} else {
			this.container._alpha = 20;
			if (this.active) {
				this.toolGroup.setCursor(undefined);				
				this.setActive(false);
			}
		}
		this._enabled = b;
	}
}