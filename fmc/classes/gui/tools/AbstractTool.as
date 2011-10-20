/**
 * ...
 * @author Roy Braam
 */
import core.AbstractPositionable;
import tools.Logger;
class gui.tools.AbstractTool extends AbstractPositionable
{
	private var holder:MovieClip;
	private var intervalId;
	
	private var active:Boolean = false;
	
	private var mcUp:MovieClip;
	private var mcOver:MovieClip;
	private var mcDown:MovieClip;
	
	private var toolDownLink:String = null;
	private var toolUpLink:String = null;
	private var toolOverLink:String = null;
	
	public function AbstractTool(id, container) {
		super(id, container);
		
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
			Logger.console("onRollOver "+thisObj.active);
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
				thisObj.active = true;
				thisObj.mcOver._visible = false;
				thisObj.mcDown._visible = true;
			}else {
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
		this.active = active;
	}
	public function isActive():Boolean {
		return this.active;
	}
}