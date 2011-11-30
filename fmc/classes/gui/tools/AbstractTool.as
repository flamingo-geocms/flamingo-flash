/**
 * ...
 * @author Roy Braam
 */
import core.AbstractPositionable;
import gui.tools.ToolGroup;
import tools.Logger;
import gui.button.AbstractButton;

class gui.tools.AbstractTool extends AbstractButton
{
	private var _holder:MovieClip;
	private var _toolGroup:ToolGroup;
	
	//Is the tool active (used at the moment)
	private var _active:Boolean;
	
	//the map listener. If this tool is active this object will listen to the actions done by the user.
	private var _lMap:Object;
	
	//scroll properties:
	private var _zoomscroll:Boolean;
	
	public function AbstractTool(id, toolGroup:ToolGroup, container) {			
		super(id, container);
		this.toolGroup = toolGroup;
		this.parent = toolGroup;
		//init vars
		this.lMap = new Object();		
		this.active = false;
		this.zoomscroll = true;
		
		var thisObj:AbstractTool = this;
		//add mousewheel event to tool:
		this.lMap.onMouseWheel = function(map:MovieClip, delta:Number, xmouse:Number, ymouse:Number, coord:Object) {
			if (thisObj.zoomscroll) {
				if (!thisObj._parent.updating) {
					thisObj._parent.cancelAll();
					var zoom;
					if (delta<=0) {
						zoom = 80;
					} else {
						zoom = 120;
					}
					var w = map.getWidth();
					var h = map.getHeight();
					var c = map.getCenter();
					var cx = (w/2)-((w/2)/(zoom/100));
					var cy = (h/2)-((h/2)/(zoom/100));
					var px = (coord.x-c.x)/(w/2);
					var py = (coord.y-c.y)/(h/2);
					coord.x = c.x+(px*cx);
					coord.y = c.y+(py*cy);
					map.moveToPercentage(zoom, coord, 500, 0);
					thisObj._parent.updateOther(map, 500);
				}
			}
		};
			
	}	
	
	/***********************************************************
	 * Special getters / setters.... TODO: Still needed or implement in the other setters and getters?
	 */
	/**
	 * Returns the real parent
	 * @return the real parent In this case its always the borderNavigation
	 */
	public function getParent():Object {
		return this.toolGroup;
	}	 
	 
	/**
	 * Get the listento. Default its the listento of the toolgroup
	 */
	public function get listento():Array 
	{
		return this.toolGroup.listento;
	}
	/**
	 * Enable/disable (grayout) the tool
	 * @param	b true(enable) or false(disable
	 */
	public function setEnabled(b:Boolean):Void{
		if (!b && this._active) {
			this.toolGroup.setCursor(undefined);				
			this.setActive(false);
		}
		super.setEnabled(b);
	}
	/**
	 * Active/deactivate the tool
	 * @param	active true (Active) or false(deactivate)
	 */ 
	public function setActive(active:Boolean):Void {
		//turn off
		if (this.active && !active) {
			flamingo.removeListener(this.lMap, this.listento, this.toolGroup);		
			this.toolGroup.setCursor(undefined);
			this.mcDown._visible = false;
			this.mcOver._visible = false;
			this.mcUp._visible = true;
			//TODO: Set correct cursor this.setCursor(mc.cursors[cursorid]);
		}//turn on
		else if (!this.active && active) {
			flamingo.addListener(this.lMap, this.listento, this.toolGroup);
			this.toolGroup.setCursor(this.cursors[this.cursorId]);
			this.mcUp._visible = false;
			this.mcOver._visible = false;
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
	/**
	 * Returns true if this button is clickable
	 */
	public function isClickable():Boolean {
		return super.isClickable() && !this.active;
	}
	
	/**
	 * Handles the press of the button.
	 */
	public function onRelease() { 
		this.toolGroup.setTool(this.id);
	}
	/***********************************************************
	 * Getters and Setters.
	 */ 
	public function get active():Boolean {
		return this._active;
	}
	public function set active(value:Boolean) {
		this._active = value;
	}
	
	public function get toolGroup():ToolGroup {
		return _toolGroup;
	}
	
	public function set toolGroup(value:ToolGroup):Void {
		_toolGroup = value;
	}
	
	public function get enabled():Boolean {
		return _enabled;
	}
	
	public function set enabled(value:Boolean) {
		this._enabled = value;
	}
	
	public function get lMap():Object {
		return _lMap;
	}
	
	public function set lMap(value:Object):Void {
		_lMap = value;
	}
	
	public function get zoomscroll():Boolean {
		return _zoomscroll;
	}
	
	public function set zoomscroll(value:Boolean):Void {
		_zoomscroll = value;
	}
	
}