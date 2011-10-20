import core.AbstractComposite;
import tools.Logger;
/**
 * ...
 * @author Roy Braam
 */
class core.AbstractPositionable extends AbstractComposite
{
	private var _width:String;
	private var _height:String;
	private var _left:String;
	private var _top:String;
	
	private var _loaded:Boolean = true;
    private var _type:String = null;
	
	private var _id:String;
	private var _container:MovieClip;
	
	public function AbstractPositionable (id:String, container:MovieClip) {
		Logger.console("Positionable with id: " , id);
		this.id = id;
		this.container = container;
	}
	
	function parseConfig(xmlNode:XMLNode):Void {
        this.name = xmlNode.attributes["name"];
        
        // Parses the attributes from the config.
        for (var name:String in xmlNode.attributes) {
            var value:String = xmlNode.attributes[name];
			var nametoLower = name.toLowerCase();
			switch(nametoLower) {
				case "width":
				case "height":
				case "left":
				case "top":				
					this[nametoLower] = value;
					break;
				default:
					setAttribute(name, value);
			}
        }
        
        // Parses the child nodes from the config.
        var childNode:XMLNode = null;
        var name:String = null;
        for (var i:Number = 0; i < xmlNode.childNodes.length; i++) {
            childNode = xmlNode.childNodes[i];
            name = childNode.nodeName;
            if (name.indexOf(":") > -1) {
                name = name.substr(name.indexOf(":") + 1);
            }
            addComposite(name, childNode);
        }
    }
	
	public function get target():String {
		return this.container._target;
	}
	public function get _target():String {
		return this.container._target;
	}
	public function get _parent():MovieClip {
		return this.container._parent;
	}
	public function get parent():MovieClip {
		return this.container._parent;
	}
	
	/**
	 * todo implement movieclip interface en toepassen op container
	 */
	public function get width():String 
	{
		return _width;
	}
	
	public function set width(value:String):Void 
	{
		_width = value;
	}
	
	public function get height():String 
	{
		return _height;
	}
	
	public function set height(value:String):Void 
	{
		_height = value;
	}
	
	public function get left():String 
	{
		return _left;
	}
	
	public function set left(value:String):Void 
	{
		_left = value;
	}
	
	public function get top():String 
	{
		return _top;
	}
	
	public function set top(value:String):Void 
	{
		_top = value;
	}
	
	public function get id():String 
	{
		return _id;
	}
	
	public function set id(value:String):Void 
	{
		_id = value;
	}
	
	public function get container():MovieClip 
	{
		return _container;
	}
	
	public function set container(value:MovieClip):Void 
	{
		_container = value;
	}
	
	public function get loaded():Boolean 
	{
		return _loaded;
	}
	
	public function set loaded(value:Boolean):Void 
	{
		//_loaded = value;
	}
	public function get type():String 
	{
		return _type;
	}
	
	public function set type(value:String):Void 
	{
		_type = value;
	}
	
}