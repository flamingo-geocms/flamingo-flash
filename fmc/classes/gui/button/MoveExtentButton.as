/**
 * ...
 * @author Roy Braam
 */
import gui.BorderNavigation;
import gui.button.AbstractButton;

class gui.button.MoveExtentButton extends AbstractButton {
	private var _moveId:Number;
	
	private var _xDirection:Number;
	private var _yDirection:Number;
	private var _borderNavigation:BorderNavigation;
	
	public function MoveExtentButton(id:String, container:MovieClip, borderNavigation:BorderNavigation) {
		super(id, container);		
		this.borderNavigation = borderNavigation;
	}
	
	public function setDirectionMatrix(x, y) {
		this.xDirection = x;
		this.yDirection = y;
	}
	
	public function onPress() {
		this.startMove();
	}
	public function onRelease() {
		this.stopMove();
	}
	public function onReleaseOutside() {
		this.stopMove();		
	}
	
	public function startMove() {		
		var dx = 0;
		var dy = 0;
		var e = map.getCurrentExtent();
		var msx = (e.maxx-e.minx)/map.__width;
		var msy = (e.maxy - e.miny) / map.__height;
		dy = this.yDirection * map.__height / 40 * msy;
		dx = this.xDirection * map.__width / 40 * msx;
		
		var obj:Object = new Object();
		obj.map = map;
		obj.dx = dx;
		obj.dy = dy;
		_moveId = setInterval(this, "_move", 10, obj);
		
	}
	public function stopMove() {
		clearInterval(_moveId);
		this.borderNavigation.updateMaps();
	}
	
	function _move(obj:Object) {
		var e = obj.map.getCurrentExtent();
		e.minx = e.minx+obj.dx;
		e.miny = e.miny+obj.dy;
		e.maxx = e.maxx+obj.dx;
		e.maxy = e.maxy+obj.dy;
		obj.map.moveToExtent(e, -1, 0);
	}
	
	/*********************************************************
	 * getters and setters
	 */ 
	public function get map():Object {
		return flamingo.getComponent(this.borderNavigation.listento[0]);
	}
	public function get xDirection():Number {
		return _xDirection;
	}
	
	public function set xDirection(value:Number):Void {
		_xDirection = value;
	}
	
	public function get yDirection():Number {
		return _yDirection;
	}
	
	public function set yDirection(value:Number):Void {
		_yDirection = value;
	}
	
	public function get borderNavigation():BorderNavigation {
		return _borderNavigation;
	}
	
	public function set borderNavigation(value:BorderNavigation):Void {
		_borderNavigation = value;
	}
}